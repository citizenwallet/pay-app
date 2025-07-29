import 'package:flutter_test/flutter_test.dart';
import 'package:pay_app/services/nfc/ndef_uri_parser.dart';
import 'dart:typed_data';

void main() {
  group('NdefUriParser Tests', () {
    test('should parse URI with http://www. prefix', () {
      final payload = Uint8List.fromList([0x01, ...'example.com'.codeUnits]);
      final result = NdefUriParser.parseUriPayload(payload);
      expect(result, equals('http://www.example.com'));
    });

    test('should parse URI with https:// prefix', () {
      final payload = Uint8List.fromList([0x04, ...'example.com'.codeUnits]);
      final result = NdefUriParser.parseUriPayload(payload);
      expect(result, equals('https://example.com'));
    });

    test('should parse URI with tel: prefix', () {
      final payload = Uint8List.fromList([0x05, ...'+1234567890'.codeUnits]);
      final result = NdefUriParser.parseUriPayload(payload);
      expect(result, equals('tel:+1234567890'));
    });

    test('should parse URI with mailto: prefix', () {
      final payload =
          Uint8List.fromList([0x06, ...'user@example.com'.codeUnits]);
      final result = NdefUriParser.parseUriPayload(payload);
      expect(result, equals('mailto:user@example.com'));
    });

    test('should parse URI with no prefix (full URI)', () {
      final payload =
          Uint8List.fromList([0x00, ...'https://example.com'.codeUnits]);
      final result = NdefUriParser.parseUriPayload(payload);
      expect(result, equals('https://example.com'));
    });

    test('should handle empty payload', () {
      final payload = Uint8List.fromList([]);
      final result = NdefUriParser.parseUriPayload(payload);
      expect(result, equals(''));
    });

    test('should handle unknown prefix code', () {
      final payload = Uint8List.fromList([0xFF, ...'example.com'.codeUnits]);
      final result = NdefUriParser.parseUriPayload(payload);
      expect(result, equals('example.com'));
    });

    test('should validate prefix codes', () {
      expect(NdefUriParser.isValidPrefixCode(0x00), isTrue);
      expect(NdefUriParser.isValidPrefixCode(0x01), isTrue);
      expect(NdefUriParser.isValidPrefixCode(0x23), isTrue);
      expect(NdefUriParser.isValidPrefixCode(0xFF), isFalse);
    });

    test('should get prefix for valid code', () {
      expect(NdefUriParser.getPrefix(0x01), equals('http://www.'));
      expect(NdefUriParser.getPrefix(0x04), equals('https://'));
      expect(NdefUriParser.getPrefix(0x05), equals('tel:'));
    });

    test('should get empty string for invalid prefix code', () {
      expect(NdefUriParser.getPrefix(0xFF), equals(''));
    });

    test('should parse URI components', () {
      final components = NdefUriParser.parseUriComponents(
          'https://example.com/path?param=value#fragment');
      expect(components['scheme'], equals('https'));
      expect(components['host'], equals('example.com'));
      expect(components['path'], equals('/path'));
      expect(components['query'], equals('param=value'));
      expect(components['fragment'], equals('fragment'));
    });

    test('should check well-known schemes', () {
      expect(NdefUriParser.isWellKnownScheme('https://example.com'), isTrue);
      expect(NdefUriParser.isWellKnownScheme('tel:+1234567890'), isTrue);
      expect(
          NdefUriParser.isWellKnownScheme('mailto:user@example.com'), isTrue);
      expect(NdefUriParser.isWellKnownScheme('custom://example.com'), isFalse);
    });

    test('should get available prefix codes', () {
      final codes = NdefUriParser.getAvailablePrefixCodes();
      expect(codes, contains(0x00));
      expect(codes, contains(0x01));
      expect(codes, contains(0x23));
      expect(codes.length, equals(36)); // Total number of defined prefixes
    });

    test('should get available prefixes', () {
      final prefixes = NdefUriParser.getAvailablePrefixes();
      expect(prefixes, contains('http://www.'));
      expect(prefixes, contains('https://'));
      expect(prefixes, contains('tel:'));
      expect(prefixes, contains('mailto:'));
    });
  });
}
