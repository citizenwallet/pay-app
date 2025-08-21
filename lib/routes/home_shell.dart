import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/l10n/app_localizations.dart';
import 'package:pay_app/screens/home/profile_bar.dart';
import 'package:pay_app/screens/home/scanner_modal/scanner_modal.dart'
    as scanner;
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/state/cards.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/state/state.dart';
import 'package:pay_app/state/topup.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:pay_app/widgets/modals/nfc_modal.dart';
import 'package:pay_app/widgets/scan_qr_circle.dart';
import 'package:pay_app/widgets/toast/toast.dart';
import 'package:pay_app/widgets/webview/connected_webview_modal.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class HomeShell extends StatefulWidget {
  final Widget child;
  final GoRouterState state;
  final Config config;

  const HomeShell({
    super.key,
    required this.child,
    required this.state,
    required this.config,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late AppState _appState;
  late CardsState _cardsState;
  late TopupState _topupState;
  late ProfileState _profileState;
  late WalletState _walletState;

  String? _selectedAddress;

  bool _hideProfileBar = false;
  bool _pauseDeepLinkHandling = false;

  String? _deepLink;

  PageController? _pageController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appState = context.read<AppState>();
      _cardsState = context.read<CardsState>();
      _topupState = context.read<TopupState>();
      _profileState = context.read<ProfileState>();
      _walletState = context.read<WalletState>();

      setState(() {
        _pageController = PageController(
          viewportFraction: 0.85,
          initialPage: 0,
          onAttach: (ScrollPosition position) {
            onAttach();
          },
        );
      });
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void onAttach() async {
    await delay(const Duration(milliseconds: 500));

    final lastAccount = _appState.lastAccount;

    if (lastAccount != null && mounted) {
      // switch to page of last account
      final cards = context.read<CardsState>().cards;
      final index = cards.indexWhere(
        (card) => card.account == lastAccount,
      );

      _pageController?.animateToPage(
        index == -1 ? 0 : index + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.decelerate,
      );
    }
  }

  void handleDismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void handleCardChanged(String account) {
    HapticFeedback.heavyImpact();

    setState(() {
      _selectedAddress = account;
    });

    _appState.setLastAccount(account);
    _profileState.setAccount(account);
    _walletState.switchAccount(account);

    final navigator = GoRouter.of(context);

    navigator.replace('/$account');
  }

  void handleTopUp(String baseUrl) async {
    await _topupState.generateTopupUrl(baseUrl);

    if (!mounted) {
      return;
    }

    HapticFeedback.heavyImpact();

    final redirectDomain = dotenv.env['APP_REDIRECT_DOMAIN'];

    final redirectUrl = redirectDomain != null ? 'https://$redirectDomain' : '';

    final result = await showCupertinoModalPopup<String?>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      barrierColor: blackColor.withAlpha(160),
      builder: (modalContext) {
        final topupUrl =
            modalContext.select((TopupState state) => state.topupUrl);

        if (topupUrl.isEmpty) {
          return const SizedBox.shrink();
        }

        return ConnectedWebViewModal(
          modalKey: 'connected-webview',
          url: topupUrl,
          redirectUrl: redirectUrl,
        );
      },
    );

    if (result == null) {
      return;
    }

    if (!result.startsWith(redirectUrl)) {
      return;
    }

    if (!mounted) {
      return;
    }

    HapticFeedback.heavyImpact();

    toastification.showCustom(
      context: context,
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.bottomCenter,
      builder: (context, toast) => Toast(
        icon: const Text('🚀'),
        title: Text(AppLocalizations.of(context)!.topupOnWay),
      ),
    );

    await _walletState.updateBalance();
  }

  Future<void> handleDeepLink(String accountAddress, String? deepLink) async {
    if (deepLink != null && !_pauseDeepLinkHandling) {
      _pauseDeepLinkHandling = true;

      await delay(const Duration(milliseconds: 100));

      if (!mounted) {
        return;
      }

      await handleQRScan(
        context,
        accountAddress,
        () {},
        manualResult: deepLink,
      );

      _pauseDeepLinkHandling = false;
    }
  }

  Future<void> handleQRScan(
    BuildContext context,
    String myAddress,
    Function() callback, {
    String? manualResult,
  }) async {
    final tokenAddress = context.read<AppState>().currentTokenAddress;

    final cards = context.read<CardsState>().cards;

    final index = cards.indexWhere(
      (card) => card.account == _selectedAddress,
    );

    final selectedAccount = await showCupertinoDialog<String?>(
      context: context,
      useRootNavigator: false,
      builder: (modalContext) => provideSendingState(
        context,
        widget.config,
        myAddress,
        scanner.ScannerModal(
          modalKey: 'home-qr-sending',
          tokenAddress: tokenAddress,
          manualScanResult: manualResult,
          initialIndex: index == -1 ? 0 : index + 1,
        ),
      ),
    );

    if (selectedAccount != null && context.mounted) {
      final cards = context.read<CardsState>().cards;

      final index = cards.indexWhere(
        (card) => card.account == selectedAccount,
      );

      _pageController?.jumpToPage(index == -1 ? 0 : index + 1);

      handleCardChanged(selectedAccount);

      final navigator = GoRouter.of(context);

      navigator.replace('/$selectedAccount');
    }

    callback();
  }

  Future<void> handleAddCard() async {
    HapticFeedback.heavyImpact();

    final result = await showCupertinoModalPopup<(String, String?)?>(
      context: context,
      barrierDismissible: true,
      barrierColor: blackColor.withAlpha(160),
      builder: (_) => const NFCModal(
        modalKey: 'modal-nfc-scanner',
      ),
    );

    if (result == null) {
      return;
    }

    final (uid, uri) = result;

    final (token, cardAddress, error) =
        await _cardsState.claim(uid, uri, 'card');

    if (error == null) {
      if (!mounted) {
        return;
      }

      if (token != null && cardAddress != null) {
        final navigator = GoRouter.of(context);
        navigator.replace('/$cardAddress?token=$token');

        handleCardChanged(cardAddress);
      }

      toastification.showCustom(
        context: context,
        autoCloseDuration: const Duration(seconds: 5),
        alignment: Alignment.bottomCenter,
        builder: (context, toast) => Toast(
          icon: const Text('✅'),
          title: Text(AppLocalizations.of(context)!.cardAdded),
        ),
      );

      return;
    }

    await handleAddCardError(error);

    if (token != null && cardAddress != null && mounted) {
      final navigator = GoRouter.of(context);
      navigator.replace('/$cardAddress?token=$token');
    }
    return;
  }

  Future<void> handleAddCardError(AddCardError error) async {
    if (error == AddCardError.cardAlreadyExists) {
      // show error
      if (!mounted) {
        return;
      }

      toastification.showCustom(
        context: context,
        autoCloseDuration: const Duration(seconds: 5),
        alignment: Alignment.bottomCenter,
        builder: (context, toast) => Toast(
          icon: const Text('✅'),
          title: Text(AppLocalizations.of(context)!.cardAlreadyAdded),
        ),
      );
    }

    if (error == AddCardError.cardNotConfigured) {
      // show error
      if (!mounted) {
        return;
      }

      // show a confirmation modal
      final confirmed = await showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => CupertinoAlertDialog(
          title: Text(AppLocalizations.of(context)!.cardNotConfigured),
          content: Text(
              'This card is not configured. Would you like to configure it?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.configure),
            ),
          ],
        ),
      );

      if (confirmed == null || !confirmed) {
        return;
      }

      await delay(const Duration(milliseconds: 500));

      if (!mounted) {
        return;
      }

      final writeResult = await showCupertinoModalPopup<(String, String?)?>(
        context: context,
        barrierDismissible: true,
        barrierColor: blackColor.withAlpha(160),
        builder: (_) => const NFCModal(
          modalKey: 'modal-nfc-scanner',
          write: true,
        ),
      );

      if (writeResult == null) {
        await handleAddCardError(AddCardError.unknownError);
        return;
      }

      final (uid, uri) = writeResult;

      if (uri == null) {
        await handleAddCardError(AddCardError.unknownError);
        return;
      }

      if (!mounted) {
        return;
      }

      toastification.showCustom(
        context: context,
        autoCloseDuration: const Duration(seconds: 5),
        alignment: Alignment.bottomCenter,
        builder: (context, toast) => Toast(
          icon: const Text('✅'),
          title: Text(AppLocalizations.of(context)!.cardConfigured),
        ),
      );

      return;
    }

    if (error == AddCardError.nfcNotAvailable) {
      // show error
      if (!mounted) {
        return;
      }

      toastification.showCustom(
        context: context,
        autoCloseDuration: const Duration(seconds: 5),
        alignment: Alignment.bottomCenter,
        builder: (context, toast) => Toast(
          icon: const Text('❌'),
          title: Text(AppLocalizations.of(context)!.nfcNotAvailable),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountAddress = widget.state.pathParameters['account']!;
    final deepLink = widget.state.uri.queryParameters['deepLink'];
    final parts = widget.state.uri.toString().split('/');

    final navigated = parts.length > 2;

    if (_deepLink != deepLink && deepLink != null) {
      handleDeepLink(accountAddress, deepLink);
    }
    _deepLink = deepLink;

    if (_hideProfileBar && !navigated) {
      setState(() {
        _hideProfileBar = navigated;
      });
    }

    final small = context.select<AppState, bool>((state) => state.small);

    return Stack(
      children: [
        widget.child,
        if (!_hideProfileBar && _pageController != null)
          AnimatedOpacity(
            opacity: navigated ? 0 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            onEnd: () {
              setState(() {
                _hideProfileBar = navigated;
              });
            },
            child: ProfileBar(
              selectedAddress: _selectedAddress,
              onCardChanged: handleCardChanged,
              pageController: _pageController!,
              small: small,
              config: widget.config,
              loading: false,
              accountAddress: accountAddress,
              backgroundColor: backgroundColor,
              onTopUpTap: handleTopUp,
              onAddCard: handleAddCard,
            ),
          ),
        if (!navigated)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: small ? -120 : 40,
            child: SizedBox(
              height: 120,
              width: 120,
              child: Center(
                child: ScanQrCircle(
                  handleQRScan: (callback) => handleQRScan(
                    context,
                    accountAddress,
                    callback,
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
