import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/checkout.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/wide_button.dart';

class Footer extends StatelessWidget {
  final Checkout checkout;
  final Function(Checkout) onPay;

  const Footer({
    required this.checkout,
    required this.onPay,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = checkout.total == 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFD9D9D9),
            width: 1,
          ),
        ),
      ),
      child: WideButton(
        onPressed: () => onPay(checkout),
        color: disabled
            ? surfaceDarkColor.withValues(alpha: 0.8)
            : surfaceDarkColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pay',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: disabled
                    ? CupertinoColors.white.withValues(alpha: 0.7)
                    : CupertinoColors.white,
              ),
            ),
            const SizedBox(width: 8),
            CoinLogo(
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              checkout.total.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: disabled
                    ? CupertinoColors.white.withValues(alpha: 0.7)
                    : CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
