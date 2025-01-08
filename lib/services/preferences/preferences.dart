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
    await _preferences.clear();
  }

  // save the chain id
  Future setChainId(int chainId) async {
    await _preferences.setInt('chainId', chainId);
  }

  int get chainId => _preferences.getInt('chainId') ?? 1;

  // save chain id for a given alias
  Future setChainIdForAlias(String alias, String chainId) async {
    await _preferences.setString('chainId_$alias', chainId);
  }

  String? getChainIdForAlias(String alias) {
    return _preferences.getString('chainId_$alias');
  }

  // saved balance
  Future setBalance(String key, String value) async {
    await _preferences.setString('balance_$key', value);
  }

  String? getBalance(String key) {
    return _preferences.getString('balance_$key');
  }

  // save account address for given key
  Future setAccountAddress(String key, String accaddress) async {
    await _preferences.setString('accountAddress_$key', accaddress);
  }

  String? getAccountAddress(String key) {
    return _preferences.getString('accountAddress_$key');
  }

  Future setLastAlias(String alias) async {
    await _preferences.setString('lastAlias', alias);
  }

  String? get lastAlias => _preferences.getString('lastAlias');

  Future setLastWallet(String address) async {
    await _preferences.setString('lastWallet', address);
  }

  String? get lastWallet => _preferences.getString('lastWallet');
}
