// TODO: different model for Places listing in home screen

enum ExchangeDirection {
  sent,
  received,
}

class Interaction {
  final String id;
  final ExchangeDirection exchangeDirection;

  final String withAccount;
  final String? imageUrl;
  final String name;

  // last interaction
  final double? amount; 
  final String? description;

  final bool isPlace;
  final int? placeId; // id from supabase
  final String? location; // geo address of place

  final int? userId; // id from supabase

  final bool hasUnreadMessages;
  final DateTime? lastMessageAt; // FIXME: remove null

  const Interaction({
    required this.id, 
    required this.exchangeDirection,  
    required this.withAccount,
    required this.imageUrl,
    required this.name,
    this.userId,
    this.isPlace = false,
    this.hasUnreadMessages = false,
    this.location,
    this.lastMessageAt,
    this.description,
    this.placeId,
    this.amount,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      id: json['id'],
      exchangeDirection: _parseExchangeDirection(json['direction']),
      withAccount: json['withAccount'],
      imageUrl: json['imageUrl'],
      name: json['name'],
      amount: json['amount'],
      description: json['description'],
      isPlace: json['isPlace'],
      placeId: json['placeId'],
      location: json['location'],
      userId: json['userId'],
      hasUnreadMessages: json['hasUnreadMessages'],
      lastMessageAt: json['lastMessageAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'direction': exchangeDirection,
      'withAccount': withAccount,
      'name': name,
      'imageUrl': imageUrl,
      'amount': amount,
      'description': description,
      'isPlace': isPlace,
      'placeId': placeId,
      'location': location,
      'userId': userId,
      'hasUnreadMessages': hasUnreadMessages,
      'lastMessageAt': lastMessageAt,
    };
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
