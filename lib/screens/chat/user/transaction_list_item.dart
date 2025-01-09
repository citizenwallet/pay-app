import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart';

import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/utils/date.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/utils/strings.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0E9F4),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildLeft(),
          const Spacer(),
          _buildRight(),
        ],
      ),
    );
  }

  Widget _buildLeft() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PaymentMethodBadge(paymentMode: transaction.paymentMode),
        // SizedBox(height: 4),
        Description(description: transaction.description),
        SizedBox(height: 4),
        TransactionHash(transactionHash: transaction.txHash),
      ],
    );
  }

  Widget _buildRight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Amount(
          amount: transaction.amount,
          exchangeDirection: transaction.exchangeDirection,
        ),
        SizedBox(height: 4),
        TimeAgo(createdAt: transaction.createdAt),
      ],
    );
  }
}

class Description extends StatelessWidget {
  final String? description;

  const Description({super.key, this.description});

  @override
  Widget build(BuildContext context) {
    if (description == null) {
      return const SizedBox.shrink();
    }

    return Text(
      description!,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4D4D4D),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class TransactionHash extends StatelessWidget {
  final String transactionHash;

  const TransactionHash({super.key, required this.transactionHash});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Transaction #${formatLongText(transactionHash)}',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Color(0xFF8F8A9D),
      ),
      maxLines: 1,
      overflow: TextOverflow.fade,
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
    final theme = CupertinoTheme.of(context);
    return Row(
      children: [
        CoinLogo(
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${exchangeDirection == ExchangeDirection.sent ? '-' : '+'} ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }
}

class TimeAgo extends StatelessWidget {
  final DateTime createdAt;

  const TimeAgo({super.key, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    return Text(
      getTimeAgo(createdAt),
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF8F8A9D),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
