import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

class WalletState with ChangeNotifier {
  final ConfigService _configService = ConfigService();
  final PreferencesService _preferencesService = PreferencesService();
  final SecureService _secureService = SecureService();

  late Config _config;

  EthereumAddress? _address;
  EthereumAddress? get address => _address;

  String _balance = '0';
  int _decimals = 6;
  double get doubleBalance =>
      double.tryParse(_preferencesService.balance ?? _balance) ?? 0.0;
  double get balance => doubleBalance / pow(10, _decimals);

  bool loading = false;
  bool error = false;

  Timer? _pollingTimer;
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

  Future<bool> init() async {
    try {
      final config = await _configService.getLocalConfig();
      if (config == null) {
        throw Exception('Community not found in local asset');
      }

      await config.initContracts();

      _config = config;
      _decimals = config.getPrimaryToken().decimals;

      final credentials = _secureService.getCredentials();

      if (credentials == null) {
        throw Exception('Credentials not found');
      }

      final (account, key) = credentials;

      _address = account;

      final expired = await _config.sessionManagerModuleContract.isExpired(
        account,
        key.address,
      );

      if (expired) {
        await _secureService.clearCredentials();
        return false;
      }

      await updateBalance();

      return true;
    } catch (e, s) {
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
      error = true;
      safeNotifyListeners();
    }

    return false;
  }

  Future<void> startBalancePolling() async {
    stopBalancePolling();

    _pollingTimer = Timer.periodic(
      Duration(seconds: 1),
      (_) {
        updateBalance();
      },
    );
  }

  Future<void> stopBalancePolling() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> updateBalance() async {
    _balance = await getBalance(_config, _address!);
    await _preferencesService.setBalance(_balance);
    safeNotifyListeners();
  }
}
