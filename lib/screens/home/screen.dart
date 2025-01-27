import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/models/place.dart';
import 'package:pay_app/models/user.dart';
import 'package:pay_app/state/interactions/interactions.dart';
import 'package:pay_app/state/interactions/selectors.dart';
import 'package:pay_app/state/places/places.dart';
import 'package:pay_app/state/places/selectors.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/widgets/scan_qr_circle.dart';
import 'package:provider/provider.dart';

import 'profile_bar.dart';
import 'search_bar.dart';
import 'interaction_list_item.dart';
import 'place_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool isKeyboardVisible = false;

  double _scrollOffset = 0.0;
  final double _maxScrollOffset = 100.0;

  late InteractionState _interactionState;
  late PlacesState _placesState;
  late WalletState _walletState;

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(_searchListener);
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interactionState = context.read<InteractionState>();
      _placesState = context.read<PlacesState>();
      _walletState = context.read<WalletState>();
      onLoad();
    });
  }

  Future<void> onLoad() async {
    await _walletState.updateBalance();
    await _interactionState.getInteractions();
    _interactionState.startPolling();
    await _placesState.getAllPlaces();
  }

  @override
  void dispose() {
    _interactionState.stopPolling();

    _searchFocusNode.removeListener(_searchListener);
    _searchFocusNode.dispose();

    _searchController.dispose();

    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();

    super.dispose();
  }

  void _searchListener() {
    if (_searchFocusNode.hasFocus) {
      setState(() {
        isKeyboardVisible = true;
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
    if (interaction.isPlace && interaction.placeId != null) {
      final place = Place(
        id: interaction.placeId!,
        name: interaction.name,
        imageUrl: interaction.imageUrl,
        account: interaction.withAccount,
      );
      _goToInteractionWithPlace(myAddress, place);
    } else if (!interaction.isPlace) {
      final user = User(
        name: interaction.name,
        username: '',
        account: interaction.withAccount,
        imageUrl: interaction.imageUrl,
      );

      _goToInteractionWithUser(myAddress, user);
    }
  }

  void _goToInteractionWithPlace(String? myAddress, Place place) {
    if (myAddress == null) {
      return;
    }

    final navigator = GoRouter.of(context);

    navigator.go('/$myAddress/place/${place.slug}');
  }

  void _goToInteractionWithUser(String? myAddress, User user) {
    if (myAddress == null) {
      return;
    }

    final navigator = GoRouter.of(context);

    navigator.go('/$myAddress/user/${user.account}');
  }

  void handleSearch(String query) {
    _interactionState.setSearchQuery(query);
    _placesState.setSearchQuery(query);
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final double heightFactor = 1 - (_scrollOffset / _maxScrollOffset);

    final interactions = context.select(sortByUnreadAndDate);
    final places = context.select(selectFilteredPlaces);

    final myAddress =
        context.select((WalletState state) => state.address?.hexEip55);

    final safeBottomPadding = MediaQuery.of(context).padding.bottom;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          bottom: false,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              CustomScrollView(
                controller: _scrollController,
                scrollBehavior: const CupertinoScrollBehavior(),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPersistentHeader(
                    floating: true,
                    delegate: ProfileBarDelegate(),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SearchBarDelegate(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onSearch: handleSearch,
                    ),
                  ),
                  CupertinoSliverRefreshControl(
                    onRefresh: onLoad,
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: interactions.length,
                      (context, index) => InteractionListItem(
                        interaction: interactions[index],
                        onTap: (interaction) async {
                          // Navigate first
                          goToChatHistory(myAddress, interaction);
                          // Then mark as read
                          await _interactionState
                              .markInteractionAsRead(interaction);
                        },
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: places.length,
                      (context, index) => PlaceListItem(
                        place: places[index],
                        onTap: (place) =>
                            _goToInteractionWithPlace(myAddress, place),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 10 + safeBottomPadding,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: isKeyboardVisible ? 0 : (100 * heightFactor),
                  child: ScanQrCircle(
                      handleQRScan: () {}, heightFactor: heightFactor),
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
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / maxExtent;
    final heightFactor = 1 - progress;
    final translateY = -shrinkOffset;
    final opacity = 1 - progress;

    return SizeTransition(
      sizeFactor: AlwaysStoppedAnimation(heightFactor.clamp(0, 1)),
      axisAlignment: -1,
      child: Transform.translate(
        offset: Offset(0, translateY),
        child: Opacity(
          opacity: opacity.clamp(0, 1),
          child: const ProfileBar(),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 95.0; // Maximum height of header

  @override
  double get minExtent => 0; // Minimum height of header

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearch;

  SearchBarDelegate({
    required this.controller,
    required this.focusNode,
    required this.onSearch,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SearchBar(
      controller: controller,
      focusNode: focusNode,
      onSearch: onSearch,
    );
  }

  @override
  double get maxExtent => 57.0; // Height of your SearchBar

  @override
  double get minExtent => 57.0; // Same as maxExtent for fixed height

  @override
  bool shouldRebuild(covariant SearchBarDelegate oldDelegate) => true;
}
