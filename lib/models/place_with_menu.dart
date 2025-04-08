import 'package:pay_app/models/place.dart';
import 'package:pay_app/models/user.dart';
import 'package:pay_app/models/menu_item.dart';

class PlaceWithMenu {
  final Place place;
  final User? profile;
  final List<MenuItem> items;
  final Map<int, MenuItem> mappedItems;

  PlaceWithMenu({
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

    final profile = profileData != null ? User.fromJson(profileData) : null;

    // Parse items data
    final itemsData = json['items'] as List<dynamic>;
    final items = itemsData.map((itemJson) {
      // Adjust item data to match MenuItem model expectations
      return MenuItem.fromJson(itemJson);
    }).toList();

    return PlaceWithMenu(
      place: place,
      profile: profile,
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'place': place.toMap(),
      'profile': profile?.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'PlaceWithMenu(place: $place, profile: $profile, items: $items)';
  }
}
