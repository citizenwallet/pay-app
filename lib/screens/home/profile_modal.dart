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
import 'package:web3dart/web3dart.dart';

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

  void handleTokenSelect(String tokenKey) {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();
    navigator.pop(tokenKey);
  }

  Future<void> handleCardSelect(
    String? myAddress,
    String? cardId,
    String? project,
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
    Map<String, double> cardBalances,
    ProfileV1 profile,
    String alias,
  ) {
    final width = MediaQuery.of(context).size.width;
    final safeArea = MediaQuery.of(context).padding;
    const headerHeight = 276.9;

    final balance = context.watch<WalletState>().balance;
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
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(height: headerHeight + safeArea.top),
                    ),
                    ..._buildCardsList(
                      context,
                      cards,
                      cardBalances,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 70 + safeArea.top,
            child: _buildAccountCard(
              ValueKey('account_card'),
              width,
              profile,
              alias,
              balance,
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
    double balance,
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
              ),
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
        const SizedBox(height: 12),
      ],
    );
  }

  List<Widget> _buildCardsList(
    BuildContext context,
    List<DBCard> cards,
    Map<String, double> cardBalances,
  ) {
    final width = MediaQuery.of(context).size.width;

    final primaryColor = CupertinoTheme.of(context).primaryColor;

    final claimingCard = context.watch<CardsState>().claimingCard;

    final profiles = context.watch<CardsState>().profiles;

    final profile = context.select<ProfileState, ProfileV1?>(
      (state) => state.profile,
    );

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
                Card(
                  width: width * 0.75,
                  uid: card.uid,
                  color: cardColor,
                  profile: profiles[card.account],
                  onCardPressed: (uid) => handleCardSelect(
                    widget.accountAddress,
                    uid,
                    card.project,
                  ),
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
