import 'package:flutter/cupertino.dart';

import 'package:pay_app/models/order.dart';
import 'package:pay_app/utils/date.dart';
import 'package:pay_app/widgets/coin_logo.dart';

class OrderListItem extends StatelessWidget {
  final Order order;

  const OrderListItem({
    super.key,
    required this.order,
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
        PaymentMethodBadge(paymentMode: order.type),
        SizedBox(height: 4),
        OrderId(orderId: order.id),
        SizedBox(height: 4),
        Description(description: order.description),
      ],
    );
  }

  Widget _buildRight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Amount(amount: order.total),
        SizedBox(height: 4),
        TimeAgo(createdAt: order.createdAt),
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

class OrderId extends StatelessWidget {
  final int? orderId;

  const OrderId({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    if (orderId == null) {
      return const SizedBox.shrink();
    }

    return Text(
      '#Order ${orderId!}',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Color(0xFF8F8A9D),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class PaymentMethodBadge extends StatelessWidget {
  final OrderType? paymentMode;

  const PaymentMethodBadge({super.key, this.paymentMode});

  @override
  Widget build(BuildContext context) {
    if (paymentMode == null) {
      return const SizedBox.shrink();
    }

    return _paymentBadge(paymentMode!);
  }

  Widget _qrPaymentBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/qr-code.png',
            width: 16,
            height: 16,
          ),
          SizedBox(width: 4),
          Text(
            'QR code',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _terminalPaymentBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/card.png',
            width: 16,
            height: 16,
          ),
          SizedBox(width: 4),
          Text(
            'terminal',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _appPaymentBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/app.png',
            width: 16,
            height: 16,
          ),
          SizedBox(width: 4),
          Text(
            'app',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4D4D4D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentBadge(OrderType orderType) {
    switch (orderType) {
      case OrderType.terminal:
        return _terminalPaymentBadge();
      case OrderType.web:
        return _qrPaymentBadge();
      case OrderType.app:
        return _appPaymentBadge();
    }
  }
}

class Amount extends StatelessWidget {
  final double amount;

  const Amount({
    super.key,
    required this.amount,
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
          '${amount >= 0 ? '+' : '-'}${amount.toStringAsFixed(2)}',
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
