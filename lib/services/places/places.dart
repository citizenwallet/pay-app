import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/models/place.dart';
import 'package:pay_app/services/api/api.dart';

class PlacesService {
  final APIService apiService =
      APIService(baseURL: dotenv.env['CHECKOUT_API_BASE_URL'] ?? '');
  String myAccount;

  PlacesService({required this.myAccount});

  Future<List<Place>> getAllPlaces() async {
    try {
      final response = await apiService.get(url: '/places');

      final Map<String, dynamic> data = response;
      final List<dynamic> placesApiResponse = data['places'];
      /* Example API Response:
        [
            {
                "id": 1,
                "name": "Commons Hub Fridge", 
                "slug": "fridge",
                "image": null,
                "accounts": [
                    "0x8b120C5756b86dE2cdeBf53C08D8bDD36f897c03"
                ],
                "description": null
            }
        ]
        */

      // Transform the API response into the format expected by Place.fromJson
      final List<Map<String, dynamic>> transformedPlaces =
          placesApiResponse.map((place) {
        final accounts = place['accounts'] as List<dynamic>;  
        final account = accounts.first;

        return {
          'id': place['id'],
          'name': place['name'],
          'slug': place['slug'],
          'account': account,
          'imageUrl': place['image'],
          'description': place['description'],
        };
      }).toList();

      return transformedPlaces.map((i) => Place.fromJson(i)).toList();
    } catch (e, s) {
      debugPrint('Error getting places: ${e.toString()}');
      debugPrint('Stack trace: ${s.toString()}');
      rethrow;
    }
  }
}
