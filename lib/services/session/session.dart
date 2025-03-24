import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart';
import 'package:pay_app/services/api/api.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final APIService _apiService = APIService(
    baseURL: dotenv.env['DASHBOARD_API_BASE_URL'] ?? '',
  );

  EthereumAddress get provider =>
      EthereumAddress.fromHex(dotenv.get('SESSION_PROVIDER'));

  /// Generates a salt from source and type
  Uint8List generateSessionSalt(String source, String type) {
    final saltString = '$source:$type';
    return keccak256(utf8.encode(saltString));
  }

  /// Generates a hash for session request
  Uint8List generateSessionRequestHash(
    String sessionProvider,
    String sessionOwner,
    Uint8List salt,
    int expiry,
  ) {
    final providerAddr = EthereumAddress.fromHex(sessionProvider);
    final ownerAddr = EthereumAddress.fromHex(sessionOwner);

    final packed = LengthTrackingByteSink();

    final List<AbiType> encoders = [
      parseAbiType('address'),
      parseAbiType('address'),
      parseAbiType('bytes32'),
      parseAbiType('uint48'),
    ];

    final List<dynamic> values = [
      providerAddr,
      ownerAddr,
      salt,
      BigInt.from(expiry),
    ];

    for (var i = 0; i < encoders.length; i++) {
      encoders[i].encode(values[i], packed);
    }

    return keccak256(packed.asBytes());
  }

  Uint8List generateSessionHash(Uint8List sessionRequestHash, int challenge) {
    final packed = LengthTrackingByteSink();

    final List<AbiType> encoders = [
      parseAbiType('bytes32'),
      parseAbiType('uint256'),
    ];

    final List<dynamic> values = [
      sessionRequestHash,
      BigInt.from(challenge),
    ];

    for (var i = 0; i < encoders.length; i++) {
      encoders[i].encode(values[i], packed);
    }

    return keccak256(packed.asBytes());
  }

  /// Creates a session request
  Future<(String, Uint8List)?> request(
    EthPrivateKey privateKey,
    String source,
  ) async {
    try {
      final sessionOwner = privateKey.address.hexEip55;
      final sessionType = 'sms';

      // Generate expiry timestamp (current time + 365 days in seconds)
      final expiry = (DateTime.now().millisecondsSinceEpoch ~/ 1000) +
          (60 * 60 * 24 * 365); // 365 days

      // Generate salt
      final salt = generateSessionSalt(source, sessionType);

      // Generate hash
      final hash = generateSessionRequestHash(
        provider.hexEip55,
        sessionOwner,
        salt,
        expiry,
      );

      // Sign the hash
      final signature = privateKey.signPersonalMessageToUint8List(hash);
      final signatureHex = bytesToHex(signature, include0x: true);

      // Create request body
      final requestBody = {
        'provider': provider.hexEip55,
        'owner': sessionOwner,
        'source': source,
        'type': sessionType,
        'expiry': expiry,
        'signature': signatureHex,
      };

      // Send POST request
      final response = await _apiService.post(
        url: '/app/session',
        body: requestBody,
      );

      return (response['sessionRequestTxHash'] as String, hash);
    } catch (e, s) {
      debugPrint('Failed to create session request: $e');
      debugPrint('Stack trace: $s');
      return null;
    }
  }

  /// Updates a session with confirmation
  Future<String?> confirm(
    EthPrivateKey privateKey,
    Uint8List sessionRequestHash,
    int challenge,
  ) async {
    try {
      final sessionOwner = privateKey.address.hexEip55;

      // Convert sessionRequestHash to hex string
      final sessionRequestHashHex =
          bytesToHex(sessionRequestHash, include0x: true);

      final sessionHash = generateSessionHash(
        sessionRequestHash,
        challenge,
      );
      final sessionHashHex = bytesToHex(sessionHash, include0x: true);

      // Sign the session hash
      // final signedSessionHash = privateKey
      //     .signPersonalMessageToUint8List(utf8.encode(sessionHashHex));
      final signedSessionHash = privateKey.signPersonalMessageToUint8List(
        sessionHash,
      );
      final signedSessionHashHex =
          bytesToHex(signedSessionHash, include0x: true);

      // Create request body
      final requestBody = {
        'provider': provider.hexEip55,
        'owner': sessionOwner,
        'sessionRequestHash': sessionRequestHashHex,
        'sessionHash': sessionHashHex,
        'signedSessionHash': signedSessionHashHex,
      };

      // Send PATCH request
      final response = await _apiService.patch(
        url: '/app/session',
        body: requestBody,
      );

      return response['sessionConfirmTxHash'] as String;
    } catch (e, s) {
      debugPrint('Failed to update session: $e');
      debugPrint('Stack trace: $s');
    }

    return null;
  }
}
