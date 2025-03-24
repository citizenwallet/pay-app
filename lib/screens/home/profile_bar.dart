import 'package:flutter/cupertino.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/profile_circle.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileBar extends StatefulWidget {
  final String accountAddress;

  const ProfileBar({super.key, required this.accountAddress});

  @override
  State<ProfileBar> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> {
  @override
  void initState() {
    super.initState();
  }

  void _goToMyAccount() async {
    final myAddress = widget.accountAddress;

    final navigator = GoRouter.of(context);

    navigator.push('/$myAddress/my-account');
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    final walletState = context.watch<WalletState>();
    final balance = walletState.balance.toStringAsFixed(2);

    final profile = context.watch<ProfileState>().profile;

    return GestureDetector(
      onTap: _goToMyAccount,
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
                  borderColor: theme.primaryColor,
                  imageUrl: profile.imageMedium,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Name(name: profile.name),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Balance(balance: balance),
                        const SizedBox(width: 16),
                        TopUpButton(),
                      ],
                    )
                  ],
                )
              ],
            ),
            RightChevron(),
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
  const TopUpButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      color: theme.primaryColor,
      borderRadius: BorderRadius.circular(8),
      minSize: 0,
      onPressed: () {
        // TODO: add a button to navigate to the top up screen
        debugPrint('Top up');
      },
      child: SizedBox(
        width: 60,
        height: 28,
        child: Center(
          child: Text(
            '+ add',
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

class RightChevron extends StatelessWidget {
  const RightChevron({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return Icon(
      CupertinoIcons.chevron_right,
      color: theme.primaryColor,
      size: 16,
    );
  }
}
