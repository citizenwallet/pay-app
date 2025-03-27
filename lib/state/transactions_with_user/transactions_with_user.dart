import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/models/user.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/engine/utils.dart';
import 'package:pay_app/services/pay/profile.dart';
import 'package:pay_app/services/pay/transactions_with_user.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/wallet/contracts/erc20.dart';
import 'package:pay_app/services/wallet/utils.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/utils/random.dart';
import 'package:web3dart/credentials.dart';

class TransactionsWithUserState with ChangeNotifier {
  late Config _config;

  final ConfigService _configService = ConfigService();
  final SecureService _secureService = SecureService();
  late ProfileService myProfileService;
  late ProfileService withUserProfileService;
  late TransactionsService transactionsWithUserService;

  String withUserAddress;
  User? withUser;
  String myAddress;

  List<Transaction> transactions = [];
  List<Transaction> newTransactions = [];
  List<Transaction> sendingQueue = [];

  Timer? _pollingTimer;

  double toSendAmount = 0.0;
  String toSendMessage = '';

  bool loading = false;
  bool error = false;

  TransactionsWithUserState({
    required this.withUserAddress,
    required this.myAddress,
  }) {
    myProfileService = ProfileService(account: myAddress);
    withUserProfileService = ProfileService(account: withUserAddress);
    transactionsWithUserService = TransactionsService(
        firstAccount: myAddress, secondAccount: withUserAddress);

    init();
  }

  void init() async {
    final config = await _configService.getLocalConfig();
    if (config == null) {
      throw Exception('Community not found in local asset');
    }

    await config.initContracts();

    _config = config;
  }

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
        decimals: _config.getPrimaryToken().decimals,
      );

      if (parsedAmount == BigInt.zero) {
        return null;
      }

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        throw Exception('Credentials not found');
      }

      final (account, key) = credentials;

      debugPrint('account: ${account.hexEip55}');
      debugPrint('key: ${key.address.hexEip55}');

      final toAddress = withUserAddress;

      final tempId = '${pendingTransactionId}_${generateRandomId()}';
      final sendingTransaction = Transaction(
        id: tempId,
        txHash: '',
        createdAt: DateTime.now(),
        fromAccount: account.hexEip55,
        toAccount: toAddress,
        amount: parsedAmount /
            BigInt.from(pow(10, _config.getPrimaryToken().decimals)),
        exchangeDirection: ExchangeDirection.sent,
        status: TransactionStatus.sending,
        description: toSendMessage.trim(),
      );
      sendingQueue.add(sendingTransaction);
      safeNotifyListeners();

      final calldata = tokenTransferCallData(
        _config,
        account,
        toAddress,
        parsedAmount,
      );

      final (_, userOp) = await prepareUserop(
        _config,
        account,
        key,
        [_config.getPrimaryToken().address],
        [calldata],
      );

      final args = {
        'from': account.hexEip55,
        'to': toAddress,
      };

      if (_config.getPrimaryToken().standard == 'erc1155') {
        args['operator'] = account.hexEip55;
        args['id'] = '0';
        args['amount'] = parsedAmount.toString();
      } else {
        args['value'] = parsedAmount.toString();
      }

      final eventData = createEventData(
        stringSignature: transferEventStringSignature(_config),
        topic: transferEventSignature(_config),
        args: args,
      );

      final txHash = await submitUserop(
        _config,
        userOp,
        data: eventData,
        extraData:
            toSendMessage != '' ? TransferData(toSendMessage.trim()) : null,
      );

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
