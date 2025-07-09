import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/photos/photos.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/services/wallet/wallet.dart';

class AccountState with ChangeNotifier {
  // instantiate services here
  final SecureService _secureService = SecureService();
  final PhotosService _photosService = PhotosService();

  final Config _config;

  // private variables here

  // constructor here
  AccountState(this._config);

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
  bool deletingData = false;
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

  Future<bool> deleteData() async {
    try {
      deletingData = true;
      error = false;
      safeNotifyListeners();

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        throw Exception('No credentials found');
      }

      final (account, key) = credentials;

      final address = key.address;

      // TODO: fix delete endpoint
      // await deleteCurrentProfile(
      //   _config,
      //   account,
      //   key,
      // );

      final profile = ProfileV1(account: account.hexEip55);

      final url = await setProfile(
        _config,
        account,
        key,
        ProfileRequest.fromProfileV1(profile),
        image: await _photosService.photoFromBundle('assets/icons/profile.png'),
        fileType: '.png',
      );
      if (url == null) {
        throw Exception('Failed to set profile url');
      }

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

      deletingData = false;
      safeNotifyListeners();
    }

    return true;
  }
}
