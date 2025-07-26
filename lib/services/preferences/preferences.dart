import 'dart:convert';

import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  late SharedPreferences _preferences;

  Future init(SharedPreferences pref) async {
    _preferences = pref;
  }

  Future clear() async {
    await _preferences.remove('balance');
    await _preferences.remove('profile');
  }

  // save profile
  Future setProfile(ProfileV1 profile) async {
    await _preferences.setString('profile', jsonEncode(profile.toJson()));
  }

  ProfileV1? get profile {
    final json = _preferences.getString('profile');
    if (json == null) {
      return null;
    }
    return ProfileV1.fromJson(jsonDecode(json));
  }

  // save token balances
  Future setTokenBalances(String account, Map<String, String> balances) async {
    await _preferences.setString(
      'token_balances_$account',
      jsonEncode(balances),
    );
  }

  Map<String, String> tokenBalances(String account) {
    final json = _preferences.getString('token_balances_$account');
    if (json == null) {
      return {};
    }
    return Map<String, String>.from(jsonDecode(json));
  }

  // save contact permission
  Future setContactPermission(bool permission) async {
    await _preferences.setBool('contact_permission', permission);
  }

  bool? get contactPermission {
    return _preferences.getBool('contact_permission');
  }

  String? get tokenAddress {
    return _preferences.getString('token_address');
  }

  Future setToken(String? tokenAddress) async {
    if (tokenAddress == null) {
      await _preferences.remove('token_address');
    } else {
      await _preferences.setString('token_address', tokenAddress);
    }
  }
}
