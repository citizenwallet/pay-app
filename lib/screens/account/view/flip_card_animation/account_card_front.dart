import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/widgets/profile_circle.dart';

class AccountCardFront extends StatefulWidget {
  final void Function() onTap;

  const AccountCardFront({super.key, required this.onTap});

  @override
  State<AccountCardFront> createState() => _AccountCardFrontState();
}

class _AccountCardFrontState extends State<AccountCardFront> {
  void _navigateToEditAccount() {
    final navigator = GoRouter.of(context);

    final userId = GoRouter.of(context).state?.pathParameters['id'];

    navigator.go('/$userId/my-account/edit');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _navigateToEditAccount,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Color(0xFFF7F7FF),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Color(0xFF3431C4), width: 2),
            ),
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ProfileCircle(
                  size: 135,
                ),
                Text(
                  'Kevin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Color(0xFF171717),
                  ),
                ),
                Text(
                  '@kevin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Color(0xFF171717),
                  ),
                ),
              ],
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
            onPressed: widget.onTap,
            child: Container(
              width: 30, // Fixed width
              height: 30, // Fixed height (same as width for perfect circle)
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.qrcode, // Your icon
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
