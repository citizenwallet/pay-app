import 'package:flutter/cupertino.dart';
import 'package:pay_app/theme/colors.dart';

class WideButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final bool disabled;

  const WideButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: disabled
            ? (color ?? primaryColor).withValues(alpha: 0.5)
            : color ?? primaryColor,
        borderRadius: BorderRadius.circular(100),
        padding: const EdgeInsets.symmetric(vertical: 16),
        onPressed: disabled ? null : onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: disabled
                ? CupertinoColors.white.withValues(alpha: 0.7)
                : CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}
