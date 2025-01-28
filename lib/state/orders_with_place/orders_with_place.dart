import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/place_with_menu.dart';
import 'package:pay_app/services/pay/orders.dart';
import 'package:pay_app/services/pay/places.dart';

class OrdersWithPlaceState with ChangeNotifier {
  // instantiate services here
  final PlacesService placesService = PlacesService();
  final OrdersService ordersService;

  // private variables here
  bool _mounted = true;

  // constructor here
  OrdersWithPlaceState({
    required this.slug,
    required this.myAddress,
  }) : ordersService = OrdersService(account: myAddress);

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
  String slug;
  PlaceWithMenu? place;
  String myAddress;
  List<Order> orders = [];

  // state methods here
  bool loading = false;
  bool error = false;

  Future<void> fetchPlaceAndMenu() async {
    try {
      final placeWithMenu = await placesService.getPlaceAndMenu(slug);
      place = placeWithMenu;

      safeNotifyListeners();
    } catch (e) {
      error = true;
      safeNotifyListeners();
    }
  }

  Future<void> fetchOrders() async {
    try {
      final response = await ordersService.getOrders();
      orders = response.orders;
      safeNotifyListeners();
    } catch (e) {
      error = true;
      safeNotifyListeners();
    }
  }
}
