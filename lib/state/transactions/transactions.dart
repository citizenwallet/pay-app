import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/services/audio/audio.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/db/app/contacts.dart';
import 'package:pay_app/services/db/app/db.dart';
import 'package:pay_app/services/db/app/orders.dart';
import 'package:pay_app/services/db/app/transactions.dart';
import 'package:pay_app/services/pay/orders.dart';
import 'package:pay_app/services/pay/transactions.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/services/wallet/wallet.dart';

class TransactionsState with ChangeNotifier {
  late Config _config;

  final ContactsTable _contacts = AppDBService().contacts;
  final TransactionsTable _transactionsTable = AppDBService().transactions;
  final OrdersTable _ordersTable = AppDBService().orders;
  final AudioService _audioService = AudioService();
  final ConfigService _configService = ConfigService();
  final SecureService _secureService = SecureService();

  late TransactionsService transactionsService;
  late OrdersService ordersService;

  String accountAddress;

  List<Transaction> transactions = [];
  List<Transaction> newTransactions = [];

  Map<String, Order> orders = {};
  Map<String, ProfileV1> profiles = {};

  Timer? _pollingTimer;

  int transactionsLimit = 10;
  int transactionsOffset = 0;

  bool loading = false;
  bool error = false;
  bool loadingMore = false;
  bool hasMoreTransactions = true;

  TransactionsState({
    required this.accountAddress,
  }) {
    transactionsService = TransactionsService(account: accountAddress);
    ordersService = OrdersService(account: accountAddress);
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
    getTransactions();
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

  void loadProfiles(List<Transaction> transactions) {
    for (final transaction in transactions) {
      if (transaction.fromProfile != null) {
        fetchProfile(transaction.fromAccount);
      }
    }
  }

  void fetchProfile(String account) async {
    final contact = await _contacts.getByAccount(account);
    final profile = contact?.getProfile();
    if (profile != null) {
      profiles[account] = profile;
      safeNotifyListeners();

      return;
    }

    final remoteProfile = await getProfile(_config, account);
    if (remoteProfile == null) {
      return;
    }

    profiles[account] = remoteProfile;
    safeNotifyListeners();

    _contacts.upsert(DBContact.fromProfile(remoteProfile));
  }

  void fetchOrdersByTxHash(String txHash) async {
    final order = await _ordersTable.getByTxHash(txHash);
    if (order != null) {
      orders[txHash] = order;
      safeNotifyListeners();

      if (order.isFinalized) {
        return;
      }
    }

    try {
      final apiOrder = await ordersService.getOrdersByTxHash(txHash);

      orders[txHash] = apiOrder;
      safeNotifyListeners();

      await _ordersTable.upsert(apiOrder);
    } catch (e) {
      debugPrint('Error fetching orders by tx hash: $e');
    }
  }

  void startPolling({Future<void> Function()? updateBalance}) {
    // Cancel any existing timer first
    stopPolling();

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
      final newTransactions =
          await transactionsService.getNewTransactions(transactionsFromDate);

      if (newTransactions.isNotEmpty) {
        // Store new transactions in database
        await _transactionsTable.upsertMany(newTransactions);

        for (final transaction in newTransactions) {
          if (transaction.fromProfile != null) {
            _contacts.upsert(DBContact.fromProfile(transaction.fromProfile!));
          }

          if (transaction.toProfile != null) {
            _contacts.upsert(DBContact.fromProfile(transaction.toProfile!));
          }
        }

        _upsertNewTransactions(newTransactions);

        loadProfiles(newTransactions);

        safeNotifyListeners();
        updateBalance?.call();
      }
    } catch (e, s) {
      debugPrint('Error polling transactions: $e');
      debugPrint('Stack trace: $s');
    }
  }

