import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/checkout.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/place_menu.dart';
import 'package:pay_app/models/place_with_menu.dart';
import 'package:pay_app/services/engine/utils.dart';
import 'package:pay_app/services/pay/orders.dart';
import 'package:pay_app/services/pay/places.dart';
import 'package:pay_app/services/wallet/contracts/erc20.dart';
import 'package:pay_app/services/wallet/utils.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/utils/random.dart';

class OrdersWithPlaceState with ChangeNotifier {
  // instantiate services here
  final PlacesService _placesService = PlacesService();
  final OrdersService _ordersService;
  final WalletService _walletService = WalletService();

  // private variables here
  bool _mounted = true;
  Timer? _pollingTimer;

  // constructor here
  OrdersWithPlaceState({
    required this.slug,
    required this.myAddress,
  }) : _ordersService = OrdersService(account: myAddress);

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
  Future<void> fetchPlaceAndMenu() async {
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
    } catch (e, s) {
      print('fetchPlaceAndMenu error: $e');
      print('fetchPlaceAndMenu stack trace: $s');
      error = true;
      safeNotifyListeners();
    } finally {
      loading = false;
      safeNotifyListeners();
    }
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
        decimals: _walletService.currency.decimals,
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

      final calldata =
          _walletService.tokenTransferCallData(toAddress, parsedAmount);

      final (_, userOp) = await _walletService.prepareUserop(
        [_walletService.tokenAddress],
        [calldata],
      );

      final args = {
        'from': fromAddress,
        'to': toAddress,
      };

      if (_walletService.standard == 'erc1155') {
        args['operator'] = _walletService.account.hexEip55;
        args['id'] = '0';
        args['amount'] = parsedAmount.toString();
      } else {
        args['value'] = parsedAmount.toString();
      }

      final eventData = createEventData(
        stringSignature: _walletService.transferEventStringSignature,
        topic: _walletService.transferEventSignature,
        args: args,
      );

      print('sending message: ${message.trim()}');

      final txHash = await _walletService.submitUserop(
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
}
