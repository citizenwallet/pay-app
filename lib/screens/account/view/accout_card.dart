import 'package:flutter/cupertino.dart';
import 'package:pay_app/widgets/profile_circle.dart';

// TODO: navigate to edit account page

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 224,
        decoration: BoxDecoration(
          color: Color(0xFFF7F7FF),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Color(0xFF3431C4), width: 2),
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            ProfileCircle(
              size: 135,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
    );
  }
}
