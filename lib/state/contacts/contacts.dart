import 'package:flutter/cupertino.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/contacts/contacts.dart';
import 'package:pay_app/services/session/session.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

class ContactsState extends ChangeNotifier {
  // instantiate services here
  final ConfigService _configService = ConfigService();
  final SessionService _sessionService = SessionService();
  final ContactsService _contactsService = ContactsService();

  // private variables here

  // constructor here
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

  // state variables here
  List<SimpleContact> contacts = [];
  String searchQuery = '';

  // state methods here
  Future<void> fetchContacts() async {
    contacts = await _contactsService.getContacts();
    safeNotifyListeners();
  }

  void clearContacts() {
    contacts = [];
    safeNotifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    safeNotifyListeners();
  }

  Future<EthereumAddress?> getContactAddress(
    String source,
    String type,
  ) async {
    try {
      final config = await _configService.getLocalConfig();
      if (config == null) {
        throw Exception('Community not found in local asset');
      }

      await config.initContracts();

      final result = await parse(source);
      final parsedNumber = result['e164'];
      if (parsedNumber == null) {
        return null;
      }

      return await getTwoFAAddress(
        config,
        _sessionService.provider,
        parsedNumber,
        type,
      );
    } catch (e, s) {
      print('error: $e');
      print('stack trace: $s');
    }

    return null;
  }
}
