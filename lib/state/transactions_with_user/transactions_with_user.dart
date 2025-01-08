import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/models/user.dart';
import 'package:pay_app/services/profile/profile.dart';
import 'package:pay_app/services/transactions/transactions_with_user.dart';

class TransactionsWithUserState with ChangeNotifier {
  User withUser;
  String myAddress;
  List<Transaction> transactions = [];

  ProfileService myProfileService;
  ProfileService withUserProfileService;
  TransactionsService transactionsWithUserService;

  bool loading = false;
  bool error = false;

  TransactionsWithUserState({required this.withUser, required this.myAddress})
      : myProfileService = ProfileService(account: myAddress),
        withUserProfileService = ProfileService(account: withUser.account),
        transactionsWithUserService = TransactionsService(
            firstAccount: myAddress, secondAccount: withUser.account);

  bool _mounted = true;
  void safeNotifyListeners() {
    if (_mounted) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> getProfileOfWithUser() async {
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      final profile = await withUserProfileService.getProfile();
      withUser = profile;
      safeNotifyListeners();
    } catch (e) {
      error = true;
      safeNotifyListeners();
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }

  Future<void> getTransactionsWithUser() async {
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      final transactions =
          await transactionsWithUserService.getTransactionsWithUser();

      if (transactions.isNotEmpty) {
        final upsertedTransactions = _upsertTransactions(transactions);
        this.transactions = upsertedTransactions;
        safeNotifyListeners();
      }
    } catch (e, s) {
      debugPrint('Error fetching transactions with user: $e');
      debugPrint('Stack trace: $s');
      error = true;
      safeNotifyListeners();
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }

  List<Transaction> _upsertTransactions(List<Transaction> newTransactions) {
    final existingList = transactions;
    final existingMap = {for (var i in existingList) i.id: i};

    for (final newTransaction in newTransactions) {
      if (existingMap.containsKey(newTransaction.id)) {
        // Update existing transaction
      } else {
        // Add new interaction
        existingMap[newTransaction.id] = newTransaction;
      }
    }

    return existingMap.values.toList();
  }
}
