import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/state/community.dart';
import 'package:pay_app/state/onboarding.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/wide_button.dart';
import 'package:pay_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late OnboardingState _onboardingState;
  late CommunityState _communityState;
  late WalletState _walletState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onboardingState = context.read<OnboardingState>();
      _communityState = context.read<CommunityState>();
      _walletState = context.read<WalletState>();
      onLoad();
    });
  }

  void onLoad() async {
    await _communityState.fetchCommunity();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void handleConfirm() async {
    final addressFromCreate = await _walletState.createWallet();
    final addressFromOpen = await _walletState.openWallet();

    debugPrint('addressFromCreate: $addressFromCreate');
    debugPrint('addressFromOpen: $addressFromOpen');

    // final exists = await _walletState.createAccount();

    // debugPrint('account exists: $exists');
    // debugPrint('finish');

    if (!mounted) return;

    final navigator = GoRouter.of(context);
    navigator.replace('/$addressFromOpen');
  }

  void handlePhoneNumberChange(String phoneNumber) {
    _onboardingState.formatPhoneNumber(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    final community = context.select((CommunityState state) => state.community);

    final phoneNumberController =
        context.read<OnboardingState>().phoneNumberController;

    final touched = context.select((OnboardingState state) => state.touched);
    final regionCode =
        context.select((OnboardingState state) => state.regionCode);

    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Top content in an Expanded to push it to the center
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      CoinLogo(size: 140),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        community?.community.name ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        community?.community.description ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textMutedColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Bottom content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Email Input
                    CustomTextField(
                      controller: phoneNumberController,
                      placeholder: '+32475123456',
                      autofocus: true,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: !touched
                              ? mutedColor
                              : touched && regionCode != null
                                  ? primaryColor
                                  : warningColor,
                        ),
                      ),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: touched && regionCode != null
                            ? FontWeight.w700
                            : FontWeight.w500,
                        letterSpacing: 2,
                      ),
                      placeholderStyle: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: textMutedColor,
                        letterSpacing: 2,
                      ),
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: regionCode != null
                            ? CountryFlag.fromCountryCode(
                                regionCode,
                                shape: const Circle(),
                                height: 40,
                                width: 40,
                              )
                            : SizedBox(
                                height: 40,
                                width: 40,
                                child: Icon(
                                  CupertinoIcons.phone,
                                  color: iconColor,
                                ),
                              ),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: handlePhoneNumberChange,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Button
                    WideButton(
                      disabled: regionCode == null,
                      onPressed:
                          regionCode != null ? () => handleConfirm() : null,
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
