import 'package:flutter/cupertino.dart';
import 'package:pay_app/widgets/coin_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

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
                      const Text(
                        'Brussels Pay',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14023F),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      const Text(
                        'A local and inclusive payment network',
                        style: TextStyle(
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
                    CupertinoTextField(
                      controller: _emailController,
                      placeholder: 'Enter your email address',
                      placeholderStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFB7ADC4),
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF3431C4),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      suffix: const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(
                          CupertinoIcons.mail,
                          color: Color(0xFF3431C4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: const Color(0xFF3431C4),
                        borderRadius: BorderRadius.circular(100),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        onPressed: () {
                          // Handle confirmation
                        },
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.white,
                          ),
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
