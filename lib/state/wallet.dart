import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/utils/currency.dart';
import 'package:web3dart/web3dart.dart';

class WalletState with ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();
  final SecureService _secureService = SecureService();

  final Config _config;
  Config get config => _config;

  EthereumAddress? _address;
  EthereumAddress? get address => _address;

  // Token balances management
  Map<String, String> tokenBalances = {};

  Map<String, bool> tokenLoadingStates = {};

  bool _loadingTokenBalances = false;
  bool get loadingTokenBalances => _loadingTokenBalances;

  bool loading = false;
  bool error = false;

  bool credentialsExpired = false;

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

  WalletState(this._config, String address)
      : _address = EthereumAddress.fromHex(address) {
    init();
  }

  Future<void> init() async {
    try {
      loading = true;
      safeNotifyListeners();

      tokenBalances = _preferencesService.tokenBalances(_address!.hexEip55);
      updateBalance();
      loadTokenBalances();

      safeNotifyListeners();

      final credentials = _secureService.getCredentials();

      if (credentials == null) {
        throw Exception('Credentials not found');
      }

      final (account, key) = credentials;

      final expired = await _config.sessionManagerModuleContract.isExpired(
        account,
        key.address,
      );

      if (expired) {
        await _secureService.clearCredentials();
        loading = false;
        credentialsExpired = true;
        safeNotifyListeners();
        return;
      }

      loading = false;
      safeNotifyListeners();

      return;
    } catch (e, s) {
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
      error = true;
      safeNotifyListeners();
    }
  }

  Future<void> startBalancePolling() async {
    stopBalancePolling();

    _pollingTimer = Timer.periodic(
      Duration(seconds: 1),
      (_) {
        updateBalance();
        updateTokenBalances();
      },
    );
  }

  Future<void> stopBalancePolling() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> updateBalance() async {
    tokenBalances = _preferencesService.tokenBalances(_address!.hexEip55);
    safeNotifyListeners();

    final tokenConfig = config.getToken(
      _preferencesService.tokenAddress ?? config.getPrimaryToken().address,
    );

    final balance = await getBalance(
      _config,
      _address!,
      tokenAddress: tokenConfig.address,
    );

    final token = _config.getToken(tokenConfig.address);

    tokenBalances[tokenConfig.address] =
        formatCurrency(balance, token.decimals);
    safeNotifyListeners();

    await _preferencesService.setTokenBalances(
        _address!.hexEip55, tokenBalances);
  }

  Future<void> loadTokenBalances() async {
    if (_address == null || _config.tokens.isEmpty) {
      return;
    }

    try {
      tokenBalances = _preferencesService.tokenBalances(_address!.hexEip55);
      _loadingTokenBalances = true;
      safeNotifyListeners();

      // Initialize loading states for all tokens
      for (final tokenEntry in _config.tokens.entries) {
        tokenLoadingStates[tokenEntry.key] = true;
      }
      safeNotifyListeners();

      final balances = <String, String>{};

      for (final tokenEntry in _config.tokens.entries) {
        final tokenAddress = tokenEntry.value.address;
        try {
          final balance = await getBalance(
            _config,
            _address!,
            tokenAddress: tokenAddress,
          );

          balances[tokenAddress] =
              formatCurrency(balance, tokenEntry.value.decimals);
        } catch (e) {
          debugPrint('Error loading balance for token $tokenAddress: $e');
          balances[tokenAddress] = '0';
        } finally {
          tokenLoadingStates[tokenAddress] = false;
          safeNotifyListeners();
        }
      }

      tokenBalances = balances;
      safeNotifyListeners();

      await _preferencesService.setTokenBalances(
        _address!.hexEip55,
        tokenBalances,
      );
    } catch (e) {
      debugPrint('Error loading token balances: $e');
    } finally {
      _loadingTokenBalances = false;
      safeNotifyListeners();
    }
  }

  Future<void> updateTokenBalances() async {
    if (_address == null || _config.tokens.isEmpty) {
      return;
    }

    try {
      tokenBalances = _preferencesService.tokenBalances(_address!.hexEip55);
      safeNotifyListeners();

      final balances = <String, String>{};

      for (final tokenEntry in _config.tokens.entries) {
        final tokenKey = tokenEntry.key;
        final tokenAddress = tokenEntry.value.address;
        try {
          final balance = await getBalance(
            _config,
            _address!,
            tokenAddress: tokenAddress,
          );
          balances[tokenAddress] = formatCurrency(
            balance,
            tokenEntry.value.decimals,
          );
        } catch (e) {
          debugPrint('Error updating balance for token $tokenKey: $e');
          balances[tokenKey] = tokenBalances[tokenKey] ?? '0';
        }
      }

      tokenBalances = balances;
      await _preferencesService.setTokenBalances(
        _address!.hexEip55,
        tokenBalances,
      );
      safeNotifyListeners();
    } catch (e) {
      debugPrint('Error updating token balances: $e');
    }
  }

  String getTokenBalance(String tokenAddress) {
    return tokenBalances[tokenAddress] ?? '0';
  }

  bool isTokenLoading(String tokenAddress) {
    return tokenLoadingStates[tokenAddress] ?? false;
  }

  void setLastAccount(String account) {
    _preferencesService.setLastAccount(account);
  }

  void clear() {
    _address = null;
    tokenBalances = {};
    _preferencesService.setToken(null);
    safeNotifyListeners();
  }
}
