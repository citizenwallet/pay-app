class MenuItem {
  final int id;
  final int placeId;
  final String? imageUrl;
  final int price;
  final String name;
  final String? description;
  final String category;
  final int vat;
  final String? emoji;
  final double orderId;

  double get formattedPrice => price / 100;

  String get priceString => (price / 100).toStringAsFixed(2);

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

class PlaceMenu {
  final List<MenuItem> menuItems;

  const PlaceMenu({required this.menuItems});

  factory PlaceMenu.fromJson(Map<String, dynamic> json) {
    return PlaceMenu(
      menuItems: (json['menuItems'] as List).map((i) => MenuItem.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuItems': menuItems.map((i) => i.toMap()).toList(),
    };
  }

  List<String> get categories => menuItems.map((i) => i.category).toSet().toList();

  List<MenuItem> getItemsByCategory(String category) {
    return menuItems.where((i) => i.category == category).toList();
  }
}
