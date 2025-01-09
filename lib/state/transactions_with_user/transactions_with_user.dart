import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/models/user.dart';
import 'package:pay_app/services/engine/utils.dart';
import 'package:pay_app/services/profile/profile.dart';
import 'package:pay_app/services/transactions/transactions_with_user.dart';
import 'package:pay_app/services/wallet/contracts/erc20.dart';
import 'package:pay_app/services/wallet/utils.dart';
import 'package:pay_app/services/wallet/wallet.dart';

class TransactionsWithUserState with ChangeNotifier {
  User withUser;
  String myAddress;
  List<Transaction> transactions = [];
  Timer? _pollingTimer;

  double toSendAmount = 0.0;
  String toSendMessage = '';

  ProfileService myProfileService;
  ProfileService withUserProfileService;
  TransactionsService transactionsWithUserService;

  final WalletService _walletService = WalletService();

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

  void updateAmount(double amount) {
    toSendAmount = amount;
    safeNotifyListeners();
  }

  void updateMessage(String message) {
    toSendMessage = message;
    safeNotifyListeners();
  }

  Future<String?> sendTransaction() async {
    try {
      final doubleAmount = toSendAmount.toString().replaceAll(',', '.');
      final parsedAmount = toUnit(
        doubleAmount,
        decimals: _walletService.currency.decimals,
      );

      if (parsedAmount == BigInt.zero) {
        return null;
      }

      final toAddress = withUser.account;
      final fromAddress = myAddress;

      final calldata =
          _walletService.tokenTransferCallData(toAddress, parsedAmount);

      final (_, userOp) = await _walletService.prepareUserop(
        [_walletService.tokenAddress],
        [calldata],
      );

      final args = {
        'from': fromAddress,
        'to': toAddress,
      };

      if (_walletService.standard == 'erc1155') {
        args['operator'] = _walletService.account.hexEip55;
        args['id'] = '0';
        args['amount'] = parsedAmount.toString();
      } else {
        args['value'] = parsedAmount.toString();
      }

      final eventData = createEventData(
        stringSignature: _walletService.transferEventStringSignature,
        topic: _walletService.transferEventSignature,
        args: args,
      );

      final txHash = await _walletService.submitUserop(userOp,
          data: eventData,
          extraData:
              toSendMessage != '' ? TransferData(toSendMessage.trim()) : null);

      if (txHash != null) {
        final newTransaction = Transaction(
          id: txHash,
          txHash: txHash,
          createdAt: DateTime.now(),
          fromAccount: myAddress,
          toAccount: toAddress,
          amount: double.parse(fromUnit(parsedAmount,
              decimals: _walletService.currency.decimals)),
          exchangeDirection: ExchangeDirection.sent,
          status: TransactionStatus.success,
          description: toSendMessage.trim(),
        );

        final upsertedTransactions = _upsertTransactions([newTransaction]);
        transactions = upsertedTransactions;
        safeNotifyListeners();
      }

      debugPrint('txHash: $txHash');
      return txHash;
    } catch (e, s) {
      debugPrint('Error sending transaction: $e');
      debugPrint('Stack trace: $s');
      return null;
    } finally {
      toSendAmount = 0.0;
      toSendMessage = '';
      safeNotifyListeners();
    }
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
      final newTransactions = await transactionsWithUserService
          .getNewTransactionsWithUser(transactionsFromDate);

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
    final existingMap = {for (var i in existingList) i.txHash: i};

    for (final newTransaction in newTransactions) {
      if (existingMap.containsKey(newTransaction.txHash)) {
        // Update existing transaction
        existingMap[newTransaction.txHash] = newTransaction;
      } else {
        // Add new interaction
        existingMap[newTransaction.txHash] = newTransaction;
      }
    }

    return existingMap.values.toList();
  }
}
