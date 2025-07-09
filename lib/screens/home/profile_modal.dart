import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/currency.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:pay_app/widgets/button.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/modals/dismissible_modal_popup.dart';
import 'package:provider/provider.dart';

class ProfileModal extends StatefulWidget {
  final String accountAddress;

  const ProfileModal({super.key, required this.accountAddress});

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  late WalletState _walletState;

  @override
  void initState() {
    super.initState();

    _walletState = context.read<WalletState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLoad();
    });
  }

  void onLoad() async {
    await delay(const Duration(milliseconds: 100));

    await _walletState.loadTokenBalances();
  }

  void handleEditProfile() {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();

    navigator.push('/${widget.accountAddress}/my-account/edit');
  }

  void handleAppSettings() {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();

    navigator.push('/${widget.accountAddress}/my-account/settings');
  }

  void handleClose(BuildContext context) {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();
    navigator.pop();
  }

  void handleTokenSelect(String tokenKey) {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();
    navigator.pop(tokenKey);
  }

  @override
  Widget build(BuildContext context) {
    return DismissibleModalPopup(
      modalKey: 'profile_modal',
      maxHeight: 600,
      paddingSides: 16,
      paddingTopBottom: 16,
      topRadius: 12,
      onDismissed: (dir) {
        handleClose(context);
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // _buildProfileHeader(context),
          // const SizedBox(height: 24),
          _buildTokensList(context),
          const SizedBox(height: 12),
          Container(
            height: 1,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Color(0xFFD9D9D9),
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButtons(),
          // const SizedBox(height: 24),
          // _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Button(
          onPressed: handleEditProfile,
          text: 'Edit Profile',
          labelColor: whiteColor,
          prefix: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              CupertinoIcons.pencil,
              color: whiteColor,
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Button(
          onPressed: handleAppSettings,
          text: 'App Settings',
          labelColor: textColor,
          color: surfaceColor,
          prefix: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              CupertinoIcons.settings,
              color: textColor,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTokensList(BuildContext context) {
    final config = context.select<WalletState, Config>(
      (state) => state.config,
    );
    final tokenLoadingStates = context.select<WalletState, Map<String, bool>>(
      (state) => state.tokenLoadingStates,
    );
    final tokenBalances = context.select<WalletState, Map<String, String>>(
      (state) => state.tokenBalances,
    );

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tokens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: whiteColor,
              borderRadius: BorderRadius.circular(8),
              onPressed: () => handleClose(context),
              child: Icon(
                CupertinoIcons.xmark,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...(config.tokens.entries.map((entry) {
          final tokenKey = entry.key;
          final tokenConfig = entry.value;
          final isTokenLoading = tokenLoadingStates[tokenKey] ?? false;
          final formattedBalance = formatCurrency(
            tokenBalances[tokenKey] ?? '0',
            tokenConfig.decimals,
          );

          return GestureDetector(
            onTap: () => handleTokenSelect(tokenKey),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
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
      ],
    );
  }
}
