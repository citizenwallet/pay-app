import 'package:flutter/cupertino.dart';
import 'package:pay_app/l10n/app_localizations.dart';
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
          AppLocalizations.of(context)!.about,
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 20),
        SettingsRow(
          label: AppLocalizations.of(context)!.termsAndConditions,
          icon: 'assets/icons/docs.svg',
          onTap: handleTermsAndConditions,
        ),
        SettingsRow(
          label: AppLocalizations.of(context)!.privacyPolicy,
          icon: 'assets/icons/docs.svg',
          onTap: handlePrivacyPolicy,
        ),
        SettingsRow(
          label: AppLocalizations.of(context)!.brusselsPay,
          icon: 'assets/logo.svg',
          onTap: handleBrusselsPay,
        ),
      ],
    );
  }
}
