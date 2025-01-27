import 'package:pay_app/models/place.dart';
import 'package:pay_app/models/user.dart';
import 'package:pay_app/models/menu_item.dart';

class PlaceWithMenu {
  final Place place;
  final User profile;
  final List<MenuItem> items;

  const PlaceWithMenu({
    required this.place,
    required this.profile,
    required this.items,
  });

  factory PlaceWithMenu.fromJson(Map<String, dynamic> json) {
    // Parse place data
    final placeData = json['place'] as Map<String, dynamic>;
    final place = Place.fromJson(placeData);

    // Parse profile data
    final profileData = json['profile'] as Map<String, dynamic>;

    final profile = User.fromJson(profileData);

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
      'profile': profile.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'PlaceWithMenu(place: $place, profile: $profile, items: $items)';
  }
}
