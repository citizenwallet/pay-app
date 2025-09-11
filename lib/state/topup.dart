import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/sigauth/sigauth.dart';

class TopupState extends ChangeNotifier {
  // instantiate services here
  final SecureService _secureService = SecureService();

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
  Future<void> generateTopupUrl(String baseUrl) async {
    try {
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

      final topupUrl = '$baseUrl?${sigAuthConnection.queryParams}';

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
