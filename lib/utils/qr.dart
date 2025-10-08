import 'package:pay_app/services/wallet/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class QRData {
  final String rawValue;
  final QRFormat format;
  final String address;

  QRData({
    required this.rawValue,
    required this.format,
    required this.address,
  });

  factory QRData.fromRawValue(String rawValue) {
    final format = parseQRFormat(rawValue);
    final (address, _, _, _) = parseQRCode(rawValue);
    return QRData(
      rawValue: rawValue,
      format: format,
      address: address,
    );
  }
}

// enum that represents the different qr code formats
enum QRFormat {
  address,
  voucher,
  eip681,
  eip681Transfer,
  receiveUrl,
  sendtoUrl,
  sendtoUrlWithEIP681,
  checkoutUrl,
  cardUrl,
  accountUrl,
  url,
  unsupported,
}

QRFormat parseQRFormat(String raw) {
  if (raw.startsWith('ethereum:') && !raw.contains('/')) {
    return QRFormat.eip681;
  } else if (raw.startsWith('ethereum:') && raw.contains('/transfer')) {
    return QRFormat.eip681Transfer;
  } else if (raw.startsWith('https://') && raw.contains('eip681=')) {
    return QRFormat.sendtoUrlWithEIP681;
  } else if (raw.startsWith('http://') && raw.contains('sendto=')) {
    return QRFormat.sendtoUrl;
  } else if (raw.startsWith('https://') && raw.contains('sendto=')) {
    return QRFormat.sendtoUrl;
  } else if (raw.startsWith('0x')) {
    return QRFormat.address;
  } else if (raw.contains('receiveParams=')) {
    return QRFormat.receiveUrl;
  } else if (raw.contains('voucher=')) {
    return QRFormat.voucher;
  } else if (raw.contains(dotenv.env['CHECKOUT_DOMAIN'] ?? '')) {
    return QRFormat.checkoutUrl;
  } else if (raw.contains(dotenv.env['CARD_DOMAIN'] ?? '')) {
    return QRFormat.cardUrl;
  } else if (raw.contains(dotenv.env['APP_REDIRECT_DOMAIN'] ?? '')) {
    return QRFormat.accountUrl;
  } else if (raw.startsWith('https://') || raw.startsWith('http://')) {
    return QRFormat.url;
  } else {
    return QRFormat.unsupported;
  }
}

// address, value, null, null
(String, String?, String?, String?) parseEIP681(String raw) {
  final url = Uri.parse(raw);

  String address = url.pathSegments.first;
  if (address.contains('@')) {
    // includes chain id, remove
    address = address.split('@').first;
  }

  final params = url.queryParameters;

  final value = params['value'];

  return (address, value, null, null);
}

(String, String?, String?, String?) parseEIP681Transfer(String raw) {
  final url = Uri.parse(raw);

  final params = url.queryParameters;

  final address = params['address'];
  final value = params['uint256'];

  return (address ?? '', value, null, null);
}

(String, String?, String?, String?) parseSendtoUrlWithEIP681(String raw) {
  final cleanRaw = raw.replaceFirst('/#/', '/');

  final receiveUrl = Uri.parse(cleanRaw);
  final urlEncodedParams = receiveUrl.queryParameters['eip681'];
  if (urlEncodedParams == null) {
    return ('', null, null, null);
  }

  // Need to url decode the sendto param
  final decodedEIP681Param = Uri.decodeComponent(urlEncodedParams);
  return parseEIP681(decodedEIP681Param);
}

// parse the sendto url
// raw is the URL from the QR code, eg. https://example.com/?sendto=:username@:communitySlug&amount=100&description=Hello
(String, String?, String?, String?) parseSendtoUrl(String raw) {
  final cleanRaw = raw.replaceFirst('/#/', '/');
  final decodedRaw = Uri.decodeComponent(cleanRaw);

  final receiveUrl = Uri.parse(decodedRaw);

  final sendToParam = receiveUrl.queryParameters['sendto'];
  final amountParam = receiveUrl.queryParameters['amount'];
  final descriptionParam = receiveUrl.queryParameters['description'];

  if (sendToParam == null) {
    return ('', null, null, null);
  }

  final address = sendToParam.split('@').first;
  final alias = sendToParam.split('@').last;

  return (address, amountParam, descriptionParam, alias);
}

