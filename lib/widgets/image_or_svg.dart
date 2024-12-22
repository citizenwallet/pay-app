import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class ImageOrSvg extends StatelessWidget {
  final String image;
  final BoxFit fit;

  final bool isSvg;

  final Widget placeholder = Image.asset(
    'assets/logo.png',
    fit: BoxFit.cover,
  );

  ImageOrSvg({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
  }) : isSvg = image.endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (isSvg) {
      try {
        return SvgPicture.network(
          image,
          fit: fit,
          placeholderBuilder: (context) => placeholder,
        );
      } catch (e) {
        return placeholder;
      }
    }

    return Image.network(
      image,
      fit: fit,
      errorBuilder: (context, error, stack) => placeholder,
    );
  }
}
