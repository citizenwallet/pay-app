import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/db/app/cards.dart';
import 'package:pay_app/services/db/app/db.dart';
import 'package:pay_app/services/nfc/default.dart';
import 'package:pay_app/services/nfc/service.dart';

enum AddCardError {
  cardAlreadyExists,
  cardNotConfigured,
  nfcNotAvailable,
  missingCardDomain,
  unknownError,
}

class CardsState with ChangeNotifier {
  // instantiate services here
  final CardsTable _cards = AppDBService().cards;
  final NFCService _nfc = DefaultNFCService();

  // private variables here
  final Config _config;

  // constructor here
  CardsState(this._config) {
    init();
  }

  void init() async {
    nfcAvailable = await _nfc.isAvailable();
    safeNotifyListeners();
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
  bool nfcAvailable = false;

  List<DBCard> cards = [];

  // state methods here
  Future<void> fetchCards() async {
    cards = await _cards.getAll();
    safeNotifyListeners();
  }

  Future<void> removeCard(String uid) async {
    try {
      await _cards.delete(uid);

      cards.removeWhere((card) => card.uid == uid);
      safeNotifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<AddCardError?> addCard() async {
    try {
      final available = await _nfc.isAvailable();
      if (!available) {
        return AddCardError.nfcNotAvailable;
      }

      final (uid, uri) = await _nfc.readTag(
        message: 'Bring the card close to the phone',
        successMessage: 'Card identified',
      );

      final cardAddress = await _config.cardManagerContract!.getCardAddress(
        uid,
      );

      String project = '';
      if (uri != null) {
        final parsedUri = Uri.parse(uri);

        if (parsedUri.queryParameters.containsKey('project')) {
          project = parsedUri.queryParameters['project']!;
        }

        // error when ordering cards, it should be project
        if (parsedUri.queryParameters.containsKey('community')) {
          project = parsedUri.queryParameters['community']!;
        }
      }

      final existingCard = await _cards.getByUid(uid);
      if (existingCard != null) {
        return AddCardError.cardAlreadyExists;
      }

      final card =
          DBCard(uid: uid, project: project, account: cardAddress.hexEip55);

      await _cards.upsert(card);

      cards.add(card);
      safeNotifyListeners();

      if (uri == null) {
        // this is not an error, it just means the card is not configured
        return AddCardError.cardNotConfigured;
      }
    } catch (e) {
      debugPrint(e.toString());

      _nfc.stop();

      return AddCardError.unknownError;
    }

    return null;
  }

  Future<AddCardError?> configureCard() async {
    try {
      final available = await _nfc.isAvailable();
      if (!available) {
        return AddCardError.nfcNotAvailable;
      }

      final cardDomain = dotenv.env['CARD_DOMAIN'];

      if (cardDomain == null) {
        return AddCardError.missingCardDomain;
      }

      final (uid, uri) = await _nfc.configureTag(
        'https://$cardDomain/card',
        message: 'Bring the card close to the phone',
        successMessage: 'Card configured',
      );

      if (uri == null) {
        // this is not an error, it just means the card is not configured
        return AddCardError.cardNotConfigured;
      }
    } catch (e) {
      debugPrint(e.toString());

      _nfc.stop();

      return AddCardError.unknownError;
    }

    return null;
  }
}