(String, String?, String?, String?) parseCheckoutUrl(String raw) {
  final cleanRaw = raw.replaceFirst('/#/', '/');
  final decodedRaw = Uri.decodeComponent(cleanRaw);

  final checkoutUrl = Uri.parse(decodedRaw);

  final placeSlug = checkoutUrl.pathSegments.first;

  if (placeSlug == '') {
    return ('', null, null, null);
  }

  return (placeSlug, null, null, null);
}

(String, String?, String?, String?) parseCardUrl(String raw) {
  final cleanRaw = raw.replaceFirst('/#/', '/');
  final decodedRaw = Uri.decodeComponent(cleanRaw);

  final receiveUrl = Uri.parse(decodedRaw);

  final cardId = receiveUrl.pathSegments.last;

  if (cardId == '') {
    return ('', null, null, null);
  }

  return (cardId, null, null, null);
}

String? parseCardProject(String raw) {
  final cleanRaw = raw.replaceFirst('/#/', '/');
  final decodedRaw = Uri.decodeComponent(cleanRaw);

  final receiveUrl = Uri.parse(decodedRaw);

  final cardId = receiveUrl.pathSegments.last;

  if (cardId == '') {
    return null;
  }

  final project = receiveUrl.queryParameters['project'];

  return project;
}

(String, String?, String?, String?) parseAccountUrl(String raw) {
  final cleanRaw = raw.replaceFirst('/#/', '/');
  final decodedRaw = Uri.decodeComponent(cleanRaw);

  final receiveUrl = Uri.parse(decodedRaw);

  final userAccount = receiveUrl.pathSegments.last;

  if (userAccount == '') {
    return ('', null, null, null);
  }

  return (userAccount, null, null, null);
}

(String, String?, String?, String?) parseReceiveUrl(String raw) {
  final receiveUrl = Uri.parse(raw.split('/#/').last);

  final encodedParams = receiveUrl.queryParameters['receiveParams'];
  if (encodedParams == null) {
    return ('', null, null, null);
  }

  final decodedParams = decompress(encodedParams);

  final paramUrl = Uri.parse(decodedParams);

  final address = paramUrl.queryParameters['address'];

  final amount = paramUrl.queryParameters['amount'];

  final alias = paramUrl.queryParameters['alias'];

  return (address ?? '', amount, null, alias != '' ? alias : null);
}

// address, amount, description, alias
(String, String?, String?, String?) parseQRCode(String raw) {
  final format = parseQRFormat(raw);

  switch (format) {
    case QRFormat.address:
      return (raw, null, null, null);
    case QRFormat.eip681:
      return parseEIP681(raw);
    case QRFormat.eip681Transfer:
      return parseEIP681Transfer(raw);
    case QRFormat.receiveUrl:
      return parseReceiveUrl(raw);
    case QRFormat.sendtoUrl:
      return parseSendtoUrl(raw);
    case QRFormat.sendtoUrlWithEIP681:
      return parseSendtoUrlWithEIP681(raw);
    case QRFormat.checkoutUrl:
      return parseCheckoutUrl(raw);
    case QRFormat.cardUrl:
      return parseCardUrl(raw);
    case QRFormat.accountUrl:
      return parseAccountUrl(raw);
    case QRFormat.url:
    // nothing to parse
    case QRFormat.voucher:
    // vouchers are invalid for a transfer
    default:
      return ('', null, null, null);
  }
}

String? parseAliasFromReceiveParams(String receiveParams) {
  final receiveUrl = Uri.parse(receiveParams.split('/#/').last);

  final encodedParams = receiveUrl.queryParameters['receiveParams'];
  if (encodedParams == null) {
    return null;
  }

  final decodedParams = decompress(encodedParams);

  final paramUrl = Uri.parse(decodedParams);

  final alias = paramUrl.queryParameters['alias'];

  return alias;
}

String? parseMessageFromReceiveParams(String receiveParams) {
  final receiveUrl = Uri.parse(receiveParams.split('/#/').last);

  final encodedParams = receiveUrl.queryParameters['receiveParams'];
  if (encodedParams == null) {
    return null;
  }

  final decodedParams = decompress(encodedParams);

  final paramUrl = Uri.parse(decodedParams);

  final message = paramUrl.queryParameters['message'];

  return message;
}
