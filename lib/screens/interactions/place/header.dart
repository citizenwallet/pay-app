import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pay_app/widgets/profile_circle.dart';

class ChatHeader extends StatelessWidget {
  final bool loading;
  final String? imageUrl;
  final String? placeName;
  final String? placeDescription;
  final VoidCallback? onTapLeading;

  const ChatHeader({
    super.key,
    this.loading = false,
    this.imageUrl,
    this.placeName,
    this.placeDescription,
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
          ProfileCircle(
            loading: loading,
            imageUrl: imageUrl,
            size: 70,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/shop.svg',
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      placeName ?? '',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  placeDescription ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF71717A),
                  ),
                ),
              ],
            ),
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
