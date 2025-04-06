import 'package:flutter_test/flutter_test.dart';
import 'package:web3dart/crypto.dart';
import 'package:pay_app/services/session/session.dart';

void main() {
  setUp(() async {
    // Initialize dotenv if needed for tests
  });

  group('SessionService Hash Generation', () {
    test('generateSessionRequestHash should produce the expected hash', () {
      // Given
      final provider = '0xF3004A1690f97Cf5d307eDc5958a7F76b62f9FC9';
      final owner = '0x7aCA83D8270d61824195d459Fef373D9B61A83E0';
      final source = '+32478123123';
      final type = 'sms';
      final expiry = 1741704470;

      // Expected hash
      final expectedHash =
          '0x79d7d5c7ac68a4c4bf9bf7402aea177c3c78def1df5f683693f472aea3017af2';

      // Generate salt
      final salt = generateSessionSalt(source, type);

      // When
      final hash = generateSessionRequestHash(
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
      final source = '+32478123123';
      final type = 'sms';

      // When
      final salt1 = generateSessionSalt(source, type);
      final salt2 = generateSessionSalt(source, type);

      // Then
      expect(bytesToHex(salt1), equals(bytesToHex(salt2)));
    });

    test('different expiry values should produce different hashes', () {
      // Given
      final provider = '0xF3004A1690f97Cf5d307eDc5958a7F76b62f9FC9';
      final owner = '0x7aCA83D8270d61824195d459Fef373D9B61A83E0';
      final source = '+32478123123';
      final type = 'sms';
      final salt = generateSessionSalt(source, type);

      // When
      final hash1 = generateSessionRequestHash(
        provider,
        owner,
        salt,
        1741704470,
      );

      final hash2 = generateSessionRequestHash(
        provider,
        owner,
        salt,
        1741704471, // One second later
      );

      // Then
      expect(bytesToHex(hash1), isNot(equals(bytesToHex(hash2))));
    });

    test('different owners should produce different hashes', () {
      // Given
      final provider = '0xF3004A1690f97Cf5d307eDc5958a7F76b62f9FC9';
      final owner1 = '0x7aCA83D8270d61824195d459Fef373D9B61A83E0';
      final owner2 = '0x7479Cf7f93676Acd82608105B75Ce7fd12B6CF7E';
      final source = '+32478123123';
      final type = 'sms';
      final expiry = 1741704470;
      final salt = generateSessionSalt(source, type);

      // When
      final hash1 = generateSessionRequestHash(
        provider,
        owner1,
        salt,
        expiry,
      );

      final hash2 = generateSessionRequestHash(
        provider,
        owner2,
        salt,
        expiry,
      );

      // Then
      expect(bytesToHex(hash1), isNot(equals(bytesToHex(hash2))));
    });
  });
}
