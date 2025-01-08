import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/models/user.dart';
import 'package:pay_app/services/profile/profile.dart';

// TODO: api service for transactions with user

class TransactionsWithUserState with ChangeNotifier {
  User withUser;
  String myAddress;
  List<Transaction> transactions = [];

  ProfileService myProfileService;
  ProfileService withUserProfileService;

  bool loading = false;
  bool error = false;

  TransactionsWithUserState({required this.withUser, required this.myAddress})
      : myProfileService = ProfileService(account: myAddress),
        withUserProfileService = ProfileService(account: withUser.account);

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
}
