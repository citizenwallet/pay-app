import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/currency.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/modals/dismissible_modal_popup.dart';
import 'package:provider/provider.dart';

class TokenModal extends StatefulWidget {
  const TokenModal({super.key});

  @override
  State<TokenModal> createState() => _TokenModalState();
}

class _TokenModalState extends State<TokenModal> {
  late WalletState _walletState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _walletState = context.read<WalletState>();

      onLoad();
    });
  }

  Future<void> onLoad() async {
    await _walletState.loadTokenBalances();
  }

  void handleTokenSelect(String tokenKey) {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();
    navigator.pop(tokenKey);
  }

  void handleClose(BuildContext context) {
    final navigator = GoRouter.of(context);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DismissibleModalPopup(
        modalKey: 'token_modal',
        maxHeight: 240,
        paddingSides: 16,
        paddingTopBottom: 0,
        topRadius: 12,
        onDismissed: (dir) {
          handleClose(context);
        },
        child: _buildContent(
          context,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final config = context.select<WalletState, Config>(
      (state) => state.config,
    );

    final currentTokenAddress = context.select<WalletState, String?>(
      (state) => state.currentTokenAddress,
    );

    final tokenLoadingStates = context.watch<WalletState>().tokenLoadingStates;
    final tokenBalances = context.watch<WalletState>().tokenBalances;

    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;

    if (config.tokens.isEmpty) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (config.tokens.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No tokens available',
          style: TextStyle(
            color: textMutedColor,
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Tokens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...(config.tokens.entries.map((entry) {
          final tokenAddress = entry.value.address;
          final tokenConfig = entry.value;
          final isTokenLoading = tokenLoadingStates[tokenAddress] ?? false;
          final formattedBalance = formatCurrency(
            tokenBalances[tokenAddress] ?? '0',
            tokenConfig.decimals,
          );

          final isSelected = currentTokenAddress == tokenAddress;

          return GestureDetector(
            onTap: () => handleTokenSelect(tokenAddress),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(
                  color: isSelected ? primaryColor : backgroundColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Token logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: tokenConfig.logo != null
                        ? CoinLogo(
                            size: 40,
                            logo: tokenConfig.logo,
                          )
                        : Icon(
                            CupertinoIcons.circle_fill,
                            color: primaryColor,
                            size: 40,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Token info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tokenConfig.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          tokenConfig.symbol,
                          style: TextStyle(
                            fontSize: 14,
                            color: textMutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Balance
                  if (isTokenLoading)
                    CupertinoActivityIndicator(
                      radius: 8,
                      color: textMutedColor,
                    )
                  else ...[
                    tokenConfig.logo != null
                        ? CoinLogo(
                            size: 20,
                            logo: tokenConfig.logo,
                          )
                        : Icon(
                            CupertinoIcons.circle_fill,
                            color: primaryColor,
                            size: 20,
                          ),
                    const SizedBox(width: 4),
                    Text(
                      formattedBalance,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        }).toList()),
        const SizedBox(height: 12),
      ],
    );
  }
}
