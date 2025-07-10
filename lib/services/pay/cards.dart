import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/models/card.dart';
import 'package:pay_app/services/api/api.dart';
import 'package:pay_app/services/sigauth/sigauth.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';

class CardsService {
  final APIService apiService =
      APIService(baseURL: dotenv.env['CHECKOUT_API_BASE_URL'] ?? '');

  CardsService();

  Future<Card> claim(
    SigAuthConnection connection,
    String serial, {
    String? project,
  }) async {
    try {
      final body = {
        'account': connection.address.hexEip55,
        'project': project,
      };

      final response = await apiService.put(
        url: '/app/cards/$serial/claim',
        body: body,
        headers: connection.toMap(),
      );

      final card = Card.fromJson(response);

      return card;
    } catch (e, s) {
      debugPrint('Failed to fetch orders: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to fetch orders');
    }
  }

  Future<void> unclaim(
    SigAuthConnection connection,
    String serial,
  ) async {
    try {
      await apiService.delete(
        url: '/app/cards/$serial/claim',
        body: {},
        headers: connection.toMap(),
      );
    } catch (e, s) {
      debugPrint('Failed to unclaim card: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to unclaim card');
    }
  }

  Future<ProfileV1?> setProfile(
      SigAuthConnection connection, String serial, String name) async {
    try {
      final body = {
        'name': name,
      };

      final response = await apiService.put(
        url: '/app/cards/$serial/profile',
        body: body,
        headers: connection.toMap(),
      );

      final profile = ProfileV1.fromJson(response);

      return profile;
    } catch (e, s) {
      debugPrint('Failed to fetch orders: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to fetch orders');
    }
  }

  Future<void> deleteProfile(
      SigAuthConnection connection, String serial) async {
    try {
      await apiService.delete(
        url: '/app/cards/$serial/profile',
        body: {},
        headers: connection.toMap(),
      );
    } catch (e, s) {
      debugPrint('Failed to delete card: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to delete card');
    }
  }
}
