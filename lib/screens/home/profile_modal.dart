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
import 'package:pay_app/utils/currency.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:pay_app/utils/ratio.dart';
import 'package:pay_app/widgets/account_card.dart';
import 'package:pay_app/widgets/button.dart';
import 'package:pay_app/widgets/card.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/modals/dismissible_modal_popup.dart';
import 'package:pay_app/widgets/modals/nfc_modal.dart';
import 'package:pay_app/widgets/persistent_header_delegate.dart';
import 'package:pay_app/widgets/toast/toast.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class ProfileModal extends StatefulWidget {
  final String accountAddress;

  const ProfileModal({super.key, required this.accountAddress});

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  final ScrollController _controller = ScrollController();

  bool _atTop = true;
  bool _showFixedHeader = true;
  bool _showShrinkingHeader = false;

  late WalletState _walletState;
  late CardsState _cardsState;

  @override
  void initState() {
    super.initState();

    _walletState = context.read<WalletState>();
    _cardsState = context.read<CardsState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLoad();
    });
  }

  Future<void> onLoad() async {
    await delay(const Duration(milliseconds: 100));

    _walletState.loadTokenBalances();
    await _cardsState.fetchCards();
  }

  void handleScrollToTop() {
    _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void handleEditProfile() {
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

  void handleTokenSelect(String tokenKey) {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();
    navigator.pop(tokenKey);
  }

  Future<void> handleCardSelect(
    String? myAddress,
    String cardId,
    String? project,
  ) async {
    if (myAddress == null) {
      return;
    }

    final config = context.read<WalletState>().config;

    final cardAddress = await config.cardManagerContract!.getCardAddress(
      cardId,
    );

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
          cardId,
          cardAddress.hexEip55,
          myAddress,
          CardModal(uid: cardId, project: project),
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

    final profile = context.select((ProfileState p) => p.profile);
    final alias = context.select((ProfileState p) => p.alias);

    return DismissibleModalPopup(
      modalKey: 'profile_modal',
      maxHeight: height * 0.9,
      paddingSides: 16,
      paddingTopBottom: 0,
      topRadius: 12,
      onDismissed: (dir) {
        handleClose(context);
      },
      child: _buildContent(context, cards, profile, alias),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<DBCard> cards,
    ProfileV1 profile,
    String alias,
  ) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: _controller,
                  scrollBehavior: const CupertinoScrollBehavior(),
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPersistentHeader(
                      pinned: false,
                      floating: false,
                      delegate: PersistentHeaderDelegate(
                        expandedHeight: 440,
                        minHeight: 290,
                        builder: (_, shrink) {
                          final atTop = shrink == 0;

                          if (_atTop != atTop) {
                            Future.delayed(
                                Duration(milliseconds: atTop ? 10 : 30), () {
                              setState(() {
                                _showFixedHeader = atTop;
                              });
                            });
                            Future.delayed(
                                Duration(milliseconds: atTop ? 30 : 10), () {
                              setState(() {
                                _showShrinkingHeader = !atTop;
                              });
                            });
                          }
                          _atTop = atTop;

                          final maxShrink = shrink > 0.30 ? 0.30 : shrink;

                          return GestureDetector(
                            onTap: handleScrollToTop,
                            child: Opacity(
                              opacity: _showShrinkingHeader ? 1 : 0,
                              child: _buildAccountCard(
                                ValueKey('account_card'),
                                maxShrink,
                                profile,
                                alias,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildActionButtons(
                        profile,
                        alias,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildTokensList(context),
                    ),
                    SliverToBoxAdapter(
                      child: _buildCardsList(context, cards),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showFixedHeader)
            Container(
              height: 440,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: dividerMutedColor,
                    width: 1,
                  ),
                ),
              ),
              child: _buildAccountCard(
                ValueKey('account_card_fixed'),
                0,
                profile,
                alias,
              ),
            ),
          Positioned(
            top: 16,
            right: 0,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: whiteColor,
              borderRadius: BorderRadius.circular(8),
              onPressed: () => handleClose(context),
              child: Icon(
                CupertinoIcons.xmark,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
      Key? key, double shrink, ProfileV1 profile, String alias) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Expanded(
          child: AccountCard(
            key: key,
            profile: profile,
            alias: alias,
            shrink: shrink,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ProfileV1 profile, String alias) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Button(
          onPressed: handleEditProfile,
          text: 'Edit Profile',
          labelColor: whiteColor,
          prefix: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              CupertinoIcons.pencil,
              color: whiteColor,
              size: 18,
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
      ],
    );
  }

  Widget _buildTokensList(BuildContext context) {
    final config = context.select<WalletState, Config>(
      (state) => state.config,
    );

    final currentTokenAddress = context.select<WalletState, String?>(
      (state) => state.currentTokenAddress,
    );

    final tokenLoadingStates = context.watch<WalletState>().tokenLoadingStates;
    final tokenBalances = context.watch<WalletState>().tokenBalances;

    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;

    if (config.tokens.isEmpty) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (config.tokens.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No tokens available',
          style: TextStyle(
            color: textMutedColor,
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Tokens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...(config.tokens.entries.map((entry) {
          final tokenAddress = entry.value.address;
          final tokenConfig = entry.value;
          final isTokenLoading = tokenLoadingStates[tokenAddress] ?? false;
          final formattedBalance = formatCurrency(
            tokenBalances[tokenAddress] ?? '0',
            tokenConfig.decimals,
          );

          final isSelected = currentTokenAddress == tokenAddress;

          return GestureDetector(
            onTap: () => handleTokenSelect(tokenAddress),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(
                  color: isSelected ? primaryColor : backgroundColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Token logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: tokenConfig.logo != null
                        ? CoinLogo(
                            size: 40,
                            logo: tokenConfig.logo,
                          )
                        : Icon(
                            CupertinoIcons.circle_fill,
                            color: primaryColor,
                            size: 40,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Token info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tokenConfig.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          tokenConfig.symbol,
                          style: TextStyle(
                            fontSize: 14,
                            color: textMutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Balance
                  if (isTokenLoading)
                    CupertinoActivityIndicator(
                      radius: 8,
                      color: textMutedColor,
                    )
                  else ...[
                    tokenConfig.logo != null
                        ? CoinLogo(
                            size: 20,
                            logo: tokenConfig.logo,
                          )
                        : Icon(
                            CupertinoIcons.circle_fill,
                            color: primaryColor,
                            size: 20,
                          ),
                    const SizedBox(width: 4),
                    Text(
                      formattedBalance,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildCardsList(BuildContext context, List<DBCard> cards) {
    final width = MediaQuery.of(context).size.width;

    final primaryColor = CupertinoTheme.of(context).primaryColor;

    final claimingCard = context.watch<CardsState>().claimingCard;

    final profiles = context.watch<CardsState>().profiles;

    final profile = context.select<ProfileState, ProfileV1?>(
      (state) => state.profile,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...(cards.map((card) {
          final cardColor = projectCardColor(card.project);

          return Card(
            width: width * 0.8,
            uid: card.uid,
            color: cardColor,
            profile: profiles[card.account],
            onCardPressed: (uid) => handleCardSelect(
              widget.accountAddress,
              uid,
              card.project,
            ),
          );
        }).toList()),
        const SizedBox(height: 12),
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
      ],
    );
  }
}
