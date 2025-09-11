import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/services/api/api.dart';

class TransactionsService {
  final APIService apiService =
      APIService(baseURL: dotenv.env['CHECKOUT_API_BASE_URL'] ?? '');
  String account;

  TransactionsService({required this.account});

  Future<(List<Transaction>, int)> getTransactions({
    int limit = 10,
    int offset = 0,
    String? contract,
  }) async {
    try {
      String url =
          '/app/transactions?account=$account&limit=$limit&offset=$offset';
      if (contract != null) {
        url += '&contract=$contract';
      }

      final response = await apiService.get(
        url: url,
      );

      final Map<String, dynamic> data = response;
      final List<dynamic> transactionsApiResponse = data['transactions'];
      final int count = data['total'];

      return (
        transactionsApiResponse.map((t) => Transaction.fromJson(t)).toList(),
        count
      );
    } catch (e, s) {
      debugPrint('Failed to fetch transactions: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to fetch transactions');
    }
  }

  Future<List<Transaction>> getNewTransactions(
    DateTime fromDate, {
    String? contract,
  }) async {
    try {
      String url =
          '/app/transactions/new?account=$account&from_date=${fromDate.toUtc()}';
      if (contract != null) {
        url += '&contract=$contract';
      }

      final response = await apiService.get(
        url: url,
      );

      final Map<String, dynamic> data = response;
      final List<dynamic> transactionsApiResponse = data['transactions'];

      return transactionsApiResponse
          .map((t) => Transaction.fromJson(t))
          .toList();
    } catch (e, s) {
      debugPrint('Failed to fetch transactions: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to fetch transactions');
    }
  }
}
