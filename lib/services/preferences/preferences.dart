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

  // Future<String?> get lastActiveOrgId => _preferences.get('lastActiveOrgId');

  // Future setLastActiveOrgId(String id) async {
  //   await _preferences.set('lastActiveOrgId', id);
  // }

  // Future<String?> getOrgThreshold(String id) async {
  //   return _preferences.get('orgThreshold-$id');
  // }

  // Future setOrgThreshold(String id, String threshold) async {
  //   await _preferences.set('orgThreshold-$id', threshold);
  // }
}
