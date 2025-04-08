import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/checkout.dart';
import 'package:pay_app/models/menu_item.dart';
import 'package:pay_app/models/place.dart';

class CheckoutState with ChangeNotifier {
  Checkout checkout;
  final Place? place;
  final String _account;
  final String _slug;

  CheckoutState({
    required account,
    required slug,
    this.place,
  })  : _account = account,
        _slug = slug,
        checkout = Checkout(items: []);

  bool loading = false;

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

  void clear() {
    checkout = Checkout(items: []);
    safeNotifyListeners();
  }

  void addItem(
    MenuItem menuItem, {
    int quantity = 1,
  }) {
    final newCheckout = checkout.addItem(menuItem, quantity: quantity);

    checkout = newCheckout;

    safeNotifyListeners();
  }

  void decreaseItem(MenuItem menuItem) {
    final newCheckout = checkout.decreaseItem(menuItem);
    checkout = newCheckout;
    safeNotifyListeners();
  }

  void increaseItem(MenuItem menuItem) {
    final newCheckout = checkout.increaseItem(menuItem);
    checkout = newCheckout;
    safeNotifyListeners();
  }
}
