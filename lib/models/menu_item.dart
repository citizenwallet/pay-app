class MenuItem {
  final int id;
  final int placeId;
  final String? imageUrl;
  final int price;
  final String name;
  final String? description;
  final String category;
  final int vat; // in percent
  final String? emoji;
  final double orderId;

  double get formattedPrice => price / 100 * (1 + vat / 100);

  String get priceString => (formattedPrice).toStringAsFixed(2);

  const MenuItem({
    required this.id,
    required this.placeId,
    this.imageUrl,
    required this.price,
    required this.name,
    this.description,
    required this.category,
    required this.vat,
    this.emoji,
    required this.orderId,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      placeId: json['placeId'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      vat: json['vat'],
      emoji: json['emoji'],
      orderId: (json['orderId'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'placeId': placeId,
      'imageUrl': imageUrl,
      'price': price,
      'name': name,
      'description': description,
      'category': category,
      'vat': vat,
      'emoji': emoji,
      'orderId': orderId,
    };
  }
  
}