import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/models/user.dart';
import 'package:pay_app/services/audio/audio.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/db/app/contacts.dart';
import 'package:pay_app/services/db/app/db.dart';
import 'package:pay_app/services/db/app/transactions.dart';
import 'package:pay_app/services/engine/utils.dart';
import 'package:pay_app/services/invite/invite.dart';
import 'package:pay_app/services/pay/profile.dart';
import 'package:pay_app/services/pay/transactions_with_user.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/wallet/contracts/erc20.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/services/wallet/utils.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/utils/random.dart';

class TransactionsWithUserState with ChangeNotifier {
  late Config _config;

  final ContactsTable _contacts = AppDBService().contacts;
  final TransactionsTable _transactionsTable = AppDBService().transactions;

  final AudioService _audioService = AudioService();

  final ConfigService _configService = ConfigService();
  final SecureService _secureService = SecureService();
  final InviteService _inviteService = InviteService();
  late ProfileService myProfileService;
  late ProfileService withUserProfileService;
  late TransactionsService transactionsWithUserService;

  String withUserAddress;
  ProfileV1? withUser;
  String myAddress;

  List<Transaction> transactions = [];
  List<Transaction> newTransactions = [];
  List<Transaction> sendingQueue = [];

  Timer? _pollingTimer;

  double toSendAmount = 0.0;
  String toSendMessage = '';

  int transactionsLimit = 10;
  int transactionsOffset = 0;

  bool loading = false;
  bool error = false;
  bool loadingMore = false;
  bool hasMoreTransactions = true;

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

    // Initial sync with API to populate database
    await _syncTransactionsFromAPI();
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

