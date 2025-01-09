import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/state/transactions_with_user/transactions_with_user.dart';

List<Transaction> reverseChronologicalOrder(TransactionsWithUserState state) {
  final sendingQueue = List<Transaction>.from(state.sendingQueue);
  final transactions = List<Transaction>.from(state.transactions);

  final mergedTransactions = [...sendingQueue, ...transactions];
  mergedTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return mergedTransactions;
}