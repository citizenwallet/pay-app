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
    final accounts = json['accounts'] as List<dynamic>;
    final account = accounts.first;

    return Place(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      account: account,
      imageUrl: json['image'] == '' ? null : json['image'],
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
      'image': imageUrl,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Place(name: $name, account: $account, slug: $slug, hasMenu: $hasMenu, imageUrl: $imageUrl, description: $description)';
  }
}
