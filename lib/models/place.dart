import 'package:collection/collection.dart';

enum Display {
  amount,
  menu,
  amountAndMenu,
  topup,
}

class Place {
  int id;
  String name;
  String account;
  String slug;
  String? imageUrl;
  String? description;
  Display display;

  Place({
    required this.id,
    required this.name,
    required this.account,
    this.slug = '',
    this.imageUrl,
    this.description,
    this.display = Display.amount,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    final accounts = json['accounts'] as List<dynamic>?;
    final account = accounts?.first ?? json['account'] ?? '';

    return Place(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      account: account,
      imageUrl: json['image'] == '' ? null : json['image'],
      description: json['description'] != null && json['description'] != ''
          ? json['description']
          : null,
      display:
          Display.values.firstWhereOrNull((e) => e.name == json['display']) ??
              Display.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'account': account,
      'image': imageUrl,
      'description': description,
      'display': display.name,
    };
  }

  @override
  String toString() {
    return 'Place(name: $name, account: $account, slug: $slug, display: $display, imageUrl: $imageUrl, description: $description)';
  }
}
