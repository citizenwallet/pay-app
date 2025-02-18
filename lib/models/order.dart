import 'package:collection/collection.dart';
import 'package:web3dart/web3dart.dart' show EthereumAddress;

enum PaymentMode {
  terminal,
  qrCode,
  app,
}

enum OrderStatus {
  pending,
  paid,
  cancelled,
}

enum OrderType {
  web,
  app,
  terminal,
}

class Order {
  final int id;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double total;
  final double due;
  final int placeId;
  final List<OrderItem> items;
  final OrderStatus status;
  final String? description;
  final String? txHash;
  final OrderType? type;
  final EthereumAddress? account;
  final double fees;

  Order({
    required this.id,
    required this.createdAt,
    this.completedAt,
    required this.total,
    required this.due,
    required this.placeId,
    required this.items,
    required this.status,
    required this.description,
    this.txHash,
    this.type,
    this.account,
    this.fees = 0,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      total: json['total'].toDouble() / 100,
      due: json['due'].toDouble() / 100,
      placeId: json['place_id'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      status: _parseOrderStatus(json['status']),
      description: json['description'],
      txHash: json['tx_hash'],
      type: _parseOrderType(json['type']),
      account: json['account'] != null
          ? EthereumAddress.fromHex(json['account'])
          : null,
      fees: (json['fees'] ?? 0).toDouble() / 100,
    );
  }

  static OrderStatus _parseOrderStatus(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.pending,
    );
  }

  static OrderType? _parseOrderType(String? type) {
    if (type == null) return null;
    return OrderType.values.firstWhereOrNull(
      (e) => e.name == type,
    );
  }
}

class OrderItem {
  final int id;
  final int quantity;

  OrderItem({
    required this.id,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      quantity: json['quantity'],
    );
  }
}
