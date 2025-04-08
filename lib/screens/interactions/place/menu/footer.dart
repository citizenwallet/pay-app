import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/checkout.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/wide_button.dart';
import 'package:provider/provider.dart';

class Footer extends StatelessWidget {
  final Checkout checkout;
  final Function(Checkout) onPay;
  final Function() onTopUp;

  const Footer({
    required this.checkout,
    required this.onPay,
    required this.onTopUp,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<WalletState>().balance;
    final insufficientBalance = balance < checkout.total;

    final disabled = checkout.total == 0 || balance < checkout.total;

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
      child: Column(
        children: [
          WideButton(
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
          if (insufficientBalance) const SizedBox(height: 10),
          if (insufficientBalance)
            WideButton(
              onPressed: onTopUp,
              child: Text(
                'Top up',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
