import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/models/user.dart';
import 'package:pay_app/services/engine/utils.dart';
import 'package:pay_app/services/pay/profile.dart';
import 'package:pay_app/services/pay/transactions_with_user.dart';
import 'package:pay_app/services/wallet/contracts/erc20.dart';
import 'package:pay_app/services/wallet/utils.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/utils/random.dart';

class TransactionsWithUserState with ChangeNotifier {
  String withUserAddress;
  User? withUser;
  String myAddress;

  List<Transaction> transactions = [];
  List<Transaction> newTransactions = [];
  List<Transaction> sendingQueue = [];

  Timer? _pollingTimer;

  double toSendAmount = 0.0;
  String toSendMessage = '';

  ProfileService myProfileService;
  ProfileService withUserProfileService;
  TransactionsService transactionsWithUserService;

  final WalletService _walletService = WalletService();

  bool loading = false;
  bool error = false;

  TransactionsWithUserState({
    required this.withUserAddress,
    required this.myAddress,
  })  : myProfileService = ProfileService(account: myAddress),
        withUserProfileService = ProfileService(account: withUserAddress),
        transactionsWithUserService = TransactionsService(
            firstAccount: myAddress, secondAccount: withUserAddress);

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

      final toAddress = withUserAddress;
      final fromAddress = myAddress;

      final tempId = '${pendingTransactionId}_${generateRandomId()}';
      final sendingTransaction = Transaction(
        id: tempId,
        txHash: '',
        createdAt: DateTime.now(),
        fromAccount: myAddress,
        toAccount: toAddress,
        amount: parsedAmount /
            BigInt.from(pow(10, _walletService.currency.decimals)),
        exchangeDirection: ExchangeDirection.sent,
        status: TransactionStatus.sending,
        description: toSendMessage.trim(),
      );
      sendingQueue.add(sendingTransaction);
      safeNotifyListeners();

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

      if (txHash == null) return null;

      final index = sendingQueue.indexWhere((tx) => tx.id == tempId);

      if (index != -1) {
        sendingQueue[index] = sendingQueue[index].copyWith(
          txHash: txHash,
          status: TransactionStatus.success,
        );

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

  void startPolling({Future<void> Function()? updateBalance}) {
    // Cancel any existing timer first
    stopPolling();

    transactionsFromDate = DateTime.now();

    // Create new timer
    _pollingTimer = Timer.periodic(
      const Duration(milliseconds: pollingInterval),
      (_) => _pollTransactions(updateBalance: updateBalance),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('stopPolling');
  }

  static const pollingInterval = 3000; // ms
  DateTime transactionsFromDate = DateTime.now();
  Future<void> _pollTransactions(
      {Future<void> Function()? updateBalance}) async {
    try {
      debugPrint('polling transactions');
      final newTransactions = await transactionsWithUserService
          .getNewTransactionsWithUser(transactionsFromDate);

      if (newTransactions.isNotEmpty) {
        _upsertNewTransactions(newTransactions);

        safeNotifyListeners();
        updateBalance?.call();
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
      debugPrint('profile: $profile');
      withUser = profile;
      safeNotifyListeners();
    } catch (e, s) {
      debugPrint('Error getting profile of with user: $e');
      debugPrint('Stack trace: $s');
      error = true;
      safeNotifyListeners();
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }

  Future<void> getTransactionsWithUser() async {
    debugPrint('get transactions');
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      final transactions =
          await transactionsWithUserService.getTransactionsWithUser();

      if (transactions.isNotEmpty) {
        _upsertTransactions(transactions);
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

  void _upsertTransactions(List<Transaction> newTransactions) {
    final existingList = [...transactions];

    for (final newTransaction in newTransactions) {
      sendingQueue.removeWhere((element) =>
          element.id == newTransaction.id ||
          element.txHash == newTransaction.txHash);

      final index =
          existingList.indexWhere((element) => element.id == newTransaction.id);

      if (index != -1) {
        existingList[index] = newTransaction;
      } else {
        existingList.add(newTransaction);
      }
    }

    transactions = [...existingList];
  }

  void _upsertNewTransactions(List<Transaction> newTransactions) {
    final existingList = [...this.newTransactions];

    for (final newTransaction in newTransactions) {
      sendingQueue.removeWhere((element) =>
          element.id == newTransaction.id ||
          element.txHash == newTransaction.txHash);

      final index =
          existingList.indexWhere((element) => element.id == newTransaction.id);

      if (index != -1) {
        existingList[index] = newTransaction;
      } else {
        existingList.insert(0, newTransaction);
      }
    }

    this.newTransactions = [...existingList];
  }
}
