import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/profile_circle.dart';

enum ProfileCardType {
  user,
  place,
}

class ProfileCard extends StatelessWidget {
  final ProfileV1 profile;
  final ProfileCardType type;
  final String? tokenLogo;
  final Order? order;
  final bool loading;
  final Function()? onClose;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.type,
    this.tokenLogo,
    this.order,
    this.loading = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: blackColor.withAlpha(100),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: blackColor.withAlpha(50),
            blurRadius: 10,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileCircle(
                imageUrl: profile.imageSmall,
                size: 60,
                borderWidth: 4,
                borderColor: primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (type == ProfileCardType.place)
                          SvgPicture.asset(
                            'assets/icons/shop.svg',
                            height: 16,
                            width: 16,
                            semanticsLabel: 'shop',
                          ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            profile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${profile.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: loading ? null : onClose,
                child: Container(
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: loading
                        ? CupertinoActivityIndicator()
                        : Icon(
                            CupertinoIcons.xmark,
                            color: blackColor.withAlpha(200),
                            size: 24,
                          ),
                  ),
                ),
              ),
            ],
          ),
          if (profile.description.isNotEmpty) const SizedBox(height: 16),
          if (profile.description.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    profile.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: blackColor.withAlpha(150),
                    ),
                  ),
                ),
              ],
            ),
          if (order != null) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: blackColor.withAlpha(40),
                    width: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Order #${order!.id}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CoinLogo(size: 20, logo: tokenLogo),
                const SizedBox(width: 8),
                Text(order!.total.toString()),
              ],
            ),
            if (order!.description != null) const SizedBox(height: 8),
            if (order!.description != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      order!.description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: blackColor.withAlpha(150),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
