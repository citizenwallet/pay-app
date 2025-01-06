// TODO: different model for Places listing in home screen

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

  final bool hasUnreadMessages;
  final DateTime lastMessageAt;

  const Interaction({
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
      exchangeDirection: _parseExchangeDirection(json['exchange_direction']),
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

  @override
  String toString() {
    return 'Interaction(id: $id, exchangeDirection: $exchangeDirection, withAccount: $withAccount, imageUrl: $imageUrl, name: $name, amount: $amount, description: $description, isPlace: $isPlace, placeId: $placeId, hasUnreadMessages: $hasUnreadMessages, lastMessageAt: $lastMessageAt)';
  }

  static ExchangeDirection _parseExchangeDirection(String direction) {
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
