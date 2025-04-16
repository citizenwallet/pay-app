import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/place.dart';
import 'package:pay_app/services/pay/places.dart';

class PlacesState with ChangeNotifier {
  String searchQuery = '';
  List<Place> places = [];
  PlacesService apiService = PlacesService();

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

  void setSearchQuery(String query) {
    searchQuery = query;
    safeNotifyListeners();
  }

  void clearSearch() {
    searchQuery = '';
    safeNotifyListeners();
  }

  Future<void> getAllPlaces() async {
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      final places = await apiService.getAllPlaces();
      this.places = places;
    } catch (e, s) {
      debugPrint('Error fetching places: $e');
      debugPrint('Stack trace: $s');
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'Error fetching places',
      );
      error = true;
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }
}
