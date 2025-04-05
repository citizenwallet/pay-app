import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/checkout.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/place_menu.dart';
import 'package:pay_app/models/place_with_menu.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/engine/utils.dart';
import 'package:pay_app/services/pay/orders.dart';
import 'package:pay_app/services/pay/places.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/wallet/contracts/erc20.dart';
import 'package:pay_app/services/wallet/utils.dart';
import 'package:pay_app/services/wallet/wallet.dart';

class OrdersWithPlaceState with ChangeNotifier {
  // instantiate services here
  late Config _config;

  final ConfigService _configService = ConfigService();
  final SecureService _secureService = SecureService();
  final PlacesService _placesService = PlacesService();
  late OrdersService _ordersService;

  // private variables here
  bool _mounted = true;
  Timer? _pollingTimer;

  // constructor here
  OrdersWithPlaceState({
    required this.slug,
    required this.myAddress,
  }) {
    _ordersService = OrdersService(account: myAddress);

    init();
  }

  void init() async {
    final config = await _configService.getLocalConfig();
    if (config == null) {
      throw Exception('Community not found in local asset');
    }

    await config.initContracts();

    _config = config;
  }

  void safeNotifyListeners() {
    if (_mounted) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    stopPolling();
    super.dispose();
  }

  // state variables here
  String slug;
  PlaceWithMenu? place;
  PlaceMenu? placeMenu;
  List<GlobalKey<State<StatefulWidget>>> categoryKeys = [];
  String myAddress;
  List<Order> orders = [];
  double toSendAmount = 0.0;
  int total = 0;
  bool loading = false;
  bool error = false;

  Order? payingOrder;

  // state methods here
  void startPolling({Future<void> Function()? updateBalance}) {
    // Cancel any existing timer first
    stopPolling();

    if (place == null) {
      return;
    }

    // Create new timer
    _pollingTimer = Timer.periodic(
      const Duration(milliseconds: pollingInterval),
      (_) => _fetchOrders(place!.place.id),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('stopPolling');
  }

  static const pollingInterval = 2000; // ms
  Future<PlaceWithMenu?> fetchPlaceAndMenu() async {
    try {
      loading = true;
      error = false;
      safeNotifyListeners();

      final placeWithMenu = await _placesService.getPlaceAndMenu(slug);
      place = placeWithMenu;

      placeMenu = PlaceMenu(menuItems: placeWithMenu.items);
      categoryKeys =
          placeMenu!.categories.map((category) => GlobalKey()).toList();

      safeNotifyListeners();

      _fetchOrders(placeWithMenu.place.id);
      startPolling();

      loading = false;
      safeNotifyListeners();

      return placeWithMenu;
    } catch (e, s) {
      print('fetchPlaceAndMenu error: $e');
      print('fetchPlaceAndMenu stack trace: $s');
      error = true;
      safeNotifyListeners();
    } finally {
      loading = false;
      safeNotifyListeners();
    }

    return null;
  }

  Future<void> _fetchOrders(int placeId) async {
    try {
      debugPrint('fetchOrders, placeId: ${place?.place.id}');
      final response = await _ordersService.getOrders(placeId: place?.place.id);

      orders = response.orders;
      total = response.total;
      safeNotifyListeners();
    } catch (e) {
      error = true;
      safeNotifyListeners();
    }
  }

  Future<String?> payOrder(Checkout checkout) async {
    try {
      if (place == null || place?.place == null) {
        return null;
      }

      final token = _config.getPrimaryToken();

      final total = checkout.total;

      final message = checkout.message ??
          checkout.items.fold<String>('', (acc, item) {
            final line = '${item.menuItem.name} x ${item.quantity}';
            if (acc.isEmpty) {
              return line;
            }

            return '$acc\n$line';
          });

      final doubleAmount = total.toString().replaceAll(',', '.');
      final parsedAmount = toUnit(
        doubleAmount,
        decimals: token.decimals,
      );

      if (parsedAmount == BigInt.zero) {
        return null;
      }

      final toAddress = place!.place.account;
      final fromAddress = myAddress;

      final tempId = 0;

      final order = Order(
        id: tempId,
        createdAt: DateTime.now(),
        total: total,
        due: total,
        placeId: place!.place.id,
        items: [],
        status: OrderStatus.pending,
        description: message,
      );

      payingOrder = order;
      safeNotifyListeners();

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        throw Exception('Credentials not found');
      }

      final (account, key) = credentials;

      final calldata = tokenTransferCallData(
        _config,
        account,
        toAddress,
        parsedAmount,
      );

      final (_, userOp) = await prepareUserop(
        _config,
        account,
        key,
        [_config.getPrimaryToken().address],
        [calldata],
      );

      final args = {
        'from': fromAddress,
        'to': toAddress,
      };

      if (_config.getPrimaryToken().standard == 'erc1155') {
        args['operator'] = account.hexEip55;
        args['id'] = '0';
        args['amount'] = parsedAmount.toString();
      } else {
        args['value'] = parsedAmount.toString();
      }

      final eventData = createEventData(
        stringSignature: transferEventStringSignature(_config),
        topic: transferEventSignature(_config),
        args: args,
      );

      final txHash = await submitUserop(
        _config,
        userOp,
        data: eventData,
        extraData:
            message.trim().isNotEmpty ? TransferData(message.trim()) : null,
      );

      if (txHash == null) {
        throw Exception('Failed to pay order');
      }

      return txHash;
    } catch (e, s) {
      print('payOrder error: $e');
      print('payOrder stack trace: $s');
      payingOrder = null;
      safeNotifyListeners();
      return null;
    }
  }

  void updateAmount(double amount) {
    toSendAmount = amount;
    safeNotifyListeners();
  }
}
