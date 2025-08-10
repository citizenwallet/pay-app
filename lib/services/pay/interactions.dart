import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/services/api/api.dart';

class InteractionService {
  final APIService apiService =
      APIService(baseURL: dotenv.env['CHECKOUT_API_BASE_URL'] ?? '');

  Future<List<Interaction>> getInteractions(String account) async {
    try {
      final response =
          await apiService.get(url: '/accounts/$account/interactions');

      final Map<String, dynamic> data = response;
      final List<dynamic> interactionsApiResponse = data['interactions'];

      return interactionsApiResponse
          .map((i) => Interaction.fromJson(i))
          .toList();
    } catch (e, s) {
      debugPrint('Error getting interactions: ${e.toString()}');
      debugPrint('Stack trace: ${s.toString()}');
      rethrow;
    }
  }

  // polling new interactions since fromDate
  Future<List<Interaction>> getNewInteractions(
    String account,
    DateTime fromDate,
  ) async {
    try {
      final response = await apiService.get(
          url:
              '/accounts/$account/interactions/new?from_date=${fromDate.toUtc()}');

      final Map<String, dynamic> data = response;
      final List<dynamic> interactionsApiResponse = data['interactions'];

      return interactionsApiResponse
          .map((i) => Interaction.fromJson(i))
          .toList();
    } catch (e, s) {
      debugPrint('Error getting interactions: ${e.toString()}');
      debugPrint('Stack trace: ${s.toString()}');
      rethrow;
    }
  }

  Future<void> setInteractionAsRead(
      String account, String interactionId) async {
    await apiService.patch(
      url: '/accounts/$account/interactions/$interactionId/read',
    );
  }
}
