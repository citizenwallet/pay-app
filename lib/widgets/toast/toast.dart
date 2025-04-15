import 'package:flutter/cupertino.dart';
import 'package:pay_app/theme/colors.dart';

class Toast extends StatelessWidget {
  final Widget? icon;
  final Widget title;

  const Toast({
    super.key,
    this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: blackColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) icon!,
          if (icon != null) const SizedBox(width: 16),
          title,
        ],
      ),
    );
  }
}
