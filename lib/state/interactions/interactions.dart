import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/services/interactions/interactions.dart';


// TODO: upsert into interactions against withAccount


class InteractionState with ChangeNotifier {
  List<Interaction> interactions = [];
  InteractionService apiService;

  InteractionState({required String account})
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
    _mounted = false;
    super.dispose();
  }

  Future<void> getInteractions() async {
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      final interactions = await apiService.getInteractions();
      this.interactions = interactions;
    } catch (e, s) {
      debugPrint('Error fetching interactions: $e');
      debugPrint('Stack trace: $s');
      error = true;
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }
}
