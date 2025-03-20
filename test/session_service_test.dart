import 'package:flutter_test/flutter_test.dart';
import 'package:web3dart/crypto.dart';
import 'package:pay_app/services/session/session.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  late SessionService sessionService;

  setUp(() async {
    // Initialize dotenv if needed for tests
    await dotenv.load(fileName: '.env');
    sessionService = SessionService();
  });

  group('SessionService', () {
    test('generateSessionRequestHash should produce the expected hash', () {
      // Given
      final provider = '0xF3004A1690f97Cf5d307eDc5958a7F76b62f9FC9';
      final owner = '0x7479Cf7f93676Acd82608105B75Ce7fd12B6CF7E';
      final source = '+32478163203';
      final type = 'sms';
      final expiry = 1741701361;

      // Expected hash
      final expectedHash =
          '0xe6d82f76be30881b9ea730417c9ab833c37357b26771d4c562ddcd8a18ae15ba';

      // Generate salt
      final salt = sessionService.generateSessionSalt(source, type);

      // When
      final hash = sessionService.generateSessionRequestHash(
        provider,
        owner,
        salt,
        expiry,
      );

      // Then
      final hashHex = bytesToHex(hash, include0x: true);
      expect(hashHex.toLowerCase(), equals(expectedHash.toLowerCase()));
    });

    test('generateSessionSalt should produce consistent salt', () {
      // Given
      final source = '+32478163203';
      final type = 'sms';

      // When
      final salt1 = sessionService.generateSessionSalt(source, type);
      final salt2 = sessionService.generateSessionSalt(source, type);

      // Then
      expect(bytesToHex(salt1), equals(bytesToHex(salt2)));
    });

    test('full session request flow with manual values', () {
      // Given
      final provider = '0xF3004A1690f97Cf5d307eDc5958a7F76b62f9FC9';
      final owner = '0x7479Cf7f93676Acd82608105B75Ce7fd12B6CF7E';
      final source = '+32478163203';
      final type = 'sms';
      final expiry = 1741701361;

      // Expected hash
      final expectedHash =
          '0xe6d82f76be30881b9ea730417c9ab833c37357b26771d4c562ddcd8a18ae15ba';

      // Step 1: Generate salt
      final salt = sessionService.generateSessionSalt(source, type);

      // Step 2: Generate hash
      final hash = sessionService.generateSessionRequestHash(
        provider,
        owner,
        salt,
        expiry,
      );

      final hashHex = bytesToHex(hash, include0x: true);

      expect(hashHex.toLowerCase(), equals(expectedHash.toLowerCase()));
    });
  });
}
