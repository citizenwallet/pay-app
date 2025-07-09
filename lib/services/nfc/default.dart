import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:pay_app/services/nfc/service.dart';
import 'package:pay_app/services/nfc/ndef_uri_parser.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:pay_app/utils/platform.dart';
import 'package:nfc_manager/nfc_manager.dart';

class DefaultNFCService implements NFCService {
  @override
  NFCScannerDirection get direction =>
      Platform.isAndroid ? NFCScannerDirection.right : NFCScannerDirection.top;

  @override
  Future<void> printReceipt(
      {String? amount,
      String? symbol,
      String? description,
      String? link}) async {}

  @override
  Future<(String, String?)> readTag(
      {String? message, String? successMessage}) async {
    // Check availability
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      throw Exception('NFC is not available');
    }

    final completer = Completer<(String, String?)>();

    NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      noPlatformSoundsAndroid: true,
      alertMessageIos: message ?? 'Scan to confirm',
      onDiscovered: (NfcTag rawTag) async {
        final tag = Ndef.from(rawTag);
        if (tag == null) {
          if (completer.isCompleted) return;
          completer.completeError('Invalid tag');
          return;
        }

        // ignore: invalid_use_of_protected_member
        final Uint8List? identifier = parseTagIdentifier(rawTag);
        if (identifier == null) {
          if (completer.isCompleted) return;
          completer.completeError('Invalid tag');
          return;
        }

        final String? payload = parseTagFirstPayload(rawTag);

        String uid = identifier
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join()
            .toUpperCase();

        if (completer.isCompleted) return;

        await NfcManager.instance
            .stopSession(alertMessageIos: successMessage ?? 'Confirmed');

        if (isPlatformApple()) {
          await delay(const Duration(milliseconds: 2000));
        }

        completer.complete((uid, payload));
      },
      onSessionErrorIos: (error) async {
        if (completer.isCompleted) return;
        completer.completeError(error); // Complete the Future with the error
      },
    );

    return completer.future;
  }

  @override
  Future<(String, String?)> configureTag(String baseUri,
      {String? message, String? successMessage}) async {
    // Check availability
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      throw Exception('NFC is not available');
    }

    final completer = Completer<(String, String?)>();

    NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      noPlatformSoundsAndroid: true,
      alertMessageIos: message ?? 'Scan to configured',
      onDiscovered: (NfcTag rawTag) async {
        final tag = Ndef.from(rawTag);
        if (tag == null) {
          if (completer.isCompleted) return;
          completer.completeError('Invalid tag');
          return;
        }

        if (!tag.isWritable) {
          if (completer.isCompleted) return;
          completer.completeError('This card cannot be configured');
          return;
        }

        // ignore: invalid_use_of_protected_member
        final Uint8List? identifier = parseTagIdentifier(rawTag);
        if (identifier == null) {
          if (completer.isCompleted) return;
          completer.completeError('Invalid tag');
          return;
        }

        String uid = identifier
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join()
            .toUpperCase();

        final uri = Uri.parse('$baseUri/$uid');

        final message = NdefMessage(records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: utf8.encode('U'),
            identifier: identifier,
            payload: NdefUriParser.encodeUriPayload(uri.toString()),
          ),
        ]);

        await tag.write(message: message);

        if (completer.isCompleted) return;

        await NfcManager.instance
            .stopSession(alertMessageIos: successMessage ?? 'Card configured');

        if (isPlatformApple()) {
          await delay(const Duration(milliseconds: 2000));
        }

        completer.complete((uid, uri.toString()));
      },
      onSessionErrorIos: (error) async {
        if (completer.isCompleted) return;
        completer.completeError(error); // Complete the Future with the error
      },
    );

    return completer.future;
  }

  @override
  Future<void> stop() async {
    await NfcManager.instance.stopSession();
  }

  @override
  Future<bool> isAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  Uint8List? parseTagIdentifier(NfcTag rawTag) {
    if (isPlatformApple()) {
      // try MiFareIos (seems to be the only one that works on ios)
      final mifare = MiFareIos.from(rawTag);
      if (mifare != null) {
        return mifare.identifier;
      }

      // try Iso15693Ios
      final iso15693 = Iso15693Ios.from(rawTag);
      if (iso15693 != null) {
        return iso15693.identifier;
      }

      // try Iso7816Ios
      final iso7816 = Iso7816Ios.from(rawTag);
      if (iso7816 != null) {
        return iso7816.identifier;
      }

      // try NdefIos
      final ndef = NdefIos.from(rawTag);
      if (ndef != null) {
        return ndef.cachedNdefMessage?.records.first.identifier;
      }

      return null;
    }

    // Try NdefAndroid first
    final ndef = NdefAndroid.from(rawTag);
    if (ndef != null) {
      return ndef.tag.id;
    }

    // Try NfcAAndroid
    final nfcA = NfcAAndroid.from(rawTag);
    if (nfcA != null) {
      return nfcA.tag.id;
    }

    // Try NfcBAndroid
    final nfcB = NfcBAndroid.from(rawTag);
    if (nfcB != null) {
      return nfcB.tag.id;
    }

    // Try NfcFAndroid
    final nfcF = NfcFAndroid.from(rawTag);
    if (nfcF != null) {
      return nfcF.tag.id;
    }

    // Try NfcVAndroid
    final nfcV = NfcVAndroid.from(rawTag);
    if (nfcV != null) {
      return nfcV.tag.id;
    }

    // Try IsoDepAndroid
    final isoDep = IsoDepAndroid.from(rawTag);
    if (isoDep != null) {
      return isoDep.tag.id;
    }

    // Try MifareClassicAndroid
    final mifareClassic = MifareClassicAndroid.from(rawTag);
    if (mifareClassic != null) {
      return mifareClassic.tag.id;
    }

    // Try MifareUltralightAndroid
    final mifareUltralight = MifareUltralightAndroid.from(rawTag);
    if (mifareUltralight != null) {
      return mifareUltralight.tag.id;
    }

    // Try NfcBarcodeAndroid
    final nfcBarcode = NfcBarcodeAndroid.from(rawTag);
    if (nfcBarcode != null) {
      return nfcBarcode.tag.id;
    }

    // Try NdefFormatableAndroid
    final ndefFormatable = NdefFormatableAndroid.from(rawTag);
    if (ndefFormatable != null) {
      return ndefFormatable.tag.id;
    }

    return null;
  }

  String? parseTagFirstPayload(NfcTag rawTag) {
    return parseTagURIRecord(rawTag);
  }

  String? parseTagURIRecord(NfcTag rawTag) {
    if (isPlatformApple()) {
      final ndef = NdefIos.from(rawTag);
      if (ndef != null) {
        final message =
            NdefMessage(records: ndef.cachedNdefMessage?.records ?? []);
        if (message.records.isEmpty) {
          return null;
        }

        for (final record in message.records) {
          if (record.typeNameFormat == TypeNameFormat.empty) {
            continue;
          }

          if (record.typeNameFormat == TypeNameFormat.wellKnown) {
            // Check if this is a URI record (type 'U')
            if (record.type.length == 1 && record.type.first == 0x55) {
              return parseURIPayload(record.payload);
            }
          }

          if (record.typeNameFormat == TypeNameFormat.absoluteUri) {
            return utf8.decode(record.payload);
          }
        }

        return null;
      }
    } else {
      // Android implementation
      final ndef = NdefAndroid.from(rawTag);
      if (ndef != null) {
        try {
          final message = ndef.cachedNdefMessage;
          if (message != null && message.records.isNotEmpty) {
            for (final record in message.records) {
              if (record.typeNameFormat == TypeNameFormat.empty) {
                continue;
              }

              if (record.typeNameFormat == TypeNameFormat.wellKnown) {
                // Check if this is a URI record (type 'U')
                if (record.type.length == 1 && record.type.first == 0x55) {
                  return parseURIPayload(record.payload);
                }
              }

              if (record.typeNameFormat == TypeNameFormat.absoluteUri) {
                return utf8.decode(record.payload);
              }
            }
          }
        } catch (e) {
          // Handle potential errors when reading NDEF message
          return null;
        }
      }
    }

    return null;
  }

  String parseURIPayload(Uint8List payload) {
    return NdefUriParser.parseUriPayload(payload);
  }
}
