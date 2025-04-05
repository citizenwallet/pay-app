import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/widgets/qr/qr.dart';
import 'package:provider/provider.dart';

class AccountCard extends StatelessWidget {
  final String appRedirectUrl;

  AccountCard({
    super.key,
  }) : appRedirectUrl = dotenv.get('APP_REDIRECT_URL');

  @override
  Widget build(BuildContext context) {
    final profile = context.select((ProfileState p) => p.profile);
    final alias = context.select((ProfileState p) => p.alias);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              QR(
                data: '$appRedirectUrl/?sendto=${profile.username}@$alias',
                size: 230,
                padding: EdgeInsets.all(20),
                logo: 'assets/icons/profile.png',
              ),
              Text(
                '@${profile.username}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: Color(0xFF171717),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
