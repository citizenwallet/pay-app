import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/photos/photos.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:pay_app/utils/random.dart';

class ProfileState with ChangeNotifier {
  // instantiate services here
  final WalletService _walletService = WalletService();
  final PhotosService _photosService = PhotosService();

  // private variables here
  bool _pauseProfileCreation = false;
  final String _account;

  // constructor here
  ProfileState(this._account);

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
  bool loading = false;
  bool error = false;
  ProfileV1 profile = ProfileV1();

  // state methods here
  Future<String?> _generateProfileUsername() async {
    String username = await getRandomUsername();

    const maxTries = 3;
    const baseDelay = Duration(milliseconds: 100);

    for (int tries = 1; tries <= maxTries; tries++) {
      final exists = await _walletService.profileExists(username);

      if (!exists) {
        return username;
      }

      if (tries > maxTries) break;

      username = await getRandomUsername();
      await delay(baseDelay * tries);
    }

    return null;
  }

  Future<void> giveProfileUsername() async {
    debugPrint('handleNewProfile');

    try {
      loading = true;
      error = false;
      safeNotifyListeners();

      final existingProfile = await _walletService.getProfile(_account);

      if (existingProfile != null) {
        profile = existingProfile;
        safeNotifyListeners();
        return;
      }

      final username = await _generateProfileUsername();
      if (username == null) {
        return;
      }

      final address = _walletService.account.hexEip55;

      profile.username = username;
      profile.account = address;
      profile.name = username.isNotEmpty
          ? username[0].toUpperCase() + username.substring(1)
          : 'Anonymous';

      safeNotifyListeners();

      if (_pauseProfileCreation) {
        return;
      }

      final exists = await _walletService.createAccount();
      if (!exists) {
        throw Exception('Failed to create account');
      }

      if (_pauseProfileCreation) {
        return;
      }

      final url = await _walletService.setProfile(
        ProfileRequest.fromProfileV1(profile),
        image: await _photosService.photoFromBundle('assets/icons/profile.png'),
        fileType: '.png',
      );
      if (url == null) {
        throw Exception('Failed to create profile url');
      }

      if (_pauseProfileCreation) {
        return;
      }

      final newProfile = await _walletService.getProfileFromUrl(url);
      if (newProfile == null) {
        throw Exception('Failed to get profile from url $url');
      }

      if (_pauseProfileCreation) {
        return;
      }
    } catch (e, s) {
      debugPrint('giveProfileUsername error: $e, $s');
      error = true;
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }

  void pause() {
    _pauseProfileCreation = true;
  }

  void resume() {
    _pauseProfileCreation = false;
  }
}
