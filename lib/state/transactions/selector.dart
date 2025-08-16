import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/state/transactions/transactions.dart';

class TransactionsSelector {
  static List<Transaction> getTransactions(TransactionsState state) {
    return state.transactions;
  }

  static List<Transaction> getNewTransactions(TransactionsState state) {
    return state.newTransactions;
  }

  static bool isLoading(TransactionsState state) {
    return state.loading;
  }

  static bool hasError(TransactionsState state) {
    return state.error;
  }

  static bool isLoadingMore(TransactionsState state) {
    return state.loadingMore;
  }

  static bool hasMoreTransactions(TransactionsState state) {
    return state.hasMoreTransactions;
  }

  static List<Transaction> getSentTransactions(TransactionsState state) {
    return state.transactions
        .where((tx) =>
            tx.exchangeDirection(state.accountAddress) ==
            ExchangeDirection.sent)
        .toList();
  }

  static List<Transaction> getReceivedTransactions(TransactionsState state) {
    return state.transactions
        .where((tx) =>
            tx.exchangeDirection(state.accountAddress) ==
            ExchangeDirection.received)
        .toList();
  }

  static List<Transaction> getTransactionsByStatus(
    TransactionsState state,
    TransactionStatus status,
  ) {
    return state.transactions.where((tx) => tx.status == status).toList();
  }

  static List<Transaction> getTransactionsByContract(
    TransactionsState state,
    String contract,
  ) {
    return state.transactions.where((tx) => tx.contract == contract).toList();
  }

  static double getTotalAmount(TransactionsState state) {
    return state.transactions.fold(0.0, (sum, tx) {
      final amount = double.tryParse(tx.amount) ?? 0.0;
      return sum + amount;
    });
  }

  static double getTotalSentAmount(TransactionsState state) {
    return getSentTransactions(state).fold(0.0, (sum, tx) {
      final amount = double.tryParse(tx.amount) ?? 0.0;
      return sum + amount;
    });
  }

  static double getTotalReceivedAmount(TransactionsState state) {
    return getReceivedTransactions(state).fold(0.0, (sum, tx) {
      final amount = double.tryParse(tx.amount) ?? 0.0;
      return sum + amount;
    });
  }
}
