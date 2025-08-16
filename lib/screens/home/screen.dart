import 'package:collection/collection.dart';
import 'package:dart_debouncer/dart_debouncer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/screens/home/contact_list_item.dart';
import 'package:pay_app/screens/home/profile_list_item.dart';
import 'package:pay_app/screens/home/profile_modal.dart';
import 'package:pay_app/screens/home/transaction_list_item.dart';
import 'package:pay_app/services/contacts/contacts.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/state/cards.dart';
import 'package:pay_app/state/contacts/contacts.dart';
import 'package:pay_app/state/contacts/selectors.dart';
import 'package:pay_app/state/interactions/interactions.dart';
import 'package:pay_app/state/interactions/selectors.dart';
import 'package:pay_app/state/onboarding.dart';
import 'package:pay_app/state/places/places.dart';
import 'package:pay_app/state/places/selectors.dart';
import 'package:pay_app/state/state.dart';
import 'package:pay_app/state/topup.dart';
import 'package:pay_app/state/transactions/transactions.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:pay_app/utils/ratio.dart';
import 'package:pay_app/widgets/modals/confirm_modal.dart';
import 'package:pay_app/widgets/scan_qr_circle.dart';
import 'package:pay_app/screens/home/scanner_modal/scanner_modal.dart';
import 'package:pay_app/widgets/toast/toast.dart';
import 'package:pay_app/widgets/webview/connected_webview_modal.dart';
import 'package:pay_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:universal_io/io.dart';
import 'package:web3dart/web3dart.dart';
import 'package:pay_app/models/transaction.dart' as tx;

import 'search_bar.dart';
import 'interaction_list_item.dart';
import 'place_list_item.dart';

class HomeScreen extends StatefulWidget {
  final String accountAddress;
  final String? deepLink;

