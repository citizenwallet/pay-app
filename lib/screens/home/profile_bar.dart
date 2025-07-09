import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/profile_circle.dart';
import 'package:provider/provider.dart';

class ProfileBar extends StatefulWidget {
  final bool loading;
  final String accountAddress;
  final Future<void> Function() onProfileTap;
  final Function(String) onTopUpTap;
  final Function() onSettingsTap;

  const ProfileBar({
    super.key,
    required this.loading,
    required this.accountAddress,
    required this.onProfileTap,
    required this.onTopUpTap,
    required this.onSettingsTap,
  });

  @override
  State<ProfileBar> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> with TickerProviderStateMixin {
  bool _isTapped = false;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void handleProfileTap() async {
    await widget.onProfileTap();

    setState(() {
      _isTapped = false;
    });
    _rotationController.reverse();
  }

  void handleTapIn() {
    HapticFeedback.lightImpact();
    setState(() {
      _isTapped = true;
    });
    _rotationController.forward();
  }

  void handleTapOut() {
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.select<WalletState, String>(
      (state) => state.balance.toStringAsFixed(2),
    );
    final config = context.select<WalletState, Config?>(
      (state) => state.config,
    );
    final tokenConfig = context.select<WalletState, TokenConfig?>(
      (state) => state.currentTokenConfig,
    );

    final topUpPlugin = config?.plugins?.firstWhereOrNull(
      (plugin) => plugin.action == 'topup' && plugin.token == tokenConfig?.key,
    );

    final profile = context.watch<ProfileState>().profile;

    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;

    return GestureDetector(
      onTap: widget.loading ? null : handleProfileTap,
      onTapDown: widget.loading ? null : (_) => handleTapIn(),
      onTapUp: widget.loading ? null : (_) => handleTapOut(),
      onTapCancel: widget.loading ? null : () => handleTapOut(),
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFD9D9D9),
              width: 1,
            ),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: !_isTapped
                ? primaryColor.withAlpha(20)
                : primaryColor.withAlpha(40),
            // borderRadius: BorderRadius.circular(16),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: !_isTapped
                  ? primaryColor.withAlpha(40)
                  : primaryColor.withAlpha(60),
              width: _isTapped ? 3 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  ProfileCircle(
                    size: 70,
                    borderWidth: 3,
                    borderColor: primaryColor,
                    imageUrl: profile.imageMedium,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Name(name: '@${profile.username}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Balance(balance: balance, logo: tokenConfig?.logo),
                          const SizedBox(width: 16),
                          if (!widget.loading && topUpPlugin != null)
                            TopUpButton(
                                onTopUpTap: () =>
                                    widget.onTopUpTap(topUpPlugin.url)),
                        ],
                      )
                    ],
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(right: 2),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Icon(
                          CupertinoIcons.chevron_down,
                          color: iconColor,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
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
    final primaryColor = context.select<WalletState, Color>(
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
