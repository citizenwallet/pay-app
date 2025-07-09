import 'package:pay_app/services/nfc/service.dart';
import 'package:pay_app/state/scanner.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NFCModal extends StatefulWidget {
  final String? modalKey;
  final bool confirm;
  final bool write;

  const NFCModal({
    super.key,
    this.modalKey,
    this.confirm = false,
    this.write = false,
  });

  @override
  NFCModalState createState() => NFCModalState();
}

class NFCModalState extends State<NFCModal>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  (String, String?)? result;
  late ScanState _scanState;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      lowerBound: 0,
      upperBound: 1,
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _controller.repeat();

    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // make initial requests here
      _scanState = context.read<ScanState>();

      onLoad(context);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
      // Restart the scanner when the app is resumed.
      // Don't forget to resume listening to the barcode events.

      case AppLifecycleState.inactive:
      // Stop the scanner when the app is paused.
      // Also stop the barcode events subscription.
    }
  }

  void onLoad(BuildContext context) async {
    await delay(const Duration(milliseconds: 50));

    if (widget.write) {
      result = await _scanState.configureNFC();
    } else {
      result = await _scanState.readNFC();
    }

    if (!context.mounted) {
      return;
    }

    handleSubmit(context);
  }

  @override
  void dispose() {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();

    super.dispose();
  }

  void handleDismiss(BuildContext context) {
    _scanState.cancelScan();
    GoRouter.of(context).pop();
  }

  void handleSubmit(BuildContext context) async {
    final navigator = GoRouter.of(context);

    await delay(const Duration(milliseconds: 1000));

    navigator.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final nfcDirection = context.watch<ScanState>().scannerDirection;

    final message = context.watch<ScanState>().message;

    return CupertinoPageScaffold(
        backgroundColor: Colors.black,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    if (nfcDirection == NFCScannerDirection.right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 160,
                            width: 240,
                            decoration: BoxDecoration(
                              color: whiteColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: whiteColor.withAlpha(100),
                              ),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Image.asset(
                                  'assets/icons/nfc.png',
                                  height: 40,
                                  width: 40,
                                ),
                                const SizedBox(width: 20),
                              ],
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) => Opacity(
                              opacity: (1 - _controller.view.value),
                              child: const Icon(
                                CupertinoIcons.arrow_right,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (nfcDirection == NFCScannerDirection.top)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) => Opacity(
                              opacity: (1 - _controller.view.value),
                              child: const Icon(
                                CupertinoIcons.arrow_up,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            height: 160,
                            width: 240,
                            decoration: BoxDecoration(
                              color: whiteColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: whiteColor.withAlpha(100),
                              ),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Image.asset(
                                  'assets/icons/nfc.png',
                                  height: 40,
                                  width: 40,
                                ),
                                const SizedBox(width: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    Text(
                      message ?? 'Tap to scan',
                      style: const TextStyle(fontSize: 48, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    OutlinedButton.icon(
                      onPressed: () => handleDismiss(context),
                      icon: const Icon(
                        CupertinoIcons.clear,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Cancel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ));
  }
}
