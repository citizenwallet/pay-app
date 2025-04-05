import 'package:flutter/cupertino.dart';

import 'package:pay_app/widgets/settings_row.dart';

class About extends StatelessWidget {
  const About({super.key});

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
          trailing: Icon(
            CupertinoIcons.chevron_right,
            color: Color(0xFF000000),
          ),
        ),
        SettingsRow(
          label: 'Brussels Pay',
          icon: 'assets/logo.svg',
          trailing: Icon(
            CupertinoIcons.chevron_right,
            color: Color(0xFF000000),
          ),
        ),
      ],
    );
  }
}