  Future<void> getTransactions() async {
    debugPrint('get transactions');
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      // First, try to load from database
      final dbTransactions = await _transactionsTable.getTransactionsForAccount(
        accountAddress,
        limit: transactionsLimit,
        offset: transactionsOffset,
      );

      if (dbTransactions.isNotEmpty) {
        _upsertTransactions(dbTransactions);

        loadProfiles(dbTransactions);

        transactionsOffset += dbTransactions.length;
        hasMoreTransactions = dbTransactions.length == transactionsLimit;
        safeNotifyListeners();
      }

      // Then sync with API to get latest transactions
      await _syncTransactionsFromAPI();
    } catch (e, s) {
      debugPrint('Error fetching transactions: $e');
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
      final dbTransactions = await _transactionsTable.getTransactionsForAccount(
        accountAddress,
        limit: transactionsLimit,
        offset: transactionsOffset,
      );

      if (dbTransactions.isNotEmpty) {
        _upsertTransactions(dbTransactions);

        loadProfiles(dbTransactions);

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
      final (apiTransactions, _) = await transactionsService.getTransactions(
        limit: 50, // Get more transactions to ensure we have recent data
        offset: 0,
      );

      if (apiTransactions.isNotEmpty) {
        // Store transactions in database
        await _transactionsTable.upsertMany(apiTransactions);

        for (final transaction in apiTransactions) {
          if (transaction.fromProfile != null) {
            _contacts.upsert(DBContact.fromProfile(transaction.fromProfile!));
          }

          if (transaction.toProfile != null) {
            _contacts.upsert(DBContact.fromProfile(transaction.toProfile!));
          }
        }

        loadProfiles(apiTransactions);

        // Refresh the current view if we have new transactions
        final currentTransactions =
            await _transactionsTable.getTransactionsForAccount(
          accountAddress,
          limit: transactions.length + 10, // Get a bit more than current
          offset: 0,
        );

        if (currentTransactions.isNotEmpty) {
          _upsertTransactions(currentTransactions);

          loadProfiles(currentTransactions);

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
      final index =
          existingList.indexWhere((element) => element.id == newTransaction.id);

      if (index != -1) {
        existingList[index] = newTransaction;
      } else {
        existingList.add(newTransaction);
      }

      fetchOrdersByTxHash(newTransaction.txHash);
    }

    // Sort by creation date (newest first) to maintain proper order
    existingList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    transactions = [...existingList];
  }

  void _upsertNewTransactions(List<Transaction> newTransactions) {
    final existingList = [...this.newTransactions];

    for (final newTransaction in newTransactions) {
      final index =
          existingList.indexWhere((element) => element.id == newTransaction.id);

      if (index != -1) {
        existingList[index] = newTransaction;
      } else {
        existingList.insert(0, newTransaction);
      }

      fetchOrdersByTxHash(newTransaction.txHash);

      // Remove old pending transactions
      existingList.removeWhere((element) =>
          element.status == TransactionStatus.pending &&
          element.createdAt
              .isBefore(DateTime.now().subtract(Duration(seconds: 20))));
    }

    this.newTransactions = [...existingList];
  }

  Future<void> refreshTransactions() async {
    // Reset pagination state
    transactionsOffset = 0;
    hasMoreTransactions = true;

    // Clear current transactions
    transactions = [];
    safeNotifyListeners();

    // Reload from database and sync with API
    await getTransactions();
  }

  // Filter transactions by contract if needed
  Future<void> getTransactionsByContract(String contract) async {
    debugPrint('get transactions by contract: $contract');
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      final (apiTransactions, _) = await transactionsService.getTransactions(
        limit: transactionsLimit,
        offset: 0,
        contract: contract,
      );

      if (apiTransactions.isNotEmpty) {
        _upsertTransactions(apiTransactions);

        for (final transaction in apiTransactions) {
          if (transaction.fromProfile != null) {
            _contacts.upsert(DBContact.fromProfile(transaction.fromProfile!));
          }

          if (transaction.toProfile != null) {
            _contacts.upsert(DBContact.fromProfile(transaction.toProfile!));
          }
        }

        loadProfiles(apiTransactions);

        transactionsOffset = apiTransactions.length;
        hasMoreTransactions = apiTransactions.length == transactionsLimit;
        safeNotifyListeners();
      }
    } catch (e, s) {
      debugPrint('Error fetching transactions by contract: $e');
      debugPrint('Stack trace: $s');
      error = true;
      safeNotifyListeners();
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }

  // Load more transactions for a specific contract
  Future<void> loadMoreTransactionsByContract(String contract) async {
    if (loadingMore || !hasMoreTransactions) return;

    debugPrint('load more transactions by contract: $contract');
    loadingMore = true;
    safeNotifyListeners();

    try {
      final (apiTransactions, _) = await transactionsService.getTransactions(
        limit: transactionsLimit,
        offset: transactionsOffset,
        contract: contract,
      );

      if (apiTransactions.isNotEmpty) {
        _upsertTransactions(apiTransactions);

        for (final transaction in apiTransactions) {
          if (transaction.fromProfile != null) {
            _contacts.upsert(DBContact.fromProfile(transaction.fromProfile!));
          }

          if (transaction.toProfile != null) {
            _contacts.upsert(DBContact.fromProfile(transaction.toProfile!));
          }
        }

        loadProfiles(apiTransactions);

        transactionsOffset += apiTransactions.length;
        hasMoreTransactions = apiTransactions.length == transactionsLimit;
        safeNotifyListeners();
      } else {
        hasMoreTransactions = false;
        safeNotifyListeners();
      }
    } catch (e, s) {
      debugPrint('Error loading more transactions by contract: $e');
      debugPrint('Stack trace: $s');
    } finally {
      loadingMore = false;
      safeNotifyListeners();
    }
  }
}
