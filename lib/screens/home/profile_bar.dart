import 'package:flutter/cupertino.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/profile_circle.dart';
import 'package:provider/provider.dart';

class ProfileBar extends StatefulWidget {
  final String accountAddress;
  final Function() onProfileTap;
  final Function() onTopUpTap;
  final Function() onSettingsTap;

  const ProfileBar({
    super.key,
    required this.accountAddress,
    required this.onProfileTap,
    required this.onTopUpTap,
    required this.onSettingsTap,
  });

  @override
  State<ProfileBar> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = context.watch<WalletState>();
    final balance = walletState.balance.toStringAsFixed(2);

    final profile = context.watch<ProfileState>().profile;

    return GestureDetector(
      onTap: widget.onProfileTap,
      child: Container(
        height: 95,
        color: CupertinoColors.systemBackground,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                ProfileCircle(
                  size: 70,
                  borderWidth: 3,
                  borderColor: primaryColor,
                  imageUrl: profile.imageMedium,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Name(name: '@${profile.username}'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Balance(balance: balance),
                        const SizedBox(width: 16),
                        TopUpButton(onTopUpTap: widget.onTopUpTap),
                      ],
                    )
                  ],
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.onSettingsTap,
                child: Icon(
                  CupertinoIcons.settings,
                  color: primaryColor,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Name extends StatelessWidget {
  final String name;

  const Name({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class Balance extends StatelessWidget {
  final String balance;

  const Balance({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CoinLogo(size: 33),
        SizedBox(width: 4),
        Text(
          balance,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class TopUpButton extends StatelessWidget {
  final Function() onTopUpTap;

  const TopUpButton({super.key, required this.onTopUpTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      color: primaryColor,
      borderRadius: BorderRadius.circular(8),
      minSize: 0,
      onPressed: onTopUpTap,
      child: SizedBox(
        width: 70,
        height: 28,
        child: Center(
          child: Text(
            '+ top up',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
