import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/place.dart';

class OrdersWithPlaceState with ChangeNotifier {
  Place place;
  String myAddress;
  List<Order> orders = [];

  OrdersWithPlaceState({required this.place, required this.myAddress});

  bool loading = false;
  bool error = false;

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
}
