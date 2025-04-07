import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:pay_app/widgets/profile_circle.dart';

class ChatHeader extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? photo;
  final String? username;
  final String? phone;
  final String? name;
  final VoidCallback? onTapLeading;

  const ChatHeader({
    super.key,
    this.username,
    this.phone,
    this.imageUrl,
    this.photo,
    this.name,
    this.onTapLeading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD9D9D9),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildLeft(),
          _buildMiddle(),
        ],
      ),
    );
  }

  Widget _buildMiddle() {
    return Expanded(
      child: Row(
        children: [
          if (imageUrl != null)
            ProfileCircle(
              imageUrl: imageUrl,
              size: 70,
            ),
          if (imageUrl == null && photo != null)
            ProfileCircle(
              imageBytes: photo,
              size: 70,
            ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name ?? '',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (username != null)
                Text(
                  '@$username',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (phone != null && phone!.isNotEmpty)
                Text(
                  phone ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeft() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTapLeading,
      child: Icon(
        CupertinoIcons.back,
        color: Color(0xFF09090B),
        size: 20,
      ),
    );
  }
}
