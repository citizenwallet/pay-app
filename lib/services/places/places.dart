import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/models/place.dart';
import 'package:pay_app/services/api/api.dart';

class PlacesService {
  final APIService apiService =
      APIService(baseURL: dotenv.env['CHECKOUT_API_BASE_URL'] ?? '');

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
          'hasMenu': true,
        };
      }).toList();

      return transformedPlaces.map((i) => Place.fromJson(i)).toList();
    } catch (e, s) {
      debugPrint('Error getting places: ${e.toString()}');
      debugPrint('Stack trace: ${s.toString()}');
      rethrow;
    }
  }

  Future<Place> getPlaceAndMenu(String account) async {
    final response = await apiService.get(url: '/places/$account/menu');
    /*
    {
        "place": {
            "id": 1,
            "created_at": "2024-10-27T21:20:44.925188+00:00",
            "name": "Commons Hub Fridge",
            "business_id": 2,
            "slug": "fridge",
            "accounts": [
                "0x8b120C5756b86dE2cdeBf53C08D8bDD36f897c03"
            ],
            "invite_code": null,
            "terminal_id": 16525076,
            "image": null,
            "description": null
        },
        "profile": {
            "account": "0x8b120C5756b86dE2cdeBf53C08D8bDD36f897c03",
            "username": "fridge",
            "name": "Commons Hub Fridge",
            "description": "Pick a drink, pay to regenerate",
            "image": "https://ipfs.internal.citizenwallet.xyz/QmTdek5iJiAtqZxmr3HG9LxWwzXCkNqzV4otRt1WecjLrw",
            "image_medium": "https://ipfs.internal.citizenwallet.xyz/QmeTM1Xcssr2g6okS8SnQk9JLaCJcgNJuqH8oeLaMqMzjk",
            "image_small": "https://ipfs.internal.citizenwallet.xyz/QmUy2TdHBY8RPcfzRJmVDaVoPqFRGWFp8G4S2tZhazUfL6",
            "token_id": "793952205625355567340975105020620960685070318595"
        },
        "items": [
            {
                "id": 26,
                "created_at": "2024-12-02T16:44:29.303851+00:00",
                "place_id": 1,
                "image": "https://ounjigiydhimruivuxjv.supabase.co/storage/v1/object/public/uploads/soft.png",
                "price": 300,
                "name": "Soft drink",
                "category": "Soft",
                "vat": 21,
                "emoji": "🍸",
                "description": "Fritz Lemonade (rhubarb, lemon, orange)",
                "order": 0
            }
        ]
    }
    */
    final Map<String, dynamic> data = response;
    final Map<String, dynamic> placeData = data['place'];
    final Map<String, dynamic> profileData = data['profile'];
    final List<dynamic> itemsData = data['items'];

    return Place.fromJson(response);
  }
}
