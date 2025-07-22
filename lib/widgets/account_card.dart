import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/profile_circle.dart';
import 'package:pay_app/widgets/qr/qr.dart';

class AccountCard extends StatelessWidget {
  final ProfileV1 profile;
  final String alias;
  final String appRedirectDomain;
  final double? size;
  final double? shrink;

  AccountCard({
    super.key,
    required this.profile,
    required this.alias,
    this.size,
    this.shrink,
  }) : appRedirectDomain = dotenv.get('APP_REDIRECT_DOMAIN');

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final double scale = shrink != null ? 1 - shrink! : 1;
    final size = (this.size ?? (width > height ? height : width)) * 0.8;

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: Container(
            width: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                QR(
                  data:
                      'https://$appRedirectDomain/?sendto=${profile.username}@$alias',
                  size: size - 20,
                  padding: EdgeInsets.all(20),
                  logo: 'assets/logo.png',
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProfileCircle(
                      size: 20,
                      imageUrl: profile.imageSmall,
                    ),
                    const SizedBox(width: 10),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
