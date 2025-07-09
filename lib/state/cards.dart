import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/db/app/cards.dart';
import 'package:pay_app/services/db/app/db.dart';

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

  // private variables here
  final Config _config;

  // constructor here
  CardsState(this._config) {
    init();
  }

  void init() async {
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

  Future<AddCardError?> addCard(String uid, String? uri) async {
    try {
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

      return AddCardError.unknownError;
    }

    return null;
  }
}
