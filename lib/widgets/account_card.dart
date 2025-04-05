import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/qr/qr.dart';

class AccountCard extends StatelessWidget {
  final ProfileV1 profile;
  final String alias;
  final String appRedirectUrl;

  AccountCard({
    super.key,
    required this.profile,
    required this.alias,
  }) : appRedirectUrl = dotenv.get('APP_REDIRECT_URL');

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final size = (width > height ? height : width) * 0.8;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              QR(
                data: '$appRedirectUrl/?sendto=${profile.username}@$alias',
                size: size - 20,
                padding: EdgeInsets.all(20),
                logo: profile.imageSmall.isNotEmpty
                    ? profile.imageSmall
                    : 'assets/icons/profile.png',
              ),
              const SizedBox(height: 10),
              Text(
                '@${profile.username}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: textMutedColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
