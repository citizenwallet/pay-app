// TODO: implement this with biometrics instead
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class SecureService {
  static final SecureService _instance = SecureService._internal();

  factory SecureService() => _instance;
  SecureService._internal();

  static const String _versionKey = 'secure_version';
  static const int version = 1;

  late SharedPreferences _preferences;

  static const String _privateKeyKey = 'ethereum_private_key';
  static const String _pendingSessionKey = 'pending_session';

  Future init(SharedPreferences pref) async {
    _preferences = pref;

    final version = _preferences.getInt(_versionKey);
    if (version == null || version < SecureService.version) {
      await migrate(version ?? 0, SecureService.version);
    }
  }

  Future migrate(int oldVersion, int newVersion) async {
    switch (newVersion) {
      case 1:
        // migrate to version 1
        _preferences.setInt(_versionKey, newVersion);
        break;
      default:
    }
  }

  Future clear() async {
    await _preferences.clear();
  }

  // Save private key with account address
  Future setCredentials(
      EthereumAddress accountAddress, EthPrivateKey privateKey) async {
    final privateKeyHex = bytesToHex(privateKey.privateKey);
    final storedValue = '${accountAddress.hexEip55}:$privateKeyHex';
    await _preferences.setString(_privateKeyKey, storedValue);
  }

  // Get private key without needing arguments
  (EthereumAddress, EthPrivateKey)? getCredentials() {
    final storedValue = _preferences.getString(_privateKeyKey);
    if (storedValue == null) return null;

    try {
      final parts = storedValue.split(':');
      if (parts.length != 2) return null;

      final privateKeyHex = parts[1];
      return (
        EthereumAddress.fromHex(parts[0]),
        EthPrivateKey.fromHex(privateKeyHex),
      );
    } catch (_) {
      return null;
    }
  }

  // Get account address associated with the stored private key
  String? getAccountAddress() {
    final storedValue = _preferences.getString(_privateKeyKey);
    if (storedValue == null) return null;

    final parts = storedValue.split(':');
    if (parts.length != 2) return null;

    return parts[0];
  }

  // Check if a private key is stored
  bool hasCredentials() {
    return _preferences.containsKey(_privateKeyKey);
  }

  // Delete the stored private key
  Future clearCredentials() async {
    await _preferences.remove(_privateKeyKey);
  }

  // Save pending session state (for SMS code waiting)
  Future setPendingSession(
    EthPrivateKey sessionKey,
    Uint8List sessionHash,
    EthereumAddress accountAddress,
  ) async {
    final sessionKeyHex = bytesToHex(sessionKey.privateKey);
    final sessionHashHex = bytesToHex(sessionHash);
    final storedValue =
        '${accountAddress.hexEip55}:$sessionKeyHex:$sessionHashHex';
    await _preferences.setString(_pendingSessionKey, storedValue);
  }

  // Get pending session state
  (EthPrivateKey, Uint8List, EthereumAddress)? getPendingSession() {
    final storedValue = _preferences.getString(_pendingSessionKey);
    if (storedValue == null) return null;

    try {
      final parts = storedValue.split(':');
      if (parts.length != 3) return null;

      return (
        EthPrivateKey.fromHex(parts[1]),
        hexToBytes(parts[2]),
        EthereumAddress.fromHex(parts[0]),
      );
    } catch (_) {
      return null;
    }
  }

  // Clear pending session state
  Future clearPendingSession() async {
    await _preferences.remove(_pendingSessionKey);
  }
}
