import 'package:flutter/cupertino.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/profile_circle.dart';
import 'package:go_router/go_router.dart';

class ProfileBar extends StatefulWidget {
  const ProfileBar({super.key});

  @override
  State<ProfileBar> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> {
  void _goToMyAccount() async {
    final navigator = GoRouter.of(context);

    final userId = navigator.state?.pathParameters['id'];

    navigator.go('/$userId/my-account');
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
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
                  imageUrl: 'https://robohash.org/JQQ.png?set=set2',
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Name(),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Balance(),
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
  const Name({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Kevin',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class Balance extends StatelessWidget {
  const Balance({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CoinLogo(size: 33),
        SizedBox(width: 4),
        Text(
          '12.00',
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: theme.primaryColor,
      borderRadius: BorderRadius.circular(8),
      minSize: 0,
      onPressed: () {
        // TODO: add a button to navigate to the top up screen
        print('Top up');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.plus,
            color: Color(0xFFFFFFFF),
            size: 16,
          ),
          const SizedBox(width: 4),
          const Text(
            'Top up',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ],
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
