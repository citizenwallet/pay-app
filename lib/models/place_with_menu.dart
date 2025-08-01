import 'dart:convert';

import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/models/place.dart';
import 'package:pay_app/models/menu_item.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';

class PlaceWithMenu {
  final int placeId;
  final String slug;
  final Place place;
  final ProfileV1 profile;
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
    final placeData = (json['place'] ?? json) as Map<String, dynamic>;
    final place = Place.fromJson(placeData);

    // Parse profile data
    final profileData = json['profile'] as Map<String, dynamic>?;

    final profile = profileData != null
        ? ProfileV1.fromJson(profileData)
        : ProfileV1(
            account: place.account,
            name: place.name,
            username: place.slug,
            imageSmall: place.imageUrl ?? '',
            imageMedium: place.imageUrl ?? '',
            image: place.imageUrl ?? '',
            description: place.description ?? '',
          );

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

  factory PlaceWithMenu.fromInteraction(Interaction interaction) {
    return interaction.place!;
  }

  factory PlaceWithMenu.fromMap(Map<String, dynamic> json) {
    final place = Place.fromJson(jsonDecode(json['place']));

    final profile = json['profile'] != null
        ? ProfileV1.fromJson(jsonDecode(json['profile']))
        : ProfileV1(
            account: place.account,
            name: place.name,
            username: place.slug,
            imageSmall: place.imageUrl ?? '',
            imageMedium: place.imageUrl ?? '',
            image: place.imageUrl ?? '',
            description: place.description ?? '',
          );

    final items = jsonDecode(json['items'] ?? '[]') as List<dynamic>;
    return PlaceWithMenu(
      placeId: json['place_id'],
      slug: json['slug'],
      place: place,
      profile: profile,
      items: items.map((item) => MenuItem.fromMap(item)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'place_id': placeId,
      'slug': slug,
      'place': jsonEncode(place.toMap()),
      'profile': jsonEncode(profile.toJson()),
      'items': jsonEncode(items.map((item) => item.toMap()).toList()),
    };
  }

  @override
  String toString() {
    return 'PlaceWithMenu(place: $place, profile: $profile, items: $items)';
  }
}
