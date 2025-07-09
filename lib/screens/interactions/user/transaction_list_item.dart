import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';

import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/date.dart';
import 'package:pay_app/widgets/coin_logo.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final bool isSending;
  final Function(String) onRetry;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.isSending = false,
    required this.onRetry,
  });

  void handleRetry() {
    onRetry(transaction.id);
  }

  @override
  Widget build(BuildContext context) {
    final isReceived =
        transaction.exchangeDirection == ExchangeDirection.received;

    const bubbleBorderRadius = 20.0;
    const bubbleCornerBorderRadius = 2.0;

    final failed = transaction.status == TransactionStatus.fail;

    final iconColor = isReceived ? textMutedColor : textSurfaceMutedColor;

    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;

    final rowChildren = [
      Expanded(
        child: const SizedBox(),
      ),
      if (failed)
        CupertinoButton(
          color: whiteColor,
          borderRadius: BorderRadius.circular(22),
          padding: const EdgeInsets.all(5),
          onPressed: handleRetry,
          child: Icon(
            CupertinoIcons.arrow_counterclockwise,
            color: dangerColor,
          ),
        ),
      if (failed) const SizedBox(width: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: transaction.status == TransactionStatus.sending ? 1.05 : 1,
          curve: Curves.easeInOut,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isReceived
                  ? surfaceColor
                  : failed
                      ? primaryColor.withAlpha(200)
                      : primaryColor,
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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Amount(
                            amount: transaction.amount,
                            exchangeDirection: transaction.exchangeDirection,
                          ),
                        ],
                      ),
                      if (transaction.description != null &&
                          transaction.description!.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Description(
                          exchangeDirection: transaction.exchangeDirection,
                          description: transaction.description,
                        ),
                      ],
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TimeAgo(
                            createdAt: transaction.createdAt,
                            exchangeDirection: transaction.exchangeDirection,
                          ),
                          const SizedBox(width: 4),
                          if (transaction.status == TransactionStatus.sending)
                            Icon(
                              CupertinoIcons.check_mark,
                              size: 10,
                              color: iconColor,
                            ),
                          if (transaction.status == TransactionStatus.success)
                            SizedBox(
                              height: 10,
                              width: 10,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: -1,
                                    child: Icon(
                                      CupertinoIcons.check_mark,
                                      size: 10,
                                      color: iconColor,
                                    ),
                                  ),
                                  Positioned(
                                    left: 2,
                                    child: Icon(
                                      CupertinoIcons.check_mark,
                                      size: 10,
                                      color: iconColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (transaction.status == TransactionStatus.fail)
                            Icon(
                              CupertinoIcons.xmark,
                              size: 10,
                              color: iconColor,
                            ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
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
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: isReceived ? textColor : textSurfaceColor,
      ),
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
          size: 22,
        ),
        const SizedBox(width: 4),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 24,
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
