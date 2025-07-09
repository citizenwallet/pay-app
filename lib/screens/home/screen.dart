import 'dart:typed_data';

import 'package:dart_debouncer/dart_debouncer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/screens/home/card_modal.dart';
import 'package:pay_app/screens/home/contact_list_item.dart';
import 'package:pay_app/screens/home/profile_list_item.dart';
import 'package:pay_app/screens/home/profile_modal.dart';
import 'package:pay_app/services/contacts/contacts.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/state/contacts/contacts.dart';
import 'package:pay_app/state/contacts/selectors.dart';
import 'package:pay_app/state/interactions/interactions.dart';
import 'package:pay_app/state/interactions/selectors.dart';
import 'package:pay_app/state/onboarding.dart';
import 'package:pay_app/state/places/places.dart';
import 'package:pay_app/state/places/selectors.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/state/state.dart';
import 'package:pay_app/state/topup.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/delay.dart';
import 'package:pay_app/utils/qr.dart';
import 'package:pay_app/utils/ratio.dart';
import 'package:pay_app/widgets/modals/confirm_modal.dart';
import 'package:pay_app/widgets/scan_qr_circle.dart';
import 'package:pay_app/widgets/scanner/scanner_modal.dart';
import 'package:pay_app/widgets/toast/toast.dart';
import 'package:pay_app/widgets/webview/connected_webview_modal.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:universal_io/io.dart';

