import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';

import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/date.dart';
import 'package:pay_app/widgets/coin_logo.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final bool isSending;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    final isReceived =
        transaction.exchangeDirection == ExchangeDirection.received;

    const bubbleBorderRadius = 20.0;
    const bubbleCornerBorderRadius = 2.0;

    final rowChildren = [
      Expanded(
        child: const SizedBox(),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isReceived
                ? surfaceColor
                : CupertinoTheme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(bubbleBorderRadius),
              topRight: const Radius.circular(bubbleBorderRadius),
              bottomLeft: Radius.circular(
                  isReceived ? bubbleCornerBorderRadius : bubbleBorderRadius),
              bottomRight: Radius.circular(
                  isReceived ? bubbleBorderRadius : bubbleCornerBorderRadius),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Amount(
                    amount: transaction.amount,
                    exchangeDirection: transaction.exchangeDirection,
                  ),
                  if (transaction.description != null) ...[
                    SizedBox(height: 4),
                    Description(
                      exchangeDirection: transaction.exchangeDirection,
                      description: transaction.description,
                    ),
                  ],
                  SizedBox(height: 4),
                  if (transaction.status == TransactionStatus.sending)
                    Text(
                      transaction.exchangeDirection == ExchangeDirection.sent
                          ? 'Sending...'
                          : 'Receiving...',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            isReceived ? textMutedColor : textSurfaceMutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (transaction.status == TransactionStatus.pending ||
                      transaction.status == TransactionStatus.success)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TimeAgo(
                          createdAt: transaction.createdAt,
                          exchangeDirection: transaction.exchangeDirection,
                        ),
                      ],
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    ];

    return Row(
      children: isReceived ? rowChildren.reversed.toList() : rowChildren,
    );
  }
}

class Description extends StatelessWidget {
  final ExchangeDirection exchangeDirection;
  final String? description;

  const Description(
      {super.key, required this.exchangeDirection, this.description});

  @override
  Widget build(BuildContext context) {
    if (description == null) {
      return const SizedBox.shrink();
    }

    final isReceived = exchangeDirection == ExchangeDirection.received;

    return Text(
      description!,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: isReceived ? textColor : textSurfaceColor,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class Amount extends StatelessWidget {
  final double amount;
  final ExchangeDirection exchangeDirection;

  const Amount({
    super.key,
    required this.amount,
    required this.exchangeDirection,
  });

  @override
  Widget build(BuildContext context) {
    final isReceived = exchangeDirection == ExchangeDirection.received;

    return Row(
      children: [
        CoinLogo(
          size: 24,
        ),
        const SizedBox(width: 4),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: isReceived ? textColor : CupertinoColors.white,
          ),
        ),
      ],
    );
  }
}

class TimeAgo extends StatelessWidget {
  final DateTime createdAt;
  final ExchangeDirection exchangeDirection;

  const TimeAgo({
    super.key,
    required this.createdAt,
    required this.exchangeDirection,
  });

  @override
  Widget build(BuildContext context) {
    final isReceived = exchangeDirection == ExchangeDirection.received;

    return Text(
      getTimeAgo(createdAt),
      style: TextStyle(
        fontSize: 10,
        color: isReceived ? textMutedColor : textSurfaceMutedColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
