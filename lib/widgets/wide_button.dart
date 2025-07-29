import 'package:flutter/cupertino.dart';
import 'package:pay_app/theme/colors.dart';

class WideButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final bool disabled;

  const WideButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;

    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: disabled
            ? (color ?? primaryColor).withValues(alpha: 0.5)
            : color ?? primaryColor,
        borderRadius: BorderRadius.circular(100),
        padding: const EdgeInsets.symmetric(vertical: 16),
        onPressed: disabled ? null : onPressed,
        child: child,
      ),
    );
  }
}
