import 'package:flutter/cupertino.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

class OnboardingState with ChangeNotifier {
  // instantiate services here

  // private variables here
  final TextEditingController _phoneNumberController = TextEditingController();

  TextEditingController get phoneNumberController => _phoneNumberController;

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
  bool touched = false;
  String? regionCode;

  // state methods here
  Future<void> formatPhoneNumber(String phoneNumber) async {
    try {
      final result = await parse(phoneNumber);

      regionCode = result['region_code'];
    } catch (e) {
      regionCode = null;
    }

    touched = true;

    safeNotifyListeners();
  }
}