  Future<String?> sendTransaction(
    String tokenAddress, {
    int? chainId,
    String? retryId,
  }) async {
    final tempId = retryId ?? '${pendingTransactionId}_${generateRandomId()}';
    final toRetry = sendingQueue.firstWhereOrNull((tx) => tx.id == retryId);
    if (retryId != null && toRetry == null) {
      return null;
    }

    try {
      final token = _config.getToken(
        tokenAddress,
        chainId: chainId,
      );

      final doubleAmount = toRetry != null
          ? toRetry.amount.toString().replaceAll(',', '.')
          : toSendAmount.toString().replaceAll(',', '.');
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

      final toAddress = toRetry != null ? toRetry.toAccount : withUserAddress;
      final message =
          toRetry != null ? toRetry.description : toSendMessage.trim();

      if (toRetry != null) {
        final index = sendingQueue.indexWhere((tx) => tx.id == toRetry.id);
        if (index != -1) {
          sendingQueue[index] = sendingQueue[index].copyWith(
            createdAt: DateTime.now(),
            status: TransactionStatus.sending,
          );
          safeNotifyListeners();
        }
      }

      if (toRetry == null) {
        final sendingTransaction = Transaction(
          id: tempId,
          txHash: '',
          createdAt: DateTime.now(),
          fromAccount: account.hexEip55,
          toAccount: toAddress,
          contract: token.address,
          amount: double.parse(doubleAmount).toStringAsFixed(2),
          status: TransactionStatus.sending,
          description: message,
        );
        sendingQueue.add(sendingTransaction);
        safeNotifyListeners();
      }

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
        [token.address],
        [calldata],
      );

      final args = {
        'from': account.hexEip55,
        'to': toAddress,
      };

      if (token.standard == 'erc1155') {
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
            message != null && message != '' ? TransferData(message) : null,
      );

      if (txHash == null) return null;

      _audioService.txNotification();

      final index = sendingQueue.indexWhere((tx) => tx.id == tempId);
      if (index != -1) {
        sendingQueue[index] = sendingQueue[index].copyWith(
          txHash: txHash,
          status: TransactionStatus.sending,
        );
      }

      debugPrint('txHash: $txHash');
      return txHash;
    } catch (e, s) {
      debugPrint('Error sending transaction: $e');
      debugPrint('Stack trace: $s');

      final index = sendingQueue.indexWhere((tx) => tx.id == tempId);
      if (index != -1) {
        sendingQueue[index] = sendingQueue[index].copyWith(
          status: TransactionStatus.fail,
        );
      }

      safeNotifyListeners();

      HapticFeedback.lightImpact();

      return null;
    } finally {
      toSendAmount = 0.0;
      toSendMessage = '';
      safeNotifyListeners();

      HapticFeedback.lightImpact();
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
        // Store new transactions in database
        await _transactionsTable.upsertMany(newTransactions);

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
      final contact = await _contacts.getByAccount(withUserAddress);
      final cachedProfile = contact?.getProfile();
      if (cachedProfile != null) {
        withUser = cachedProfile;
        safeNotifyListeners();
      }

      final profile = await getProfile(_config, withUserAddress);
      if (profile != null) {
        withUser = profile;
        safeNotifyListeners();

        _contacts.upsert(DBContact.fromProfile(profile));
      }
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
      // First, try to load from database
      final dbTransactions =
          await _transactionsTable.getTransactionsBetweenUsers(
        myAddress,
        withUserAddress,
        limit: transactionsLimit,
        offset: transactionsOffset,
      );

      if (dbTransactions.isNotEmpty) {
        _upsertTransactions(dbTransactions);
        transactionsOffset += dbTransactions.length;
        hasMoreTransactions = dbTransactions.length == transactionsLimit;
        safeNotifyListeners();
      }

      // Then sync with API to get latest transactions
      await _syncTransactionsFromAPI();
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

  Future<void> loadMoreTransactions() async {
    if (loadingMore || !hasMoreTransactions) return;

    debugPrint('load more transactions');
    loadingMore = true;
    safeNotifyListeners();

    try {
      final dbTransactions =
          await _transactionsTable.getTransactionsBetweenUsers(
        myAddress,
        withUserAddress,
        limit: transactionsLimit,
        offset: transactionsOffset,
      );

      if (dbTransactions.isNotEmpty) {
        _upsertTransactions(dbTransactions);
        transactionsOffset += dbTransactions.length;
        hasMoreTransactions = dbTransactions.length == transactionsLimit;
        safeNotifyListeners();
      } else {
        hasMoreTransactions = false;
        safeNotifyListeners();
      }
    } catch (e, s) {
      debugPrint('Error loading more transactions: $e');
      debugPrint('Stack trace: $s');
    } finally {
      loadingMore = false;
      safeNotifyListeners();
    }
  }

  Future<void> _syncTransactionsFromAPI() async {
    try {
      // Get transactions from API with a larger limit to ensure we have recent data
      final (apiTransactions, _) =
          await transactionsWithUserService.getTransactionsWithUser(
        limit: 50, // Get more transactions to ensure we have recent data
        offset: 0,
      );

      if (apiTransactions.isNotEmpty) {
        // Store transactions in database
        await _transactionsTable.upsertMany(apiTransactions);

        // Refresh the current view if we have new transactions
        final currentTransactions =
            await _transactionsTable.getTransactionsBetweenUsers(
          myAddress,
          withUserAddress,
          limit: transactions.length + 10, // Get a bit more than current
          offset: 0,
        );

        if (currentTransactions.isNotEmpty) {
          _upsertTransactions(currentTransactions);
          safeNotifyListeners();
        }
      }
    } catch (e, s) {
      debugPrint('Error syncing transactions from API: $e');
      debugPrint('Stack trace: $s');
      // Don't throw here as we want to show cached data even if sync fails
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

    // Sort by creation date (newest first) to maintain proper order
    existingList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

      existingList.removeWhere((element) =>
          element.exchangeDirection(myAddress) == ExchangeDirection.received &&
          element.status == TransactionStatus.pending &&
          element.createdAt
              .isBefore(DateTime.now().subtract(Duration(seconds: 20))));
    }

    this.newTransactions = [...existingList];
  }

  void shareInviteLink(String phoneNumber) {
    _inviteService.shareInviteLink(phoneNumber);
  }

  Future<void> refreshTransactions() async {
    // Reset pagination state
    transactionsOffset = 0;
    hasMoreTransactions = true;

    // Clear current transactions
    transactions = [];
    safeNotifyListeners();

    // Reload from database and sync with API
    await getTransactionsWithUser();
  }
}
