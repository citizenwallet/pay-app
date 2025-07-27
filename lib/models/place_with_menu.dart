import 'dart:convert';

import 'package:pay_app/models/place.dart';
import 'package:pay_app/models/menu_item.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';

class PlaceWithMenu {
  final int placeId;
  final String slug;
  final Place place;
  final ProfileV1? profile;
  final List<MenuItem> items;
  final Map<int, MenuItem> mappedItems;

  PlaceWithMenu({
    required this.placeId,
    required this.slug,
    required this.place,
    required this.profile,
    required this.items,
  }) : mappedItems = {for (var item in items) item.id: item};

  factory PlaceWithMenu.fromJson(Map<String, dynamic> json) {
    // Parse place data
    final placeData = json['place'] as Map<String, dynamic>;
    final place = Place.fromJson(placeData);

    // Parse profile data
    final profileData = json['profile'] as Map<String, dynamic>?;

    final profile =
        profileData != null ? ProfileV1.fromJson(profileData) : null;

    // Parse items data
    final itemsData = json['items'] as List<dynamic>;
    final items = itemsData.map((itemJson) {
      // Adjust item data to match MenuItem model expectations
      return MenuItem.fromJson(itemJson);
    }).toList();

    return PlaceWithMenu(
      placeId: place.id,
      slug: place.slug,
      place: place,
      profile: profile,
      items: items,
    );
  }

  factory PlaceWithMenu.fromMap(Map<String, dynamic> json) {
    final items = jsonDecode(json['items'] ?? '[]') as List<dynamic>;
    return PlaceWithMenu(
      placeId: json['place_id'],
      slug: json['slug'],
      place: Place.fromJson(jsonDecode(json['place'])),
      profile: ProfileV1.fromJson(jsonDecode(json['profile'])),
      items: items.map((item) => MenuItem.fromMap(item)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'place_id': placeId,
      'slug': slug,
      'place': jsonEncode(place.toMap()),
      'profile': jsonEncode(profile?.toJson()),
      'items': jsonEncode(items.map((item) => item.toMap()).toList()),
    };
  }

  @override
  String toString() {
    return 'PlaceWithMenu(place: $place, profile: $profile, items: $items)';
  }
}
