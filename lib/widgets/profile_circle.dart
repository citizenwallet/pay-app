import 'package:cached_network_image/cached_network_image.dart';
import 'package:pay_app/widgets/loaders/progress_circle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';

class ProfileCircle extends StatelessWidget {
  final bool loading;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double size;
  final double padding;
  final double innerPadding;
  final double? borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final BoxFit? fit;

  const ProfileCircle({
    super.key,
    this.loading = false,
    this.imageUrl,
    this.imageBytes,
    this.size = 50,
    this.padding = 0,
    this.innerPadding = 0,
    this.borderWidth,
    this.borderColor,
    this.backgroundColor,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final String asset = imageUrl != null && imageUrl != ''
        ? imageUrl!
        : 'assets/icons/profile.png';

    final network = asset.startsWith('http') || asset.startsWith('https');

    if (kDebugMode && asset.endsWith('.svg') && network) {
      return SvgPicture.asset(
        'assets/logo.svg',
        height: size,
        width: size,
      );
    }

    final child = imageBytes != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Padding(
              padding: EdgeInsets.all(innerPadding),
              child: Image(
                image: MemoryImage(imageBytes!),
                semanticLabel: 'profile icon',
                height: size,
                width: size,
                fit: fit,
              ),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Padding(
              padding: EdgeInsets.all(innerPadding),
              child: asset.endsWith('.svg')
                  ? network && !kDebugMode
                      ? SvgPicture.network(
                          asset,
                          semanticsLabel: 'profile icon',
                          height: size,
                          width: size,
                          placeholderBuilder: (_) => SvgPicture.asset(
                            'assets/logo.svg',
                            height: size,
                            width: size,
                          ),
                        )
                      : SvgPicture.asset(
                          asset,
                          semanticsLabel: 'profile icon',
                          height: size,
                          width: size,
                        )
                  : Stack(
                      children: [
                        if (!network)
                          Image.asset(
                            asset,
                            semanticLabel: 'profile icon',
                            height: size,
                            width: size,
                            fit: fit,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/icons/profile.png',
                              semanticLabel: 'profile icon',
                              height: size,
                              width: size,
                              fit: fit,
                            ),
                          ),
                        if (network) ...[
                          CachedNetworkImage(
                            imageUrl: asset,
                            height: size,
                            width: size,
                            fit: fit,
                            progressIndicatorBuilder:
                                (context, url, progress) => ProgressCircle(
                              progress: progress.progress ?? 0,
                              size: size,
                            ),
                            errorWidget: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/icons/profile.png',
                              semanticLabel: 'profile icon',
                              height: size,
                              width: size,
                              fit: fit,
                            ),
                          ),
                        ]
                      ],
                    ),
            ),
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? CupertinoColors.systemGrey5,
          width: borderWidth ?? 0,
        ),
      ),
      padding: EdgeInsets.all(padding),
      child:
          loading ? const Center(child: CupertinoActivityIndicator()) : child,
    );
  }
}
