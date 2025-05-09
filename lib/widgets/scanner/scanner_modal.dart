import 'dart:async';

import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerModal extends StatefulWidget {
  final String? modalKey;
  final bool confirm;

  const ScannerModal({
    super.key,
    this.modalKey,
    this.confirm = false,
  });

  @override
  ScannerModalState createState() => ScannerModalState();
}

class ScannerModalState extends State<ScannerModal>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final MobileScannerController _controller = MobileScannerController(
    autoStart: true,
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
    formats: <BarcodeFormat>[BarcodeFormat.qrCode],
  );

  double _opacity = 0;
  bool _complete = false;
  bool _hasTorch = false;
  bool _isTextEmpty = true;
  TorchState _torchState = TorchState.off;

  StreamSubscription<Object?>? _subscription;

  @override
  void initState() {
    _complete = false;
    _hasTorch = false;
    _torchState = TorchState.off;

    _controller.stop();

    super.initState();

    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // make initial requests here

      onLoad();
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
        _subscription = _controller.barcodes.listen(handleDetection);

        unawaited(_controller.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(_controller.stop());
    }
  }

  void onLoad() async {
    await delay(const Duration(milliseconds: 500));

    _controller.barcodes.listen(handleDetection);

    unawaited(_controller.start());

    await delay(const Duration(milliseconds: 250));

    setState(() {
      _opacity = 1;
      _hasTorch = _controller.torchEnabled;
    });
  }

  @override
  void dispose() {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;

    super.dispose();

    _controller.dispose();
  }

  void handleDismiss(BuildContext context) {
    _complete = true;
    GoRouter.of(context).pop();
  }

  void handleToggleTorch() {
    if (_complete) return;
    _controller.toggleTorch();

    setState(() {
      _torchState = _controller.torchEnabled ? TorchState.on : TorchState.off;
    });
  }

  void handleDetection(BarcodeCapture capture) async {
    if (_complete) return;

    if (capture.barcodes.isEmpty) {
      return;
    }

    HapticFeedback.heavyImpact();

    setState(() {
      _complete = true;
    });

    final navigator = GoRouter.of(context);

    if (widget.confirm) {
      await delay(const Duration(milliseconds: 1000));

      _textController.text = '${capture.barcodes[0].rawValue}';

      setState(() {
        _isTextEmpty = _textController.value.text.isEmpty;
        _complete = false;
      });

      return;
    }

    navigator.pop('${capture.barcodes[0].rawValue}');
  }

  void handleChanged() {
    setState(() {
      _isTextEmpty = _textController.value.text.isEmpty;
    });
  }

  void handleSubmit(BuildContext context) async {
    final navigator = GoRouter.of(context);

    if (_textController.value.text.isNotEmpty) {
      navigator.pop(_textController.value.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final size = (height > width ? width : height) - 40;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CupertinoPageScaffold(
        backgroundColor: primaryColor,
        resizeToAvoidBottomInset: false,
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      height: height,
                      width: width,
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(180),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _opacity,
                          duration: const Duration(milliseconds: 1000),
                          child: MobileScanner(
                            controller: _controller,
                            fit: BoxFit.cover,
                            // placeholderBuilder: (context, _) {
                            //   return Container(
                            //     height: height,
                            //     width: width,
                            //     decoration: BoxDecoration(
                            //       color: Theme.of(context)
                            //           .colors
                            //           .uiBackground
                            //           .resolveFrom(context),
                            //       borderRadius: BorderRadius.circular(10),
                            //     ),
                            //     child: Center(
                            //       child: CupertinoActivityIndicator(
                            //         color: Theme.of(context)
                            //             .colors
                            //             .subtle
                            //             .resolveFrom(context),
                            //       ),
                            //     ),
                            //   );
                            // },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: size,
                    width: size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 2,
                        color: whiteColor,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Flex(
                      direction: Axis.vertical,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                              child: Center(
                                child: CupertinoButton(
                                  padding: const EdgeInsets.all(5),
                                  onPressed: () => handleDismiss(context),
                                  child: Icon(
                                    CupertinoIcons.xmark,
                                    color: iconColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (_hasTorch)
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  margin:
                                      const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                  child: Center(
                                    child: CupertinoButton(
                                      padding: const EdgeInsets.all(5),
                                      onPressed: handleToggleTorch,
                                      child: Icon(
                                        _torchState == TorchState.off
                                            ? CupertinoIcons.lightbulb
                                            : CupertinoIcons.lightbulb_fill,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  if (widget.confirm)
                    Positioned(
                      bottom: bottomInset <= 100 ? 100 : bottomInset,
                      child: Container(
                        height: 50,
                        width: width - 40,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Center(
                          child: CupertinoTextField(
                            controller: _textController,
                            placeholder: 'Manual Entry',
                            maxLines: 1,
                            autofocus: false,
                            autocorrect: false,
                            enableSuggestions: false,
                            textInputAction: TextInputAction.done,
                            decoration: BoxDecoration(
                              color: const CupertinoDynamicColor.withBrightness(
                                color: CupertinoColors.white,
                                darkColor: CupertinoColors.black,
                              ),
                              border: Border.all(
                                color: transparentColor,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            onChanged: (_) {
                              handleChanged();
                            },
                            onSubmitted: (_) {
                              handleSubmit(context);
                            },
                            suffix: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color:
                                    _isTextEmpty ? neutralColor : primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // margin:
                              //     const EdgeInsets.fromLTRB(20, 20, 20, 20),
                              child: Center(
                                child: CupertinoButton(
                                  padding: const EdgeInsets.all(5),
                                  onPressed: _isTextEmpty
                                      ? null
                                      : () => handleSubmit(context),
                                  child: Icon(
                                    CupertinoIcons.arrow_right,
                                    color: _isTextEmpty
                                        ? textMutedColor
                                        : iconColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_complete)
                    Container(
                      decoration: BoxDecoration(
                        color: blackColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.check_mark,
                          color: whiteColor,
                          size: 50,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
