import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/checkout.dart';
import 'package:pay_app/models/checkout_item.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/place_with_menu.dart';
import 'package:pay_app/services/audio/audio.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/db/app/cards.dart';
import 'package:pay_app/services/db/app/contacts.dart';
import 'package:pay_app/services/db/app/db.dart';
import 'package:pay_app/services/db/app/orders.dart';
import 'package:pay_app/services/db/app/places_with_menu.dart';
import 'package:pay_app/services/engine/utils.dart';
import 'package:pay_app/services/pay/orders.dart';
import 'package:pay_app/services/pay/places.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/sigauth/sigauth.dart';
import 'package:pay_app/services/wallet/contracts/erc20.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/services/wallet/utils.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/utils/qr.dart';

class SendingState with ChangeNotifier {
  // instantiate services here
  final OrdersTable _ordersTable = AppDBService().orders;
  final ContactsTable _contacts = AppDBService().contacts;
  final PlacesWithMenuTable _places = AppDBService().placesWithMenu;
  final CardsTable _cards = AppDBService().cards;
  late OrdersService _ordersService;
  PlacesService apiService = PlacesService();
  final SecureService _secureService = SecureService();
  final AudioService _audioService = AudioService();
  final PreferencesService _preferencesService = PreferencesService();

  // private variables here
  final Config _config;
  QRData? _previousQRData;

  // constructor here

