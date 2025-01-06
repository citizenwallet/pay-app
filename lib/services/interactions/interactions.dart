import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/services/api/api.dart';

class InteractionService {
  final APIService apiService = APIService(
      baseURL: 'http://192.168.200.230:3000/api/v1'); // FIXME: make dynamic
  String myAccount;

  InteractionService({required this.myAccount});

// TODO: polling
  Future<List<Interaction>> getInteractions() async {
    try {
      final response = await apiService.get(url: '/interactions/$myAccount');

      final Map<String, dynamic> data = response;
      final List<dynamic> interactionsApiResponse = data['interactions'];
      /**
       * [
       *   {
       *     "id": string,
       *     "account": string, // my account
       *     "with": string, // account of the other party
       *     "transaction": {
       *       "id": string,
       *       "value": string, // formatted with decimal
       *       "description": string,
       *       "from": string,
       *       "to": string,
       *       "created_at": "2024-07-11T17:39:40+00:00"
       *     },
       *     "with_profile": {
       *       "account": string, // account of the other party
       *       "username": string,
       *       "name": string,
       *       "image": string,
       *       "description": string
       *     },
       *     "with_place": {
       *       "id": int,
       *       "name": string,
       *       "slug": string,
       *       "image": string | null,
       *       "description": string | null
       *     } | null,
       *     "exchange_direction": "sent" | "received",
       *     "is_new_interaction": boolean
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
          'direction': i['exchange_direction'],
          'withAccount': i['with'],
          'imageUrl':
              withPlace != null ? withPlace['image'] : withProfile['image'],
          'name': withPlace != null ? withPlace['name'] : withProfile['name'],
          'amount': double.tryParse(transaction['value']),
          'description': transaction['description'],
          'isPlace': withPlace != null,
          'placeId': withPlace?['id'],
          'location': null, // Not provided in API response
          'userId': null, // Not provided in API response
          'hasUnreadMessages': i['is_new_interaction'],
          'lastMessageAt': DateTime.parse(transaction['created_at']),
        };
      }).toList();

      return transformedInteractions.map((i) => Interaction.fromJson(i)).toList();
    } catch (e, s) {
      debugPrint('Error getting interactions: ${e.toString()}');
      debugPrint('Stack trace: ${s.toString()}');
      rethrow;
    }
  }
}
