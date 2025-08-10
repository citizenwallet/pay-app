import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/theme/colors.dart';

class AppState with ChangeNotifier {
  // instantiate services here
  final PreferencesService _preferencesService = PreferencesService();

  // private variables here
  final Config _config;
  Config get config => _config;

  // constructor here
  AppState(this._config)
      : currentTokenAddress = _config.getPrimaryToken().address,
        currentTokenConfig = _config.getPrimaryToken();

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
  String currentTokenAddress;
  TokenConfig currentTokenConfig;

  bool small = false;

  Color get tokenPrimaryColor => currentTokenConfig.color != null
      ? Color(int.parse(currentTokenConfig.color!.replaceAll('#', '0xFF')))
      : primaryColor;

  // state methods here
  void setCurrentToken(String tokenAddress) {
    currentTokenAddress = tokenAddress;
    currentTokenConfig = _config.getToken(tokenAddress);

    _preferencesService.setToken(tokenAddress);
    safeNotifyListeners();
  }

  void setLastAccount(String account) {
    _preferencesService.setLastAccount(account);
    safeNotifyListeners();
  }

  void setSmall(bool small) {
    if (this.small == small) {
      return;
    }

    this.small = small;
    safeNotifyListeners();
  }
}
