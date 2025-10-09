import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/sigauth/sigauth.dart';

class TopupState extends ChangeNotifier {
  // instantiate services here
  final SecureService _secureService = SecureService();
  final PreferencesService _preferencesService = PreferencesService();

  // private variables here

  // constructor here
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
  String topupUrl = '';

  // state methods here
  Future<void> generateTopupUrl(String baseUrl,
      {String? account, String? token}) async {
    try {
      final lastAccount = account ?? _preferencesService.lastAccount;
      final tokenAddress = token ?? _preferencesService.tokenAddress;

      String topupUrl = baseUrl;
      if (lastAccount != null) {
        topupUrl = '$baseUrl?account=$lastAccount';
        if (tokenAddress != null) {
          topupUrl += '&token=$tokenAddress';
        }
      } else {
        final credentials = _secureService.getCredentials();
        if (credentials == null) {
          return;
        }

        final (account, key) = credentials;

        final redirectDomain = dotenv.env['APP_REDIRECT_DOMAIN'];

        final sigAuthService = SigAuthService(
          credentials: key,
          address: account,
          redirect: redirectDomain != null ? 'https://$redirectDomain' : '',
        );

        final sigAuthConnection = sigAuthService.connect();

        topupUrl = '$baseUrl?${sigAuthConnection.queryParams}';
      }

      this.topupUrl = topupUrl;

      safeNotifyListeners();
    } catch (e, s) {
      debugPrint('Error generating topup url: $e');
      debugPrint('Stack trace: $s');

      topupUrl = '';

      safeNotifyListeners();
    }
  }
}