  SendingState({
    required config,
    required this.myAddress,
  }) : _config = config {
    _ordersService = OrdersService(account: myAddress);
    initialCard = _preferencesService.lastCard;
    lastCard = _preferencesService.lastCard;
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
  String myAddress;

  QRData? qrData;
  ProfileV1? profile;
  PlaceWithMenu? place;
  Order? order;
  String? cardProject;

  ProfileV1? accountProfile;
  String? accountBalance;

  bool showTransactionInput = false;
  bool transactionSending = false;
  double amount = 0.0;

  String? initialCard;
  String? lastCard;

  // state methods here
  void setLastCard(String cardAddress) {
    _preferencesService.setLastCard(cardAddress);
    lastCard = cardAddress;
    safeNotifyListeners();
  }

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

  String? getCardProject(String rawValue) {
    cardProject = parseCardProject(rawValue);
    safeNotifyListeners();

    return cardProject;
  }

  Future<ProfileV1?> getContactProfileFromAddress(String address) async {
    try {
      final contact = await _contacts.getByAccount(address);
      profile = contact?.getProfile();
      safeNotifyListeners();

      if (profile != null) {
        getProfile(
          _config,
          address,
        ).then((result) {
          if (result != null) {
            profile = result;
            safeNotifyListeners();

            _contacts.upsert(DBContact.fromProfile(result));
          }
        });

        return profile;
      }

      profile = await getProfile(
        _config,
        address,
      );
      safeNotifyListeners();

      if (profile != null) {
        _contacts.upsert(DBContact.fromProfile(profile!));
      }

      profile ??= ProfileV1(
        account: address,
        image: 'assets/icons/profile.png',
        imageMedium: 'assets/icons/profile.png',
        imageSmall: 'assets/icons/profile.png',
      );
      safeNotifyListeners();

      return profile;
    } catch (e, s) {
      print('error: $e');
      print('stack trace: $s');
    }

    return null;
  }

  Future<ProfileV1?> getContactProfileFromUsername(String query) async {
    try {
      final potentialUsername = query.trim().replaceFirst('@', '');

      final contact = await _contacts.getByUsername(potentialUsername);
      profile = contact?.getProfile();
      safeNotifyListeners();

      if (profile != null) {
        getProfileByUsername(
          _config,
          potentialUsername,
        ).then((result) {
          if (result != null) {
            profile = result;
            safeNotifyListeners();

            _contacts.upsert(DBContact.fromProfile(result));
          }
        });

        return profile;
      }

      profile = await getProfileByUsername(
        _config,
        potentialUsername,
      );
      safeNotifyListeners();

      if (profile != null) {
        _contacts.upsert(DBContact.fromProfile(profile!));
      }

      return profile;
    } catch (e, s) {
      print('error: $e');
      print('stack trace: $s');
    }

    return null;
  }

  Future<ProfileV1?> getContactProfileFromSerial(String serial) async {
    try {
      final potentialSerial = serial.trim();

      String? cardAddress;

      final cachedCard = await _cards.getByUid(potentialSerial);
      if (cachedCard != null) {
        cardAddress = cachedCard.account;
      }

      if (cardAddress == null) {
        final remoteAddress = await _config.cardManagerContract!.getCardAddress(
          serial,
        );

        cardAddress = remoteAddress.hexEip55;
      }

      final contact = await _contacts.getByAccount(cardAddress);
      profile = contact?.getProfile();
      safeNotifyListeners();

      if (profile != null) {
        getProfile(
          _config,
          cardAddress,
        ).then((result) => {
              if (result != null)
                {
                  _contacts.upsert(DBContact.fromProfile(result)),
                }
            });

        return profile;
      }

      profile = await getProfile(
        _config,
        cardAddress,
      );
      safeNotifyListeners();

      profile ??= ProfileV1(
        account: cardAddress,
        name: 'NFC Card',
        image: 'assets/icons/nfc.png',
        imageMedium: 'assets/icons/nfc.png',
        imageSmall: 'assets/icons/nfc.png',
      );
      safeNotifyListeners();

      return profile;
    } catch (e, s) {
      print('error: $e');
      print('stack trace: $s');
    }

    return null;
  }

  Future<Order?> loadExternalOrder(String slug, String orderId) async {
    try {
      final cachedOrder = await _ordersTable.getById(int.parse(orderId));

      if (cachedOrder != null) {
        order = cachedOrder;
        safeNotifyListeners();

        _ordersService.getOrder(slug, int.parse(orderId)).then((result) {
          order = result;
          safeNotifyListeners();
        });

        return order;
      }

      final remoteOrder =
          await _ordersService.getOrder(slug, int.parse(orderId));

      order = remoteOrder;
      safeNotifyListeners();

      return order;
    } catch (e, s) {
      print('loadExternalOrder error: $e');
      print('loadExternalOrder stack trace: $s');
    }

    return null;
  }

  Future<PlaceWithMenu?> getPlaceWithMenu(String slug) async {
    try {
      final place = await _places.getBySlug(slug);
      this.place = place;

      if (place != null) {
        apiService.getPlaceAndMenu(slug).then((result) {
          this.place = result;
          safeNotifyListeners();

          _places.upsert(result);
        });
      }

      if (place == null) {
        final remotePlace = await apiService.getPlaceAndMenu(slug);
        this.place = remotePlace;
        safeNotifyListeners();

        _places.upsert(remotePlace);
      }

      return place;
    } catch (e, s) {
      print('getPlaceWithMenu error: $e');
      print('getPlaceWithMenu stack trace: $s');
    }

    return null;
  }

  Future<void> getAccountProfile() async {
    try {
      final contact = await _contacts.getByAccount(myAddress);
      final cachedProfile = contact?.getProfile();
      if (cachedProfile != null) {
        accountProfile = cachedProfile;

        safeNotifyListeners();
      }

      accountProfile = await getProfile(
        _config,
        myAddress,
      );
      safeNotifyListeners();
    } catch (e, s) {
      debugPrint('getAccountProfile error: $e');
      debugPrint('getAccountProfile stack trace: $s');
    }
  }

  Future<bool> sendTransaction(
    String tokenAddress, {
    String? amount,
    String? message,
    Checkout? manualCheckout,
    String? serial,
  }) async {
    try {
      transactionSending = true;
      safeNotifyListeners();

      final credentials = _secureService.getCredentials();

      if (credentials == null) {
        throw Exception('Credentials not found');
      }

      final (account, key) = credentials;

      final token = _config.getToken(tokenAddress);

      final data = qrData;
      if (data == null) {
        throw Exception('Invalid QR data');
      }

      String? sendAmount = switch (data.format) {
        QRFormat.checkoutUrl =>
          order?.total != null ? order!.total.toString() : amount,
        _ => amount,
      };
      if (manualCheckout != null) {
        sendAmount = manualCheckout.total.toString();
      }
      if (sendAmount == null) {
        throw Exception('Amount is required');
      }

      String? sendMessage = switch (data.format) {
        QRFormat.checkoutUrl =>
          order?.description != null ? order!.description : message,
        _ => message,
      };
      if (manualCheckout != null) {
        sendMessage = manualCheckout.message;
      }

      final parsedAmount = toUnit(
        sendAmount,
        decimals: _config.getPrimaryToken().decimals,
      );

      if (parsedAmount == BigInt.zero) {
        throw Exception('Invalid amount');
      }

      final String? toAddress = switch (data.format) {
        QRFormat.checkoutUrl => place?.place.account,
        QRFormat.sendtoUrl => profile?.account,
        QRFormat.sendtoUrlWithEIP681 => profile?.account,
        QRFormat.accountUrl => profile?.account,
        QRFormat.eip681 => data.address,
        QRFormat.eip681Transfer => data.address,
        QRFormat.address => data.address,
        _ => null,
      };

      if (toAddress == null) {
        throw Exception('Invalid to address');
      }

      Checkout? checkout = manualCheckout;
      switch (data.format) {
        case QRFormat.checkoutUrl:
          List<CheckoutItem> items = [];
          if (order != null && place != null) {
            for (final item in order!.items) {
              final menuItem = place?.mappedItems[item.id];
              if (menuItem == null) {
                continue;
              }

              items.add(CheckoutItem(
                menuItem: menuItem,
                quantity: item.quantity,
              ));
            }
          }

          checkout = Checkout(
            items: items,
            manualAmount: double.parse(sendAmount),
            message: sendMessage,
          );
          break;
        default:
          checkout = null;
          break;
      }

      final sigAuthService = SigAuthService(credentials: key, address: account);

      final sigAuthConnection = sigAuthService.connect();

      if (serial == null) {
        // this is an account, submit tx from app
        final calldata = tokenTransferCallData(
          _config,
          account,
          toAddress,
          parsedAmount,
        );

        final (_, userOp) = await prepareUserop(
          _config,
          account,
          key,
          [token.address],
          [calldata],
        );

        final args = {
          'from': account.hexEip55,
          'to': toAddress,
        };

        if (token.standard == 'erc1155') {
          args['operator'] = account.hexEip55;
          args['id'] = '0';
          args['amount'] = parsedAmount.toString();
        } else {
          args['value'] = parsedAmount.toString();
        }

        final eventData = createEventData(
          stringSignature: transferEventStringSignature(_config),
          topic: transferEventSignature(_config),
          args: args,
        );

        final txHash = await submitUserop(
          _config,
          userOp,
          data: eventData,
          extraData: sendMessage != null && sendMessage != ''
              ? TransferData(sendMessage)
              : null,
        );

        if (txHash == null) {
          throw Exception('Transaction failed');
        }

        _audioService.txNotification();

        if (order != null && place != null) {
          final newOrder = await _ordersService.confirmOrder(
            sigAuthConnection,
            place!.place.id,
            order!.id,
            txHash,
          );

          if (newOrder == null) {
            throw Exception('Failed to create order');
          }

          _ordersTable.upsert(newOrder);
        } else {
          if (checkout != null) {
            final newOrder = await _ordersService.createOrder(
              sigAuthConnection,
              place!.place.id,
              checkout,
              txHash,
            );

            if (newOrder == null) {
              throw Exception('Failed to create order');
            }

            _ordersTable.upsert(newOrder);
          }
        }
      } else {
        // this is a card, submit tx from card as owner
        if (order != null && place != null) {
          final newOrder = await _ordersService.confirmCardOrder(
            sigAuthConnection,
            serial,
            order!.id,
          );

          if (newOrder == null) {
            throw Exception('Failed to create order');
          }

          _ordersTable.upsert(newOrder);
        } else {
          if (checkout != null) {
            final newOrder = await _ordersService.createCardOrder(
              sigAuthConnection,
              serial,
              place!.place.id,
              checkout,
              tokenAddress,
            );

            if (newOrder == null) {
              throw Exception('Failed to create order');
            }

            _ordersTable.upsert(newOrder);
          }
        }

        _audioService.txNotification();
      }

      transactionSending = false;
      safeNotifyListeners();

      return true;
    } catch (e, s) {
      debugPrint('sendTransaction error: $e');
      debugPrint('sendTransaction stack trace: $s');

      transactionSending = false;
      safeNotifyListeners();
    }

    return false;
  }

  void setShowTransactionInput(bool show) {
    showTransactionInput = show;
    safeNotifyListeners();
  }

  void setAmount(double amount) {
    this.amount = amount;
    safeNotifyListeners();
  }

  void clearParsedData() {
    _previousQRData = null;
    qrData = null;
    profile = null;
    place = null;
    order = null;
    cardProject = null;
    amount = 0.0;
    showTransactionInput = false;
    safeNotifyListeners();
  }
}
