import 'package:pay_app/models/menu_item.dart';

class PlaceMenu {
  final List<MenuItem> menuItems;

  const PlaceMenu({
    required this.menuItems,
  });

  factory PlaceMenu.fromJson(Map<String, dynamic> json) {
    return PlaceMenu(
      menuItems:
          (json['menuItems'] as List).map((i) => MenuItem.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuItems': menuItems.map((i) => i.toMap()).toList(),
    };
  }

  Map<int, MenuItem> get menuItemsById => menuItems.fold<Map<int, MenuItem>>(
      {},
      (map, item) => {
            ...map,
            item.id: item,
          });

  List<String> get categories =>
      menuItems.map((i) => i.category).toSet().toList();

  List<MenuItem> getItemsByCategory(String category) {
    return menuItems.where((i) => i.category == category).toList();
  }
}
