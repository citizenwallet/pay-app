import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/models/menu_item.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/profile_circle.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/utils/date.dart';
import 'package:provider/provider.dart';

class TransactionListItem extends StatelessWidget {
  final String myAddress;
  final Transaction transaction;
  final Map<String, ProfileV1> profiles;
  final Order? order;
  final Function(Transaction, Order?) onTap;

  const TransactionListItem({
    super.key,
    required this.myAddress,
    required this.transaction,
    required this.profiles,
    this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const circleSize = 60.0;

    final profile =
        myAddress.toLowerCase() == transaction.toAccount.toLowerCase()
            ? profiles[transaction.fromAccount]
            : profiles[transaction.toAccount];

    final exchangeDirection = transaction.exchangeDirection(myAddress);

    final config = context.select((WalletState c) => c.config);

    final logo = config.getToken(transaction.contract);

    return CupertinoButton(
      padding: EdgeInsets.symmetric(vertical: 4),
      onPressed: () => onTap(transaction, order),
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFF0E9F4),
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          4,
        ),
        child: Column(
          children: [
            Row(
              children: [
                ProfileCircle(
                  imageUrl: profile?.imageSmall ?? 'assets/logo.svg',
                  size: circleSize,
                  padding: 2,
                ),
                const SizedBox(width: 12),
                Details(
                  profile: profile,
                  transaction: transaction,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (order != null &&
                        (order?.status == OrderStatus.refund ||
                            order?.status == OrderStatus.refunded))
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: order?.status == OrderStatus.refund
                              ? warningColor
                              : mutedColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              order?.status.name ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    AmountDescription(
                      amount: double.parse(transaction.amount),
                      description: transaction.description,
                      exchangeDirection: exchangeDirection,
                      logo: logo.logo,
                    ),
                    TimeAgo(lastMessageAt: transaction.createdAt),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  8,
                  0,
                  8,
                  4,
                ),
                child: Row(
                  children: [
                    OrderDetails(
                      order: order!,
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

class Details extends StatelessWidget {
  final ProfileV1? profile;
  final Transaction transaction;

  const Details({
    super.key,
    this.profile,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Name(name: profile?.name ?? 'Unknown'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '@${profile?.username ?? 'unknown'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8F8A9D),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ],
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

class AmountDescription extends StatelessWidget {
  final double amount;
  final String? description;
  final ExchangeDirection exchangeDirection;
  final String? logo;

  const AmountDescription({
    super.key,
    required this.amount,
    this.description,
    required this.exchangeDirection,
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
          '${exchangeDirection == ExchangeDirection.sent ? '-' : '+'}${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
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

class OrderDetails extends StatelessWidget {
  final Order order;

  const OrderDetails({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final items = order.items;
    final description = order.description;
    final menuItems = order.place.items;

    if (items.isEmpty && (description == null || description.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    final mappedItems = menuItems.fold<Map<int, MenuItem>>(
      {},
      (acc, item) => {
        ...acc,
        item.id: item,
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order #${order.id}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        if (description != null && description.isNotEmpty && items.isEmpty)
          Text(
            description,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textMutedColor,
            ),
          ),
        ...items.map(
          (item) => Text(
            key: Key('item-${item.id}'),
            '${mappedItems[item.id]?.name ?? ''} x ${item.quantity}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textMutedColor,
            ),
          ),
        ),
      ],
    );
  }
}

class TransactionListItemSkeleton extends StatelessWidget {
  const TransactionListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const circleSize = 60.0;

    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0E9F4),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        8,
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              // Profile circle skeleton
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey.withAlpha(40),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CupertinoColors.systemGrey.withAlpha(80),
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Details skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name skeleton
                    Container(
                      height: 20,
                      width: 120,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey.withAlpha(40),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Username skeleton
                    Container(
                      height: 14,
                      width: 80,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              // Amount and time skeleton
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 4),
                  // Amount skeleton
                  Row(
                    children: [
                      // Coin logo skeleton
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Amount text skeleton
                      Container(
                        height: 16,
                        width: 60,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey.withAlpha(40),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Time skeleton
                  Container(
                    height: 12,
                    width: 40,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
