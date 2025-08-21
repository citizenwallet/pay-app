import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/db/app/cards.dart';
import 'package:pay_app/services/db/app/contacts.dart';
import 'package:pay_app/services/db/app/db.dart';
import 'package:pay_app/services/pay/cards.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/sigauth/sigauth.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/utils/currency.dart';
import 'package:pay_app/utils/projects.dart';
import 'package:web3dart/credentials.dart';

enum AddCardError {
  cardAlreadyExists,
  cardAlreadyClaimed,
  cardNotConfigured,
  nfcNotAvailable,
  missingCardDomain,
  unknownError,
}

class CardsState with ChangeNotifier {
  // instantiate services here
  final ContactsTable _contacts = AppDBService().contacts;
  final CardsTable _cards = AppDBService().cards;
  final SecureService _secureService = SecureService();
  final CardsService _cardsService = CardsService();

  final PreferencesService _preferencesService = PreferencesService();

  // private variables here
  final Config _config;

  // constructor here
  CardsState(this._config) {
    init();
  }

  void init() async {
    final token = _preferencesService.tokenAddress;
    fetchCards(tokenAddress: token);
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
  Map<String, String> cardBalances = {};
  Map<String, ProfileV1> profiles = {};

  bool updatingCardName = false;
  String? updatingCardNameUid;
  bool claimingCard = false;
  bool releasingCard = false;

  // state methods here
  Future<void> fetchCards({String? tokenAddress}) async {
    try {
      cards = await _cards.getAll();
      safeNotifyListeners();

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        return;
      }

      final (account, key) = credentials;

      final redirectDomain = dotenv.env['APP_REDIRECT_DOMAIN'];

      final sigAuthService = SigAuthService(
        credentials: key,
        address: account,
        redirect: redirectDomain != null ? 'https://$redirectDomain' : '',
      );

      final sigAuthConnection = sigAuthService.connect();

      _cardsService
          .getCards(sigAuthConnection, account.hexEip55)
          .then((cards) async {
        final newCards = await Future.wait(cards.map((e) async {
          // skip address fetch for existing cards
          final existingCard = await _cards.getByUid(e.serial);
          if (existingCard != null) {
            return DBCard(
              uid: e.serial,
              project: e.project ?? '',
              account: existingCard.account,
            );
          }

          // fetch address for new cards
          final cardAddress = await _config.cardManagerContract!.getCardAddress(
            e.serial,
          );
          return DBCard(
            uid: e.serial,
            project: e.project ?? '',
            account: cardAddress.hexEip55,
          );
        }).toList());

        await _cards.replaceAll(newCards);

        this.cards = await _cards.getAll();
        safeNotifyListeners();
      });

      final token =
          _config.getToken(tokenAddress ?? _config.getPrimaryToken().address);

      for (final card in cards) {
        final balance = await getBalance(
          _config,
          EthereumAddress.fromHex(card.account),
          tokenAddress: token.address,
        );

        cardBalances[card.account] = formatCurrency(balance, token.decimals);
      }

      safeNotifyListeners();
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  Future<void> fetchProfile(String address) async {
    final contact = await _contacts.getByAccount(address);
    final cachedProfile = contact?.getProfile();
    if (cachedProfile != null) {
      profiles[address] = cachedProfile;
      safeNotifyListeners();
    }

    final profile = await getProfile(_config, address);

    if (profile != null) {
      profiles[address] = profile;
      safeNotifyListeners();

      _contacts.upsert(DBContact.fromProfile(profile));
    }
  }

  Future<void> updateCardName(
      String uid, String newName, String originalName) async {
    try {
      updatingCardName = true;
      profiles[uid]?.name = newName;
      safeNotifyListeners();

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        updatingCardName = false;
        profiles[uid]?.name = originalName;
        safeNotifyListeners();

        return;
      }

      final (account, key) = credentials;

      final redirectDomain = dotenv.env['APP_REDIRECT_DOMAIN'];

      final sigAuthService = SigAuthService(
        credentials: key,
        address: account,
        redirect: redirectDomain != null ? 'https://$redirectDomain' : '',
      );

      final sigAuthConnection = sigAuthService.connect();

      final updatedProfile =
          await _cardsService.setProfile(sigAuthConnection, uid, newName);

      if (updatedProfile != null) {
        updatingCardName = false;
        profiles[uid] = updatedProfile;

        safeNotifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
      profiles[uid]?.name = originalName;
    } finally {
      updatingCardName = false;
      safeNotifyListeners();
    }
  }

  Future<void> release(String uid) async {
    try {
      final card = await _cards.getByUid(uid);
      if (card == null) {
        return;
      }

      releasingCard = true;
      safeNotifyListeners();

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        releasingCard = false;
        safeNotifyListeners();

        return;
      }

      final (account, key) = credentials;

      final redirectDomain = dotenv.env['APP_REDIRECT_DOMAIN'];

      final sigAuthService = SigAuthService(
        credentials: key,
        address: account,
        redirect: redirectDomain != null ? 'https://$redirectDomain' : '',
      );

      final sigAuthConnection = sigAuthService.connect();

      _cardsService.deleteProfile(sigAuthConnection, uid);

      await _cardsService.release(sigAuthConnection, uid);

      await _cards.delete(uid);

      profiles.remove(card.account);

      cards.removeWhere((card) => card.uid == uid);
      safeNotifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      releasingCard = false;
      safeNotifyListeners();
    }
  }

  Future<(String?, String?, AddCardError?)> claim(
    String uid,
    String? uri,
    String? name, {
    String? project,
  }) async {
    String? tokenAddress;
    EthereumAddress? cardAddress;
    try {
      updatingCardNameUid = uid;
      claimingCard = true;
      safeNotifyListeners();

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        claimingCard = false;
        safeNotifyListeners();

        return (tokenAddress, null, AddCardError.unknownError);
      }

      final (account, key) = credentials;

      final redirectDomain = dotenv.env['APP_REDIRECT_DOMAIN'];

      final sigAuthService = SigAuthService(
        credentials: key,
        address: account,
        redirect: redirectDomain != null ? 'https://$redirectDomain' : '',
      );

      final sigAuthConnection = sigAuthService.connect();

      String? parsedProject = project ?? parseProject(uri);

      final tokenConfig = _config.getTokenByProject(parsedProject ?? 'main');

      tokenAddress = tokenConfig.address;

      _preferencesService.setToken(tokenConfig.address);

      await _cardsService.claim(
        sigAuthConnection,
        uid,
        project: parsedProject,
      );

      cardAddress = await _config.cardManagerContract!.getCardAddress(
        uid,
      );

      final existingCard = await _cards.getByUid(uid);
      if (existingCard != null) {
        claimingCard = false;
        safeNotifyListeners();

        return (
          tokenAddress,
          existingCard.account,
          AddCardError.cardAlreadyExists
        );
      }

      final card = DBCard(
          uid: uid, project: project ?? '', account: cardAddress.hexEip55);

      await _cards.upsert(card);

      cards.add(card);
      safeNotifyListeners();

      final profile = await _cardsService.setProfile(
        sigAuthConnection,
        uid,
        name ?? 'new',
      );

      if (profile != null) {
        profiles[profile.account] = profile;
        safeNotifyListeners();
      }

      if (uri == null) {
        updatingCardNameUid = null;
        claimingCard = false;
        safeNotifyListeners();
        // this is not an error, it just means the card is not configured
        return (
          tokenAddress,
          cardAddress.hexEip55,
          AddCardError.cardNotConfigured
        );
      }
    } catch (e) {
      debugPrint(e.toString());

      updatingCardNameUid = null;
      claimingCard = false;
      safeNotifyListeners();

      return (tokenAddress, cardAddress?.hexEip55, AddCardError.unknownError);
    }

    updatingCardNameUid = null;
    claimingCard = false;
    safeNotifyListeners();

    return (tokenAddress, cardAddress.hexEip55, null);
  }
}
