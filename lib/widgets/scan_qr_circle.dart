import 'package:flutter/cupertino.dart';
import 'package:pay_app/theme/colors.dart';

// TODO: disabled styling

class ScanQrCircle extends StatelessWidget {
  final Function() handleQRScan;
  final bool isDisabled;
  final double heightFactor;

  const ScanQrCircle(
      {super.key,
      required this.handleQRScan,
      this.isDisabled = false,
      this.heightFactor = 1});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return GestureDetector(
      onTap: handleQRScan,
      child: Container(
        height: 90,
        width: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFFFFF),
          border: Border.all(
            color: theme.primaryColor,
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
            size: 60 * heightFactor,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }
}