import 'profile_bar.dart';
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool isKeyboardVisible = false;
  bool isSearching = false;

  double _scrollOffset = 0.0;
  final double _maxScrollOffset = 100.0;

  final Debouncer _debouncer =
      Debouncer(timerDuration: const Duration(milliseconds: 300));

  late OnboardingState _onboardingState;
  late InteractionState _interactionState;
  late PlacesState _placesState;
  late WalletState _walletState;
  late ProfileState _profileState;
  late ContactsState _contactsState;
  late TopupState _topupState;

  bool _stopInitRetries = false;
  bool _pauseDeepLinkHandling = false;

  @override
  void initState() {
    super.initState();

    _initState();

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
    _onboardingState = context.read<OnboardingState>();
    _interactionState = context.read<InteractionState>();
    _placesState = context.read<PlacesState>();
    _walletState = context.read<WalletState>();
    _profileState = context.read<ProfileState>();
    _contactsState = context.read<ContactsState>();
    _topupState = context.read<TopupState>();
  }

  Future<void> onLoad() async {
    if (_stopInitRetries) {
      return;
    }

    final navigator = GoRouter.of(context);

    final success = await _walletState.init();
    if (success == null) {
      await delay(const Duration(milliseconds: 2000));
      return onLoad();
    }

    if (success == false) {
      _onboardingState.clearConnectedAccountAddress();
      navigator.go('/');
      return;
    }

    if (!mounted) {
      return;
    }

    final connectedAccountAddress =
        context.read<OnboardingState>().connectedAccountAddress;
    if (connectedAccountAddress == null) {
      await delay(const Duration(milliseconds: 2000));
      return onLoad();
    }

    await _walletState.updateBalance();
    await _interactionState.getInteractions();
    _interactionState.startPolling(updateBalance: _walletState.updateBalance);
    await _placesState.getAllPlaces();
    await _profileState.giveProfileUsername();
  }

  Future<void> handleDeepLink(String accountAddress, String? deepLink) async {
    if (deepLink != null && !_pauseDeepLinkHandling) {
      _pauseDeepLinkHandling = true;

      await delay(const Duration(milliseconds: 100));

      await handleQRScan(accountAddress, () {}, manualResult: deepLink);

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
              title: 'Display contacts',
              details: [
                'This app uses your contact list to help you search for the right person.',
                'No contact data is sent to our servers.',
                'We generate the account number on device.',
              ],
              cancelText: 'Skip',
              confirmText: 'Allow',
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
    String slug, {
    bool openMenu = false,
    String? orderId,
  }) async {
    if (myAddress == null) {
      return;
    }

    _contactsState.clearContacts();

    final navigator = GoRouter.of(context);

    _stopInitRetries = true;

    await navigator.push('/$myAddress/place/$slug', extra: {
      'openMenu': openMenu,
      'orderId': orderId,
    });

    _stopInitRetries = false;

    clearSearch();
  }

  void handleInteractionWithCard(
      String? myAddress, String cardId, String? project) async {
    if (myAddress == null) {
      return;
    }

    final config = context.read<WalletState>().config;

    HapticFeedback.heavyImpact();

    await showCupertinoModalPopup(
      useRootNavigator: false,
      context: context,
      builder: (modalContext) => provideCardState(
        context,
        config,
        cardId,
        CardModal(project: project),
      ),
    );
  }

  Future<void> handleInteractionWithContact(
      String? myAddress, SimpleContact contact) async {
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

  Future<void> handleProfileTap(String myAddress) async {
    _searchFocusNode.unfocus();

    _stopInitRetries = true;

    HapticFeedback.heavyImpact();

    final selectedToken = await showCupertinoModalPopup<String?>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (modalContext) => ProfileModal(
        accountAddress: myAddress,
      ),
    );

    if (selectedToken != null) {
      _walletState.setCurrentToken(selectedToken);
    }

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
        title: const Text('Your topup is on the way'),
      ),
    );

    await _walletState.updateBalance();
  }

  void handleSettingsTap(String myAddress) async {
    _searchFocusNode.unfocus();

    final navigator = GoRouter.of(context);

    _stopInitRetries = true;

    HapticFeedback.heavyImpact();

    await navigator.push('/$myAddress/my-account/settings');

    _stopInitRetries = false;

    clearSearch();
    onLoad();
  }

  Future<void> handleQRScan(String myAddress, Function() callback,
      {String? manualResult}) async {
    _stopInitRetries = true;

    final result = manualResult ??
        await showCupertinoModalPopup<String?>(
          context: context,
          barrierDismissible: true,
          builder: (_) => const ScannerModal(
            modalKey: 'home-qr-scanner',
          ),
        );

    callback();

    _stopInitRetries = false;

    if (result == null) {
      return;
    }

    final (address, _, _, alias) = parseQRCode(result);
    if (address.isEmpty) {
      // invalid QR code
      return;
    }

    if (alias != null && alias.isNotEmpty && alias != _profileState.alias) {
      // TODO: toast with invalid alias message
      return;
    }

    final format = parseQRFormat(result);

    switch (format) {
      case QRFormat.checkoutUrl:
        final checkoutUrl = Uri.parse(result);
        final orderId = checkoutUrl.queryParameters['orderId'];
        handleInteractionWithPlace(myAddress, address,
            openMenu: true, orderId: orderId);
        break;
      case QRFormat.cardUrl:
        final project = parseCardProject(result);

        handleInteractionWithCard(myAddress, address, project);
        break;
      case QRFormat.sendtoUrl:
      case QRFormat.sendtoUrlWithEIP681:
      case QRFormat.accountUrl:
        final profile = address.startsWith('0x')
            ? await _contactsState.getContactProfileFromAddress(address)
            : await _contactsState.getContactProfileFromUsername(address);

        if (profile != null) {
          handleInteractionWithUser(
            myAddress,
            profile.account,
            name: profile.name,
            imageUrl: profile.image,
          );
        } else {
          _searchController.text = address;
          _searchFocusNode.requestFocus();
          handleSearch(address);
        }
        break;
      case QRFormat.voucher:
        // TODO: vouchers need to be handled by the voucher screen
        break;
      case QRFormat.url:
        // TODO: urls need to be handled by the webview
        break;
      default:
        final profile =
            await _contactsState.getContactProfileFromAddress(address);

        if (profile != null) {
          handleInteractionWithUser(
            myAddress,
            profile.account,
            name: profile.name,
            imageUrl: profile.image,
          );
        }
        break;
    }
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

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final double heightFactor = 1 - (_scrollOffset / _maxScrollOffset);

    final loading = context.select((WalletState state) => state.loading);

    final interactions = context.select(sortByUnreadAndDate);
    final places = context.select(selectFilteredPlaces);
    final contacts = context.select(selectFilteredContacts);
    final customContact = context.select(selectCustomContact);
    final customContactProfileByUsername = context
        .select((ContactsState state) => state.customContactProfileByUsername);

    final searching =
        context.select((InteractionState state) => state.searching);

    final myAddress =
        context.select((WalletState state) => state.address?.hexEip55);

    final safeBottomPadding = MediaQuery.of(context).padding.bottom;

    final nothingFound = _searchController.text.isNotEmpty &&
        interactions.isEmpty &&
        places.isEmpty &&
        contacts.isEmpty;

    return CupertinoPageScaffold(
      backgroundColor: whiteColor,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          bottom: false,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                color: whiteColor,
                child: CustomScrollView(
                  controller: _scrollController,
                  scrollBehavior: const CupertinoScrollBehavior(),
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPersistentHeader(
                      floating: true,
                      pinned: true,
                      delegate: ProfileBarDelegate(
                        loading: loading,
                        accountAddress: myAddress ?? '',
                        onProfileTap: () => handleProfileTap(myAddress ?? ''),
                        onTopUpTap: handleTopUp,
                        onSettingsTap: () => handleSettingsTap(myAddress ?? ''),
                      ),
                    ),
                    SliverPersistentHeader(
                      floating: true,
                      delegate: SearchBarDelegate(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onSearch: handleSearch,
                        onCancel: clearSearch,
                        isSearching: isSearching,
                        searching: searching,
                      ),
                    ),
                    CupertinoSliverRefreshControl(
                      onRefresh: onLoad,
                    ),
                    if (customContact != null)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: 1,
                          (context, index) => ContactListItem(
                            contact: customContact,
                            onTap: (contact) => handleInteractionWithContact(
                              myAddress,
                              contact,
                            ),
                          ),
                        ),
                      ),
                    if (customContactProfileByUsername != null)
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
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: interactions.length,
                        (context, index) => InteractionListItem(
                          interaction: interactions[index],
                          onTap: (interaction) =>
                              handleInteractionTap(myAddress, interaction),
                        ),
                      ),
                    ),
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
                    if (contacts.isNotEmpty && isSearching)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: contacts.length,
                          (context, index) => ContactListItem(
                            contact: contacts[index],
                            onTap: (contact) => handleInteractionWithContact(
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
                          child: Text('No results found'),
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
                        whiteColor.withValues(alpha: 0.0),
                        whiteColor,
                      ],
                    ),
                  ),
                ),
              ),
              if (!loading)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  left: 0,
                  right: 0,
                  bottom: -1 *
                      progressiveClamp(
                        -10 - safeBottomPadding,
                        120,
                        heightFactor,
                      ),
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: Center(
                      child: ScanQrCircle(
                        handleQRScan: (callback) => handleQRScan(
                          myAddress ?? '',
                          callback,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileBarDelegate extends SliverPersistentHeaderDelegate {
  final bool loading;
  final String accountAddress;
  final Future<void> Function() onProfileTap;
  final Function(String) onTopUpTap;
  final Function() onSettingsTap;

  ProfileBarDelegate({
    required this.loading,
    required this.accountAddress,
    required this.onProfileTap,
    required this.onTopUpTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ProfileBar(
      loading: loading,
      accountAddress: accountAddress,
      onProfileTap: onProfileTap,
      onTopUpTap: onTopUpTap,
      onSettingsTap: onSettingsTap,
    );
  }

  @override
  double get maxExtent => 120.0; // Maximum height of header

  @override
  double get minExtent => 120.0; // Minimum height of header

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearch;
  final Function() onCancel;
  final bool isSearching;
  final bool searching;

  SearchBarDelegate({
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.onCancel,
    this.isSearching = false,
    this.searching = false,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 77,
            width: MediaQuery.of(context).size.width,
            color: whiteColor,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SearchBar(
              controller: controller,
              focusNode: focusNode,
              onSearch: onSearch,
              isFocused: isSearching,
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
                  child: const Text('Cancel'),
                )
      ],
    );
  }

  @override
  double get maxExtent => 77.0; // Height of your SearchBar

  @override
  double get minExtent => 77.0; // Same as maxExtent for fixed height

  @override
  bool shouldRebuild(covariant SearchBarDelegate oldDelegate) => true;
}
