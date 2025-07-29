import 'dart:convert';
import 'dart:typed_data';

/// Utility class for parsing NDEF URI records according to NFC Forum specifications
class NdefUriParser {
  /// Map of URI prefix codes to their corresponding prefixes
  /// Based on NFC Forum URI Record Type Definition
  static const Map<int, String> uriPrefixes = {
    0x00: '', // No prefix (full URI)
    0x01: 'http://www.',
    0x02: 'https://www.',
    0x03: 'http://',
    0x04: 'https://',
    0x05: 'tel:',
    0x06: 'mailto:',
    0x07: 'ftp://anonymous:anonymous@',
    0x08: 'ftp://ftp.',
    0x09: 'ftps://',
    0x0A: 'sftp://',
    0x0B: 'smb://',
    0x0C: 'nfs://',
    0x0D: 'ftp://',
    0x0E: 'dav://',
    0x0F: 'news:',
    0x10: 'telnet://',
    0x11: 'imap:',
    0x12: 'rtsp://',
    0x13: 'urn:',
    0x14: 'pop:',
    0x15: 'sip:',
    0x16: 'sips:',
    0x17: 'tftp:',
    0x18: 'btspp://',
    0x19: 'btl2cap://',
    0x1A: 'btgoep://',
    0x1B: 'tcpobex://',
    0x1C: 'irdaobex://',
    0x1D: 'file://',
    0x1E: 'urn:epc:id:',
    0x1F: 'urn:epc:tag:',
    0x20: 'urn:epc:pat:',
    0x21: 'urn:epc:raw:',
    0x22: 'urn:epc:',
    0x23: 'urn:nfc:',
  };

  /// Parse a URI payload from NDEF record
  ///
  /// [payload] - The raw payload bytes from the NDEF record
  /// Returns the complete URI string with proper prefix
  static String parseUriPayload(Uint8List payload) {
    if (payload.isEmpty) {
      return '';
    }

    final prefixCode = payload.first;
    final uriBody = payload.sublist(1);
    final uriBodyString = utf8.decode(uriBody);

    final prefix = uriPrefixes[prefixCode] ?? '';
    return prefix + uriBodyString;
  }

  /// Get the prefix string for a given prefix code
  ///
  /// [prefixCode] - The prefix code (0x00-0x23)
  /// Returns the corresponding URI prefix string
  static String getPrefix(int prefixCode) {
    return uriPrefixes[prefixCode] ?? '';
  }

  /// Check if a prefix code is valid
  ///
  /// [prefixCode] - The prefix code to validate
  /// Returns true if the prefix code is valid
  static bool isValidPrefixCode(int prefixCode) {
    return uriPrefixes.containsKey(prefixCode);
  }

  /// Get all available prefix codes
  ///
  /// Returns a list of all valid prefix codes
  static List<int> getAvailablePrefixCodes() {
    return uriPrefixes.keys.toList()..sort();
  }

  /// Get all available URI prefixes
  ///
  /// Returns a list of all available URI prefix strings
  static List<String> getAvailablePrefixes() {
    return uriPrefixes.values.toList();
  }

  /// Parse a URI and extract its components
  ///
  /// [uri] - The complete URI string
  /// Returns a map with parsed components (scheme, authority, path, etc.)
  static Map<String, String> parseUriComponents(String uri) {
    try {
      final uriObj = Uri.parse(uri);
      return {
        'scheme': uriObj.scheme,
        'authority': uriObj.authority,
        'path': uriObj.path,
        'query': uriObj.query,
        'fragment': uriObj.fragment,
        'host': uriObj.host,
        'port': uriObj.port?.toString() ?? '',
      };
    } catch (e) {
      return {};
    }
  }

  /// Check if a URI is a well-known scheme
  ///
  /// [uri] - The URI to check
  /// Returns true if the URI uses a well-known scheme
  static bool isWellKnownScheme(String uri) {
    final schemes = [
      'http',
      'https',
      'tel',
      'mailto',
      'ftp',
      'ftps',
      'sftp',
      'smb',
      'nfs',
      'dav',
      'news',
      'telnet',
      'imap',
      'rtsp',
      'urn',
      'pop',
      'sip',
      'sips',
      'tftp',
      'btspp',
      'btl2cap',
      'btgoep',
      'tcpobex',
      'irdaobex',
      'file'
    ];

    try {
      final uriObj = Uri.parse(uri);
      return schemes.contains(uriObj.scheme.toLowerCase());
    } catch (e) {
      return false;
    }
  }

  /// Encode a URI for NDEF record payload
  ///
  /// [uri] - The complete URI string to encode
  /// Returns the encoded payload bytes for NDEF URI record
  static Uint8List encodeUriPayload(String uri) {
    if (uri.isEmpty) {
      return Uint8List(0);
    }

    try {
      // Find the appropriate prefix code
      int? prefixCode;
      String uriBody = uri;

      // Check for exact matches first
      for (final entry in uriPrefixes.entries) {
        if (uri.startsWith(entry.value)) {
          prefixCode = entry.key;
          uriBody = uri.substring(entry.value.length);
          break;
        }
      }

      // If no prefix found, use 0x00 (no prefix)
      if (prefixCode == null) {
        prefixCode = 0x00;
        uriBody = uri;
      }

      // Create payload: prefix code + URI body
      final prefixCodeBytes = Uint8List.fromList([prefixCode]);
      final uriBodyBytes = utf8.encode(uriBody);

      return Uint8List.fromList([...prefixCodeBytes, ...uriBodyBytes]);
    } catch (e) {
      // If URI parsing fails, encode as-is with no prefix
      return Uint8List.fromList([0x00, ...utf8.encode(uri)]);
    }
  }
}
