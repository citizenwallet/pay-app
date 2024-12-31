import 'package:flutter/cupertino.dart';

class WideButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const WideButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: color ?? theme.primaryColor,
        borderRadius: BorderRadius.circular(100),
        padding: const EdgeInsets.symmetric(vertical: 16),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}
