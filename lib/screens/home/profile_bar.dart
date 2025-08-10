import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/models/card.dart';
import 'package:pay_app/screens/home/token_modal.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/state/cards.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/state/state.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/blurry_child.dart';
import 'package:pay_app/widgets/cards/card.dart' as cardWidget;
import 'package:pay_app/widgets/cards/card_skeleton.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:provider/provider.dart';

class ProfileBar extends StatefulWidget {
  final String? selectedAddress;
  final void Function(String) onCardChanged;
  final PageController pageController;
  final bool small;
  final Config config;
  final bool loading;
  final String accountAddress;
  final Color backgroundColor;
  final Function(String) onTopUpTap;

  const ProfileBar({
    super.key,
    this.selectedAddress,
    required this.onCardChanged,
    required this.pageController,
    required this.small,
    required this.config,
    required this.loading,
    required this.accountAddress,
    required this.backgroundColor,
    required this.onTopUpTap,
  });

  @override
  State<ProfileBar> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> with TickerProviderStateMixin {
  late AppState _appState;
  late CardsState _cardsState;
  late ProfileState _profileState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appState = context.read<AppState>();
      _cardsState = context.read<CardsState>();
      _profileState = context.read<ProfileState>();
    });
  }

  Future<void> handleProfileTap() async {
    // await widget.onProfileTap();
  }

  Future<void> handleBalanceTap(
      BuildContext context, Config config, String account) async {
    final selectedToken = await showCupertinoModalPopup<String?>(
      context: context,
      barrierDismissible: true,
      builder: (_) => provideWalletState(
        context,
        config,
        account,
        TokenModal(
          config: config,
        ),
      ),
    );

    if (selectedToken != null) {
      _appState.setCurrentToken(selectedToken);
    }
  }

  Future<void> handleEditProfile() async {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();

    navigator.push('/${widget.accountAddress}/my-account/edit');
  }

  Future<void> handleUpdateCardName(
      String uid, String name, String originalName) async {
    await _cardsState.updateCardName(uid, name, originalName);

    _profileState.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final tokenConfig = context.select<AppState, TokenConfig>(
      (state) => state.currentTokenConfig,
    );

    final balance = context.select<WalletState, String>(
      (state) => state.tokenBalances[tokenConfig.address] ?? '0.0',
    );
    final config = widget.config;

    final topUpPlugin = config.getTopUpPlugin(
      tokenAddress: tokenConfig.address,
    );

    final profile = context.watch<ProfileState>().profile;

    return _buildProfileCard(
      context,
      profile,
      balance,
      config,
      tokenConfig,
      topUpPlugin,
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    ProfileV1 profile,
    String balance,
    Config? config,
    TokenConfig? tokenConfig,
    PluginConfig? topUpPlugin,
  ) {
    final safeArea = MediaQuery.of(context).padding;
    final width = MediaQuery.of(context).size.width;
    final adjustedWidth = widget.small ? width * 0.8 : width;

    final primaryColor = context.select<AppState, Color>(
      (state) => state.tokenPrimaryColor,
    );

    final cards = context.watch<CardsState>().cards;
    final cardBalances = context.watch<CardsState>().cardBalances;
    final profiles = context.watch<CardsState>().profiles;

    final appProfile = context.watch<ProfileState>().appProfile;

    final updatingCardName = context.watch<CardsState>().updatingCardName;

    // Create list of all cards (app profile + card profiles)
    final List<CardInfo> cardInfoList = [
      CardInfo(
        uid: 'main',
        profile: appProfile,
        balance: balance,
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

    return BlurryChild(
      child: Container(
        width: width,
        height: widget.small ? 280 : 320,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: blackColor.withAlpha(40),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: safeArea.top),
            if (profile.isAnonymous || updatingCardName)
              CardSkeleton(
                width: (adjustedWidth < 360 ? 360 : adjustedWidth) * 0.8,
                color: primaryColor,
              ),
            if (!profile.isAnonymous && cardInfoList.isNotEmpty)
              SizedBox(
                height: widget.small ? 220 : 260,
                width: width,
                child: PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  controller: widget.pageController,
                  onPageChanged: (index) {
                    widget.onCardChanged(cardInfoList[index].profile.account);
                  },
                  itemCount: cardInfoList.length,
                  itemBuilder: (context, index) {
                    final card = cardInfoList[index];
                    final isAppAccount =
                        appProfile.account == card.profile.account;
                    final cardData = cards.firstWhereOrNull(
                        (c) => c.account == card.profile.account);

                    final isSelected = card.profile.account ==
                        (widget.selectedAddress ?? appProfile.account);

                    return Container(
                      key: Key(card.uid),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Center(
                        child: AnimatedScale(
                          scale: isSelected ? 1.1 : 1,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: cardWidget.Card(
                            width: (adjustedWidth < 360 ? 360 : adjustedWidth) *
                                0.8,
                            uid: card.uid,
                            color: primaryColor,
                            profile: card.profile,
                            icon: isAppAccount
                                ? CupertinoIcons.device_phone_portrait
                                : null,
                            onTopUpPressed:
                                !widget.loading && topUpPlugin != null
                                    ? () => widget.onTopUpTap(topUpPlugin.url)
                                    : null,
                            onCardNameTapped:
                                isAppAccount ? handleEditProfile : null,
                            onCardNameUpdated: !isAppAccount &&
                                    cardData != null &&
                                    !updatingCardName
                                ? (name) => handleUpdateCardName(
                                    cardData.uid, name, card.profile.name)
                                : null,
                            onCardPressed: (_) => handleProfileTap(),
                            onCardBalanceTapped: config != null
                                ? () => handleBalanceTap(
                                      context,
                                      config,
                                      card.profile.account,
                                    )
                                : null,
                            logo: tokenConfig?.logo,
                            balance: card.balance,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Name extends StatelessWidget {
  final String name;

  const Name({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class Balance extends StatelessWidget {
  final String balance;
  final String? logo;

  const Balance({super.key, required this.balance, this.logo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CoinLogo(size: 33, logo: logo),
        SizedBox(width: 4),
        Text(
          balance,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class TopUpButton extends StatelessWidget {
  final Function() onTopUpTap;

  const TopUpButton({super.key, required this.onTopUpTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.select<AppState, Color>(
      (state) => state.tokenPrimaryColor,
    );

    return CupertinoButton(
      padding: EdgeInsets.zero,
      color: primaryColor,
      borderRadius: BorderRadius.circular(8),
      minSize: 0,
      onPressed: onTopUpTap,
      child: SizedBox(
        width: 70,
        height: 28,
        child: Center(
          child: Text(
            '+ top up',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
