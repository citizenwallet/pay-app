import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/wallet/wallet.dart';

class AccountState with ChangeNotifier {
  // instantiate services here
  final SecureService _secureService = SecureService();
  final ConfigService _configService = ConfigService();

  late Config _config;

  // private variables here

  // constructor here
  AccountState() {
    init();
  }

  Future<void> init() async {
    final config = await _configService.getLocalConfig();
    if (config == null) {
      throw Exception('Community not found in local asset');
    }

    await config.initContracts();

    _config = config;
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
  bool loggingOut = false;
  bool error = false;

  // state methods here
  Future<bool> logout() async {
    try {
      loggingOut = true;
      error = false;
      safeNotifyListeners();

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        throw Exception('No credentials found');
      }

      final (account, key) = credentials;

      final address = key.address;

      final calldata =
          _config.sessionManagerModuleContract.revokeCallData(address);

      final (_, userOp) = await prepareUserop(
        _config,
        account,
        key,
        [_config.sessionManagerModuleContract.addr],
        [calldata],
      );

      final txHash = await submitUserop(
        _config,
        userOp,
      );

      if (txHash == null) {
        throw Exception('Failed to revoke session');
      }
    } catch (e, s) {
      error = true;
      safeNotifyListeners();
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
    } finally {
      await _secureService.clearCredentials();

      loggingOut = false;
      safeNotifyListeners();
    }

    return true;
  }
}
