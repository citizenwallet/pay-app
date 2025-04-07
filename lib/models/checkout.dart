import 'package:pay_app/models/checkout_item.dart';
import 'package:pay_app/models/menu_item.dart';

class Checkout {
  final List<CheckoutItem> items;
  final double? manualAmount;
  final String? message;

  const Checkout({
    required this.items,
    this.manualAmount,
    this.message,
  });

  double get total =>
      manualAmount ?? items.fold(0, (sum, item) => sum + item.subtotal);

  double get decimalTotal => total * 100;

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

  int quantityOfMenuItem(
    MenuItem menuItem,
  ) {
    try {
      return items
          .firstWhere(
            (item) => item.menuItem.id == menuItem.id,
          )
          .quantity;
    } catch (e) {
      return 0; // Return 0 if item not found
    }
  }

  Checkout copyWith({
    List<CheckoutItem>? items,
  }) {
    return Checkout(
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
    };
  }

  factory Checkout.fromMap(Map<String, dynamic> map) {
    return Checkout(
      items: List<CheckoutItem>.from(
        map['items']?.map((item) => CheckoutItem.fromMap(item)),
      ),
    );
  }

  Checkout addItem(
    MenuItem menuItem, {
    int quantity = 1,
  }) {
    final existingItemIndex =
        items.indexWhere((item) => item.menuItem.id == menuItem.id);

    if (existingItemIndex != -1) {
      // Item exists, increase quantity
      return _updateItemQuantity(
        existingItemIndex,
        items[existingItemIndex].quantity + quantity,
      );
    } else {
      // New item, add to list
      return copyWith(
        items: [
          ...items,
          CheckoutItem(
            menuItem: menuItem,
            quantity: quantity,
          ),
        ],
      );
    }
  }

  Checkout decreaseItem(MenuItem menuItem) {
    final index = items.indexWhere((item) => item.menuItem.id == menuItem.id);
    if (index < 0 || index >= items.length) return this;

    final item = items[index];
    if (item.quantity <= 1) {
      // Remove item if quantity would become 0
      return removeItem(menuItem);
    }

    return _updateItemQuantity(index, item.quantity - 1);
  }

  Checkout increaseItem(MenuItem menuItem) {
    final index = items.indexWhere((item) => item.menuItem.id == menuItem.id);
    if (index < 0 || index >= items.length) return this;

    final item = items[index];
    return _updateItemQuantity(index, item.quantity + 1);
  }

  Checkout removeItem(MenuItem menuItem) {
    final index = items.indexWhere((item) => item.menuItem.id == menuItem.id);
    if (index < 0 || index >= items.length) return this;

    return copyWith(
      items: [
        ...items.sublist(0, index),
        ...items.sublist(index + 1),
      ],
    );
  }

  Checkout _updateItemQuantity(int index, int newQuantity) {
    if (index < 0 || index >= items.length || newQuantity < 0) return this;

    return copyWith(
      items: [
        ...items.sublist(0, index),
        items[index].copyWith(quantity: newQuantity),
        ...items.sublist(index + 1),
      ],
    );
  }

  // Helper method to compare modifications lists
  // ignore: unused_element
  bool _areModificationsEqual(List<String>? list1, List<String>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;

    final sorted1 = [...list1]..sort();
    final sorted2 = [...list2]..sort();
    for (var i = 0; i < sorted1.length; i++) {
      if (sorted1[i] != sorted2[i]) return false;
    }
    return true;
  }
}
