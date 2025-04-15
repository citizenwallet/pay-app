import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/photos/photos.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:pay_app/utils/random.dart';
import 'package:pay_app/utils/uint8.dart';

enum ProfileUpdateState {
  idle,
  existing,
  uploading,
  fetching;

  double get progress {
    switch (this) {
      case ProfileUpdateState.idle:
        return 0;
      case ProfileUpdateState.existing:
        return 0.25;
      case ProfileUpdateState.uploading:
        return 0.5;
      case ProfileUpdateState.fetching:
        return 1;
    }
  }
}

class ProfileState with ChangeNotifier {
  // instantiate services here
  final ConfigService _configService = ConfigService();
  final PreferencesService _preferencesService = PreferencesService();
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
  ProfileV1? _profile;
  ProfileV1 get profile =>
      _profile ?? _preferencesService.profile ?? ProfileV1();
  String get alias => _config.community.alias;

  bool hasChanges = false;
  String? newUsername;
  String? newName;
  String? newDescription;
  bool usernameTaken = false;

  ProfileUpdateState profileUpdateState = ProfileUpdateState.idle;
  Uint8List? editingImage;
  String? editingImageExt;

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
      final cachedProfile = _preferencesService.profile;
      if (cachedProfile != null) {
        _profile = cachedProfile;
        safeNotifyListeners();
      }

      loading = true;
      error = false;
      safeNotifyListeners();

      final existingProfile = await getProfile(_config, _account);

      if (existingProfile != null && cachedProfile == null) {
        await _preferencesService.setProfile(existingProfile);
      }

      if (existingProfile != null) {
        _profile = existingProfile;
        safeNotifyListeners();
        return;
      }

      // don't go further if profile has been automatically setup
      if (cachedProfile != null) {
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

      _profile = newProfile;
      safeNotifyListeners();

      await _preferencesService.setProfile(newProfile);

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

  void checkForChanges() {
    final usernameChanged =
        newUsername != null && newUsername != profile.username;
    final nameChanged = newName != null && newName != profile.name;
    final descriptionChanged =
        newDescription != null && newDescription != profile.description;
    final imageChanged = editingImage != null;

    hasChanges =
        usernameChanged || nameChanged || descriptionChanged || imageChanged;
    safeNotifyListeners();
  }

  void resetName() {
    newName = null;
    checkForChanges();
    safeNotifyListeners();
  }

  void setName(String name) {
    newName = name;
    checkForChanges();
    safeNotifyListeners();
  }

  void resetDescription() {
    newDescription = null;
    checkForChanges();
    safeNotifyListeners();
  }

  void setDescription(String description) {
    newDescription = description;
    checkForChanges();
    safeNotifyListeners();
  }

  void resetUsernameTaken() {
    newUsername = null;
    usernameTaken = false;
    checkForChanges();
    safeNotifyListeners();
  }

  Future<void> checkUsernameTaken(String username) async {
    if (profile.username == username) {
      newUsername = null;
      usernameTaken = false;
      checkForChanges();
      safeNotifyListeners();
      return;
    }

    try {
      final exists = await profileExists(_config, username);
      newUsername = null;
      usernameTaken = exists;
      if (!exists) {
        newUsername = username;
      }
      checkForChanges();
      safeNotifyListeners();
    } catch (e, s) {
      debugPrint('checkUsernameTaken error: $e, $s');
    }
  }

  void resetEditingImage() {
    editingImage = null;
    editingImageExt = null;
    checkForChanges();
    safeNotifyListeners();
  }

  void startEditing() async {
    try {
      final isNetwork = profile.image.startsWith('http');
      if (isNetwork) {
        editingImage = null;
        editingImageExt = null;
        checkForChanges();
        safeNotifyListeners();
        return;
      }

      final (b, ext) = await _photosService.photoToData(profile.image);
      editingImage = convertBytesToUint8List(b);
      editingImageExt = ext;
      checkForChanges();
      safeNotifyListeners();
    } catch (e, s) {
      debugPrint('startEditing error: $e, $s');
    }
  }

  Future<void> selectPhoto() async {
    try {
      final result = await _photosService.selectPhoto();

      if (result != null) {
        editingImage = result.$1;
        editingImageExt = result.$2;
        checkForChanges();
        safeNotifyListeners();
      }
    } catch (_) {}
  }

  Future<void> saveProfile() async {
    try {
      loading = true;
      safeNotifyListeners();

      await delay(const Duration(milliseconds: 100));

      profileUpdateState = ProfileUpdateState.uploading;
      safeNotifyListeners();

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        throw Exception('Credentials not found');
      }

      final (address, privateKey) = credentials;

      if (newUsername != null) {
        profile.username = newUsername!;
      }

      if (newName != null) {
        profile.name = newName!;
      }

      if (newDescription != null) {
        profile.description = newDescription!;
      }

      String? url;
      if (editingImage != null) {
        final Uint8List newImage = editingImage != null
            ? convertBytesToUint8List(editingImage!)
            : await _photosService.photoFromBundle('assets/icons/profile.png');

        url = await setProfile(
          _config,
          address,
          privateKey,
          ProfileRequest.fromProfileV1(profile),
          image: newImage,
          fileType: editingImageExt ?? '.png',
        );
      } else {
        url = await updateProfile(
          _config,
          address,
          privateKey,
          profile,
        );
      }
      if (url == null) {
        throw Exception('Failed to create profile url');
      }

      profileUpdateState = ProfileUpdateState.fetching;
      safeNotifyListeners();

      final newProfile = await getProfileFromUrl(_config, url);
      if (newProfile == null) {
        throw Exception('Failed to get profile from url $url');
      }

      _profile = newProfile;
      await _preferencesService.setProfile(newProfile);

      checkForChanges();
      safeNotifyListeners();
    } catch (e, s) {
      debugPrint('updateProfile error: $e, $s');
      profileUpdateState = ProfileUpdateState.idle;
      safeNotifyListeners();
    } finally {
      await delay(const Duration(milliseconds: 100));

      loading = false;
      profileUpdateState = ProfileUpdateState.idle;
      safeNotifyListeners();
    }
  }
}
