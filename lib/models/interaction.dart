import 'package:pay_app/models/place.dart';
import 'package:pay_app/services/wallet/models/userop.dart';

enum ExchangeDirection {
  sent,
  received,
}

// TODO: interaction with place, has menu item
class Interaction {
  final String id; // id from supabase
  final ExchangeDirection exchangeDirection;

  final String withAccount; // an account address
  final String? imageUrl;
  final String name;

  // last interaction
  final double amount;
  final String? description;

  final bool isPlace;
  final bool isTreasury;
  final int? placeId; // id from supabase
  final Place? place;
  final bool hasMenuItem;
  bool hasUnreadMessages;
  final DateTime lastMessageAt;

  Interaction({
    required this.id,
    required this.exchangeDirection,
    required this.withAccount,
    required this.imageUrl,
    required this.name,
    required this.lastMessageAt,
    required this.amount,
    this.isPlace = false,
    this.isTreasury = false,
    this.hasUnreadMessages = false,
    this.hasMenuItem = false,
    this.description,
    this.placeId,
    this.place,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    final transaction = json['transaction'] as Map<String, dynamic>;
    final withProfile = json['with_profile'] as Map<String, dynamic>;
    final withPlace = json['with_place'] as Map<String, dynamic>?;

    return Interaction(
      id: json['id'],
      exchangeDirection: parseExchangeDirection(json['exchange_direction']),
      withAccount: withProfile['account'],
      imageUrl: withPlace != null ? withPlace['image'] : withProfile['image'],
      name: withPlace != null ? withPlace['name'] : withProfile['name'],
      amount: double.tryParse(transaction['value']) ?? 0,
      description: transaction['description'],
      isPlace: withPlace != null,
      isTreasury: withProfile['account'] == zeroAddress,
      placeId: withPlace?['id'],
      hasUnreadMessages: json['new_interaction'],
      lastMessageAt: DateTime.parse(transaction['created_at']),
      hasMenuItem: false,
      place: withPlace != null ? Place.fromJson(withPlace) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'direction': exchangeDirection
          .toString()
          .split('.')
          .last, // converts enum to string
      'withAccount': withAccount,
      'name': name,
      'imageUrl': imageUrl,
      'amount': amount,
      'description': description,
      'isPlace': isPlace,
      'isTreasury': isTreasury,
      'placeId': placeId,
      'hasUnreadMessages': hasUnreadMessages,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'hasMenuItem': hasMenuItem,
      'place': place?.toMap(),
    };
  }

  // to update an interaction of id with new values
  Interaction copyWith({
    ExchangeDirection? exchangeDirection,
    String? imageUrl,
    String? name,
    double? amount,
    String? description,
    bool? hasUnreadMessages,
    DateTime? lastMessageAt,
    bool? hasMenuItem,
    Place? place,
  }) {
    return Interaction(
      id: id,
      exchangeDirection: exchangeDirection ?? this.exchangeDirection,
      withAccount: withAccount,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isPlace: isPlace,
      isTreasury: isTreasury,
      placeId: placeId,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      hasMenuItem: hasMenuItem ?? this.hasMenuItem,
      place: place ?? this.place,
    );
  }

  static Interaction upsert(Interaction existing, Interaction updated) {
    if (existing.id != updated.id) {
      throw ArgumentError('Cannot upsert interactions with different IDs');
    }

    return existing.copyWith(
      exchangeDirection: updated.exchangeDirection,
      imageUrl: updated.imageUrl,
      name: updated.name,
      amount: updated.amount,
      description: updated.description,
      hasUnreadMessages: updated.hasUnreadMessages,
      lastMessageAt: updated.lastMessageAt,
      hasMenuItem: updated.hasMenuItem,
      place: updated.place,
    );
  }

  @override
  String toString() {
    return 'Interaction(id: $id, exchangeDirection: $exchangeDirection, withAccount: $withAccount, imageUrl: $imageUrl, name: $name, amount: $amount, description: $description, isPlace: $isPlace, placeId: $placeId, hasUnreadMessages: $hasUnreadMessages, lastMessageAt: $lastMessageAt)';
  }

  static ExchangeDirection parseExchangeDirection(String direction) {
    switch (direction.toLowerCase()) {
      case 'sent':
        return ExchangeDirection.sent;
      case 'received':
        return ExchangeDirection.received;
      default:
        throw ArgumentError('Unknown exchange direction: $direction');
    }
  }
}
