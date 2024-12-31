import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pay_app/models/menu_item.dart';
import 'package:pay_app/state/checkout.dart';
import 'package:pay_app/widgets/coin_logo.dart';

class MenuListItem extends StatelessWidget {
  final CheckoutState checkoutState;
  final MenuItem menuItem;

  const MenuListItem({
    super.key,
    required this.menuItem,
    required this.checkoutState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xFFD9D9D9),
          width: 1,
        ),
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ItemImage(imageUrl: menuItem.imageUrl),
          const SizedBox(width: 1.2),
          VerticalDivider(
            color: Color(0xFFD9D9D9),
            thickness: 1,
            indent: 8,
            endIndent: 8,
          ),
          const SizedBox(width: 1.2),
          Expanded(
            child: ItemNameDescription(
              name: menuItem.name,
              description: menuItem.description,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ItemPrice(price: menuItem.priceString),
              const SizedBox(height: 4),
              if (checkoutState.checkout.quantityOfMenuItem(menuItem) <= 0) ...[
                AddToCartButton(
                  onAddToCart: checkoutState.addItem,
                  menuItem: menuItem,
                ),
              ],
              if (checkoutState.checkout.quantityOfMenuItem(menuItem) > 0) ...[
                IncDecButton(
                  onIncrease: checkoutState.increaseItem,
                  onDecrease: checkoutState.decreaseItem,
                  quantityOfMenuItem: checkoutState.checkout.quantityOfMenuItem,
                  menuItem: menuItem,
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}

class ItemImage extends StatelessWidget {
  final String? imageUrl;
  const ItemImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final String placeholderSvg = 'assets/icons/menu-item-placeholder.svg';
    final String placeholderPng = 'assets/icons/menu-item-placeholder.png';

    final String asset =
        imageUrl != null && imageUrl != '' ? imageUrl! : placeholderSvg;

    final network = asset.startsWith('http') || asset.startsWith('https');

    final double size = 58;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: asset.endsWith('.svg')
            ? network && !kDebugMode
                ? SvgPicture.network(
                    asset,
                    semanticsLabel: 'menu item',
                    height: size,
                    width: size,
                    placeholderBuilder: (_) => SvgPicture.asset(
                      placeholderSvg,
                      height: size,
                      width: size,
                    ),
                  )
                : SvgPicture.asset(
                    asset,
                    semanticsLabel: 'menu item',
                    height: size,
                    width: size,
                  )
            : Stack(
                children: [
                  if (!network)
                    Image.asset(
                      asset,
                      semanticLabel: 'menu item',
                      height: size,
                      width: size,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        placeholderPng,
                        semanticLabel: 'menu item',
                        height: size,
                        width: size,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (network) ...[
                    CachedNetworkImage(
                      imageUrl: asset,
                      height: size,
                      width: size,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) => Image.asset(
                        placeholderPng,
                        semanticLabel: 'menu item',
                        height: size,
                        width: size,
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

class ItemNameDescription extends StatelessWidget {
  final String name;
  final String? description;
  const ItemNameDescription({super.key, required this.name, this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4D4D4D),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          description ?? '',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8F8A9D),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class ItemPrice extends StatelessWidget {
  final String price;
  const ItemPrice({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return Row(
      children: [
        CoinLogo(size: 16),
        Text(
          price,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }
}

class AddToCartButton extends StatelessWidget {
  final void Function(MenuItem) onAddToCart;
  final MenuItem menuItem;

  const AddToCartButton({
    super.key,
    required this.onAddToCart,
    required this.menuItem,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: () => onAddToCart(menuItem),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '+ Add to cart',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF171717),
          ),
        ),
      ),
    );
  }
}

class IncDecButton extends StatelessWidget {
  final void Function(MenuItem) onIncrease;
  final void Function(MenuItem) onDecrease;
  final int Function(MenuItem) quantityOfMenuItem;
  final MenuItem menuItem;

  const IncDecButton({
    super.key,
    required this.onIncrease,
    required this.onDecrease,
    required this.quantityOfMenuItem,
    required this.menuItem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () => onDecrease(menuItem),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFFD9D9D9),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '-',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF171717),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          quantityOfMenuItem(menuItem).toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF171717),
          ),
        ),
        const SizedBox(width: 10),
        CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () => onIncrease(menuItem),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFFD9D9D9),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF171717),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
