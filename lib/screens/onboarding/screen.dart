import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/state/community.dart';
import 'package:pay_app/state/onboarding.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/wide_button.dart';
import 'package:pay_app/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late OnboardingState _onboardingState;
  late CommunityState _communityState;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onboardingState = context.read<OnboardingState>();
      _communityState = context.read<CommunityState>();
      onLoad();
    });
  }

  // Add a focus node
  final FocusNode _focusNode = FocusNode();
  final FocusNode _challengeFocusNode = FocusNode();

  String? _previousChallenge;
  bool _navigating = false;

  void onLoad() async {
    final navigator = GoRouter.of(context);

    await _onboardingState.init();
    await _communityState.fetchCommunity();

    final account = await _onboardingState.isSessionExpired();
    if (account != null) {
      navigator.go('/${account.hexEip55}');
      return;
    }

    // Start the animation
    _animationController.forward().then((_) {
      // Focus the text field after animation completes
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void handleRequest(String source) async {
    await _onboardingState.requestSession(source);
    _onboardingState.updateChallenge(null);

    await delay(const Duration(milliseconds: 100));

    _challengeFocusNode.requestFocus();
  }

  void handleConfirm(String challenge) async {
    final navigator = GoRouter.of(context);

    await delay(const Duration(milliseconds: 50));

    final account = await _onboardingState.confirmSession(challenge);

    if (account != null && !_navigating) {
      _navigating = true;
      _onboardingState.reset();
      navigator.go('/${account.hexEip55}');
    }
  }

  void handleTermsAndConditions() {
    launchUrl(
      Uri.parse('https://www.pay.brussels/terms-and-conditions'),
      mode: LaunchMode.inAppWebView,
    );
  }

  void handleRetry() {
    _onboardingState.retry();
  }

  void handlePhoneNumberChange(String phoneNumber) {
    _onboardingState.formatPhoneNumber(phoneNumber);
  }

  void handleChallengeChange(String challenge) {
    _onboardingState.updateChallenge(challenge);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final community = context.select((CommunityState state) => state.community);

    final sessionRequestStatus =
        context.select((OnboardingState state) => state.sessionRequestStatus);

    final phoneNumberController =
        context.read<OnboardingState>().phoneNumberController;
    final challengeController =
        context.read<OnboardingState>().challengeController;

    final challenge =
        context.select((OnboardingState state) => state.challenge);

    final touched = context.select((OnboardingState state) => state.touched);
    final regionCode =
        context.select((OnboardingState state) => state.regionCode);

    final challengeTouched =
        context.select((OnboardingState state) => state.challengeTouched);

    final isValidPhoneNumber = regionCode != null;
    final isValidChallenge = challenge != null && challenge.length == 6;

    if (challenge != _previousChallenge && isValidChallenge) {
      handleConfirm(challenge);
    }
    _previousChallenge = challenge;

    return CupertinoPageScaffold(
      backgroundColor: whiteColor,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Container(
            width: width,
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

                // Bottom content with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'By signing in, you agree to the ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textMutedColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: handleTermsAndConditions,
                            child: Text(
                              'terms and conditions',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textMutedColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            '.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textMutedColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Phone Number Input
                      if (sessionRequestStatus == SessionRequestStatus.none ||
                          sessionRequestStatus ==
                              SessionRequestStatus.pending ||
                          sessionRequestStatus == SessionRequestStatus.failed)
                        CustomTextField(
                          controller: phoneNumberController,
                          placeholder: '+32475123456',
                          focusNode: _focusNode, // Use the focus node
                          autofocus:
                              false, // We'll focus manually after animation
                          enabled:
                              sessionRequestStatus == SessionRequestStatus.none,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: !touched
                                  ? mutedColor
                                  : touched && isValidPhoneNumber
                                      ? (sessionRequestStatus ==
                                              SessionRequestStatus.pending
                                          ? transparentColor
                                          : primaryColor)
                                      : warningColor,
                            ),
                          ),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 22,
                            color: sessionRequestStatus ==
                                    SessionRequestStatus.pending
                                ? textMutedColor
                                : textColor,
                            fontWeight: touched && isValidPhoneNumber
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
                            child: isValidPhoneNumber
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
                      //   Number Input
                      if (sessionRequestStatus ==
                              SessionRequestStatus.challenge ||
                          sessionRequestStatus ==
                              SessionRequestStatus.confirming ||
                          sessionRequestStatus ==
                              SessionRequestStatus.confirmFailed)
                        CustomTextField(
                          controller: challengeController,
                          placeholder: 'Enter login code',
                          focusNode: _challengeFocusNode, // Use the focus node
                          autofocus:
                              false, // We'll focus manually after animation
                          enabled: sessionRequestStatus ==
                                  SessionRequestStatus.challenge ||
                              sessionRequestStatus ==
                                  SessionRequestStatus.confirmFailed,
                          maxLength: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: !challengeTouched
                                  ? mutedColor
                                  : challengeTouched && isValidChallenge
                                      ? (sessionRequestStatus ==
                                              SessionRequestStatus.confirming
                                          ? transparentColor
                                          : primaryColor)
                                      : warningColor,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            color: sessionRequestStatus ==
                                    SessionRequestStatus.confirming
                                ? textMutedColor
                                : textColor,
                            fontWeight: challengeTouched && isValidChallenge
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
                          keyboardType: TextInputType.number,
                          onChanged: handleChallengeChange,
                        ),
                      const SizedBox(height: 16),
                      if (sessionRequestStatus ==
                          SessionRequestStatus.confirmFailed)
                        Text(
                          'Invalid code',
                          style: TextStyle(
                            color: dangerColor,
                          ),
                        ),
                      if (sessionRequestStatus ==
                          SessionRequestStatus.confirmFailed)
                        const SizedBox(
                          height: 16,
                        ),

                      // Confirm Button
                      if (sessionRequestStatus == SessionRequestStatus.none ||
                          sessionRequestStatus ==
                              SessionRequestStatus.pending ||
                          sessionRequestStatus == SessionRequestStatus.failed)
                        WideButton(
                          disabled: !isValidPhoneNumber ||
                              sessionRequestStatus ==
                                  SessionRequestStatus.pending,
                          onPressed: isValidPhoneNumber
                              ? () => handleRequest(
                                  phoneNumberController.value.text)
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                sessionRequestStatus ==
                                        SessionRequestStatus.pending
                                    ? 'Sending SMS Code...'
                                    : 'Confirm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: sessionRequestStatus ==
                                          SessionRequestStatus.pending
                                      ? primaryColor.withAlpha(180)
                                      : CupertinoColors.white,
                                ),
                              ),
                              if (sessionRequestStatus ==
                                  SessionRequestStatus.pending)
                                const SizedBox(width: 8),
                              if (sessionRequestStatus ==
                                  SessionRequestStatus.pending)
                                CupertinoActivityIndicator(
                                  color: primaryColor.withAlpha(180),
                                ),
                            ],
                          ),
                        ),
                      // Challenge Confirm Button
                      if (sessionRequestStatus ==
                              SessionRequestStatus.challenge ||
                          sessionRequestStatus ==
                              SessionRequestStatus.confirming ||
                          sessionRequestStatus ==
                              SessionRequestStatus.confirmFailed)
                        WideButton(
                          disabled: !isValidChallenge ||
                              sessionRequestStatus ==
                                  SessionRequestStatus.confirming,
                          onPressed: isValidChallenge
                              ? () =>
                                  handleConfirm(challengeController.value.text)
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                sessionRequestStatus ==
                                        SessionRequestStatus.confirming
                                    ? 'Logging in...'
                                    : sessionRequestStatus ==
                                            SessionRequestStatus.confirmFailed
                                        ? 'Confirm code again'
                                        : 'Confirm code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: sessionRequestStatus ==
                                          SessionRequestStatus.confirming
                                      ? primaryColor.withAlpha(180)
                                      : CupertinoColors.white,
                                ),
                              ),
                              if (sessionRequestStatus ==
                                  SessionRequestStatus.confirming)
                                const SizedBox(width: 8),
                              if (sessionRequestStatus ==
                                  SessionRequestStatus.confirming)
                                CupertinoActivityIndicator(
                                  color: primaryColor.withAlpha(180),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (sessionRequestStatus ==
                          SessionRequestStatus.confirmFailed)
                        WideButton(
                          onPressed: handleRetry,
                          color: whiteColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Send new code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (sessionRequestStatus ==
                          SessionRequestStatus.confirmFailed)
                        const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
