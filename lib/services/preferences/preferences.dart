import 'dart:convert';

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

  Future setTwoFAAddress(String salt, String address) async {
    await _preferences.setString('twofa_address_$salt', address);
  }

  String? getTwoFAAddress(String salt) {
    return _preferences.getString('twofa_address_$salt');
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

  Future setAudioMuted(bool muted) async {
    await _preferences.setBool('audio_muted', muted);
  }

  bool get audioMuted {
    return _preferences.getBool('audio_muted') ?? false;
  }

  Future setLastAccount(String account) async {
    await _preferences.setString('last_account', account);
  }

  String? get lastAccount {
    return _preferences.getString('last_account');
  }
}
