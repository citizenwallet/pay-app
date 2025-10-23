import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/services/secure/secure.dart';
import 'package:pay_app/services/session/session.dart';
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
  final PreferencesService _preferencesService = PreferencesService();
  final SecureService _secureService = SecureService();
  late SessionService _sessionService;
  final Config _config;

  // private variables here
  final TextEditingController _phoneNumberController = TextEditingController(
    text: dotenv.get('DEFAULT_PHONE_COUNTRY_CODE'),
  );
  final TextEditingController _challengeController = TextEditingController();

  TextEditingController get phoneNumberController => _phoneNumberController;
  TextEditingController get challengeController => _challengeController;

  EthPrivateKey? _sessionRequestPrivateKey;
  Uint8List? _sessionRequestHash;
  EthereumAddress? _tempAccountAddress;

  // constructor here
  OnboardingState(this._config) {
    connectedAccountAddress = getAccountAddress();
    init();
  }

  Future<void> init() async {
    _sessionService = SessionService(_config);

    // Check for persisted pending session (SMS sent but not confirmed)
    final pendingSession = _secureService.getPendingSession();
    if (pendingSession != null) {
      debugPrint('Restoring pending session from storage');
      final (sessionKey, sessionHash, accountAddress) = pendingSession;
      _sessionRequestPrivateKey = sessionKey;
      _sessionRequestHash = sessionHash;
      _tempAccountAddress = accountAddress;
      sessionRequestStatus = SessionRequestStatus.challenge;
    }
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
  EthereumAddress? connectedAccountAddress;

  bool touched = false;
  String? regionCode;
  bool challengeTouched = false;
  String? challenge;

  SessionRequestStatus sessionRequestStatus = SessionRequestStatus.none;

  Future<void> reset() async {
    await _secureService.clearPendingSession();

    sessionRequestStatus = SessionRequestStatus.none;
    _sessionRequestHash = null;
    _sessionRequestPrivateKey = null;
    _tempAccountAddress = null;

    touched = false;
    regionCode = null;
    challengeTouched = false;
    challenge = null;

    phoneNumberController.clear();
    challengeController.clear();
  }

  void clearConnectedAccountAddress() {
    connectedAccountAddress = null;
    _preferencesService.clear();
    safeNotifyListeners();
  }

  Future<void> retry() async {
    // Clear any saved credentials since session was not successfully confirmed
    await _secureService.clearCredentials();
    await _secureService.clearPendingSession();

    sessionRequestStatus = SessionRequestStatus.none;
    _sessionRequestHash = null;
    _sessionRequestPrivateKey = null;
    _tempAccountAddress = null;

    challenge = null;
    challengeTouched = false;

    challengeController.clear();

    safeNotifyListeners();
  }

  Future<void> goBackToPhoneEntry() async {
    // Clear any saved credentials since session was not successfully confirmed
    await _secureService.clearCredentials();
    await _secureService.clearPendingSession();

    sessionRequestStatus = SessionRequestStatus.none;
    _sessionRequestHash = null;
    _sessionRequestPrivateKey = null;
    _tempAccountAddress = null;

    challenge = null;
    challengeTouched = false;
    touched = false;
    regionCode = null;

    phoneNumberController.text = dotenv.get('DEFAULT_PHONE_COUNTRY_CODE');
    challengeController.clear();

    safeNotifyListeners();
  }

  bool tryEnterPreviousCode() {
    // Try to restore any pending session from storage
    final pendingSession = _secureService.getPendingSession();
    if (pendingSession != null) {
      debugPrint('Restoring pending session for code entry');
      final (sessionKey, sessionHash, accountAddress) = pendingSession;
      _sessionRequestPrivateKey = sessionKey;
      _sessionRequestHash = sessionHash;
      _tempAccountAddress = accountAddress;
      sessionRequestStatus = SessionRequestStatus.challenge;
      challengeController.clear();
      challenge = null;
      challengeTouched = false;
      safeNotifyListeners();
      return true;
    } else {
      debugPrint('No pending session found - cannot enter code');
      // Cannot proceed without session data
      return false;
    }
  }

  EthereumAddress? getAccountAddress() {
    final lastAccount = _preferencesService.lastAccount;
    if (lastAccount != null) {
      return EthereumAddress.fromHex(lastAccount);
    }

    final credentials = _secureService.getCredentials();
    if (credentials == null) {
      return null;
    }

    final (account, _) = credentials;

    return account;
  }

  Future<EthereumAddress?> isSessionExpired() async {
    try {
      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        return null;
      }

      final (account, privateKey) = credentials;

      // Check if account exists on-chain first to catch broken states
      // where credentials were saved but account was never created
      try {
        final exists = await accountExists(_config, account);
        if (!exists) {
          debugPrint('Account does not exist on-chain during session check');
          await _secureService.clearCredentials();
          await _preferencesService.clear();
          return null;
        }
      } catch (e) {
        debugPrint('Error checking account existence: $e');
        // Network error - don't clear credentials, just skip the check
        // and proceed to session expiry check
      }

      final isExpired = await _config.sessionManagerModuleContract.isExpired(
        account,
        privateKey.address,
      );

      if (isExpired) {
        await _secureService.clearCredentials();
        return null;
      }

      return account;
    } catch (e, s) {
      debugPrint('error checking session: $e');
      debugPrint('stack trace: $s');
      // On errors, assume session is valid to avoid navigation loops
      // Return null to stay on onboarding screen
      return null;
    }
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

      final provider = EthereumAddress.fromHex(
        _config.getPrimarySessionManager().providerAddress,
      );

      final twoFAAddress = await _config.twoFAFactoryContract.getAddress(
        provider,
        salt,
      );

      // Store the account address temporarily - credentials will be saved after confirmation
      _tempAccountAddress = twoFAAddress;

      // Persist the pending session so it survives app restarts
      await _secureService.setPendingSession(
        _sessionRequestPrivateKey!,
        _sessionRequestHash!,
        _tempAccountAddress!,
      );

      sessionRequestStatus = SessionRequestStatus.challenge;
      safeNotifyListeners();
    } catch (e, s) {
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'Error requesting session',
      );
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

      if (_tempAccountAddress == null) {
        throw Exception('Account address not found');
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

      // Now that session is confirmed, save credentials
      await _secureService.setCredentials(
        _tempAccountAddress!,
        _sessionRequestPrivateKey!,
      );

      // Clear pending session from storage
      await _secureService.clearPendingSession();

      sessionRequestStatus = SessionRequestStatus.confirmed;
      safeNotifyListeners();

      final account = _tempAccountAddress!;

      // Clean up temporary variables
      _sessionRequestPrivateKey = null;
      _tempAccountAddress = null;

      connectedAccountAddress = account;

      return account;
    } catch (e, s) {
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'Error confirming session',
      );
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
