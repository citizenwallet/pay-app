import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pay_app/theme/colors.dart';

enum TapDepth {
  none,
  tapped,
  active,
}

class ScanQrCircle extends StatefulWidget {
  final Function(Function()) handleQRScan;
  final bool isDisabled;

  const ScanQrCircle({
    super.key,
    required this.handleQRScan,
    this.isDisabled = false,
  });

  @override
  State<ScanQrCircle> createState() => _ScanQrCircleState();
}

class _ScanQrCircleState extends State<ScanQrCircle> {
  TapDepth _tapDepth = TapDepth.none;

  void handleTap() {
    widget.handleQRScan(() => {
          setState(() {
            _tapDepth = TapDepth.none;
          })
        });
  }

  void handleTapIn() {
    HapticFeedback.lightImpact();
    setState(() {
      _tapDepth = TapDepth.tapped;
    });
  }

  void handleTapOut() {
    HapticFeedback.heavyImpact();
    setState(() {
      _tapDepth = TapDepth.active;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    final primaryColor = switch (_tapDepth) {
      TapDepth.tapped => theme.primaryColor.withAlpha(200),
      TapDepth.active => theme.primaryColor.withAlpha(100),
      _ => theme.primaryColor,
    };

    final double size = switch (_tapDepth) {
      TapDepth.tapped => 110,
      TapDepth.active => 95,
      _ => 90,
    };

    return GestureDetector(
      onTap: widget.isDisabled ? null : handleTap,
      onTapDown: widget.isDisabled ? null : (_) => handleTapIn(),
      onTapUp: widget.isDisabled ? null : (_) => handleTapOut(),
      onTapCancel: widget.isDisabled ? null : () => handleTapOut(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: whiteColor,
          border: Border.all(
            color: primaryColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: blackColor.withAlpha(80),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Center(
          child: Icon(
            CupertinoIcons.qrcode_viewfinder,
            size: 60,
            color: primaryColor,
          ),
        ),
      ),
    );
  }
}
