import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pay_app/services/contacts/contacts.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/profile_circle.dart';

class ContactListItem extends StatelessWidget {
  final SimpleContact contact;
  final Function(SimpleContact) onTap;

  const ContactListItem({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const circleSize = 60.0;

    return CupertinoButton(
      padding: EdgeInsets.symmetric(vertical: 4),
      onPressed: () => onTap(contact),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (contact.photo?.isNotEmpty == true)
              ProfileCircle(
                imageBytes: contact.photo!,
                size: circleSize,
                padding: 2,
              ),
            if (contact.imageUrl != null)
              ProfileCircle(
                imageUrl: contact.imageUrl!,
                size: circleSize,
                padding: 2,
              ),
            if (contact.photo?.isNotEmpty != true && contact.imageUrl == null)
              ProfileCircle(
                imageUrl: 'assets/icons/profile.png',
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
                        'assets/icons/contact.png',
                        semanticLabel: 'contact icon',
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        contact.name,
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
                        contact.phone,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8F8A9D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 4),
                      if (contact.label != null && contact.label!.isNotEmpty)
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
                            contact.label!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8F8A9D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
