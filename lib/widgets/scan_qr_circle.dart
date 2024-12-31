import 'package:flutter/cupertino.dart';

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
    return GestureDetector(
      onTap: handleQRScan,
      child: Container(
        height: 90,
        width: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFFFFF),
          border: Border.all(
            color: Color(0xFF4a90e2),
            width: 3,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Center(
          child: Icon(
            CupertinoIcons.qrcode_viewfinder,
            size: 60 * heightFactor,
            color: Color(0xFF4a90e2),
          ),
        ),
      ),
    );
  }
}
