import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/services/api/api.dart';

class TransactionsService {
  final APIService apiService =
      APIService(baseURL: dotenv.env['CHECKOUT_API_BASE_URL'] ?? '');
  String firstAccount;
  String secondAccount;

  TransactionsService({required this.firstAccount, required this.secondAccount});

  Future<List<Transaction>> getTransactionsWithUser() async {
    try {

      final response = await apiService.get(url: '/accounts/$firstAccount/transactions/with-account/$secondAccount');

      final Map<String, dynamic> data = response;
      final List<dynamic> transactionsApiResponse = data['transactions'];

      /* Example API Response:
       * {
       *   "transactions": [
       *     {
       *       "id": "0x19b2c1d04fc95dd56879dc5e37673496de5bab78ef38a07eb97b9fe2ded37edf",
       *       "hash": "0x0aeafa881dcddf19e61666dc66f32ae190d7a7b549c9cdfcbd1abe2a602b6610", 
       *       "created_at": "2025-01-08T19:31:15+00:00",
       *       "updated_at": "2025-01-08T19:31:17.570023+00:00",
       *       "from": "0x20eC5EAF89C0e06243eE39674844BF77edB43fCc",
       *       "to": "0x48262e7f759d3c2BE5f67f81cF5911A777cF83F1",
       *       "value": "0.1",
       *       "description": "",
       *       "status": "success",
       *       "exchange_direction": "received"
       *     }
       *   ]
       * }
       */

      // Transform the API response into the format expected by Transaction.fromJson
      final List<Map<String, dynamic>> transformedTransactions = transactionsApiResponse.map((t) {
        return {
          'id': t['id'],
          'txHash': t['hash'],
          'createdAt': t['created_at'],
          'fromAccount': t['from'],
          'toAccount': t['to'],
          'amount': double.tryParse(t['value']),
          'description': t['description'],
          'status': t['status'],
          'exchangeDirection': t['exchange_direction'],
        };
      }).toList();

      return transformedTransactions
          .map((t) => Transaction.fromJson(t))
          .toList();
    } catch (e, s) {
      debugPrint('Failed to fetch transactions: $e');
      debugPrint('Stack trace: $s');
      throw Exception('Failed to fetch transactions');
    }
  }
}
