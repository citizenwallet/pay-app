import 'package:flutter/cupertino.dart';

class AppState with ChangeNotifier {
  // instantiate services here

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

  // state methods here
}