  const HomeScreen({
    super.key,
    required this.accountAddress,
    this.deepLink,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool isKeyboardVisible = false;
  bool isSearching = false;

  double _scrollOffset = 0.0;
  final double _maxScrollOffset = 100.0;

  final Debouncer _debouncer =
      Debouncer(timerDuration: const Duration(milliseconds: 300));

  late AppState _appState;
  late OnboardingState _onboardingState;
  late InteractionState _interactionState;
  late PlacesState _placesState;
  late WalletState _walletState;
  late ContactsState _contactsState;
  late TopupState _topupState;
  late CardsState _cardsState;

  bool _handlingExpiredCredentials = false;
  bool _stopInitRetries = false;
  bool _pauseDeepLinkHandling = false;

  late AnimationController _backgroundColorController;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();

    _initState();

    _backgroundColorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundColorAnimation = ColorTween(
      begin: whiteColor,
      end: blackColor,
    ).animate(CurvedAnimation(
      parent: _backgroundColorController,
      curve: Curves.easeInOut,
    ));

    _searchFocusNode.addListener(_searchListener);
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Start listening to lifecycle changes.
      WidgetsBinding.instance.addObserver(this);
      await onLoad();
      handleDeepLink(widget.accountAddress, widget.deepLink);
    });
  }

  void _initState() {
    _appState = context.read<AppState>();
    _onboardingState = context.read<OnboardingState>();
    _interactionState = context.read<InteractionState>();
    _placesState = context.read<PlacesState>();
    _walletState = context.read<WalletState>();
    _contactsState = context.read<ContactsState>();
    _topupState = context.read<TopupState>();
    _cardsState = context.read<CardsState>();
  }

  Future<void> onLoad() async {
    if (_stopInitRetries) {
      return;
    }

    final connectedAccountAddress =
        context.read<OnboardingState>().connectedAccountAddress;
    if (connectedAccountAddress == null) {
      await delay(const Duration(milliseconds: 2000));
      return onLoad();
    }

    _interactionState.startPolling(updateBalance: _walletState.updateBalance);
    _interactionState.getInteractions();
    _cardsState.fetchCards();
  }

  Future<void> handleRefresh() async {
    HapticFeedback.lightImpact();

    _interactionState.startPolling(updateBalance: _walletState.updateBalance);

    await _interactionState.getInteractions();

    HapticFeedback.heavyImpact();
  }

  void handleExpiredCredentials() {
    if (_handlingExpiredCredentials) {
      return;
    }

    _handlingExpiredCredentials = true;

    final navigator = GoRouter.of(context);

    _onboardingState.clearConnectedAccountAddress();
    navigator.go('/');
    return;
  }

  Future<void> handleDeepLink(String accountAddress, String? deepLink) async {
    if (deepLink != null && !_pauseDeepLinkHandling) {
      _pauseDeepLinkHandling = true;

      await delay(const Duration(milliseconds: 100));

      if (!mounted) {
        return;
      }

      await handleQRScan(context, accountAddress, () {},
          manualResult: deepLink);

      _pauseDeepLinkHandling = false;
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.deepLink != widget.deepLink && widget.deepLink != null) {
      handleDeepLink(
        widget.accountAddress,
        widget.deepLink,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        _stopInitRetries = false;
        onLoad();
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        _stopInitRetries = true;
        _interactionState.stopPolling();
    }
  }

  @override
  void dispose() {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);

    _stopInitRetries = true;

    _debouncer.dispose();

    _interactionState.stopPolling();

    _searchFocusNode.removeListener(_searchListener);
    _searchFocusNode.dispose();

    _searchController.dispose();

    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();

    _backgroundColorController.dispose();

    super.dispose();
  }

  void _searchListener() async {
    if (_searchFocusNode.hasFocus) {
      if (Platform.isAndroid) {
        if (PreferencesService().contactPermission == null) {
          final confirmed = await showCupertinoModalPopup<bool>(
            context: context,
            barrierDismissible: true,
            builder: (modalContext) => ConfirmModal(
              title: AppLocalizations.of(context)!.displayContacts,
              details: [
                'This app uses your contact list to help you search for the right person.',
                'No contact data is sent to our servers.',
                'We generate the account number on device.',
              ],
              cancelText: AppLocalizations.of(context)!.skip,
              confirmText: AppLocalizations.of(context)!.allow,
            ),
          );

          PreferencesService().setContactPermission(confirmed ?? false);
        }

        final hasPermission = PreferencesService().contactPermission;

        if (hasPermission == true) {
          _contactsState.fetchContacts();
        }
      } else {
        _contactsState.fetchContacts();
      }
      setState(() {
        isKeyboardVisible = true;
        isSearching = true;
      });
    }

    if (!_searchFocusNode.hasFocus) {
      setState(() {
        isKeyboardVisible = false;
      });
    }
  }

  void _scrollListener() {
    // Hide on scroll down
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      setState(() {
        _scrollOffset = _scrollController.offset.clamp(0, _maxScrollOffset);
      });

      _searchFocusNode.unfocus();
    }

    // Show on scroll up
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      setState(() {
        _scrollOffset = 0;
      });
    }

    _appState.setSmall(_scrollOffset == 100);
  }

  void goToChatHistory(String? myAddress, Interaction interaction) {
    if (interaction.isTreasury) {
      handleInteractionWithPlace(
        myAddress,
        'topup',
      );
      return;
    }

    if (interaction.isPlace && interaction.placeId != null) {
      handleInteractionWithPlace(
        myAddress,
        interaction.place?.slug ?? '',
      );
      return;
    }

    handleInteractionWithUser(myAddress, interaction.withAccount);
  }

  void handleInteractionWithPlace(
    String? myAddress,
    String slug,
  ) async {
    if (myAddress == null) {
      return;
    }

    _contactsState.clearContacts();

    final navigator = GoRouter.of(context);

    _stopInitRetries = true;

    await navigator.push('/$myAddress/place/$slug');

    _stopInitRetries = false;

    clearSearch();
  }

  Future<void> handleInteractionWithContact(
    String? myAddress,
    SimpleContact contact,
  ) async {
    if (myAddress == null) {
      return;
    }

    _contactsState.clearContacts();

    _stopInitRetries = true;

    final account = await _contactsState.getContactAddress(
      contact.phone,
      'sms',
    );

    _stopInitRetries = false;

    if (account == null) {
      return;
    }

    handleInteractionWithUser(
      myAddress,
      account.hexEip55,
      name: contact.name,
      phone: contact.phone,
      photo: contact.photo,
    );
  }

  void handleInteractionWithUser(
    String? myAddress,
    String account, {
    String? name,
    String? phone,
    Uint8List? photo,
    String? imageUrl,
  }) async {
    if (myAddress == null) {
      return;
    }

    _contactsState.clearContacts();

    _stopInitRetries = true;

    final navigator = GoRouter.of(context);

    await navigator.push('/$myAddress/user/$account', extra: {
      'name': name,
      'phone': phone,
      'photo': photo,
      'imageUrl': imageUrl,
    });

    _stopInitRetries = false;

    clearSearch();
  }

  Future<void> handleProfileTap(
    String myAddress, {
    String? tokenAddress,
  }) async {
    _searchFocusNode.unfocus();

    _stopInitRetries = true;

    _backgroundColorController.forward();

    HapticFeedback.heavyImpact();

    final account = await showCupertinoDialog<EthereumAddress?>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (modalContext) => ProfileModal(
        accountAddress: myAddress,
        tokenAddress: tokenAddress,
      ),
    );

    if (account != null && mounted) {
      _walletState.setLastAccount(account.hexEip55);

      final navigator = GoRouter.of(context);

      navigator.replace('/${account.hexEip55}');
    }

    _backgroundColorController.reverse();

    _stopInitRetries = false;

    clearSearch();
  }

  void handleTopUp(String baseUrl) async {
    _stopInitRetries = true;

    await _topupState.generateTopupUrl(baseUrl);

    if (!mounted) {
      _stopInitRetries = false;
      return;
    }

    _backgroundColorController.forward();

    HapticFeedback.heavyImpact();

    final redirectDomain = dotenv.env['APP_REDIRECT_DOMAIN'];

    final redirectUrl = redirectDomain != null ? 'https://$redirectDomain' : '';

    final result = await showCupertinoModalPopup<String?>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
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

    _stopInitRetries = false;

    _backgroundColorController.reverse();

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

  Future<void> handleQRScan(
    BuildContext context,
    String myAddress,
    Function() callback, {
    String? manualResult,
  }) async {
    _stopInitRetries = true;

    _backgroundColorController.forward();

    final tokenAddress = context.read<AppState>().currentTokenAddress;

    final selectedAccount = await showCupertinoDialog<String?>(
      context: context,
      useRootNavigator: false,
      builder: (modalContext) => provideSendingState(
        context,
        _walletState.config,
        myAddress,
        ScannerModal(
          modalKey: 'home-qr-sending',
          tokenAddress: tokenAddress,
          manualScanResult: manualResult,
        ),
      ),
    );

    if (selectedAccount != null && context.mounted) {
      final navigator = GoRouter.of(context);

      navigator.replace('/$selectedAccount');
    }

    _backgroundColorController.reverse();

    callback();

    _stopInitRetries = false;
  }

  void clearSearch() async {
    setState(() {
      isSearching = false;
    });

    _searchController.clear();
    _searchFocusNode.unfocus();

    await delay(const Duration(milliseconds: 500));

    _interactionState.clearSearch();
    _placesState.clearSearch();
    _contactsState.clearSearch();
  }

  void handleSearch(String query) {
    _interactionState.startSearching();
    _debouncer.resetDebounce(() {
      _interactionState.setSearchQuery(query);
      _placesState.setSearchQuery(query);
      _contactsState.setSearchQuery(query);
    });
  }

  void handleInteractionTap(String? myAddress, Interaction interaction) {
    goToChatHistory(myAddress, interaction);
    _interactionState.markInteractionAsRead(interaction);
  }

  void handleTransactionTap(String? myAddress, tx.Transaction transaction) {
    // goToChatHistory(myAddress, interaction);
    // _interactionState.markInteractionAsRead(interaction);
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final expiredCredentials =
        context.select<WalletState, bool>((state) => state.credentialsExpired);
    if (expiredCredentials) {
      handleExpiredCredentials();
    }

    final safeTopPadding = MediaQuery.of(context).padding.top;

    final loading = context.select((WalletState state) => state.loading);

    final interactions = context.select(sortByUnreadAndDate);

    final interactionsState = context.select((InteractionState state) => state);

    final places = context.select(selectFilteredPlaces(interactionsState));
    final contacts = context.select(selectFilteredContacts);
    final customContact = context.select(selectCustomContact);
    final customContactProfileByUsername = context
        .select((ContactsState state) => state.customContactProfileByUsername);

    final searching =
        context.select((InteractionState state) => state.searching);

    final myAddress =
        context.select((WalletState state) => state.address?.hexEip55);

    final isCard = context.select((CardsState state) =>
        state.cards.firstWhereOrNull((card) => card.account == myAddress) !=
        null);

    final transactions =
        context.select((TransactionsState state) => state.transactions);
    final orders = context.select((TransactionsState state) => state.orders);
    final profiles =
        context.select((TransactionsState state) => state.profiles);

    final nothingFound = _searchController.text.isNotEmpty &&
        interactions.isEmpty &&
        places.isEmpty &&
        contacts.isEmpty;

    return AnimatedBuilder(
      animation: _backgroundColorAnimation,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: _backgroundColorAnimation.value,
          child: GestureDetector(
            onTap: _dismissKeyboard,
            behavior: HitTestBehavior.opaque,
            child: SafeArea(
              top: false,
              bottom: false,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    color: _backgroundColorAnimation.value,
                    child: CustomScrollView(
                      controller: _scrollController,
                      scrollBehavior: const CupertinoScrollBehavior(),
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPersistentHeader(
                          floating: true,
                          delegate: SearchBarDelegate(
                            safeTopPadding: safeTopPadding,
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onSearch: handleSearch,
                            onCancel: clearSearch,
                            isSearching: isSearching,
                            searching: searching || _interactionState.syncing,
                            backgroundColor: _backgroundColorAnimation.value,
                            isCard: isCard,
                          ),
                        ),
                        CupertinoSliverRefreshControl(
                          onRefresh: handleRefresh,
                        ),
                        if (!isCard && customContact != null)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: 1,
                              (context, index) => ContactListItem(
                                contact: customContact,
                                onTap: (contact) =>
                                    handleInteractionWithContact(
                                  myAddress,
                                  contact,
                                ),
                              ),
                            ),
                          ),
                        if (!isCard && customContactProfileByUsername != null)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: 1,
                              (context, index) => ProfileListItem(
                                profile: customContactProfileByUsername,
                                onTap: (profile) => handleInteractionWithUser(
                                  myAddress,
                                  profile.account,
                                ),
                              ),
                            ),
                          ),
                        if (!isCard)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: interactions.length,
                              (context, index) => InteractionListItem(
                                interaction: interactions[index],
                                onTap: (interaction) => handleInteractionTap(
                                    myAddress, interaction),
                              ),
                            ),
                          ),
                        if (isCard && myAddress != null)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: transactions.length,
                              (context, index) => TransactionListItem(
                                myAddress: myAddress,
                                transaction: transactions[index],
                                profiles: profiles,
                                order: orders[transactions[index].txHash],
                                onTap: (transaction) => handleTransactionTap(
                                    myAddress, transaction),
                              ),
                            ),
                          ),
                        if (!isCard)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: places.length,
                              (context, index) => PlaceListItem(
                                place: places[index],
                                onTap: (place) => handleInteractionWithPlace(
                                  myAddress,
                                  place.slug,
                                ),
                              ),
                            ),
                          ),
                        if (!isCard && contacts.isNotEmpty && isSearching)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: contacts.length,
                              (context, index) => ContactListItem(
                                contact: contacts[index],
                                onTap: (contact) =>
                                    handleInteractionWithContact(
                                  myAddress,
                                  contact,
                                ),
                              ),
                            ),
                          ),
                        if (loading &&
                            places.isEmpty &&
                            interactions.isEmpty &&
                            contacts.isEmpty)
                          SliverFillRemaining(
                            child: Center(child: CupertinoActivityIndicator()),
                          ),
                        if (nothingFound)
                          SliverToBoxAdapter(
                            child: Center(
                              child: Text(
                                  AppLocalizations.of(context)!.noResultsFound),
                            ),
                          ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _backgroundColorAnimation.value
                                    ?.withValues(alpha: 0.0) ??
                                whiteColor.withValues(alpha: 0.0),
                            _backgroundColorAnimation.value ?? whiteColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final double safeTopPadding;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearch;
  final Function() onCancel;
  final bool isSearching;
  final bool searching;
  final Color? backgroundColor;
  final bool isCard;

  SearchBarDelegate({
    required this.safeTopPadding,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.onCancel,
    this.isSearching = false,
    this.searching = false,
    this.backgroundColor,
    this.isCard = false,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            if (!isCard)
              Expanded(
                child: Container(
                  height: 77,
                  width: MediaQuery.of(context).size.width,
                  color: backgroundColor,
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: SearchBar(
                    controller: controller,
                    focusNode: focusNode,
                    onSearch: onSearch,
                    isFocused: isSearching,
                    backgroundColor: backgroundColor,
                  ),
                ),
              ),
            if (isSearching)
              searching
                  ? const Padding(
                      padding: EdgeInsets.fromLTRB(18, 0, 44, 0),
                      child: CupertinoActivityIndicator(),
                    )
                  : CupertinoButton(
                      padding: const EdgeInsets.fromLTRB(5, 0, 24, 0),
                      onPressed: onCancel,
                      child: Text(AppLocalizations.of(context)!.cancel),
                    )
          ],
        ),
      ],
    );
  }

  @override
  double get maxExtent =>
      safeTopPadding + 260 + (isCard ? 0 : 77.0); // Height of your SearchBar

  @override
  double get minExtent =>
      safeTopPadding +
      260 +
      (isCard ? 0 : 77.0); // Same as maxExtent for fixed height

  @override
  bool shouldRebuild(covariant SearchBarDelegate oldDelegate) => true;
}
