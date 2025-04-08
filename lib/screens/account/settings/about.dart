import 'package:flutter/cupertino.dart';
import 'package:pay_app/widgets/settings_row.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

  void handleTermsAndConditions() {
    launchUrl(
      Uri.parse('https://www.pay.brussels/terms-and-conditions'),
      mode: LaunchMode.inAppWebView,
    );
  }

  void handleBrusselsPay() {
    launchUrl(
      Uri.parse('https://www.pay.brussels'),
      mode: LaunchMode.inAppWebView,
    );
  }

  void handlePrivacyPolicy() {
    launchUrl(
      Uri.parse('https://www.pay.brussels/privacy-policy'),
      mode: LaunchMode.inAppWebView,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 10),
        SettingsRow(
          label: 'Terms and conditions',
          icon: 'assets/icons/docs.svg',
          onTap: handleTermsAndConditions,
        ),
        SettingsRow(
          label: 'Privacy policy',
          icon: 'assets/icons/docs.svg',
          onTap: handlePrivacyPolicy,
        ),
        SettingsRow(
          label: 'Brussels Pay',
          icon: 'assets/logo.svg',
          onTap: handleBrusselsPay,
        ),
      ],
    );
  }
}
