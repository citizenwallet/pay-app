import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:pay_app/models/menu_item.dart';
import 'package:pay_app/models/place.dart';
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
  refunded,
  refund_pending,
  refund,
  correction
}

enum OrderType {
  web,
  app,
  terminal,
  pos,
}

class OrderPlace {
  final String slug;
  final Display display;
  final String account;
  final List<MenuItem> items;

  OrderPlace({
    required this.slug,
    required this.display,
    required this.account,
    required this.items,
  });

  factory OrderPlace.fromJson(Map<String, dynamic> json) {
    final accounts = json['accounts'] as List<dynamic>;
    final account = accounts.first;

    return OrderPlace(
      slug: json['slug'],
      display:
          Display.values.firstWhereOrNull((e) => e.name == json['display']) ??
              Display.amount,
      account: account,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => MenuItem.fromJson(item))
              .toList()
          : [],
    );
  }

  factory OrderPlace.fromMap(Map<String, dynamic> json) {
    final accounts = (json['accounts'] ?? []) as List<dynamic>;
    final account = accounts.first;

    return OrderPlace(
      slug: json['slug'],
      display:
          Display.values.firstWhereOrNull((e) => e.name == json['display']) ??
              Display.amount,
      account: account,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => MenuItem.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slug': slug,
      'display': display.name,
      'accounts': [account],
    };
  }
}

class Order {
  final int id;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double total;
  final double due;
  final String slug;
  final int placeId;
  final List<OrderItem> items;
  final OrderStatus status;
  final String? description;
  final String? txHash;
  final OrderType? type;
  final EthereumAddress? account;
  final double fees;
  final OrderPlace place;
  final String token;

  Order({
    required this.id,
    required this.createdAt,
    this.completedAt,
    required this.total,
    required this.due,
    required this.slug,
    required this.placeId,
    required this.items,
    required this.status,
    required this.description,
    this.txHash,
    this.type,
    this.account,
    this.fees = 0,
    required this.place,
    required this.token,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final place = OrderPlace.fromJson(json['place']);
    return Order(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      total: json['total'].toDouble() / 100,
      due: json['due'].toDouble() / 100,
      slug: place.slug,
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
      place: place,
      token: json['token'],
    );
  }

  factory Order.fromMap(Map<String, dynamic> json) {
    final place = OrderPlace.fromMap(jsonDecode(json['place'] ?? '{}'));
    return Order(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      total: json['total'].toDouble() / 100,
      due: json['due'].toDouble() / 100,
      slug: place.slug,
      placeId: json['place_id'],
      items: (jsonDecode(json['items'] ?? '[]') as List)
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
      place: place,
      token: json['token'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'total': (total * 100).toInt(),
      'due': (due * 100).toInt(),
      'slug': slug,
      'place_id': placeId,
      'items': jsonEncode(items.map((item) => item.toMap()).toList()),
      'status': status.name,
      'description': description,
      'tx_hash': txHash,
      'type': type?.name,
      'account': account?.hexEip55,
      'fees': (fees * 100).toInt(),
      'place': jsonEncode(place.toMap()),
      'token': token,
    };
  }

  bool get isFinalized =>
      status == OrderStatus.paid ||
      status == OrderStatus.refunded ||
      status == OrderStatus.correction;

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quantity': quantity,
    };
  }
}
