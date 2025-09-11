import 'package:flutter/cupertino.dart';

import 'package:pay_app/widgets/settings_row.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 10),
        SettingsRow(
          label: 'Push notifications',
          icon: 'assets/icons/notification_bell.svg',
          trailing: CupertinoSwitch(
            value: true,
            onChanged: (value) {},
          ),
        )
      ],
    );
  }
}
