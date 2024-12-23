import 'package:flutter/cupertino.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/profile_circle.dart';

class ProfileBar extends StatelessWidget {
  const ProfileBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: add a button to navigate to the settings screen
        print('Settings');
      },
      child: Container(
        height: 80,
        color: CupertinoColors.systemBackground,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ProfileCircle(
                  size: 70,
                  borderWidth: 3,
                  borderColor: Color(0xFF4338CA),
                  imageUrl: 'https://robohash.org/JQQ.png?set=set2',
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: const Color(0xFF4338CA),
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
    return const Icon(
      CupertinoIcons.chevron_right,
      color: Color(0xFF4338CA),
      size: 16,
    );
  }
}
