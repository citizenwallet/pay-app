import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/services/api/api.dart';

class OrdersService {
  final APIService apiService =
      APIService(baseURL: dotenv.env['CHECKOUT_API_BASE_URL'] ?? '');
  final String account;

  OrdersService({required this.account});

  Future<({List<Order> orders, int total})> getOrders({
    int? limit,
    int? offset,
    int? placeId,
  }) async {
    try {
      final queryParams = {
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
        if (placeId != null) 'placeId': placeId.toString(),
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
        orders: orders,
        total: response['total'] as int,
      );
    } catch (e, s) {
      debugPrint('Failed to fetch orders: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to fetch orders');
    }
  }

  Future<Order> getOrder(int orderId) async {
    try {
      final response = await apiService.get(
        url: '/accounts/$account/orders/$orderId',
      );

      return Order.fromJson(response);
    } catch (e, s) {
      debugPrint('Failed to fetch order: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to fetch order');
    }
  }
}
