import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/place.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/profile_circle.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlaceListItem extends StatelessWidget {
  final Place place;
  final Function(Place) onTap;

  const PlaceListItem({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const circleSize = 60.0;

    return CupertinoButton(
      padding: EdgeInsets.symmetric(vertical: 4),
      onPressed: () => onTap(place),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ProfileCircle(
              imageUrl: place.imageUrl ?? 'assets/icons/shop.png',
              size: circleSize,
              padding: 2,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 12),
            Details(place: place),
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

class Details extends StatelessWidget {
  final Place place;

  const Details({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/shop.svg',
                height: 16,
                width: 16,
                semanticsLabel: 'shop',
              ),
              const SizedBox(width: 4),
              Name(name: place.name),
            ],
          ),
          const SizedBox(height: 4),
          Location(location: place.description),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class Name extends StatelessWidget {
  final String name;

  const Name({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF14023F),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class Location extends StatelessWidget {
  final String? location;

  const Location({super.key, this.location});

  @override
  Widget build(BuildContext context) {
    return Text(
      location ?? '1000 Brussels',
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Color(0xFF8F8A9D),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
