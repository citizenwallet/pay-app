import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/profile_circle.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pay_app/utils/date.dart';
import 'package:provider/provider.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final Function(Transaction) onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const circleSize = 60.0;

    return CupertinoButton(
      padding: EdgeInsets.symmetric(vertical: 4),
      onPressed: () => onTap(transaction),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // if (transaction. && !transaction.isTreasury)
            //   ProfileCircle(
            //     imageUrl: transaction.imageUrl ?? 'assets/icons/shop.png',
            //     size: circleSize,
            //     padding: 2,
            //     fit: BoxFit.cover,
            //   ),
            // if (!interaction.isPlace && !interaction.isTreasury)
            //   ProfileCircle(
            //     imageUrl: interaction.imageUrl,
            //     size: circleSize,
            //     padding: 2,
            //   ),
            // if (interaction.isTreasury)
            ProfileCircle(
              imageUrl: 'assets/logo.svg',
              size: circleSize,
              padding: 2,
            ),
            const SizedBox(width: 12),
            Details(
              transaction: transaction,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TimeAgo(lastMessageAt: transaction.createdAt),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Icon(
                  CupertinoIcons.chevron_right,
                  color: iconColor,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Details extends StatelessWidget {
  final Transaction transaction;

  const Details({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final config = context.select((WalletState c) => c.config);

    final logo = config.getToken(transaction.contract);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // if (interaction.isPlace || interaction.isTreasury)
              SvgPicture.asset(
                'assets/icons/shop.svg',
                height: 16,
                width: 16,
                semanticsLabel: 'shop',
              ),
              const SizedBox(width: 4),
              // Name(name: interaction.isTreasury ? 'Top Up' : interaction.name),
              Name(name: 'Tx')
            ],
          ),
          const SizedBox(height: 4),
          AmountDescription(
            amount: double.parse(transaction.amount),
            description: transaction.description,
            // exchangeDirection: transaction.exchangeDirection,
            logo: logo.logo,
          ),
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
        fontSize: 16,
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
  final double amount;
  final String? description;
  final String? logo;

  const AmountDescription({
    super.key,
    required this.amount,
    this.description,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CoinLogo(
          size: 15,
          logo: logo,
        ),
        const SizedBox(width: 4),
        Text(
          // '${exchangeDirection == ExchangeDirection.sent ? '-' : '+'}${amount.toStringAsFixed(2)}',
          '${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8F8A9D),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            description ?? '',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF8F8A9D),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class UnreadMessageIndicator extends StatelessWidget {
  final bool hasUnreadMessages;

  const UnreadMessageIndicator({super.key, required this.hasUnreadMessages});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    if (!hasUnreadMessages) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

class TimeAgo extends StatelessWidget {
  final DateTime lastMessageAt;

  const TimeAgo({super.key, required this.lastMessageAt});

  @override
  Widget build(BuildContext context) {
    return Text(
      getTimeAgo(lastMessageAt),
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF8F8A9D),
      ),
    );
  }
}
