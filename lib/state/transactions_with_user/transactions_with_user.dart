import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/models/user.dart';
import 'package:pay_app/services/profile/profile.dart';
import 'package:pay_app/services/transactions/transactions_with_user.dart';

class TransactionsWithUserState with ChangeNotifier {
  User withUser;
  String myAddress;
  List<Transaction> transactions = [];
   Timer? _pollingTimer;

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
    stopPolling();
    super.dispose();
  }

    void startPolling() {
    // Cancel any existing timer first
    stopPolling();

    transactionsFromDate = DateTime.now();

    // Create new timer
    _pollingTimer = Timer.periodic(
      const Duration(milliseconds: pollingInterval),
      (_) => _pollTransactions(),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('stopPolling');
  }

   static const pollingInterval = 3000; // ms
  DateTime transactionsFromDate = DateTime.now();
  Future<void> _pollTransactions() async {
    try {
      debugPrint('polling transactions');
      final newTransactions =
          await transactionsWithUserService.getNewTransactionsWithUser(transactionsFromDate);

      if (newTransactions.isNotEmpty) {
        final upsertedTransactions = _upsertTransactions(newTransactions);
        transactions = upsertedTransactions;
        transactionsFromDate = DateTime.now();
        safeNotifyListeners();
      }
    } catch (e, s) {
      debugPrint('Error polling transactions: $e');
      debugPrint('Stack trace: $s');
    }
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
