import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/widgets/profile_circle.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pay_app/utils/date.dart';

class InteractionListItem extends StatelessWidget {
  final Interaction interaction;
  final Function(Interaction)? onTap;


  const InteractionListItem({
    super.key,
    required this.interaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        // Handle transaction tap
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Row(
          children: [
            // Profile/Business image
            ProfileCircle(
              imageUrl: interaction.imageUrl,
              size: 48,
            ),

            const SizedBox(width: 12),

            Details(interaction: interaction),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                UnreadMessageIndicator(
                    hasUnreadMessages: interaction.hasUnreadMessages),
                const SizedBox(height: 8),
                TimeAgo(lastMessageAt: interaction.lastMessageAt),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Details extends StatelessWidget {
  final Interaction interaction;

  const Details({super.key, required this.interaction});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (interaction.isPlace)
                SvgPicture.asset(
                  'assets/icons/shop.svg',
                  height: 16,
                  width: 16,
                  semanticsLabel: 'shop',
                ),
              const SizedBox(width: 4),
              Name(name: interaction.name),
            ],
          ),
          AmountDescription(
            amount: interaction.amount,
            description: interaction.description,
          ),
          Location(location: interaction.location),
        ],
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
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF14023F),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class Location extends StatelessWidget {
  final String? location;

  const Location({super.key, this.location});

  @override
  Widget build(BuildContext context) {
    if (location == null) {
      return const SizedBox.shrink();
    }

    return Text(
      location!,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Color(0xFF8F8A9D),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class AmountDescription extends StatelessWidget {
  final double? amount;
  final String? description;

  const AmountDescription({
    super.key,
    this.amount,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    if (amount == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        CoinLogo(
          size: 15,
        ),
        const SizedBox(width: 4),
        Text(
          '${amount! >= 0 ? '+' : '-'}${amount!.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8F8A9D),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          description ?? '',
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF8F8A9D),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class UnreadMessageIndicator extends StatelessWidget {
  final bool hasUnreadMessages;

  const UnreadMessageIndicator({super.key, required this.hasUnreadMessages});

  @override
  Widget build(BuildContext context) {
    if (!hasUnreadMessages) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Color(0xFF3431C4),
        shape: BoxShape.circle,
      ),
    );
  }
}

class TimeAgo extends StatelessWidget {
  final DateTime? lastMessageAt;

  const TimeAgo({super.key, this.lastMessageAt});

  @override
  Widget build(BuildContext context) {
    if (lastMessageAt == null) {
      return const SizedBox.shrink();
    }

    return Text(
      getTimeAgo(lastMessageAt!),
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF8F8A9D),
      ),
    );
  }
}
