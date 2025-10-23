import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/button.dart';

class HomeOnboardingModal extends StatefulWidget {
  const HomeOnboardingModal({super.key});

  @override
  State<HomeOnboardingModal> createState() => _HomeOnboardingModalState();
}

class _HomeOnboardingModalState extends State<HomeOnboardingModal>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingStep> _steps = [
    const OnboardingStep(
      title: 'Your phone number is your account!',
      description:
          'The onboarding flow you just went through confirms that you have access to this phone number. You own the tokens in your account.',
      icon: CupertinoIcons.phone,
    ),
    const OnboardingStep(
      title: 'This is your virtual card',
      description:
          'You can top it up and you can use it to spend at various vendors.',
      icon: CupertinoIcons.creditcard,
    ),
    const OnboardingStep(
      title: 'Tokens',
      description:
          'There are multiple initiatives, each has a its own token and vendors who accept it. They will appear in the list.',
      icon: CupertinoIcons.circle_grid_3x3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_currentStep < _steps.length - 1) {
      await _animationController.reverse();
      setState(() {
        _currentStep++;
      });
      _animationController.forward();
    } else {
      _complete();
    }
  }

  void _complete() {
    GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height,
      color: whiteColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stepper
              _buildStepper(),
              const SizedBox(height: 48),

              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Icon(
                          _steps[_currentStep].icon,
                          size: 60,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title
                      Text(
                        _steps[_currentStep].title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _steps[_currentStep].description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Button
              const SizedBox(height: 32),
              Button(
                onPressed: _nextStep,
                text: _currentStep < _steps.length - 1
                    ? 'Continue'
                    : 'Get Started',
                color: primaryColor,
                labelColor: whiteColor,
                maxWidth: double.infinity,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _steps.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentStep
                ? primaryColor
                : primaryColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
