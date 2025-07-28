import 'dart:async';

import 'package:pay_app/screens/home/scanner_modal/footer.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/state/cards.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/state/sending.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pay_app/utils/qr.dart';
import 'package:pay_app/widgets/button.dart';
import 'package:pay_app/widgets/cards/card.dart';
import 'package:pay_app/widgets/profile_card.dart';
import 'package:pay_app/widgets/toast/toast.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class CardInfo {
  final String uid;
  final ProfileV1 profile;
  final String balance;
  final String project;

  CardInfo({
    required this.uid,
    required this.profile,
    required this.balance,
    required this.project,
  });
}

class ScannerModal extends StatefulWidget {
  final String? modalKey;
  final bool confirm;
  final String? tokenAddress;
  // final Color primaryColor;
  // final BuildContext parentContext;

  const ScannerModal({
    super.key,
    this.modalKey,
    this.confirm = false,
    this.tokenAddress,
    // required this.primaryColor,
    // required this.parentContext,
  });

  @override
  ScannerModalState createState() => ScannerModalState();
}

class ScannerModalState extends State<ScannerModal>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final MobileScannerController _controller = MobileScannerController(
    autoStart: true,
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
    formats: <BarcodeFormat>[BarcodeFormat.qrCode],
  );

  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _messageFocusNode = FocusNode();

  late SendingState _sendingState;
  late CardsState _cardsState;

  double _opacity = 0;

  StreamSubscription<Object?>? _subscription;

  bool _showCards = false;
  bool _showControls = false;
  int _selectedCardIndex = 0;

  @override
  void initState() {
    _controller.stop();

    super.initState();

    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // make initial requests here
      _sendingState = context.read<SendingState>();
      _cardsState = context.read<CardsState>();

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
    await delay(const Duration(milliseconds: 100));

    setState(() {
      _showCards = true;
    });

    await delay(const Duration(milliseconds: 400));

    _controller.barcodes.listen(handleDetection);

    unawaited(_controller.start());

    await delay(const Duration(milliseconds: 100));

    showScanner();

    await _cardsState.fetchCards(tokenAddress: widget.tokenAddress);
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

  void showScanner() {
    setState(() {
      _opacity = 1;
    });
  }

  void hideScanner() {
    setState(() {
      _opacity = 0;
    });
  }

  void handleDismiss(BuildContext context) {
    GoRouter.of(context).pop();
  }

  void handleDetection(BarcodeCapture capture) async {
    if (capture.barcodes.isEmpty) {
      return;
    }

    final rawValue = capture.barcodes[0].rawValue;
    if (rawValue == null) {
      return;
    }

    print('capture: ${capture.barcodes[0].rawValue}');

    final qrData = _sendingState.parseQRData(rawValue);
    if (qrData == null) {
      return;
    }

    HapticFeedback.heavyImpact();

    switch (qrData.format) {
      case QRFormat.checkoutUrl:
        final checkoutUrl = Uri.parse(qrData.rawValue);
        final orderId = checkoutUrl.queryParameters['orderId'];
        if (orderId != null) {
          _sendingState.loadExternalOrder(qrData.address, orderId);
        }

        await _sendingState.getPlaceWithMenu(qrData.address);
        break;
      case QRFormat.cardUrl:
        _sendingState.getCardProject(qrData.rawValue);
        break;
      case QRFormat.sendtoUrl:
      case QRFormat.sendtoUrlWithEIP681:
      case QRFormat.accountUrl:
        qrData.address.startsWith('0x')
            ? await _sendingState.getContactProfileFromAddress(qrData.address)
            : await _sendingState.getContactProfileFromUsername(qrData.address);
        break;
      case QRFormat.voucher:
        // TODO: vouchers need to be handled by the voucher screen
        break;
      case QRFormat.url:
        // TODO: urls need to be handled by the webview
        break;
      default:
        await _sendingState.getContactProfileFromAddress(qrData.address);
        break;
    }

    // final navigator = GoRouter.of(context);

    // if (widget.confirm) {
    //   await delay(const Duration(milliseconds: 1000));

    //   _textController.text = '${capture.barcodes[0].rawValue}';

    //   setState(() {
    //     _isTextEmpty = _textController.value.text.isEmpty;
    //     _complete = false;
    //   });

    //   return;
    // }

    // navigator.pop('${capture.barcodes[0].rawValue}');
  }

  void handleCardChanged(int index, CardInfo card) {
    HapticFeedback.heavyImpact();

    setState(() {
      _selectedCardIndex = index;
    });
  }

  void handleSubmit(BuildContext context) async {
    final navigator = GoRouter.of(context);

    if (_textController.value.text.isNotEmpty) {
      navigator.pop(_textController.value.text);
    }
  }

  void handlePay({bool showTransactionInput = true}) async {
    hideScanner();

    HapticFeedback.lightImpact();

    _sendingState.setShowTransactionInput(true);

    await delay(const Duration(milliseconds: 100));

    _amountFocusNode.requestFocus();
  }

  void handleConfirmOrder(String tokenAddress) async {
    hideScanner();

    HapticFeedback.lightImpact();

    await delay(const Duration(milliseconds: 100));

    _amountFocusNode.requestFocus();

    handleSend(tokenAddress, null, null);
  }

  void handleClearData() {
    _sendingState.clearParsedData();

    showScanner();
  }

  void handleAmountChange(String amount) {
    _sendingState.setAmount(double.parse(amount));
  }

  void handleSend(String tokenAddress, String? amount, String? message) async {
    final success = await _sendingState.sendTransaction(
      tokenAddress,
      amount: amount,
      message: message,
    );

    if (!mounted) {
      return;
    }

    HapticFeedback.heavyImpact();

    if (!success) {
      toastification.showCustom(
        context: context,
        autoCloseDuration: const Duration(seconds: 5),
        alignment: Alignment.bottomCenter,
        builder: (context, toast) => Toast(
          icon: const Text('❌'),
          title: const Text('Transaction failed'),
        ),
      );
      return;
    }

    handleDismiss(context);
  }

  void handleTopUp(String tokenAddress) {}

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final size = (height > width ? width : height) - 40;

    final safeBottomPadding = MediaQuery.of(context).padding.bottom;
    final safeTopPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final tokenConfig = context.select<WalletState, TokenConfig?>(
      (state) => state.currentTokenConfig,
    );

    final qrData = context.watch<SendingState>().qrData;

    final profile = context.watch<SendingState>().profile;
    final place = context.watch<SendingState>().place;
    final order = context.watch<SendingState>().order;

    final primaryColor = context.select<WalletState, Color>(
      (state) => state.tokenPrimaryColor,
    );

    final showTransactionInput = context
        .select<SendingState, bool>((state) => state.showTransactionInput);

    final transactionSending =
        context.select<SendingState, bool>((state) => state.transactionSending);

    final amount =
        context.select<SendingState, double>((state) => state.amount);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CupertinoPageScaffold(
        backgroundColor: blackColor,
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
                        color: blackColor.withAlpha(180),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _opacity,
                          duration: const Duration(milliseconds: 300),
                          child: MobileScanner(
                            key: Key('mobile-scanner'),
                            controller: _controller,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: safeTopPadding + 20,
                    child: AnimatedScale(
                      scale: qrData != null ? 0.7 : 1,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: AnimatedOpacity(
                        opacity: !_showCards || qrData != null ? 0 : 1,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: Container(
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
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    bottom: qrData != null ? 0 : height * 0.5,
                    child: AnimatedScale(
                      scale: qrData != null ? 1 : 0.5,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.decelerate,
                      onEnd: () {
                        setState(() {
                          _showControls = qrData != null;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (place != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: width * 0.8,
                                  ),
                                  child: ProfileCard(
                                    profile: place.profile,
                                    type: ProfileCardType.place,
                                    tokenLogo: tokenConfig?.logo,
                                    order: order,
                                    loading: transactionSending,
                                    onClose: handleClearData,
                                  ),
                                ),
                              ],
                            ),
                          if (profile != null && place == null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: width * 0.8,
                                  ),
                                  child: ProfileCard(
                                    profile: profile,
                                    type: ProfileCardType.user,
                                    loading: transactionSending,
                                    onClose: handleClearData,
                                  ),
                                ),
                              ],
                            ),
                          if ((place != null || profile != null) &&
                              !showTransactionInput &&
                              tokenConfig != null)
                            AnimatedOpacity(
                              opacity: _showControls ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Button(
                                  text:
                                      '${order == null ? 'Pay' : 'Confirm Order'}${transactionSending ? '...' : ''}',
                                  color: primaryColor,
                                  labelColor: whiteColor,
                                  onPressed: transactionSending
                                      ? null
                                      : order == null
                                          ? handlePay
                                          : () => handleConfirmOrder(
                                                tokenConfig.address,
                                              ),
                                ),
                              ),
                            ),
                          SizedBox(height: safeBottomPadding),
                          if (showTransactionInput)
                            Footer(
                              onSend: handleSend,
                              onTopUpPressed: handleTopUp,
                              amountFocusNode: _amountFocusNode,
                              messageFocusNode: _messageFocusNode,
                              onAmountChange: handleAmountChange,
                              amount: amount,
                              loading: transactionSending,
                            ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.decelerate,
                    top: !_showCards || qrData != null
                        ? safeTopPadding + 20
                        : (height * 0.55),
                    child: AnimatedScale(
                      scale: _showCards ? 1 : 0.8,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.decelerate,
                      child: Container(
                        height: 240,
                        width: width,
                        decoration:
                            BoxDecoration(color: whiteColor.withAlpha(0)),
                        child: CustomScrollView(
                          controller: _scrollController,
                          scrollBehavior: const CupertinoScrollBehavior(),
                          physics: const NeverScrollableScrollPhysics(),
                          slivers: _buildCards(
                            context,
                            qrData != null,
                            primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (qrData == null)
                    Positioned(
                      bottom: safeBottomPadding,
                      child: Row(
                        children: [
                          Button(
                            text: 'Close',
                            color: blackColor,
                            labelColor: whiteColor,
                            onPressed: () => handleDismiss(context),
                          ),
                        ],
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

  List<Widget> _buildCards(
    BuildContext context,
    bool payReady,
    Color primaryColor,
  ) {
    final width = MediaQuery.of(context).size.width;

    final accountBalance = context.select<WalletState, String>(
      (state) => state.tokenBalances[state.currentTokenAddress] ?? '0.0',
    );

    final tokenConfig = context.select<WalletState, TokenConfig?>(
      (state) => state.currentTokenConfig,
    );

    final accountProfile = context.watch<ProfileState>().profile;

    final cards = context.watch<CardsState>().cards;
    final cardBalances = context.watch<CardsState>().cardBalances;
    final profiles = context.watch<CardsState>().profiles;

    final List<CardInfo> cardInfoList = [
      CardInfo(
        uid: 'main',
        profile: accountProfile,
        balance: accountBalance,
        project: 'main',
      ),
      ...cards.map(
        (card) => CardInfo(
          uid: card.uid,
          profile: profiles[card.account]!,
          balance: cardBalances[card.account] ?? '0.0',
          project: card.project,
        ),
      ),
    ];

    return [
      SliverFillRemaining(
        child: PageView.builder(
          physics: payReady
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          controller: PageController(
            viewportFraction: 0.85,
            initialPage: 0,
          ),
          onPageChanged: (index) {
            handleCardChanged(index, cardInfoList[index]);
          },
          itemCount: cardInfoList.length,
          itemBuilder: (context, index) {
            final card = cardInfoList[index];

            final isSelected = _selectedCardIndex == index;

            if (payReady && !isSelected) {
              return const SizedBox.shrink();
            }

            return Container(
              key: Key(card.uid),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Center(
                child: AnimatedScale(
                  scale: isSelected ? 1.1 : 1,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Card(
                    width: width * 0.80,
                    uid: card.uid,
                    color: primaryColor,
                    profile: card.profile,
                    logo: tokenConfig?.logo,
                    balance: card.balance,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
}
