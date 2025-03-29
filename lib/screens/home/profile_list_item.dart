import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/profile_circle.dart';

class ProfileListItem extends StatelessWidget {
  final ProfileV1 profile;
  final Function(ProfileV1) onTap;

  const ProfileListItem({
    super.key,
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const circleSize = 60.0;

    return CupertinoButton(
      padding: EdgeInsets.symmetric(vertical: 4),
      onPressed: () => onTap(profile),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ProfileCircle(
              imageUrl: profile.image,
              size: circleSize,
              padding: 2,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/at.png',
                        semanticLabel: 'at icon',
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF14023F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        profile.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8F8A9D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (profile.description.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEECF3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '@${profile.username}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8F8A9D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Icon(
                  CupertinoIcons.chevron_right,
                  color: iconColor,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
