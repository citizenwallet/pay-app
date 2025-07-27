import 'package:flutter/cupertino.dart';
import 'package:pay_app/theme/colors.dart';

class CardSkeleton extends StatelessWidget {
  final double width;
  final Color color;
  final EdgeInsets? margin;

  const CardSkeleton({
    super.key,
    this.width = 200,
    required this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    // Standard credit card proportions: 1.586 (width:height ratio)
    double cardHeight = width / 1.586;

    return Container(
      width: width,
      height: cardHeight,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.white.withAlpha(160)),
        boxShadow: [
          BoxShadow(
            color: blackColor.withAlpha(60),
            blurRadius: 10,
            offset: const Offset(0, 6),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Profile circle skeleton
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: CupertinoColors.white.withAlpha(40),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CupertinoColors.white.withAlpha(80),
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Name skeleton
                          Container(
                            height: 20,
                            width: 120,
                            decoration: BoxDecoration(
                              color: CupertinoColors.white.withAlpha(40),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Username skeleton
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Icon skeleton
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Add funds button skeleton
                Container(
                  width: 100,
                  height: 28,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Balance skeleton
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Coin logo skeleton
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: CupertinoColors.white.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Balance text skeleton
                        Container(
                          height: 20,
                          width: 60,
                          decoration: BoxDecoration(
                            color: CupertinoColors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
