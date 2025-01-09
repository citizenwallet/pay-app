class Place {
  int id;
  String name;
  String account;
  String slug;
  bool hasMenu;
  String? imageUrl;
  String? description;

  Place({
    required this.id,
    required this.name,
    required this.account,
    this.hasMenu = false,
    this.slug = '',
    this.imageUrl,
    this.description,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      account: json['account'],
      hasMenu: json['hasMenu'] ?? false,
      imageUrl: json['imageUrl'] == '' ? null : json['imageUrl'],
      description: json['description'] == '' ? null : json['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'account': account,
      'hasMenu': hasMenu,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Place(name: $name, account: $account, slug: $slug, hasMenu: $hasMenu, imageUrl: $imageUrl, description: $description)';
  }
}
