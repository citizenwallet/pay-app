import 'dart:async';

import 'package:collection/collection.dart';
import 'package:pay_app/models/checkout.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/place.dart';
import 'package:pay_app/models/place_with_menu.dart';
import 'package:pay_app/screens/home/card_modal/card_modal.dart';
import 'package:pay_app/screens/home/scanner_modal/footer.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/db/app/cards.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/state/cards.dart';
import 'package:pay_app/state/sending.dart';
import 'package:pay_app/state/state.dart';
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
import 'package:pay_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:web3dart/web3dart.dart';

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
  final String tokenAddress;
  final String? manualScanResult;

  const ScannerModal({
    super.key,
    this.modalKey,
    this.confirm = false,
    required this.tokenAddress,
    this.manualScanResult,
  });

  @override
  ScannerModalState createState() => ScannerModalState();
}

class ScannerModalState extends State<ScannerModal>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final MobileScannerController _controller = MobileScannerController(
    autoStart: false,
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

  final PageController _pageController = PageController(
    viewportFraction: 0.85,
    initialPage: 0,
  );

  StreamSubscription<Object?>? _subscription;

  bool _manualScan = false;
  bool _showCards = false;
  bool _showControls = false;

  bool _isDismissing = false;

  @override
  void initState() {
    _controller.stop();

    super.initState();

    _manualScan = widget.manualScanResult != null;

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
        return;
      case AppLifecycleState.inactive:
        handleDismiss(context);
    }
  }

  void onLoad() async {
    _sendingState.getAccountProfile();
    _cardsState.fetchCards(tokenAddress: widget.tokenAddress);

    await delay(const Duration(milliseconds: 100));

    setState(() {
      _showCards = true;
    });

    await delay(const Duration(milliseconds: 200));

    unawaited(_subscription?.cancel());
    _subscription = _controller.barcodes.listen(handleDetection);

    if (!_controller.value.isRunning) {
      await _controller.start();
    }

    await delay(const Duration(milliseconds: 100));

    if (widget.manualScanResult == null) {
      showScanner();
    }

    if (widget.manualScanResult != null) {
      await handleScanData(widget.manualScanResult!);

      setState(() {
        _manualScan = false;
      });
    }
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

  void handleDismiss(BuildContext context, {bool reverse = false}) async {
    _isDismissing = true;

    final lastAccount = context.read<SendingState>().lastAccount;

    if (reverse) {
      hideScanner();

      await delay(const Duration(milliseconds: 100));

      setState(() {
        _showCards = false;
      });

      await delay(const Duration(milliseconds: 600));
    }

    if (!context.mounted) {
      return;
    }

    GoRouter.of(context).pop(lastAccount);
  }

  void handleDetection(BarcodeCapture capture) async {
    if (capture.barcodes.isEmpty) {
      return;
    }

    final rawValue = capture.barcodes[0].rawValue;
    if (rawValue == null) {
      return;
    }

    handleScanData(rawValue);
  }

  Future<void> handleScanData(String rawValue) async {
    final qrData = _sendingState.parseQRData(rawValue);
    if (qrData == null) {
      return;
    }

    HapticFeedback.heavyImpact();

    switch (qrData.format) {
      case QRFormat.checkoutUrl:
        final checkoutUrl = Uri.parse(qrData.rawValue);
        final orderId = checkoutUrl.queryParameters['orderId'];
        Order? order;
        if (orderId != null) {
          order =
              await _sendingState.loadExternalOrder(qrData.address, orderId);
        }

        final place = await _sendingState.getPlaceWithMenu(qrData.address);

        await delay(const Duration(milliseconds: 500));

        if (!mounted) {
          return;
        }

        if (order != null) {
          break;
        }

        if (place != null &&
            (place.place.display == Display.menu ||
                place.place.display == Display.amountAndMenu) &&
            place.items.isNotEmpty) {
          final initialAddress = context.read<SendingState>().initialAddress;

          final cards = context.read<CardsState>().cards;

          final lastAccount = context.read<SendingState>().lastAccount;

          final currentCardSerial = cards
              .firstWhereOrNull((card) => card.account == lastAccount)
              ?.uid;

          handleViewMenu(
            widget.tokenAddress,
            initialAddress,
            place,
            serial: currentCardSerial,
          );
        }

        if (place != null && (place.place.display == Display.amount)) {
          handlePay();
        }

        break;
      case QRFormat.cardUrl:
        final project = _sendingState.getCardProject(qrData.rawValue);
        final profile =
            await _sendingState.getContactProfileFromSerial(qrData.address);

        await delay(const Duration(milliseconds: 500));

        if (!mounted) {
          return;
        }

        final config = context.read<WalletState>().config;
        final appAccount = context.read<SendingState>().appAccount;

        handleInspectCard(
          config,
          qrData.address,
          profile?.account ?? '',
          appAccount,
          project ?? 'main',
        );
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
  }

  void handleCardChanged(CardInfo card) {
    if (_isDismissing) {
      return;
    }

    HapticFeedback.heavyImpact();

    _sendingState.setLastAccount(card.profile.account);
  }

  void handlePay({bool showTransactionInput = true}) async {
    hideScanner();

    HapticFeedback.lightImpact();

    _sendingState.setShowTransactionInput(true);

    await delay(const Duration(milliseconds: 100));

    _amountFocusNode.requestFocus();
  }

  void handleConfirmOrder(
    String tokenAddress, {
    Checkout? checkout,
    String? serial,
  }) async {
    hideScanner();

    HapticFeedback.lightImpact();

    await delay(const Duration(milliseconds: 100));

    handleSend(tokenAddress, null, null, checkout: checkout, serial: serial);
  }

  void handleClearData() {
    _sendingState.clearParsedData();

    showScanner();
  }

  void handleAmountChange(String amount) {
    _sendingState.setAmount(double.parse(amount));
  }

  void handleSend(
    String tokenAddress,
    String? amount,
    String? message, {
    Checkout? checkout,
    String? serial,
  }) async {
    final success = await _sendingState.sendTransaction(
      tokenAddress,
      amount: amount,
      message: message,
      manualCheckout: checkout,
      serial: serial,
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
          title: Text(AppLocalizations.of(context)!.transactionFailed),
        ),
      );
      return;
    }

    handleDismiss(context);
  }

  void handleInspectCard(
    Config config,
    String serial,
    String cardAddress,
    EthereumAddress appAccount,
    String project,
  ) async {
    hideScanner();

    HapticFeedback.heavyImpact();

    await showCupertinoModalPopup(
      useRootNavigator: false,
      context: context,
      builder: (modalContext) {
        return provideCardState(
          context,
          config,
          serial,
          cardAddress,
          appAccount.hexEip55,
          CardModal(uid: serial, project: project),
        );
      },
    );

    _cardsState.fetchCards(tokenAddress: widget.tokenAddress);

    handleClearData();
  }

  void handleViewMenu(
    String tokenAddress,
    String account,
    PlaceWithMenu place, {
    String? serial,
  }) async {
    hideScanner();

    final navigator = GoRouter.of(context);

    final checkout = await navigator
        .push<Checkout?>('/$account/place/${place.place.slug}/menu');

    if (checkout == null) {
      showScanner();
      return;
    }

    handleConfirmOrder(tokenAddress, checkout: checkout, serial: serial);
  }

  void handleTopUp(String tokenAddress) {
    // TODO: implement top up
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final size = (height > width ? width : height) - 40;

    final safeBottomPadding = MediaQuery.of(context).padding.bottom;
    final safeTopPadding = MediaQuery.of(context).padding.top;

    final config = context.select<WalletState, Config>((state) => state.config);
    final tokenConfig = context.select<AppState, TokenConfig?>(
      (state) => state.currentTokenConfig,
    );

    final appAccount = context.select<SendingState, EthereumAddress>(
      (state) => state.appAccount,
    );

    final qrData = context.watch<SendingState>().qrData;
    final isCard = qrData?.format == QRFormat.cardUrl;

    final profile = context.watch<SendingState>().profile;
    final place = context.watch<SendingState>().place;
    final placeDisplay = place?.place.display;
    final order = context.watch<SendingState>().order;
    final cardProject = context.select<SendingState, String?>(
      (state) => state.cardProject,
    );

    final emptyScan = qrData != null &&
        profile == null &&
        place == null &&
        order == null &&
        cardProject == null;

    final primaryColor = context.select<AppState, Color>(
      (state) => state.tokenPrimaryColor,
    );

    final showTransactionInput = context
        .select<SendingState, bool>((state) => state.showTransactionInput);

    final transactionSending =
        context.select<SendingState, bool>((state) => state.transactionSending);

    final amount =
        context.select<SendingState, double>((state) => state.amount);

    final cards = context.watch<CardsState>().cards;

    final initialAddress = context.select<SendingState, String>(
      (state) => state.initialAddress,
    );

    final lastAccount = context.select<SendingState, String?>(
      (state) => state.lastAccount,
    );

    final currentCardSerial =
        cards.firstWhereOrNull((card) => card.account == lastAccount)?.uid;

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
                      scale: qrData != null || _manualScan ? 0.7 : 1,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: AnimatedOpacity(
                        opacity: !_showCards || qrData != null || _manualScan
                            ? 0
                            : 1,
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
                    bottom: (qrData != null || _manualScan) ? 0 : height * 0.5,
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
                          if (emptyScan && _showControls)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: width * 0.8,
                                  ),
                                  child: ProfileCard(
                                    profile: ProfileV1(
                                      username: qrData.address,
                                      account: '',
                                      name: AppLocalizations.of(context)!
                                          .noResultsFound,
                                      image: 'assets/icons/profile.png',
                                      imageMedium: 'assets/icons/profile.png',
                                      imageSmall: 'assets/icons/profile.png',
                                    ),
                                    type: ProfileCardType.user,
                                    onClose: handleClearData,
                                  ),
                                ),
                              ],
                            ),
                          if (!emptyScan &&
                              (place != null || profile != null) &&
                              (placeDisplay == Display.menu ||
                                  placeDisplay == Display.amountAndMenu) &&
                              !showTransactionInput &&
                              tokenConfig != null &&
                              !isCard &&
                              order == null)
                            AnimatedOpacity(
                              opacity: _showControls ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Button(
                                  text: AppLocalizations.of(context)!.viewMenu,
                                  color: blackColor,
                                  labelColor: whiteColor,
                                  onPressed: place == null || transactionSending
                                      ? null
                                      : () => handleViewMenu(
                                            widget.tokenAddress,
                                            lastAccount!,
                                            place,
                                            serial: currentCardSerial,
                                          ),
                                ),
                              ),
                            ),
                          if (!emptyScan &&
                              (order != null ||
                                  (place != null &&
                                      (placeDisplay == Display.amount ||
                                          placeDisplay ==
                                              Display.amountAndMenu)) ||
                                  (profile != null &&
                                      currentCardSerial == null)) &&
                              !showTransactionInput &&
                              tokenConfig != null &&
                              !isCard)
                            AnimatedOpacity(
                              opacity: _showControls ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Button(
                                  text:
                                      '${order == null ? AppLocalizations.of(context)!.pay : AppLocalizations.of(context)!.confirmOrder}${transactionSending ? '...' : ''}',
                                  color: primaryColor,
                                  labelColor: whiteColor,
                                  onPressed: transactionSending
                                      ? null
                                      : order == null
                                          ? handlePay
                                          : () => handleConfirmOrder(
                                                tokenConfig.address,
                                                serial: currentCardSerial,
                                              ),
                                ),
                              ),
                            ),
                          if (emptyScan &&
                              profile != null &&
                              !showTransactionInput &&
                              tokenConfig != null &&
                              isCard)
                            AnimatedOpacity(
                              opacity: _showControls ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Button(
                                  text:
                                      AppLocalizations.of(context)!.inspectCard,
                                  color: primaryColor,
                                  labelColor: whiteColor,
                                  onPressed: qrData.address.isNotEmpty
                                      ? () => handleInspectCard(
                                            config,
                                            qrData.address,
                                            profile.account,
                                            appAccount,
                                            cardProject ?? 'main',
                                          )
                                      : null,
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
                    top: !_showCards || qrData != null || _manualScan
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
                            qrData != null || _manualScan,
                            primaryColor,
                            cards,
                            initialAddress,
                            lastAccount,
                            _pageController,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (qrData == null && !_manualScan)
                    Positioned(
                      bottom: safeBottomPadding,
                      child: Row(
                        children: [
                          Button(
                            text: AppLocalizations.of(context)!.close,
                            color: blackColor,
                            labelColor: whiteColor,
                            onPressed: () =>
                                handleDismiss(context, reverse: true),
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
    List<DBCard> cards,
    String? initialAccount,
    String? lastAccount,
    PageController controller,
  ) {
    final width = MediaQuery.of(context).size.width;

    final tokenConfig = context.select<AppState, TokenConfig>(
      (state) => state.currentTokenConfig,
    );

    final accountBalance = context.select<WalletState, String>(
      (state) => state.tokenBalances[tokenConfig.address] ?? '0.0',
    );

    final accountProfile = context.watch<SendingState>().accountProfile;

    final cardBalances = context.watch<CardsState>().cardBalances;
    final profiles = context.watch<CardsState>().profiles;

    final List<CardInfo> cardInfoList = [
      if (accountProfile != null)
        CardInfo(
          uid: 'main',
          profile: accountProfile,
          balance: accountBalance,
          project: 'main',
        ),
      ...cards.where((card) => profiles[card.account] != null).map(
            (card) => CardInfo(
              uid: card.uid,
              profile: profiles[card.account]!,
              balance: cardBalances[card.account] ?? '0.0',
              project: card.project,
            ),
          ),
    ];
    if (initialAccount != null) {
      // Sort cards by initial card first
      cardInfoList.sort((a, b) {
        if (a.profile.account == initialAccount) return -1;
        if (b.profile.account == initialAccount) return 1;
        return a.profile.account.compareTo(b.profile.account);
      });
    }

    return [
      SliverFillRemaining(
        child: PageView.builder(
          physics: payReady
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          controller: controller,
          onPageChanged: (index) {
            handleCardChanged(cardInfoList[index]);
          },
          itemCount: cardInfoList.length,
          itemBuilder: (context, index) {
            final card = cardInfoList[index];

            final isSelected = card.profile.account == lastAccount;

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
