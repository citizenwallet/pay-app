import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:web3dart/web3dart.dart';

class WalletState with ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();
  final SecureService _secureService = SecureService();

  final Config _config;
  Config get config => _config;

  EthereumAddress? _address;
  EthereumAddress? get address => _address;

  String _balance = '0';
  int _decimals = 6;
  double get doubleBalance =>
      double.tryParse(_preferencesService.balance ?? _balance) ?? 0.0;
  double get balance => doubleBalance / pow(10, _decimals);

  // Token balances management
  Map<String, String> _tokenBalances = {};
  Map<String, String> get tokenBalances => _tokenBalances;

  Map<String, bool> tokenLoadingStates = {};

  bool _loadingTokenBalances = false;
  bool get loadingTokenBalances => _loadingTokenBalances;

  String? currentToken;
  TokenConfig? currentTokenConfig;

  Color get tokenPrimaryColor => currentTokenConfig?.color != null
      ? Color(int.parse(currentTokenConfig!.color!.replaceAll('#', '0xFF')))
      : primaryColor;

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

  WalletState(this._config);

  Future<bool?> init() async {
    try {
      loading = true;
      safeNotifyListeners();

      final tokenConfig = config.getToken(
        _preferencesService.tokenKey ?? config.getPrimaryToken().key,
      );

      _decimals = tokenConfig.decimals;

      currentToken = _preferencesService.tokenKey ?? tokenConfig.key;
      currentTokenConfig = tokenConfig;

      safeNotifyListeners();

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
        loading = false;
        safeNotifyListeners();
        return false;
      }

      await updateBalance();

      loading = false;
      safeNotifyListeners();

      return true;
    } catch (e, s) {
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
      error = true;
      safeNotifyListeners();
    }

    return null;
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
    _balance = await getBalance(
      _config,
      _address!,
      tokenAddress: currentToken,
    );
    await _preferencesService.setBalance(_balance);
    safeNotifyListeners();
  }

  Future<void> loadTokenBalances() async {
    if (_address == null || _config.tokens.isEmpty) {
      return;
    }

    try {
      _loadingTokenBalances = true;
      safeNotifyListeners();

      // Initialize loading states for all tokens
      for (final tokenEntry in _config.tokens.entries) {
        tokenLoadingStates[tokenEntry.key] = true;
      }
      safeNotifyListeners();

      final balances = <String, String>{};

      for (final tokenEntry in _config.tokens.entries) {
        final tokenKey = tokenEntry.key;
        try {
          final balance = await getBalance(
            _config,
            _address!,
            tokenAddress: tokenKey,
          );

          balances[tokenKey] = balance;
        } catch (e) {
          debugPrint('Error loading balance for token $tokenKey: $e');
          balances[tokenKey] = '0';
        } finally {
          tokenLoadingStates[tokenKey] = false;
          safeNotifyListeners();
        }
      }

      _tokenBalances = balances;
      safeNotifyListeners();
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
      final balances = <String, String>{};

      for (final tokenEntry in _config.tokens.entries) {
        final tokenKey = tokenEntry.key;
        try {
          final balance = await getBalance(
            _config,
            _address!,
            tokenAddress: tokenKey,
          );
          balances[tokenKey] = balance;
        } catch (e) {
          debugPrint('Error updating balance for token $tokenKey: $e');
          balances[tokenKey] = _tokenBalances[tokenKey] ?? '0';
        }
      }

      _tokenBalances = balances;
      safeNotifyListeners();
    } catch (e) {
      debugPrint('Error updating token balances: $e');
    }
  }

  String getTokenBalance(String tokenKey) {
    return _tokenBalances[tokenKey] ?? '0';
  }

  bool isTokenLoading(String tokenKey) {
    return tokenLoadingStates[tokenKey] ?? false;
  }

  void setCurrentToken(String tokenKey) {
    currentToken = tokenKey;
    currentTokenConfig = _config.getToken(tokenKey);

    final tokenConfig = _config.getToken(tokenKey);

    _decimals = tokenConfig.decimals;
    _balance = tokenBalances[tokenKey] ?? '0';

    _preferencesService.setToken(tokenKey);
    safeNotifyListeners();

    updateBalance();
  }

  void clear() {
    _address = null;
    _balance = '0';
    _tokenBalances = {};
    _decimals = 6;
    _preferencesService.setToken(null);
    safeNotifyListeners();
  }
}
