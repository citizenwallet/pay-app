import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/db/app/cards.dart';
import 'package:pay_app/services/db/app/contacts.dart';
import 'package:pay_app/services/db/app/db.dart';
import 'package:pay_app/services/pay/cards.dart';
import 'package:pay_app/services/pay/orders.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/sigauth/sigauth.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/utils/currency.dart';
import 'package:web3dart/web3dart.dart';

class CardState with ChangeNotifier {
  // instantiate services here
  final ContactsTable _contacts = AppDBService().contacts;
  final CardsTable _cards = AppDBService().cards;
  final PreferencesService _preferences = PreferencesService();
  final CardsService _cardsService = CardsService();
  final SecureService _secureService = SecureService();

  final Config _config;

  // private variables here

  Timer? _timer;

  // constructor here
  CardState(this._config, {required this.cardId});

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

  String balance = '0';

  DBCard? card;
  String? cardOwner;
  bool cardOwnerLoading = false;
  bool ordersLoading = false;
  List<Order> orders = [];

  bool toppingUp = false;

  // state methods here
  Future<void> fetchCardDetails(
    String? address,
    String? tokenAddress,
  ) async {
    try {
      final token =
          _config.getToken(tokenAddress ?? _config.getPrimaryToken().address);

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        return;
      }

      final (account, key) = credentials;

      final redirectDomain = dotenv.env['APP_REDIRECT_DOMAIN'];

      final sigAuthService = SigAuthService(
        credentials: key,
        address: account,
        redirect: redirectDomain != null ? 'https://$redirectDomain' : '',
      );

      final connection = sigAuthService.connect();

      cardOwnerLoading = true;
      safeNotifyListeners();

      _cardsService.getCard(connection, cardId).then((card) {
        if (card != null) {
          cardOwner = card.owner;
        }
        cardOwnerLoading = false;
        safeNotifyListeners();
      }).catchError((_) {
        cardOwnerLoading = false;
        safeNotifyListeners();
      });

      card = address != null
          ? DBCard(
              uid:
                  address, // this exists to allow me to pretend like this is a card
              project: 'main',
              account: address,
            )
          : await _cards.getByUid(cardId);

      loading = true;
      safeNotifyListeners();

      cardAddress = address != null
          ? EthereumAddress.fromHex(address)
          : await _config.cardManagerContract!.getCardAddress(
              cardId,
            );
      final balances = _preferences.tokenBalances(cardAddress!.hexEip55);
      this.balance = balances[token.address] ?? '0.0';

      safeNotifyListeners();

      if (card != null) {
        fetchOrders(
          address: cardAddress!.hexEip55,
          tokenAddress: tokenAddress,
          refresh: true,
        );
      }

      fetchProfile();

      final balance = await getBalance(
        _config,
        cardAddress!,
        tokenAddress: tokenAddress,
      );

      final formattedBalance = formatCurrency(balance, token.decimals);

      balances[token.address] = formattedBalance;
      _preferences.setTokenBalances(cardAddress!.hexEip55, balances);

      startPolling(tokenAddress);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }

  void startPolling(String? tokenAddress) {
    stopPolling();

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      updateBalance(tokenAddress);
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> fetchProfile() async {
    final contact = await _contacts.getByAccount(cardAddress!.hexEip55);
    final cachedProfile = contact?.getProfile();
    if (cachedProfile != null) {
      profile = cachedProfile;
      safeNotifyListeners();
    }

    profile = await getProfile(_config, cardAddress!.hexEip55);
    safeNotifyListeners();
  }

  Future<void> updateBalance(String? tokenAddress) async {
    if (cardAddress == null) {
      return;
    }

    final token =
        _config.getToken(tokenAddress ?? _config.getPrimaryToken().address);

    final balance = await getBalance(
      _config,
      cardAddress!,
      tokenAddress: tokenAddress,
    );

    final formattedBalance = formatCurrency(balance, token.decimals);

    final balances = _preferences.tokenBalances(cardAddress!.hexEip55);
    balances[token.address] = formattedBalance;
    _preferences.setTokenBalances(cardAddress!.hexEip55, balances);

    this.balance = formattedBalance;
    safeNotifyListeners();
  }

  int ordersLimit = 10;
  int ordersOffset = 0;
  bool hasMoreOrders = true;

  Future<void> fetchOrders(
      {String? address, String? tokenAddress, bool refresh = false}) async {
    try {
      if (address == null && cardAddress == null) {
        throw Exception('Card address not found');
      }

      ordersLoading = true;
      safeNotifyListeners();

      if (refresh) {
        ordersOffset = 0;
        hasMoreOrders = true;
      }

      final ordersService =
          OrdersService(account: address ?? cardAddress!.hexEip55);

      final (orders, total) = await ordersService.getOrders(
        limit: ordersLimit,
        offset: ordersOffset,
        tokenAddress: tokenAddress,
      );

      if (orders.length >= ordersLimit) {
        ordersOffset += ordersLimit;
      }

      if (refresh) {
        this.orders = orders;
      } else {
        _upsertOrders(orders);
      }

      hasMoreOrders = total > this.orders.length;
      safeNotifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      ordersLoading = false;
      safeNotifyListeners();
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
