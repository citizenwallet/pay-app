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
import 'package:pay_app/theme/colors.dart';
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

    navigator.push('/$myAddress/place/${place.slug}');
  }

  void _goToInteractionWithUser(String? myAddress, User user) {
    if (myAddress == null) {
      return;
    }

    final navigator = GoRouter.of(context);

    navigator.push('/$myAddress/user/${user.account}');
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
                        accountAddress: myAddress ?? '',
                      ),
                    ),
                    SliverPersistentHeader(
                      floating: true,
                      delegate: SearchBarDelegate(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onSearch: handleSearch,
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: WhiteBarDelegate(),
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
  final String accountAddress;

  ProfileBarDelegate({required this.accountAddress});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ProfileBar(accountAddress: accountAddress);
  }

  @override
  double get maxExtent => 95.0; // Maximum height of header

  @override
  double get minExtent => 95.0; // Minimum height of header

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
    return Container(
      color: whiteColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SearchBar(
        controller: controller,
        focusNode: focusNode,
        onSearch: onSearch,
      ),
    );
  }

  @override
  double get maxExtent => 77.0; // Height of your SearchBar

  @override
  double get minExtent => 77.0; // Same as maxExtent for fixed height

  @override
  bool shouldRebuild(covariant SearchBarDelegate oldDelegate) => true;
}

class WhiteBarDelegate extends SliverPersistentHeaderDelegate {
  final bool reverse;

  WhiteBarDelegate({
    this.reverse = false,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final gradientList = [
      whiteColor,
      whiteColor.withValues(alpha: 0.0),
    ];

    return Column(
      children: [
        Container(
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: reverse ? gradientList.reversed.toList() : gradientList,
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 20.0; // Height of your SearchBar

  @override
  double get minExtent => 20.0; // Same as maxExtent for fixed height

  @override
  bool shouldRebuild(covariant WhiteBarDelegate oldDelegate) => true;
}
