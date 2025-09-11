import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/services/db/app/db.dart';
import 'package:pay_app/services/db/app/interactions.dart';
import 'package:pay_app/services/db/app/places_with_menu.dart';
import 'package:pay_app/services/pay/interactions.dart';
import 'package:pay_app/services/preferences/preferences.dart';

class InteractionState with ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();
  final InteractionsTable _interactionsTable = AppDBService().interactions;
  final PlacesWithMenuTable _placesWithMenuTable =
      AppDBService().placesWithMenu;

  String searchQuery = '';
  List<Interaction> interactions = [];
  Map<String, bool> interactionsMap = {};
  InteractionService apiService = InteractionService();
  Timer? _pollingTimer;

  final String _account;

  InteractionState(account) : _account = account {
    final token = _preferencesService.tokenAddress;

    getInteractions(token: token);
    refreshFromRemote(token: token);
  }

  bool loading = false;
  bool error = false;
  bool syncing = false; // New flag for sync status

  bool searching = false;

  bool _mounted = true;
  void safeNotifyListeners() {
    if (_mounted) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopPolling();
    _mounted = false;
    super.dispose();
  }

  void startSearching() {
    searching = true;
    safeNotifyListeners();
  }

  void clearSearch() {
    searching = false;
    searchQuery = '';
    safeNotifyListeners();
  }

  void setSearchQuery(String query) {
    searching = false;
    searchQuery = query;
    safeNotifyListeners();
  }

  // Load interactions from local database first, then sync with remote
  Future<void> getInteractions({String? token}) async {
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      // First, load from local database for immediate display
      await _loadFromLocalDatabase(token: token);

      // Then sync with remote API in background
      await _syncWithRemoteAPI(token: token);
    } catch (e, s) {
      debugPrint('Error fetching interactions: $e');
      debugPrint('Stack trace: $s');
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'Error fetching interactions',
      );
      error = true;
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }

  // Load interactions from local database
  Future<void> _loadFromLocalDatabase({String? token}) async {
    try {
      final localInteractions = await _interactionsTable.getAll(
        _account,
        token: token,
      );

      if (localInteractions.isNotEmpty) {
        interactions = localInteractions;
        interactionsMap = {
          for (var i in localInteractions) i.withAccount: true
        };
        safeNotifyListeners();
      }
    } catch (e, s) {
      debugPrint('Error loading from local database: $e');
      debugPrint('Stack trace: $s');
      // Don't set error here as we'll try remote API
    }
  }

  // Sync with remote API and update local database
  Future<void> _syncWithRemoteAPI({String? token}) async {
    syncing = true;
    safeNotifyListeners();

    try {
      final remoteInteractions = await apiService.getInteractions(
        _account,
        token: token,
      );

      if (remoteInteractions.isNotEmpty) {
        // Store remote interactions in local database
        await _interactionsTable.upsertMany(remoteInteractions);

        // Update places with menu if any
        for (final interaction in remoteInteractions) {
          if (interaction.isPlace && interaction.place != null) {
            await _placesWithMenuTable.upsert(interaction.place!);
          }
        }

        // Reload from local database to get the updated data
        await _loadFromLocalDatabase(token: token);
      }
    } catch (e, s) {
      debugPrint('Error syncing with remote API: $e');
      debugPrint('Stack trace: $s');
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'Error syncing interactions with remote API',
      );
      // Don't set error here as we have local data
    } finally {
      syncing = false;
      safeNotifyListeners();
    }
  }

  void startPolling({Future<void> Function()? updateBalance}) {
    // Cancel any existing timer first
    stopPolling();

    interactionsFromDate = DateTime.now();

    // Create new timer
    _pollingTimer = Timer.periodic(
      const Duration(milliseconds: pollingInterval),
      (_) => _pollInteractions(updateBalance: updateBalance),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('stopPolling');
  }

  static const pollingInterval = 3000; // ms
  DateTime interactionsFromDate = DateTime.now();
  Future<void> _pollInteractions(
      {Future<void> Function()? updateBalance, String? token}) async {
    try {
      final newInteractions = await apiService.getNewInteractions(
        _account,
        interactionsFromDate,
        token: token,
      );

      if (newInteractions.isNotEmpty) {
        // Store new interactions in local database
        await _interactionsTable.upsertMany(newInteractions);

        // Update places with menu if any
        for (final interaction in newInteractions) {
          if (interaction.isPlace && interaction.place != null) {
            await _placesWithMenuTable.upsert(interaction.place!);
          }
        }

        // Reload from local database to get the updated data
        await _loadFromLocalDatabase(token: token);

        interactionsFromDate = DateTime.now();
        updateBalance?.call();
      }
    } catch (e, s) {
      debugPrint('Error polling interactions: $e');
      debugPrint('Stack trace: $s');
      // Don't set error here as polling failures shouldn't break the UI
    }
  }

  List<Interaction> _upsertInteractions(List<Interaction> newInteractions) {
    final existingList = interactions;
    final existingMap = {for (var i in existingList) i.withAccount: i};

    for (final newInteraction in newInteractions) {
      if (newInteraction.isPlace && newInteraction.place != null) {
        _placesWithMenuTable.upsert(newInteraction.place!);
      }

      if (existingMap.containsKey(newInteraction.withAccount)) {
        // Update existing interaction
        final existing = existingMap[newInteraction.withAccount]!;
        existingMap[newInteraction.withAccount] =
            Interaction.upsert(existing, newInteraction);
      } else {
        // Add new interaction
        existingMap[newInteraction.withAccount] = newInteraction;
      }
    }

    return existingMap.values.toList();
  }

  Future<void> markInteractionAsRead(Interaction interaction) async {
    if (!interaction.hasUnreadMessages) {
      return;
    }

    try {
      // Update local database first for immediate UI feedback
      await _interactionsTable.updateUnreadStatus(interaction.id, false);

      // Update local state
      final index = interactions
          .indexWhere((i) => i.withAccount == interaction.withAccount);
      if (index >= 0) {
        interactions[index].hasUnreadMessages = false;
        safeNotifyListeners();
      }

      // Sync with remote API
      await apiService.setInteractionAsRead(_account, interaction.id);
    } catch (e, s) {
      debugPrint('Error marking interaction as read: $e');
      debugPrint('Stack trace: $s');
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'Error marking interaction as read',
      );
    }
  }

  // Force refresh from remote API
  Future<void> refreshFromRemote({String? token}) async {
    syncing = true;
    safeNotifyListeners();

    try {
      await _syncWithRemoteAPI(token: token);
    } finally {
      syncing = false;
      safeNotifyListeners();
    }
  }

  // Get interactions for a specific account from local database
  Future<List<Interaction>> getInteractionsForAccount(
    String account, {
    int? limit,
    int? offset,
    String? token,
  }) async {
    try {
      return await _interactionsTable.getInteractionsForAccount(
        _account,
        account,
        limit: limit,
        offset: offset,
        token: token,
      );
    } catch (e, s) {
      debugPrint('Error getting interactions for account: $e');
      debugPrint('Stack trace: $s');
      return [];
    }
  }

  // Get place interactions from local database
  Future<List<Interaction>> getPlaceInteractions({
    int? limit,
    int? offset,
  }) async {
    try {
      return await _interactionsTable.getPlaceInteractions(
        _account,
        limit: limit,
        offset: offset,
      );
    } catch (e, s) {
      debugPrint('Error getting place interactions: $e');
      debugPrint('Stack trace: $s');
      return [];
    }
  }

  // Get unread interactions from local database
  Future<List<Interaction>> getUnreadInteractions({
    int? limit,
    int? offset,
    String? token,
  }) async {
    try {
      return await _interactionsTable.getUnreadInteractions(
        _account,
        limit: limit,
        offset: offset,
        token: token,
      );
    } catch (e, s) {
      debugPrint('Error getting unread interactions: $e');
      debugPrint('Stack trace: $s');
      return [];
    }
  }
}
