import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/services/api/api.dart';

class InteractionService {
  final APIService apiService = APIService(
      baseURL: dotenv.env['CHECKOUT_API_BASE_URL'] ?? '');
  String myAccount;

  InteractionService({required this.myAccount});

  Future<List<Interaction>> getInteractions() async {
    try {
      final response = await apiService.get(url: '/interactions/$myAccount');

      final Map<String, dynamic> data = response;
      final List<dynamic> interactionsApiResponse = data['interactions'];
      /* Example API Response:
       * [
       *   {
       *     "id": "4faa93a8-134f-403a-838a-66b1e67b52ab",
       *     "exchange_direction": "sent", 
       *     "new_interaction": false,
       *     "transaction": {
       *       "id": "0x523f13521497ba4b704f54dc9f395bccbc7610f3589a3540b7e882794f627b0e",
       *       "to": "0xD80A494164C2Fd356212cb8983d697c41c550673",
       *       "from": "0x0000000000000000000000000000000000000000",
       *       "value": "15.0",
       *       "created_at": "2025-01-06T13:16:55+00:00",
       *       "description": ""
       *     },
       *     "with_profile": {
       *       "account": "0xD80A494164C2Fd356212cb8983d697c41c550673", 
       *       "username": "@anonymous",
       *       "name": "Anonymous",
       *       "description": "This user does not have a profile",
       *       "image": "https://ipfs.internal.citizenwallet.xyz/QmeuAaXrJBHygzAEHnvw5AKUHfBasuavsX9fU69rdv4mhh"
       *     },
       *     "with_place": {
       *       "id": 28,
       *       "name": "Vegan Brussels VZW",
       *       "slug": "vegan-brussels-vzw-K3Pk",
       *       "image": null,
       *       "description": null
       *     } | null
       *   }
       * ]
       */

      // Transform the API response into the format expected by Interaction.fromJson
      final List<Map<String, dynamic>> transformedInteractions =
          interactionsApiResponse.map((i) {
        final transaction = i['transaction'] as Map<String, dynamic>;
        final withProfile = i['with_profile'] as Map<String, dynamic>;
        final withPlace = i['with_place'] as Map<String, dynamic>?;

        return {
          'id': i['id'],
          'exchange_direction': i['exchange_direction'],
          'withAccount': i['with_profile']['account'],

          'imageUrl':
              withPlace != null ? withPlace['image'] : withProfile['image'],
          'name': withPlace != null ? withPlace['name'] : withProfile['name'],
          'amount': double.tryParse(transaction['value']),
          'description': transaction['description'],
          'isPlace': withPlace != null,
          'placeId': withPlace?['id'],
          'hasUnreadMessages': i['new_interaction'],
          'lastMessageAt': transaction['created_at'],
        };
      }).toList();

      return transformedInteractions.map((i) => Interaction.fromJson(i)).toList();
    } catch (e, s) {
      debugPrint('Error getting interactions: ${e.toString()}');
      debugPrint('Stack trace: ${s.toString()}');
      rethrow;
    }
  }

  // polling new interactions since fromDate
  Future<List<Interaction>> getNewInteractions(DateTime fromDate) async {
    try {
      final response = await apiService.get(
          url: '/interactions/$myAccount/new?from_date=${fromDate.toUtc()}');

      final Map<String, dynamic> data = response;
      final List<dynamic> interactionsApiResponse = data['interactions'];
      /* Example API Response:
       * [
       *   {
       *     "id": "4faa93a8-134f-403a-838a-66b1e67b52ab",
       *     "exchange_direction": "sent", 
       *     "new_interaction": false,
       *     "transaction": {
       *       "id": "0x523f13521497ba4b704f54dc9f395bccbc7610f3589a3540b7e882794f627b0e",
       *       "to": "0xD80A494164C2Fd356212cb8983d697c41c550673",
       *       "from": "0x0000000000000000000000000000000000000000",
       *       "value": "15.0",
       *       "created_at": "2025-01-06T13:16:55+00:00",
       *       "description": ""
       *     },
       *     "with_profile": {
       *       "account": "0xD80A494164C2Fd356212cb8983d697c41c550673", 
       *       "username": "@anonymous",
       *       "name": "Anonymous",
       *       "description": "This user does not have a profile",
       *       "image": "https://ipfs.internal.citizenwallet.xyz/QmeuAaXrJBHygzAEHnvw5AKUHfBasuavsX9fU69rdv4mhh"
       *     },
       *     "with_place": {
       *       "id": 28,
       *       "name": "Vegan Brussels VZW",
       *       "slug": "vegan-brussels-vzw-K3Pk",
       *       "image": null,
       *       "description": null
       *     } | null
       *   }
       * ]
       */

      // Transform the API response into the format expected by Interaction.fromJson
      final List<Map<String, dynamic>> transformedInteractions =
          interactionsApiResponse.map((i) {
        final transaction = i['transaction'] as Map<String, dynamic>;
        final withProfile = i['with_profile'] as Map<String, dynamic>;
        final withPlace = i['with_place'] as Map<String, dynamic>?;

        return {
          'id': i['id'],
          'exchange_direction': i['exchange_direction'],
          'withAccount': i['with_profile']['account'],
          'imageUrl':
              withPlace != null ? withPlace['image'] : withProfile['image'],
          'name': withPlace != null ? withPlace['name'] : withProfile['name'],
          'amount': double.tryParse(transaction['value']),
          'description': transaction['description'],
          'isPlace': withPlace != null,
          'placeId': withPlace?['id'],
          'hasUnreadMessages': i['new_interaction'],
          'lastMessageAt': transaction['created_at'],
        };
      }).toList();

      return transformedInteractions
          .map((i) => Interaction.fromJson(i))
          .toList();
    } catch (e, s) {
      debugPrint('Error getting interactions: ${e.toString()}');
      debugPrint('Stack trace: ${s.toString()}');
      rethrow;
    }
  }






}
