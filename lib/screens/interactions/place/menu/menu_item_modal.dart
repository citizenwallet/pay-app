import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/models/menu_item.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/modals/dismissible_modal_popup.dart';

class MenuItemModal extends StatelessWidget {
  final MenuItem menuItem;

  const MenuItemModal({
    super.key,
    required this.menuItem,
  });

  static void show(BuildContext context, MenuItem menuItem) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (context) => MenuItemModal(menuItem: menuItem),
    );
  }

  void handleClose(BuildContext context, {String? cardAddress}) {
    final navigator = GoRouter.of(context);
    navigator.pop(cardAddress);
  }

  @override
  Widget build(BuildContext context) {
    return DismissibleModalPopup(
      maxHeight: MediaQuery.of(context).size.height * 0.7,
      backgroundColor: whiteColor,
      topRadius: 20,
      onDismissed: (dir) {
        handleClose(context);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (menuItem.imageUrl != null && menuItem.imageUrl!.isNotEmpty)
              Center(
                child: _buildImage(),
              ),

            if (menuItem.imageUrl != null && menuItem.imageUrl!.isNotEmpty)
              const SizedBox(height: 20),

            // Name
            Text(
              menuItem.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),

            const SizedBox(height: 12),

            // Price
            Row(
              children: [
                const CoinLogo(size: 20),
                const SizedBox(width: 6),
                Text(
                  menuItem.priceString,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),

            // Description
            if (menuItem.description != null &&
                menuItem.description!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Description',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                menuItem.description!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textMutedColor,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final String placeholderSvg = 'assets/icons/menu-item-placeholder.svg';
    final String placeholderPng = 'assets/icons/menu-item-placeholder.png';

    final String asset = menuItem.imageUrl!;
    final network = asset.startsWith('http') || asset.startsWith('https');

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: asset.endsWith('.svg')
            ? network && !kDebugMode
                ? SvgPicture.network(
                    asset,
                    semanticsLabel: 'menu item',
                    fit: BoxFit.cover,
                    placeholderBuilder: (_) => SvgPicture.asset(
                      placeholderSvg,
                      fit: BoxFit.cover,
                    ),
                  )
                : SvgPicture.asset(
                    asset,
                    semanticsLabel: 'menu item',
                    fit: BoxFit.cover,
                  )
            : Stack(
                children: [
                  if (!network)
                    Image.asset(
                      asset,
                      semanticLabel: 'menu item',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        placeholderPng,
                        semanticLabel: 'menu item',
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (network) ...[
                    CachedNetworkImage(
                      imageUrl: asset,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) => Image.asset(
                        placeholderPng,
                        semanticLabel: 'menu item',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ]
                ],
              ),
      ),
    );
  }
}
