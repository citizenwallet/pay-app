import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/place_with_menu.dart';
import 'package:pay_app/services/places/places.dart';

class OrdersWithPlaceState with ChangeNotifier {
  final PlacesService placesService = PlacesService();

  String slug;
  PlaceWithMenu? place;
  String myAddress;
  List<Order> orders = [];

  OrdersWithPlaceState({required this.slug, required this.myAddress});

  bool loading = false;
  bool error = false;

  bool _mounted = true;
  void safeNotifyListeners() {
    if (_mounted) {
      notifyListeners();
    }
  }

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

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}
