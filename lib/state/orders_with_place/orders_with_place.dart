import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/checkout.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/place_menu.dart';
import 'package:pay_app/models/place_with_menu.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/db/app/db.dart';
import 'package:pay_app/services/db/app/orders.dart';
import 'package:pay_app/services/db/app/places_with_menu.dart';
import 'package:pay_app/services/engine/utils.dart';
import 'package:pay_app/services/pay/orders.dart';
import 'package:pay_app/services/pay/places.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/sigauth/sigauth.dart';
import 'package:pay_app/services/wallet/contracts/erc20.dart';
import 'package:pay_app/services/wallet/utils.dart';
import 'package:pay_app/services/wallet/wallet.dart';

class OrdersWithPlaceState with ChangeNotifier {
  // instantiate services here
  final Config _config;

  final PlacesWithMenuTable _placesWithMenuTable =
      AppDBService().placesWithMenu;
  final OrdersTable _ordersTable = AppDBService().orders;

  final SecureService _secureService = SecureService();
  final PlacesService _placesService = PlacesService();
  late OrdersService _ordersService;

  // private variables here
  bool _mounted = true;
  Timer? _pollingTimer;

  // constructor here
  OrdersWithPlaceState(
    this._config, {
    required this.slug,
    required this.myAddress,
  }) {
    _ordersService = OrdersService(account: myAddress);
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

  // Pagination variables
  int ordersLimit = 10;
  int ordersOffset = 0;
  bool loadingMore = false;
  bool hasMoreOrders = true;

  bool paying = false;
  bool payError = false;

  Order? payingOrder;

  bool loadingExternalOrder = false;
  Order? payingExternalOrder;

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
      (_) => _pollOrders(),
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

      // Reset pagination for new place
      ordersOffset = 0;
      hasMoreOrders = true;
      orders = [];

      _fetchOrders();

      final cachedPlaceWithMenu = await _placesWithMenuTable.getBySlug(slug);
      if (cachedPlaceWithMenu != null) {
        place = cachedPlaceWithMenu;
        placeMenu = PlaceMenu(menuItems: cachedPlaceWithMenu.items);
        categoryKeys =
            placeMenu!.categories.map((category) => GlobalKey()).toList();

        loading = false;
        safeNotifyListeners();

        _placesService.getPlaceAndMenu(slug).then((placeWithMenu) {
          place = placeWithMenu;

          placeMenu = PlaceMenu(menuItems: placeWithMenu.items);
          categoryKeys =
              placeMenu!.categories.map((category) => GlobalKey()).toList();

          safeNotifyListeners();

          _placesWithMenuTable.upsert(placeWithMenu);
        });

        return cachedPlaceWithMenu;
      }

      final placeWithMenu = await _placesService.getPlaceAndMenu(slug);
      place = placeWithMenu;

      placeMenu = PlaceMenu(menuItems: placeWithMenu.items);
      categoryKeys =
          placeMenu!.categories.map((category) => GlobalKey()).toList();

      safeNotifyListeners();

      _placesWithMenuTable.upsert(placeWithMenu);

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

  Future<void> _fetchOrders() async {
    try {
      debugPrint('fetchOrders, placeId: ${place?.place.id}');

      // For initial load, sync with API first to ensure we have fresh data
      if (ordersOffset == 0) {
        await _syncOrdersFromAPI();
      }

      // Then load from database
      final dbOrders = await _ordersTable.getOrdersBySlug(
        slug,
        limit: ordersLimit,
        offset: ordersOffset,
      );

      if (dbOrders.isNotEmpty) {
        _upsertOrders(dbOrders);
        ordersOffset += dbOrders.length;
        hasMoreOrders = dbOrders.length == ordersLimit;
        safeNotifyListeners();
      } else {
        hasMoreOrders = false;
        safeNotifyListeners();
      }
    } catch (e, s) {
      print('fetchOrders error: $e');
      print('fetchOrders stack trace: $s');
      error = true;
      safeNotifyListeners();
    }
  }

  Future<void> _syncOrdersFromAPI() async {
    try {
      // Get orders from API with a larger limit to ensure we have recent data
      final (orders, total) = await _ordersService.getOrders(
        slug: slug,
        limit: 50, // Get more orders to ensure we have recent data
        offset: 0,
      );

      print(orders.length);

      if (orders.isNotEmpty) {
        // Store orders in database
        await _ordersTable.upsertMany(orders);
      }
    } catch (e, s) {
      debugPrint('Error syncing orders from API: $e');
      debugPrint('Stack trace: $s');
      // Don't throw here as we want to show cached data even if sync fails
    }
  }

  Future<void> _pollOrders() async {
    try {
      debugPrint('polling orders');
      // Only sync with API to update existing orders, don't affect pagination
      await _syncOrdersFromAPI();

      // Update existing orders in the list with any changes
      if (orders.isNotEmpty) {
        final currentOrders = await _ordersTable.getOrdersBySlug(
          slug,
          limit: orders.length,
          offset: 0,
        );

        if (currentOrders.isNotEmpty) {
          _upsertOrders(currentOrders);
          safeNotifyListeners();
        }
      }
    } catch (e, s) {
      debugPrint('Error polling orders: $e');
      debugPrint('Stack trace: $s');
    }
  }

  void _upsertOrders(List<Order> newOrders) {
    final existingList = [...orders];

    for (final newOrder in newOrders) {
      final index =
          existingList.indexWhere((element) => element.id == newOrder.id);

      if (index != -1) {
        existingList[index] = newOrder;
      } else {
        existingList.add(newOrder);
      }
    }

    // Sort by creation date (newest first) to maintain proper order
    existingList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    orders = [...existingList];
  }

  Future<void> loadMoreOrders() async {
    if (loadingMore || !hasMoreOrders || place == null) return;

    debugPrint('load more orders');
    loadingMore = true;
    safeNotifyListeners();

    try {
      final dbOrders = await _ordersTable.getOrdersBySlug(
        slug,
        limit: ordersLimit,
        offset: ordersOffset,
      );

      if (dbOrders.isNotEmpty) {
        _upsertOrders(dbOrders);
        ordersOffset += dbOrders.length;
        hasMoreOrders = dbOrders.length == ordersLimit;
        safeNotifyListeners();
      } else {
        hasMoreOrders = false;
        safeNotifyListeners();
      }
    } catch (e, s) {
      debugPrint('Error loading more orders: $e');
      debugPrint('Stack trace: $s');
    } finally {
      loadingMore = false;
      safeNotifyListeners();
    }
  }

  Future<void> refreshOrders() async {
    // Reset pagination state
    ordersOffset = 0;
    hasMoreOrders = true;

    // Clear current orders
    orders = [];
    safeNotifyListeners();

    // Reload from database and sync with API
    if (place != null) {
      await _fetchOrders();
    }
  }

  Future<Order?> payOrder(Checkout checkout) async {
    try {
      if (place == null || place?.place == null) {
        return null;
      }

      paying = true;
      payError = false;
      safeNotifyListeners();

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

      checkout.message ??= message;

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
        slug: slug,
        placeId: place!.place.id,
        items: [],
        status: OrderStatus.pending,
        description: message,
        place: OrderPlace(
          slug: slug,
          display: place!.place.display,
          account: place!.place.account,
        ),
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

      final sigAuthService = SigAuthService(credentials: key, address: account);

      final sigAuthConnection = sigAuthService.connect();

      final newOrder = await _ordersService.createOrder(
        sigAuthConnection,
        place!.place.id,
        checkout,
        txHash,
      );

      if (newOrder == null) {
        throw Exception('Failed to create order');
      }

      await _ordersTable.upsert(newOrder);
      _upsertOrders([newOrder]);

      payingOrder = null;
      paying = false;
      payError = false;
      safeNotifyListeners();

      return newOrder;
    } catch (e, s) {
      print('payOrder error: $e');
      print('payOrder stack trace: $s');
      payingOrder = null;
      paying = false;
      payError = true;
      safeNotifyListeners();
      return null;
    }
  }

  Future<Order?> confirmOrder(Order order) async {
    try {
      if (place == null || place?.place == null) {
        return null;
      }

      paying = true;
      payError = false;
      safeNotifyListeners();

      final token = _config.getPrimaryToken();

      final menuItemsById = placeMenu?.menuItemsById ?? {};

      final message = order.description ??
          order.items.fold<String>('', (acc, item) {
            final menuItem = menuItemsById[item.id];
            final line = '${menuItem?.name ?? item.id} x ${item.quantity}';
            if (acc.isEmpty) {
              return line;
            }

            return '$acc\n$line';
          });

      final doubleAmount = order.total.toString().replaceAll(',', '.');
      final parsedAmount = toUnit(
        doubleAmount,
        decimals: token.decimals,
      );

      if (parsedAmount == BigInt.zero) {
        return null;
      }

      final toAddress = place!.place.account;
      final fromAddress = myAddress;

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

      final sigAuthService = SigAuthService(credentials: key, address: account);

      final sigAuthConnection = sigAuthService.connect();

      final newOrder = await _ordersService.confirmOrder(
        sigAuthConnection,
        place!.place.id,
        order.id,
        txHash,
      );

      if (newOrder == null) {
        throw Exception('Failed to create order');
      }

      paying = false;
      payError = false;
      safeNotifyListeners();

      return newOrder;
    } catch (e, s) {
      print('payOrder error: $e');
      print('payOrder stack trace: $s');
      payingOrder = null;
      paying = false;
      payError = true;
      safeNotifyListeners();
      return null;
    }
  }

  void updateAmount(double amount) {
    toSendAmount = amount;
    safeNotifyListeners();
  }

  Future<void> loadExternalOrder(String slug, String orderId) async {
    try {
      final cachedOrder = await _ordersTable.getById(int.parse(orderId));

      if (cachedOrder != null) {
        payingExternalOrder = cachedOrder;
        safeNotifyListeners();
      }

      loadingExternalOrder = cachedOrder == null;
      safeNotifyListeners();

      final order = await _ordersService.getOrder(slug, int.parse(orderId));

      payingExternalOrder = order;
      safeNotifyListeners();
    } catch (e, s) {
      print('loadExternalOrder error: $e');
      print('loadExternalOrder stack trace: $s');
    } finally {
      loadingExternalOrder = false;
      safeNotifyListeners();
    }
  }
}
