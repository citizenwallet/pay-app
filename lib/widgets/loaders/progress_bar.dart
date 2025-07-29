// import 'package:citizenwallet/theme/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:simple_animations/simple_animations.dart';

class ProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final double width;
  final Color? color;
  final Color? backgroundColor;
  final double borderRadius;
  final List<(double, Widget Function(bool))>? steps;
  final Widget? child;

  const ProgressBar(
    this.value, {
    super.key,
    this.height = 20,
    this.width = 200,
    this.color,
    this.backgroundColor,
    this.borderRadius = 10,
    this.steps,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final progress = value * width;
    final stepSize = height * 1.1;
    final progressWidth = width - stepSize;

    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;

    return SizedBox(
      height: steps != null ? stepSize : height,
      width: width,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: stepSize / 2,
            child: Container(
              height: height,
              width: progressWidth,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: child,
            ),
          ),
          Positioned(
            left: stepSize / 2,
            child: MirrorAnimationBuilder<Color?>(
              builder: (context, value, child) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: height,
                width: clampDouble(progress, 0, progressWidth),
                decoration: BoxDecoration(
                  color: value,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: child,
              ),
              tween: ColorTween(
                begin: primaryColor,
                end: primaryColor,
              ),
              duration: const Duration(milliseconds: 750),
            ),
          ),
          if (steps != null && steps!.isNotEmpty)
            ...steps!.map(
              (step) => Positioned(
                top: 0,
                left: step.$1 * progressWidth,
                child: Container(
                  height: stepSize,
                  width: stepSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFFFFFFF),
                  ),
                  child: step.$2(value >= step.$1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
