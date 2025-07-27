import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/db/app/contacts.dart';
import 'package:pay_app/services/db/app/db.dart';
import 'package:pay_app/services/db/app/orders.dart';
import 'package:pay_app/services/pay/orders.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/utils/qr.dart';

class SendingState with ChangeNotifier {
  // instantiate services here
  final OrdersTable _ordersTable = AppDBService().orders;
  final ContactsTable _contacts = AppDBService().contacts;
  late OrdersService _ordersService;

  // private variables here
  final Config _config;
  QRData? _previousQRData;

  // constructor here

  SendingState({
    required config,
    required String myAddress,
  }) : _config = config {
    _ordersService = OrdersService(account: myAddress);
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
    super.dispose();
  }

  // state variables here
  QRData? qrData;
  ProfileV1? profile;
  Order? order;
  String? cardProject;

  // state methods here
  QRData? parseQRData(String rawValue) {
    if (_previousQRData != null && _previousQRData!.rawValue == rawValue) {
      return null;
    }

    qrData = QRData.fromRawValue(rawValue);
    profile = null;
    order = null;
    safeNotifyListeners();

    _previousQRData = qrData;

    return qrData;
  }

  void getCardProject(String rawValue) {
    cardProject = parseCardProject(rawValue);
    safeNotifyListeners();
  }

  Future<void> getContactProfileFromAddress(String address) async {
    try {
      final contact = await _contacts.getByAccount(address);
      profile = contact?.getProfile();
      safeNotifyListeners();

      if (profile != null) {
        getProfile(
          _config,
          address,
        ).then((result) => {
              if (result != null)
                {
                  _contacts.upsert(DBContact.fromProfile(result)),
                }
            });
      }

      profile = await getProfile(
        _config,
        address,
      );
      safeNotifyListeners();
    } catch (e, s) {
      print('error: $e');
      print('stack trace: $s');
    }
  }

  Future<void> getContactProfileFromUsername(String query) async {
    try {
      final potentialUsername = query.trim().replaceFirst('@', '');

      final contact = await _contacts.getByUsername(potentialUsername);
      profile = contact?.getProfile();
      safeNotifyListeners();

      if (profile != null) {
        getProfileByUsername(
          _config,
          potentialUsername,
        ).then((result) => {
              if (result != null)
                {
                  _contacts.upsert(DBContact.fromProfile(result)),
                }
            });
      }

      profile = await getProfileByUsername(
        _config,
        potentialUsername,
      );
      safeNotifyListeners();
    } catch (e, s) {
      print('error: $e');
      print('stack trace: $s');
    }
  }

  Future<void> loadExternalOrder(String slug, String orderId) async {
    try {
      final cachedOrder = await _ordersTable.getById(int.parse(orderId));

      if (cachedOrder != null) {
        order = cachedOrder;
        safeNotifyListeners();
      }

      final remoteOrder =
          await _ordersService.getOrder(slug, int.parse(orderId));

      order = remoteOrder;
      safeNotifyListeners();
    } catch (e, s) {
      print('loadExternalOrder error: $e');
      print('loadExternalOrder stack trace: $s');
    }
  }
}
