import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

class CardState with ChangeNotifier {
  // instantiate services here
  final ConfigService _configService = ConfigService();

  late Config _config;

  // private variables here

  // constructor here
  CardState({required this.cardId});

  init() async {
    final config = await _configService.getLocalConfig();
    if (config == null) {
      throw Exception('Community not found in local asset');
    }

    await config.initContracts();

    _config = config;
    _decimals = config.getPrimaryToken().decimals;
  }

  bool _mounted = true;
  void safeNotifyListeners() {
    if (_mounted) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  // state variables here
  final String cardId;

  bool loading = false;
  EthereumAddress? cardAddress;
  ProfileV1? profile;

  String _balance = '0';
  int _decimals = 6;
  double get doubleBalance => double.tryParse(_balance) ?? 0.0;
  double get balance => doubleBalance / pow(10, _decimals);

  // state methods here
  Future<void> fetchCardDetails() async {
    try {
      loading = true;
      safeNotifyListeners();

      cardAddress = await _config.cardManagerContract!.getCardAddress(
        cardId,
      );
      safeNotifyListeners();

      profile = await getProfile(_config, cardAddress!.hexEip55);
      safeNotifyListeners();

      _balance = await getBalance(_config, cardAddress!);
    } catch (e) {
      print(e);
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }

  Future<void> updateBalance() async {
    if (cardAddress == null) {
      return;
    }

    _balance = await getBalance(_config, cardAddress!);
    safeNotifyListeners();
  }

  Future<bool> viewCard() async {
    if (cardAddress == null) {
      return false;
    }

    try {
      return launchUrl(
        Uri.parse(
          'https://${dotenv.env['CARD_DOMAIN']}/card/$cardId',
        ),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print(e);
      return false;
    }
  }
}
