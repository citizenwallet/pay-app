import 'package:flutter/cupertino.dart';

class CupertinoCustomBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const CupertinoCustomBadge({
    super.key,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? CupertinoColors.systemBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
