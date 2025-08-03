import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/checkout.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/wide_button.dart';
import 'package:pay_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class Footer extends StatelessWidget {
  final Checkout checkout;
  final Function(Checkout) onPay;
  final Function(String) onTopUp;

  const Footer({
    required this.checkout,
    required this.onPay,
    required this.onTopUp,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final config = context.select<WalletState, Config?>(
      (state) => state.config,
    );
    final tokenConfig = context.select<WalletState, TokenConfig>(
      (state) => state.currentTokenConfig,
    );

    final balance =
        context.watch<WalletState>().tokenBalances[tokenConfig.address] ??
            '0.0';

    final insufficientBalance = double.parse(balance) < checkout.total;

    final disabled =
        checkout.total == 0 || double.parse(balance) < checkout.total;

    final topUpPlugin = config?.getTopUpPlugin(
      tokenAddress: tokenConfig?.address,
    );

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
                  AppLocalizations.of(context)!.pay,
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
          if (insufficientBalance && topUpPlugin != null)
            WideButton(
              onPressed: () => onTopUp(topUpPlugin.url),
              child: Text(
                AppLocalizations.of(context)!.topUp,
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
