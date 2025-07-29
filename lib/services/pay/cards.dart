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

  Future<List<Card>> getCards(
    SigAuthConnection connection,
    String owner,
  ) async {
    try {
      final response = await apiService.get(
        url: '/app/cards?owner=$owner',
        headers: connection.toMap(),
      );

      final List<dynamic> cards = response['cards'];

      return cards.map((e) => Card.fromJson(e)).toList();
    } catch (e, s) {
      debugPrint('Failed to fetch cards: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to fetch cards');
    }
  }

  Future<Card?> getCard(
    SigAuthConnection connection,
    String serial,
  ) async {
    try {
      final response = await apiService.get(
        url: '/app/cards/$serial',
        headers: connection.toMap(),
      );

      final card = Card.fromJson(response['card']);

      return card;
    } catch (e, s) {
      debugPrint('Failed to fetch card: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to fetch card');
    }
  }

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

  Future<void> release(
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
      debugPrint('Failed to release card: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to release card');
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

  Future<bool> deleteProfile(
      SigAuthConnection connection, String serial) async {
    try {
      await apiService.delete(
        url: '/app/cards/$serial/profile',
        body: {},
        headers: connection.toMap(),
      );

      return true;
    } catch (e, s) {
      debugPrint('Failed to delete card: $e');
      debugPrint('Stack trace: $s');
      return false;
    }
  }
}
