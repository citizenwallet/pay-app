import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/menu_item.dart';

import 'package:pay_app/models/order.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/date.dart';
import 'package:pay_app/widgets/coin_logo.dart';

class OrderListItem extends StatelessWidget {
  final Order order;
  final Map<int, MenuItem> mappedItems;

  const OrderListItem({
    super.key,
    required this.order,
    required this.mappedItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      constraints: const BoxConstraints(
        minHeight: 80,
      ),
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
        OrderId(orderId: order.id),
        SizedBox(height: 4),
        PaymentMethodBadge(paymentMode: order.type),
        SizedBox(height: 4),
        Items(
          items: order.items,
          mappedItems: mappedItems,
          description: order.description,
        ),
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

class Items extends StatelessWidget {
  final List<OrderItem> items;
  final Map<int, MenuItem> mappedItems;
  final String? description;

  const Items({
    super.key,
    required this.items,
    required this.mappedItems,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && description == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        if (description != null && description!.isNotEmpty)
          Text(
            description!,
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

class OrderId extends StatelessWidget {
  final int? orderId;

  const OrderId({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    if (orderId == null) {
      return const SizedBox.shrink();
    }

    return Text(
      'Order #${orderId!}',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
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
    return _paymentBadge(paymentMode);
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

  Widget _paymentBadge(OrderType? orderType) {
    if (orderType == null) {
      return _qrPaymentBadge();
    }

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
