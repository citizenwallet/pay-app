import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/photos/photos.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:pay_app/utils/random.dart';

class ProfileState with ChangeNotifier {
  // instantiate services here
  final ConfigService _configService = ConfigService();
  final SecureService _secureService = SecureService();
  final PhotosService _photosService = PhotosService();

  // private variables here
  bool _pauseProfileCreation = false;
  final String _account;

  late Config _config;

  // constructor here
  ProfileState(this._account) {
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
  bool loading = false;
  bool error = false;
  ProfileV1 profile = ProfileV1();
  String get alias => _config.community.alias;

  // state methods here
  Future<String?> _generateProfileUsername() async {
    String username = await getRandomUsername();

    const maxTries = 3;
    const baseDelay = Duration(milliseconds: 100);

    for (int tries = 1; tries <= maxTries; tries++) {
      final exists = await profileExists(_config, username);

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

      final existingProfile = await getProfile(_config, _account);

      if (existingProfile != null) {
        profile = existingProfile;
        safeNotifyListeners();
        return;
      }

      final username = await _generateProfileUsername();
      if (username == null) {
        return;
      }

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        throw Exception('Credentials not found');
      }

      final (address, privateKey) = credentials;

      profile.username = username;
      profile.account = address.hexEip55;
      profile.name = username.isNotEmpty
          ? username[0].toUpperCase() + username.substring(1)
          : 'Anonymous';

      safeNotifyListeners();

      if (_pauseProfileCreation) {
        return;
      }

      final exists = await accountExists(_config, address);
      if (!exists) {
        await createAccount(_config, address, privateKey);
      }

      if (_pauseProfileCreation) {
        return;
      }

      final url = await setProfile(
        _config,
        address,
        privateKey,
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

      final newProfile = await getProfileFromUrl(_config, url);
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
