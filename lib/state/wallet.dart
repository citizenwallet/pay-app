import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/models/wallet.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/wallet/contracts/account_factory.dart';
import 'package:pay_app/services/wallet/models/chain.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

class WalletState with ChangeNotifier {
  final ConfigService _configService = ConfigService();
  final WalletService _walletService = WalletService();
  final SecureService _secureService = SecureService();
  final PreferencesService _preferencesService = PreferencesService();

  late Config _config;

// TODO: remove later
  final String _credentials = dotenv.env['PRIVATE_KEY']!;
  String get credentials => _credentials;

// TODO: remove later
  EthereumAddress? _address;
  EthereumAddress? get address => _address;

  String _balance = '0';
  int _decimals = 6;
  double get doubleBalance => double.tryParse(_balance) ?? 0.0;
  double get balance => doubleBalance / pow(10, _decimals);

  bool loading = false;
  bool error = false;

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

  Future<String?> createWallet() async {
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      final config = await _configService.getLocalConfig();

      if (config == null) {
        throw Exception('Community not found in local asset');
      }

      await config.initContracts();

      EthPrivateKey privateKey = EthPrivateKey.fromHex(credentials);
      final accFactory = await accountFactoryServiceFromConfig(config);
      final address = await accFactory.getAddress(privateKey.address.hexEip55);

      final token = config.getPrimaryToken();

      _address = address;
      safeNotifyListeners();

      // wallet = CWWallet(
      //   '0.0',
      //   name: 'New ${token.symbol} Account',
      //   address: address.hexEip55,
      //   alias: config.community.alias,
      //   account: address.hexEip55,
      //   currencyName: token.name,
      //   symbol: token.symbol,
      //   currencyLogo: config.community.logo,
      //   decimalDigits: token.decimals,
      // );

      await _preferencesService.setLastWallet(address.hexEip55);
      await _preferencesService.setLastAlias(config.community.alias);

      return address.hexEip55;
    } catch (_) {
      error = true;
      safeNotifyListeners();
    } finally {
      loading = false;
      safeNotifyListeners();
    }
    return null;
  }

  Future<String?> openWallet() async {
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      final config = await _configService.getLocalConfig();

      if (config == null) {
        throw Exception('Community not found in local asset');
      }

      await config.initContracts();

      EthPrivateKey privateKey = EthPrivateKey.fromHex(credentials);
      final accFactory = await accountFactoryServiceFromConfig(config);
      final address = await accFactory.getAddress(privateKey.address.hexEip55);

      final token = config.getPrimaryToken();

      final nativeCurrency = NativeCurrency(
        name: token.name,
        symbol: token.symbol,
        decimals: token.decimals,
      );

      await _walletService.init(address, privateKey, nativeCurrency, config,
          onFinished: (bool success) {
        debugPrint('wallet service init: $success');
      });

      // wallet = CWWallet(
      //   '0.0',
      //   name: '${config.community.alias} Wallet',
      //   address: address.hexEip55,
      //   alias: config.community.alias,
      //   account: address.hexEip55,
      //   currencyName: token.name,
      //   symbol: token.symbol,
      //   currencyLogo: config.community.logo,
      //   decimalDigits: nativeCurrency.decimals,
      // );

      updateBalance();

      return address.hexEip55;
    } catch (e, s) {
      error = true;
      safeNotifyListeners();
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
    } finally {
      loading = false;
      safeNotifyListeners();
    }

    return null;
  }

  Future<bool> accountExists() async {
    try {
      if (address == null) {
        throw Exception('Wallet not created');
      }

      loading = true;
      error = false;
      safeNotifyListeners();

      final exists =
          await _walletService.accountExists(account: address!.hexEip55);
      return exists;
    } catch (e, s) {
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
      error = true;
      safeNotifyListeners();
    } finally {
      loading = false;
      safeNotifyListeners();
    }
    return false;
  }

  Future<bool> createAccount() async {
    try {
      if (address == null) {
        throw Exception('Wallet not created');
      }

      loading = true;
      error = false;
      safeNotifyListeners();

      final exists = await _walletService.createAccount();

      if (!exists) {
        throw Exception('Account not created');
      }

      return true;
    } catch (e, s) {
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
      error = true;
      safeNotifyListeners();
    } finally {
      loading = false;
      safeNotifyListeners();
    }
    return false;
  }

  Future<void> updateBalance() async {
    _balance = await getBalance(_config, _address!);
    safeNotifyListeners();
  }
}
