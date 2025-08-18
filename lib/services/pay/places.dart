import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/models/place.dart';
import 'package:pay_app/services/api/api.dart';
import 'package:pay_app/models/place_with_menu.dart';

class PlacesService {
  final APIService apiService =
      APIService(baseURL: dotenv.env['CHECKOUT_API_BASE_URL'] ?? '');

  Future<List<Place>> getAllPlaces({String? token}) async {
    try {
      String url = '/places';
      if (token != null) {
        url += '?token=$token';
      }
      final response = await apiService.get(url: url);

      final Map<String, dynamic> data = response;
      final List<dynamic> placesApiResponse = data['places'];

      return placesApiResponse.map((json) => Place.fromJson(json)).toList();
    } catch (e, s) {
      debugPrint('Error getting places: ${e.toString()}');
      debugPrint('Stack trace: ${s.toString()}');
      rethrow;
    }
  }

  Future<PlaceWithMenu> getPlaceAndMenu(String slug) async {
    final response = await apiService.get(url: '/places/$slug/menu');

    final Map<String, dynamic> data = response;
    return PlaceWithMenu.fromJson(data);
  }
}
