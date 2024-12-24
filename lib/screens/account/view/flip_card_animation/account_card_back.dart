import 'package:flutter/cupertino.dart';

class AccountCardBack extends StatelessWidget {
  final void Function() onTap;

  const AccountCardBack({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: Color(0xFFF7F7FF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Color(0xFF3431C4), width: 2),
          ),
          padding: EdgeInsets.all(8),
          child: Center(
            child: Text(
              'My QR Code',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 32,
                color: Color(0xFF171717),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: CupertinoButton(
            padding: EdgeInsets.zero, // Remove default padding
            borderRadius: BorderRadius.circular(30), // Make it circular
            color: Color(0xFF3431C4), // Background color
            onPressed: onTap,
            child: Container(
              width: 30, // Fixed width
              height: 30, // Fixed height (same as width for perfect circle)
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.person, // Your icon
                color: CupertinoColors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
