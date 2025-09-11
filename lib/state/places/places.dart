import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/place.dart';
import 'package:pay_app/services/pay/places.dart';
import 'package:pay_app/services/preferences/preferences.dart';

class PlacesState with ChangeNotifier {
  String searchQuery = '';
  List<Place> places = [];
  final PlacesService apiService = PlacesService();
  final PreferencesService _preferencesService = PreferencesService();

  bool loading = false;
  bool error = false;

  PlacesState() {
    final token = _preferencesService.tokenAddress;
    getAllPlaces(token: token);
  }

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

  Future<void> getAllPlaces({String? token}) async {
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      final places = await apiService.getAllPlaces(token: token);
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
