enum ExchangeDirection {
  sent,
  received,
}

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
  final int? placeId; // id from supabase

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
    this.hasUnreadMessages = false,
    this.description,
    this.placeId,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      id: json['id'],
      exchangeDirection: parseExchangeDirection(json['exchange_direction']),
      withAccount: json['withAccount'],
      imageUrl: json['imageUrl'] == null || json['imageUrl'] == ''
          ? null
          : json['imageUrl'],
      name: json['name'],
      amount: json['amount'],
      description: json['description'] == null || json['description'] == ''
          ? null
          : json['description'],
      isPlace: json['isPlace'],
      placeId: json['placeId'],
      hasUnreadMessages: json['hasUnreadMessages'],
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
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
      'placeId': placeId,
      'hasUnreadMessages': hasUnreadMessages,
      'lastMessageAt': lastMessageAt.toIso8601String(),
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
      placeId: placeId,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
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
