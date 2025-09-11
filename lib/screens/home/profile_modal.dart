import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/screens/home/card_modal/card_modal.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/db/app/cards.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/state/cards.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/state/state.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/card_colors.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:pay_app/widgets/button.dart';
import 'package:pay_app/widgets/cards/card.dart';
import 'package:pay_app/widgets/cards/card_skeleton.dart';
import 'package:pay_app/widgets/modals/dismissible_modal_popup.dart';
import 'package:pay_app/widgets/modals/nfc_modal.dart';
import 'package:pay_app/widgets/toast/toast.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:web3dart/web3dart.dart';

class ProfileModal extends StatefulWidget {
  final String accountAddress;
  final String? tokenAddress;

  const ProfileModal({
    super.key,
    required this.accountAddress,
    this.tokenAddress,
  });

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  final ScrollController _controller = ScrollController();

  bool _displayAccountCard = false;
  Timer? _displayCardsTimer;
  bool _displayCards = false;

  late CardsState _cardsState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardsState = context.read<CardsState>();

      onLoad();
    });
  }

  @override
  void dispose() {
    _displayCardsTimer?.cancel();
    super.dispose();
  }

  Future<void> onLoad() async {
    await delay(const Duration(milliseconds: 100));

    setState(() {
      _displayAccountCard = true;
    });

    _displayCardsTimer = Timer(const Duration(milliseconds: 200), () {
      setState(() {
        _displayCards = true;
      });
    });

    await _cardsState.fetchCards(tokenAddress: widget.tokenAddress);
  }

  void handleScrollToTop() {
    _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> handleEditProfile() async {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();

    navigator.push('/${widget.accountAddress}/my-account/edit');
  }

  void handleAppSettings() {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();

    navigator.push('/${widget.accountAddress}/my-account/settings');
  }

  void handleClose(BuildContext context) {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();
    navigator.pop();
  }

  Future<void> handleCardSelect(
    String? myAddress,
    String? cardId,
    String? project,
    String? tokenAddress,
  ) async {
    if (myAddress == null) {
      return;
    }

    final config = context.read<WalletState>().config;

    final cardAddress = cardId != null
        ? await config.cardManagerContract!.getCardAddress(
            cardId,
          )
        : EthereumAddress.fromHex(myAddress);

    if (!mounted) {
      return;
    }

    HapticFeedback.heavyImpact();

    await showCupertinoModalPopup(
      useRootNavigator: false,
      context: context,
      builder: (modalContext) {
        return provideCardState(
          context,
          config,
          cardId ?? myAddress,
          cardAddress.hexEip55,
          myAddress,
          CardModal(
            uid: cardId,
            address: cardId == null ? myAddress : null,
            project: project,
            tokenAddress: tokenAddress,
          ),
        );
      },
    );
  }

  Future<void> handleAddCard(ProfileV1? profile) async {
    HapticFeedback.heavyImpact();

    final result = await showCupertinoModalPopup<(String, String?)?>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const NFCModal(
        modalKey: 'modal-nfc-scanner',
      ),
    );

    if (result == null) {
      return;
    }

    final (uid, uri) = result;

    final error = await _cardsState.claim(uid, uri, profile?.name);

    if (error == null) {
      if (!mounted) {
        return;
      }

      toastification.showCustom(
        context: context,
        autoCloseDuration: const Duration(seconds: 5),
        alignment: Alignment.bottomCenter,
        builder: (context, toast) => Toast(
          icon: const Text('✅'),
          title: const Text('Card added'),
        ),
      );

      return;
    }

    await handleAddCardError(error);
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
          title: const Text('Card already added'),
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
          title: Text('Card not configured'),
          content: Text(
              'This card is not configured. Would you like to configure it?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Configure'),
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
          title: const Text('Card configured'),
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
          title: const Text('NFC is not available on this device'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final cards = context.watch<CardsState>().cards;
    final cardBalances = context.watch<CardsState>().cardBalances;

    final profile = context.select((ProfileState p) => p.profile);
    final alias = context.select((ProfileState p) => p.alias);

    return DismissibleModalPopup(
      modalKey: 'profile_modal',
      backgroundColor: blackColor,
      maxHeight: height,
      paddingSides: 16,
      paddingTopBottom: 0,
      topRadius: 12,
      onDismissed: (dir) {
        handleClose(context);
      },
      child: _buildContent(context, cards, cardBalances, profile, alias),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<DBCard> cards,
    Map<String, String> cardBalances,
    ProfileV1 profile,
    String alias,
  ) {
    final width = MediaQuery.of(context).size.width;
    final safeArea = MediaQuery.of(context).padding;
    const headerHeight = 276.9;

    final balance = context.watch<WalletState>().tokenBalances[
            widget.tokenAddress ??
                context.read<WalletState>().currentTokenAddress] ??
        '0.0';

    final tokenConfig = context.select<WalletState, TokenConfig?>(
      (state) => state.currentTokenConfig,
    );

    final primaryColor = context.select<WalletState, Color>(
      (state) => state.tokenPrimaryColor,
    );

    return SafeArea(
      top: false,
      bottom: false,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          AnimatedOpacity(
            opacity: _displayCards ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    controller: _controller,
                    scrollBehavior: const CupertinoScrollBehavior(),
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: _displayCards
                              ? headerHeight + safeArea.top
                              : 70 + safeArea.top,
                        ),
                      ),
                      ..._buildCardsList(
                        context,
                        cards,
                        cardBalances,
                        tokenConfig,
                        primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 70 + safeArea.top,
            child: AnimatedOpacity(
              opacity: _displayAccountCard ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildAccountCard(
                ValueKey('account_card'),
                width,
                profile,
                alias,
                balance,
                tokenConfig,
                primaryColor,
              ),
            ),
          ),
          Positioned(
            top: 10 + safeArea.top,
            right: 0,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              color: blackColor,
              borderRadius: BorderRadius.circular(16),
              onPressed: () => handleClose(context),
              child: Icon(
                CupertinoIcons.xmark,
                color: whiteColor,
              ),
            ),
          ),
          Positioned(
            bottom: safeArea.bottom,
            child: _buildActionButtons(
              context,
              profile,
              alias,
              primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
    Key? key,
    double width,
    ProfileV1 profile,
    String alias,
    String balance,
    TokenConfig? tokenConfig,
    Color primaryColor,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              width: width * 0.8,
              uid: profile.account,
              color: primaryColor,
              profile: profile,
              icon: CupertinoIcons.device_phone_portrait,
              onCardPressed: (_) => handleCardSelect(
                profile.account,
                null,
                'main',
                widget.tokenAddress,
              ),
              logo: tokenConfig?.logo,
              balance: balance,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ProfileV1 profile,
    String alias,
    Color primaryColor,
  ) {
    final claimingCard = context.watch<CardsState>().claimingCard;
    return Column(
      children: [
        Button(
          onPressed: claimingCard ? null : () => handleAddCard(profile),
          text: 'Add Card',
          labelColor: whiteColor,
          color: primaryColor,
          suffix: claimingCard
              ? const CupertinoActivityIndicator()
              : Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Image.asset(
                    'assets/icons/nfc.png',
                    width: 20,
                    height: 20,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Button(
          onPressed: handleAppSettings,
          text: 'App Settings',
          labelColor: textColor,
          color: surfaceColor,
          prefix: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              CupertinoIcons.settings,
              color: textColor,
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  List<Widget> _buildCardsList(
    BuildContext context,
    List<DBCard> cards,
    Map<String, String> cardBalances,
    TokenConfig? tokenConfig,
    Color primaryColor,
  ) {
    final width = MediaQuery.of(context).size.width;

    final updatingCardNameUid = context.watch<CardsState>().updatingCardNameUid;

    final profiles = context.watch<CardsState>().profiles;

    return [
      if (cards.isNotEmpty)
        SliverToBoxAdapter(
          child: const SizedBox(height: 20),
        ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: cards.length,
          (context, index) {
            final card = cards[index];

            final cardColor = projectCardColor(card.project);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (updatingCardNameUid == card.uid)
                  CardSkeleton(
                    width: width * 0.75,
                    color: cardColor,
                  ),
                if (updatingCardNameUid != card.uid)
                  Card(
                    width: width * 0.75,
                    uid: card.uid,
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    profile: profiles[card.account],
                    onCardPressed: (uid) => handleCardSelect(
                      widget.accountAddress,
                      uid,
                      card.project,
                      widget.tokenAddress,
                    ),
                    logo: tokenConfig?.logo,
                    balance: cardBalances[card.account],
                  ),
              ],
            );
          },
        ),
      ),
      SliverToBoxAdapter(
        child: const SizedBox(height: 60),
      ),
    ];
  }
}
