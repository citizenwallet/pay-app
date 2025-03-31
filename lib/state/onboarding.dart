import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/session/session.dart';
import 'package:pay_app/services/wallet/contracts/session_manager_module.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

enum SessionRequestStatus {
  none,
  pending,
  challenge,
  confirming,
  confirmed,
  failed,
  confirmFailed,
}

class OnboardingState with ChangeNotifier {
  // instantiate services here
  final ConfigService _configService = ConfigService();
  final SecureService _secureService = SecureService();
  final SessionService _sessionService = SessionService();
  late Config _config;

  // private variables here
  final TextEditingController _phoneNumberController = TextEditingController(
    text: dotenv.get('DEFAULT_PHONE_COUNTRY_CODE'),
  );
  final TextEditingController _challengeController = TextEditingController();

  TextEditingController get phoneNumberController => _phoneNumberController;
  TextEditingController get challengeController => _challengeController;

  EthPrivateKey? _sessionRequestPrivateKey;
  Uint8List? _sessionRequestHash;

  // constructor here
  OnboardingState() {
    init();
  }

  Future<void> init() async {
    final config = await _configService.getLocalConfig();
    if (config == null) {
      throw Exception('Community not found in local asset');
    }

    await config.initContracts();

    _config = config;
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
  bool touched = false;
  String? regionCode;
  bool challengeTouched = false;
  String? challenge;

  SessionRequestStatus sessionRequestStatus = SessionRequestStatus.none;

  void reset() {
    sessionRequestStatus = SessionRequestStatus.none;
    _sessionRequestHash = null;
    _sessionRequestPrivateKey = null;

    touched = false;
    regionCode = null;
    challengeTouched = false;
    challenge = null;

    phoneNumberController.clear();
    challengeController.clear();
  }

  void retry() {
    sessionRequestStatus = SessionRequestStatus.none;
    _sessionRequestHash = null;
    _sessionRequestPrivateKey = null;

    challenge = null;
    challengeTouched = false;

    challengeController.clear();

    safeNotifyListeners();
  }

  EthereumAddress? getAccountAddress() {
    final credentials = _secureService.getCredentials();
    if (credentials == null) {
      return null;
    }

    final (account, _) = credentials;

    return account;
  }

  Future<EthereumAddress?> isSessionExpired() async {
    final credentials = _secureService.getCredentials();
    if (credentials == null) {
      return null;
    }

    final (account, privateKey) = credentials;

    final sessionManagerModuleService =
        await sessionManagerModuleServiceFromConfig(_config);

    final isExpired = await sessionManagerModuleService.isExpired(
      account,
      privateKey.address,
    );

    if (isExpired) {
      return null;
    }

    return account;
  }

  // state methods here
  Future<void> requestSession(String source) async {
    try {
      sessionRequestStatus = SessionRequestStatus.pending;
      _sessionRequestHash = null;
      safeNotifyListeners();

      String? parsedSource;
      try {
        final result = await parse(source);

        parsedSource = result['e164'];
      } catch (e) {
        throw Exception('Invalid phone number');
      }
      if (parsedSource == null) {
        throw Exception('Invalid phone number');
      }

      final random = Random.secure();
      _sessionRequestPrivateKey = EthPrivateKey.createRandom(random);

      final response = await _sessionService.request(
          _sessionRequestPrivateKey!, parsedSource);

      if (response == null) {
        throw Exception('Failed to request session');
      }

      final sessionRequestTxHash = response.$1;
      _sessionRequestHash = response.$2;

      final success = await waitForTxSuccess(_config, sessionRequestTxHash);
      if (!success) {
        throw Exception('Failed to wait for session request tx to be mined');
      }

      final salt = generateSessionSalt(parsedSource, 'sms');

      final twoFAAddress = await _config.twoFAFactoryContract.getAddress(
        _sessionService.provider,
        salt,
      );

      await _secureService.setCredentials(
        twoFAAddress,
        _sessionRequestPrivateKey!,
      );

      sessionRequestStatus = SessionRequestStatus.challenge;
      safeNotifyListeners();
    } catch (e, s) {
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
      sessionRequestStatus = SessionRequestStatus.failed;
      safeNotifyListeners();
    }
  }

  Future<EthereumAddress?> confirmSession(String challenge) async {
    try {
      if (_sessionRequestPrivateKey == null) {
        throw Exception('Session request private key not found');
      }

      if (_sessionRequestHash == null) {
        throw Exception('Session request hash not found');
      }

      sessionRequestStatus = SessionRequestStatus.confirming;
      safeNotifyListeners();

      final parsedChallenge = int.parse(challenge);

      final sessionConfirmRequestTxHash = await _sessionService.confirm(
        _sessionRequestPrivateKey!,
        _sessionRequestHash!,
        parsedChallenge,
      );
      if (sessionConfirmRequestTxHash == null) {
        throw Exception('Failed to confirm session');
      }

      final success =
          await waitForTxSuccess(_config, sessionConfirmRequestTxHash);
      if (!success) {
        throw Exception('Failed to wait for session request tx to be mined');
      }

      sessionRequestStatus = SessionRequestStatus.confirmed;
      safeNotifyListeners();

      _sessionRequestPrivateKey = null;

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        throw Exception('No credentials found');
      }

      final (account, _) = credentials;

      return account;
    } catch (e, s) {
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
      sessionRequestStatus = SessionRequestStatus.confirmFailed;
      safeNotifyListeners();

      return null;
    }
  }

  Future<void> formatPhoneNumber(String phoneNumber) async {
    try {
      final result = await parse(phoneNumber);

      regionCode = result['region_code'];
    } catch (e) {
      regionCode = null;
    }

    touched = true;

    safeNotifyListeners();
  }

  void updateChallenge(String? challenge) {
    this.challenge = challenge;
    challengeTouched = true;
    safeNotifyListeners();
  }
}
