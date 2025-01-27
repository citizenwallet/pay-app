import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/services/interactions/interactions.dart';
import 'package:pay_app/state/wallet.dart';

class InteractionState with ChangeNotifier {
  String searchQuery = '';
  List<Interaction> interactions = [];
  InteractionService apiService;
  final WalletState walletState;
  Timer? _pollingTimer;

  InteractionState({required String account, required this.walletState})
      : apiService = InteractionService(myAccount: account);

  bool loading = false;
  bool error = false;

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

  void setSearchQuery(String query) {
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
      error = true;
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }

  void startPolling() {
    // Cancel any existing timer first
    stopPolling();

    interactionsFromDate = DateTime.now();

    // Create new timer
    _pollingTimer = Timer.periodic(
      const Duration(milliseconds: pollingInterval),
      (_) => _pollInteractions(),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('stopPolling');
  }

  static const pollingInterval = 3000; // ms
  DateTime interactionsFromDate = DateTime.now();
  Future<void> _pollInteractions() async {
    try {
      final newInteractions =
          await apiService.getNewInteractions(interactionsFromDate);

      if (newInteractions.isNotEmpty) {
        final upsertedInteractions = _upsertInteractions(newInteractions);
        interactions = upsertedInteractions;
        interactionsFromDate = DateTime.now();
        safeNotifyListeners();
        walletState.updateBalance();
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
      interaction.hasUnreadMessages = false;
      final upsertedInteractions = _upsertInteractions([interaction]);
      interactions = upsertedInteractions;
      safeNotifyListeners();

      apiService.patchInteraction(interaction);
    } catch (e, s) {
      debugPrint('Error marking interaction as read: $e');
      debugPrint('Stack trace: $s');
    }
  }
}
