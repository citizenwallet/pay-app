import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/models/checkout.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/services/api/api.dart';
import 'package:pay_app/services/sigauth/sigauth.dart';

class OrdersService {
  final APIService apiService =
      APIService(baseURL: dotenv.env['CHECKOUT_API_BASE_URL'] ?? '');
  final String account;

  OrdersService({required this.account});

  Future<(List<Order> orders, int total)> getOrders({
    int? limit,
    int? offset,
    int? placeId,
    String? slug,
    String? tokenAddress,
  }) async {
    try {
      final queryParams = {
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
        if (placeId != null) 'placeId': placeId.toString(),
        if (slug != null) 'slug': slug,
        if (tokenAddress != null) 'token': tokenAddress,
      };

      String url = '/accounts/$account/orders';
      if (queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams).query}';
      }

      final response = await apiService.get(
        url: url,
      );

      final List<Order> orders = (response['orders'] as List)
          .map((order) => Order.fromJson(order))
          .toList();

      return (
        orders,
        response['total'] as int,
      );
    } catch (e, s) {
      debugPrint('Failed to fetch orders: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to fetch orders');
    }
  }

  Future<Order> getOrder(String slug, int orderId) async {
    try {
      final response = await apiService.get(
        url: '/app/places/$slug/orders/$orderId',
      );

      return Order.fromJson(response);
    } catch (e, s) {
      debugPrint('Failed to fetch order: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to fetch order');
    }
  }

  Future<Order> getOrdersByTxHash(String txHash) async {
    try {
      final response = await apiService.get(
        url: '/app/orders?txHash=$txHash',
      );

      final orders = (response['orders'] as List);

      if (orders.isEmpty) {
        throw Exception('No orders found');
      }

      return Order.fromJson(orders.first);
    } catch (e, s) {
      debugPrint('Failed to fetch order: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to fetch order');
    }
  }

  Future<Order?> createOrder(
    SigAuthConnection connection,
    int placeId,
    Checkout checkout,
    String txHash,
  ) async {
    try {
      final body = {
        'txHash': txHash,
        'items': checkout.items.map((item) => item.toListMap()).toList(),
        'total': checkout.decimalTotal,
        'description': checkout.message,
        'account': account,
      };

      final response = await apiService.post(
        url: '/app/places/$placeId/orders',
        body: body,
        headers: connection.toMap(),
      );

      final order = Order.fromJson(response);

      return order;
    } catch (e, s) {
      debugPrint('Failed to create order: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to create order');
    }
  }

  Future<Order?> confirmOrder(
    SigAuthConnection connection,
    int placeId,
    int orderId,
    String txHash,
  ) async {
    try {
      final body = {
        'account': account,
        'txHash': txHash,
      };

      final response = await apiService.patch(
        url: '/app/places/$placeId/orders/$orderId',
        body: body,
        headers: connection.toMap(),
      );

      final order = Order.fromJson(response);

      return order;
    } catch (e, s) {
      debugPrint('Failed to confirm order: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to confirm order');
    }
  }

  Future<Order?> createCardOrder(
    SigAuthConnection connection,
    String serial,
    int placeId,
    Checkout checkout,
    String tokenAddress,
  ) async {
    try {
      final body = {
        'placeId': placeId,
        'items': checkout.items.map((item) => item.toListMap()).toList(),
        'description': checkout.message,
        'total': checkout.decimalTotal,
        'token': tokenAddress,
      };

      final response = await apiService.post(
        url: '/app/cards/$serial/orders',
        body: body,
        headers: connection.toMap(),
      );

      final order = Order.fromJson(response);

      return order;
    } catch (e, s) {
      debugPrint('Failed to create order: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to create order');
    }
  }

  Future<Order?> confirmCardOrder(
    SigAuthConnection connection,
    String serial,
    int orderId,
  ) async {
    try {
      final body = {};

      final response = await apiService.patch(
        url: '/app/cards/$serial/orders/$orderId',
        body: body,
        headers: connection.toMap(),
      );

      final order = Order.fromJson(response);

      return order;
    } catch (e, s) {
      debugPrint('Failed to confirm card order: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to confirm card order');
    }
  }
}
