import 'package:flutter/cupertino.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/wide_button.dart';

class Footer extends StatefulWidget {
  final double checkoutTotal;

  const Footer({
    required this.checkoutTotal,
    super.key,
  });

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.checkoutTotal == 0;

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
        onPressed: () => {},
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
              widget.checkoutTotal.toStringAsFixed(2),
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
