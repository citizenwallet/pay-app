import 'dart:math';
import 'package:flutter/cupertino.dart';

import 'account_card_back.dart';
import 'account_card_front.dart';

class FlipCard extends StatefulWidget {
  final Duration duration;

  const FlipCard({
    super.key,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> {
  bool _showFrontSide = true;

  void _switchCard() {
    setState(() {
      _showFrontSide = !_showFrontSide;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration,
      transitionBuilder: _transitionBuilder,
      layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
      switchInCurve: Curves.easeInBack,
      switchOutCurve: Curves.easeInBack.flipped,
      child: _showFrontSide
          ? AccountCardFront(onTap: _switchCard)
          : AccountCardBack(onTap: _switchCard),
    );
  }

  Widget _transitionBuilder(Widget child, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);

    return AnimatedBuilder(
      animation: rotateAnim,
      child: child,
      builder: (context, child) {
        final isUnder = (ValueKey(_showFrontSide) != child?.key);
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;

        final value =
            isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}
