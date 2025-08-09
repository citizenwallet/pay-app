import 'package:flutter/cupertino.dart';
import 'package:pay_app/screens/home/token_modal.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/blurry_child.dart';
import 'package:pay_app/widgets/cards/card.dart';
import 'package:pay_app/widgets/cards/card_skeleton.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:provider/provider.dart';

class ProfileBar extends StatefulWidget {
  final double shrink;
  final bool loading;
  final String accountAddress;
  final Color backgroundColor;
  final Future<void> Function() onProfileTap;
  final Function(String) onTopUpTap;

  const ProfileBar({
    super.key,
    required this.shrink,
    required this.loading,
    required this.accountAddress,
    required this.backgroundColor,
    required this.onProfileTap,
    required this.onTopUpTap,
  });

  @override
  State<ProfileBar> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> with TickerProviderStateMixin {
  late AppState _appState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appState = context.read<AppState>();
    });
  }

  Future<void> handleProfileTap() async {
    await widget.onProfileTap();
  }

  Future<void> handleBalanceTap() async {
    final selectedToken = await showCupertinoModalPopup<String?>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const TokenModal(),
    );

    if (selectedToken != null) {
      _appState.setCurrentToken(selectedToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenConfig = context.select<AppState, TokenConfig>(
      (state) => state.currentTokenConfig,
    );

    final balance = context.select<WalletState, String>(
      (state) => state.tokenBalances[tokenConfig.address] ?? '0.0',
    );
    final config = context.select<WalletState, Config?>(
      (state) => state.config,
    );

    final topUpPlugin = config?.getTopUpPlugin(
      tokenAddress: tokenConfig.address,
    );

    final profile = context.watch<ProfileState>().profile;

    return _buildProfileCard(
      context,
      profile,
      balance,
      tokenConfig,
      topUpPlugin,
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    ProfileV1 profile,
    String balance,
    TokenConfig? tokenConfig,
    PluginConfig? topUpPlugin,
  ) {
    final safeArea = MediaQuery.of(context).padding;
    final width = MediaQuery.of(context).size.width;
    final adjustedWidth = widget.shrink * width;

    final primaryColor = context.select<AppState, Color>(
      (state) => state.tokenPrimaryColor,
    );

    return BlurryChild(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: blackColor.withAlpha(40),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Column(
          children: [
            SizedBox(height: safeArea.top),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (profile.isAnonymous)
                  CardSkeleton(
                    width: (adjustedWidth < 360 ? 360 : adjustedWidth) * 0.8,
                    color: primaryColor,
                  ),
                if (!profile.isAnonymous)
                  Card(
                    width: (adjustedWidth < 360 ? 360 : adjustedWidth) * 0.8,
                    uid: profile.account,
                    color: primaryColor,
                    profile: profile,
                    icon: CupertinoIcons.device_phone_portrait,
                    onTopUpPressed: !widget.loading && topUpPlugin != null
                        ? () => widget.onTopUpTap(topUpPlugin.url)
                        : null,
                    onCardPressed: (_) => handleProfileTap(),
                    onCardBalanceTapped: handleBalanceTap,
                    logo: tokenConfig?.logo,
                    balance: balance,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Name extends StatelessWidget {
  final String name;

  const Name({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class Balance extends StatelessWidget {
  final String balance;
  final String? logo;

  const Balance({super.key, required this.balance, this.logo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CoinLogo(size: 33, logo: logo),
        SizedBox(width: 4),
        Text(
          balance,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class TopUpButton extends StatelessWidget {
  final Function() onTopUpTap;

  const TopUpButton({super.key, required this.onTopUpTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.select<AppState, Color>(
      (state) => state.tokenPrimaryColor,
    );

    return CupertinoButton(
      padding: EdgeInsets.zero,
      color: primaryColor,
      borderRadius: BorderRadius.circular(8),
      minSize: 0,
      onPressed: onTopUpTap,
      child: SizedBox(
        width: 70,
        height: 28,
        child: Center(
          child: Text(
            '+ top up',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
