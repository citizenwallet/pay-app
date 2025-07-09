import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/coin_logo.dart';

enum TapDepth {
  none,
  active,
  tapping,
}

class Card extends StatefulWidget {
  final String uid;
  final double width;
  final Color color;
  final ProfileV1? profile;
  final double? balance;
  final VoidCallback? onTopUpPressed;
  final Future<void> Function(String)? onCardPressed;

  const Card({
    super.key,
    required this.uid,
    this.width = 200,
    required this.color,
    this.profile,
    this.balance,
    this.onTopUpPressed,
    this.onCardPressed,
  });

  @override
  State<Card> createState() => _CardState();
}

class _CardState extends State<Card> {
  TapDepth tapDepth = TapDepth.none;

  void handleCardTap() async {
    if (widget.onCardPressed == null) {
      return;
    }

    await widget.onCardPressed?.call(widget.uid);

    setState(() {
      tapDepth = TapDepth.none;
    });
  }

  void handleTapUp(TapUpDetails details) {
    if (widget.onCardPressed == null) {
      return;
    }

    setState(() {
      tapDepth = TapDepth.tapping;
    });
  }

  void handleTapDown(TapDownDetails details) {
    if (widget.onCardPressed == null) {
      return;
    }

    setState(() {
      tapDepth = TapDepth.active;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Standard credit card proportions: 1.586 (width:height ratio)
    double cardWidth = switch (tapDepth) {
      TapDepth.tapping => widget.width * 1.1,
      TapDepth.active => widget.width * 1.05,
      _ => widget.width,
    };

    double cardHeight = cardWidth / 1.586;

    return GestureDetector(
      onTap: handleCardTap,
      onTapDown: handleTapDown,
      onTapUp: handleTapUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.white),
          boxShadow: [
            BoxShadow(
              color: blackColor.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.profile?.username != null
                          ? '@${widget.profile?.username}'
                          : 'anonymous',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/icons/nfc.png',
                    color: CupertinoColors.white,
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.onTopUpPressed != null)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(8),
                      minSize: 0,
                      onPressed: widget.onTopUpPressed,
                      child: SizedBox(
                        width: 100,
                        height: 28,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.plus,
                              color: widget.color,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'add funds',
                              style: TextStyle(
                                color: widget.color,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.balance != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CoinLogo(size: 20),
                            const SizedBox(width: 4),
                            Text(
                              widget.balance!.toStringAsFixed(2),
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 20,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
