import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/state/community.dart';
import 'package:pay_app/state/wallet.dart';
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
  final TextEditingController _emailController = TextEditingController();
  late CommunityState _communityState;
  late WalletState _walletState;

  @override
  void initState() {
    super.initState();

    _communityState = context.read<CommunityState>();
    _walletState = context.read<WalletState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLoad();
    });
  }

  void onLoad() async {
    await _communityState.fetchCommunity();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void handleConfirm(int userId) async {

    final addressFromCreate = await _walletState.createWallet();
    final addressFromOpen = await _walletState.openWallet();

    debugPrint('addressFromCreate: $addressFromCreate');
    debugPrint('addressFromOpen: $addressFromOpen');


    // final exists = await _walletState.createAccount();

    // debugPrint('account exists: $exists');
    // debugPrint('finish');


    final navigator = GoRouter.of(context);
    navigator.replace('/$userId');
  }



  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    final community = context.select((CommunityState state) => state.community);

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
                          color: Color(0xFF14023F),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        community?.community.description ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8F8A9D),
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
                      controller: _emailController,
                      placeholder: 'Enter your email address',
                      suffix: Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(
                          CupertinoIcons.mail,
                          color: Color(0xFF4D4D4D),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Button
                    WideButton(
                      text: 'Confirm',
                      onPressed: () => handleConfirm(1),
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
