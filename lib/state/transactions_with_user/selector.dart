import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/state/transactions_with_user/transactions_with_user.dart';

List<Transaction> reverseChronologicalOrder(TransactionsWithUserState state) {
  return List<Transaction>.from(state.transactions)..sort((a, b) {
    return b.createdAt.compareTo(a.createdAt);
  });
}