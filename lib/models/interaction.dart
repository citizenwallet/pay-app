class Interaction {
  final String imageUrl;
  final String name;

  // last interaction
  final double? amount; 
  final String? description;

  final bool isPlace;
  final int? placeId; // id from supabase
  final String? location; // geo address of place

  final int? userId; // id from supabase

  final bool hasUnreadMessages;
  final DateTime? lastMessageAt;

  const Interaction({
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
}
