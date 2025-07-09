import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/db/app/cards.dart';
import 'package:pay_app/services/db/app/db.dart';
import 'package:pay_app/services/pay/orders.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

class CardState with ChangeNotifier {
  // instantiate services here
  final CardsTable _cards = AppDBService().cards;

  final Config _config;

  // private variables here

  Timer? _timer;

  // constructor here
  CardState(this._config, {required this.cardId})
      : _decimals = _config.getPrimaryToken().decimals;

  bool _mounted = true;
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
  final String cardId;

  bool loading = false;
  EthereumAddress? cardAddress;
  ProfileV1? profile;

  String _balance = '0';
  final int _decimals;
  double get doubleBalance => double.tryParse(_balance) ?? 0.0;
  double get balance => doubleBalance / pow(10, _decimals);

  DBCard? card;
  bool ordersLoading = false;
  List<Order> orders = [];

  bool toppingUp = false;

  // state methods here
  Future<void> fetchCardDetails() async {
    try {
      card = await _cards.getByUid(cardId);

      loading = true;
      safeNotifyListeners();

      cardAddress = await _config.cardManagerContract!.getCardAddress(
        cardId,
      );
      safeNotifyListeners();

      if (card != null) {
        fetchOrders(refresh: true);
      }

      profile = await getProfile(_config, cardAddress!.hexEip55);
      safeNotifyListeners();

      _balance = await getBalance(_config, cardAddress!);

      startPolling();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }

  void startPolling() {
    stopPolling();

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      updateBalance();
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> updateBalance() async {
    if (cardAddress == null) {
      return;
    }

    _balance = await getBalance(_config, cardAddress!);
    safeNotifyListeners();
  }

  int ordersLimit = 10;
  int ordersOffset = 0;
  bool hasMoreOrders = true;

  Future<void> fetchOrders({bool refresh = false}) async {
    try {
      if (cardAddress == null) {
        throw Exception('Card address not found');
      }

      ordersLoading = true;
      safeNotifyListeners();

      if (refresh) {
        ordersOffset = 0;
        hasMoreOrders = true;
      }

      final ordersService = OrdersService(account: cardAddress!.hexEip55);

      final orders = await ordersService.getOrders(
        limit: ordersLimit,
        offset: ordersOffset,
      );

      if (orders.orders.length >= ordersLimit) {
        ordersOffset += ordersLimit;
      }

      if (refresh) {
        this.orders = orders.orders;
      } else {
        _upsertOrders(orders.orders);
      }

      hasMoreOrders = orders.total > this.orders.length;
      safeNotifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      ordersLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> saveCard(String? project) async {
    try {
      if (cardAddress == null) {
        throw Exception('Card address not found');
      }

      await _cards.upsert(DBCard(
        uid: cardId,
        project: project ?? '',
        account: cardAddress!.hexEip55,
      ));

      card = await _cards.getByUid(cardId);
      safeNotifyListeners();

      fetchOrders(refresh: true);
    } catch (e) {
      //
      debugPrint(e.toString());
    }
  }

  Future<void> topUpCard() async {
    try {
      toppingUp = true;
      safeNotifyListeners();

      // await _config.cardManagerContract!.topUpCard(cardId);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      toppingUp = false;
      safeNotifyListeners();
    }
  }

  void _upsertOrders(List<Order> orders) {
    final newOrders =
        orders.where((order) => !this.orders.any((o) => o.id == order.id));

    this.orders.addAll(newOrders);
  }
}
