import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/models/place_with_menu.dart';
import 'package:pay_app/services/db/app/db.dart';
import 'package:pay_app/services/db/app/places_with_menu.dart';
import 'package:pay_app/services/pay/interactions.dart';

class InteractionState with ChangeNotifier {
  final PlacesWithMenuTable _placesWithMenuTable =
      AppDBService().placesWithMenu;

  String searchQuery = '';
  List<Interaction> interactions = [];
  InteractionService apiService;
  Timer? _pollingTimer;

  InteractionState({required String account})
      : apiService = InteractionService(myAccount: account);

  bool loading = false;
  bool error = false;

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

  // TODO: paginate interactions
  Future<void> getInteractions() async {
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      final interactions = await apiService.getInteractions();

      if (interactions.isNotEmpty) {
        final upsertedInteractions = _upsertInteractions(interactions);
        this.interactions = upsertedInteractions;
        safeNotifyListeners();
      }
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
      {Future<void> Function()? updateBalance}) async {
    try {
      final newInteractions =
          await apiService.getNewInteractions(interactionsFromDate);

      if (newInteractions.isNotEmpty) {
        final upsertedInteractions = _upsertInteractions(newInteractions);
        interactions = upsertedInteractions;
        interactionsFromDate = DateTime.now();
        safeNotifyListeners();
        updateBalance?.call();
      }
    } catch (e, s) {
      debugPrint('Error polling interactions: $e');
      debugPrint('Stack trace: $s');
    }
  }

  List<Interaction> _upsertInteractions(List<Interaction> newInteractions) {
    final existingList = interactions;
    final existingMap = {for (var i in existingList) i.id: i};

    for (final newInteraction in newInteractions) {
      if (newInteraction.isPlace && newInteraction.place != null) {
        _placesWithMenuTable.upsert(newInteraction.place!);
      }

      if (existingMap.containsKey(newInteraction.id)) {
        // Update existing interaction
        final existing = existingMap[newInteraction.id]!;
        existingMap[newInteraction.id] =
            Interaction.upsert(existing, newInteraction);
      } else {
        // Add new interaction
        existingMap[newInteraction.id] = newInteraction;
      }
    }

    return existingMap.values.toList();
  }

  Future<void> markInteractionAsRead(Interaction interaction) async {
    if (!interaction.hasUnreadMessages) {
      return;
    }

    try {
      final index = interactions.indexWhere((i) => i.id == interaction.id);
      if (index < 0) {
        return;
      }

      interactions[index].hasUnreadMessages = false;
      safeNotifyListeners();

      await apiService.setInteractionAsRead(interaction.id);
      getInteractions();
    } catch (e, s) {
      debugPrint('Error marking interaction as read: $e');
      debugPrint('Stack trace: $s');
    }
  }
}
