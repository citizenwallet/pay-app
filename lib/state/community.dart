import 'package:flutter/cupertino.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';

class CommunityState with ChangeNotifier {
  Config? community;

  final ConfigService _configService = ConfigService();

  bool loading = false;

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

  Future<void> fetchCommunity() async {
    try {
      loading = true;
      safeNotifyListeners();

      // Get community from local asset file
      final config = await _configService.getLocalConfig();

      if (config == null) {
        throw Exception('Community not found in local asset');
      }

      await config.initContracts();

      // Update state with local data
      community = config;
      safeNotifyListeners();
    } catch (e, stack) {
      debugPrint('Error in fetchCommunity: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Error loading local community file',
      );
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }
}
