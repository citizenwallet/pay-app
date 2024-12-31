import 'package:pay_app/models/menu_item.dart';

class CheckoutItem {
  final MenuItem menuItem;
  final int quantity;

  const CheckoutItem({
    required this.menuItem,
    required this.quantity,
  }) : assert(quantity >= 0, 'Quantity must be non-negative');

  // vat included
  double get subtotal => menuItem.formattedPrice * quantity;

  CheckoutItem copyWith({
    MenuItem? menuItem,
    int? quantity,
    String? specialInstructions,
    List<String>? modifications,
  }) {
    return CheckoutItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuItem': menuItem.toMap(),
      'quantity': quantity,
    };
  }

  factory CheckoutItem.fromMap(Map<String, dynamic> map) {
    return CheckoutItem(
      menuItem: MenuItem.fromJson(map['menuItem']),
      quantity: map['quantity'],
    );
  }
}
