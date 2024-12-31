import 'dart:convert';

import 'package:pay_app/services/db/preference.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  late PreferenceTable _preferences;

  Future init(PreferenceTable pref) async {
    _preferences = pref;
  }

  Future clear() async {
    await _preferences.clear();
  }

  Future setConfig(dynamic value) async {
    await _preferences.set('config', jsonEncode(value));
  }

  Future<dynamic> getConfig() async {
    return jsonDecode(await _preferences.get('config') ?? '{}');
  }
}
