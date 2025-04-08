import 'package:url_launcher/url_launcher.dart';

class InviteService {
  static final InviteService _instance = InviteService._internal();

  factory InviteService() => _instance;

  InviteService._internal();

  Future<bool> shareInviteLink(String phoneNumber) async {
    final messageText =
        "I would like to send you a payment through Brussels Pay. It's simple, secure and free. Get it at https://wallet.pay.brussels";
    final url = Uri(
      scheme: 'sms',
      path: phoneNumber,
      query: 'body=${Uri.encodeComponent(messageText)}',
    );
    return launchUrl(url);
  }
}
