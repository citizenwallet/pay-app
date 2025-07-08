import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:pay_app/services/nfc/service.dart';
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
  Future<String> readSerialNumber(
      {String? message, String? successMessage}) async {
    // Check availability
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      throw Exception('NFC is not available');
    }

    final completer = Completer<String>();

    NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      noPlatformSoundsAndroid: true,
      alertMessageIos: message ?? 'Scan to confirm',
      onDiscovered: (NfcTag rawTag) async {
        final tag = NdefAndroid.from(rawTag);
        if (tag == null) {
          if (completer.isCompleted) return;
          completer.completeError('Invalid tag');
          return;
        }

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

        if (completer.isCompleted) return;

        await NfcManager.instance
            .stopSession(alertMessageIos: successMessage ?? 'Confirmed');

        if (isPlatformApple()) {
          // await delay(const Duration(milliseconds: 2000));
        }

        completer.complete(uid);
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
}
