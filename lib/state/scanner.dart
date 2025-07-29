import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/services/nfc/default.dart';
import 'package:pay_app/services/nfc/service.dart';
import 'package:pay_app/utils/platform.dart';

enum ScanStateType {
  loading,
  ready,
  notReady,
  readingNFC,
  error,
  notAvailable,
}

class ScanState with ChangeNotifier {
  final NFCService _nfc = DefaultNFCService();

  // constructor here
  ScanState() {
    init();
  }

  void init() async {
    nfcAvailable = await _nfc.isAvailable();
    scannerDirection =
        isPlatformApple() ? NFCScannerDirection.top : NFCScannerDirection.right;
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
  NFCScannerDirection scannerDirection = NFCScannerDirection.top;
  bool nfcAvailable = false;

  String? message;

  Future<(String, String?)?> readNFC() async {
    final available = await _nfc.isAvailable();
    if (!available) {
      return null;
    }

    message = 'Bring the card close to the phone';
    safeNotifyListeners();

    try {
      final (uid, uri) = await _nfc.readTag(
        message: message,
        successMessage: 'Card identified',
      );

      return (uid, uri);
    } catch (e) {
      return null;
    }
  }

  Future<(String, String?)?> configureNFC() async {
    try {
      final cardDomain = dotenv.env['CARD_DOMAIN'];

      if (cardDomain == null) {
        return null;
      }

      message = 'Bring the card close to the phone';
      safeNotifyListeners();

      final (uid, uri) = await _nfc.configureTag(
        'https://$cardDomain/card',
        message: 'Bring the card close to the phone',
        successMessage: 'Card configured',
      );

      if (uri == null) {
        return null;
      }

      return (uid, uri);
    } catch (e) {
      return null;
    }
  }

  void cancelScan() {
    _nfc.stop();
    message = null;
    safeNotifyListeners();
  }
}
