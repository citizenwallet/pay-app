import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/state/interactions/interactions.dart';
import 'package:pay_app/state/interactions/selectors.dart';
import 'package:pay_app/widgets/scan_qr_circle.dart';
import 'package:provider/provider.dart';

import 'profile_bar.dart';
import 'search_bar.dart';
import 'interaction_list_item.dart';

// TODO: refresh interactions on load
// TODO: paginate interactions

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

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(_searchListener);
    _scrollController.addListener(_scrollListener);

    _interactionState = context.read<InteractionState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLoad();
    });
  }

  void onLoad() async {
    await _interactionState.getInteractions();
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_searchListener);
    _searchFocusNode.dispose();

    _searchController.dispose();

    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();

    _interactionState.dispose();

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

  void goToChatHistory(Interaction interaction) {
    print(interaction);

    if (interaction.isPlace && interaction.placeId != null) {
      _goToChatWithPlace(interaction.placeId!);
    } else if (!interaction.isPlace) {
      _goToChatWithUser(interaction.withAccount);
    }
  }

  void _goToChatWithPlace(int placeId) {
    final navigator = GoRouter.of(context);

    final myUserId = navigator.state?.pathParameters['id'];

    navigator.push('/$myUserId/place/$placeId');
  }

  void _goToChatWithUser(String account) {
    final navigator = GoRouter.of(context);

    final myUserId = GoRouter.of(context).state?.pathParameters['id'];

    navigator.push('/$myUserId/user/$account');
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final double heightFactor = 1 - (_scrollOffset / _maxScrollOffset);

    final interactions = context.select(sortByUnreadAndDate);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
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
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: interactions.length,
                      (context, index) => InteractionListItem(
                        interaction: interactions[index],
                        onTap: goToChatHistory,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
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

  SearchBarDelegate({required this.controller, required this.focusNode});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SearchBar(
      controller: controller,
      focusNode: focusNode,
    );
  }

  @override
  double get maxExtent => 57.0; // Height of your SearchBar

  @override
  double get minExtent => 57.0; // Same as maxExtent for fixed height

  @override
  bool shouldRebuild(covariant SearchBarDelegate oldDelegate) => true;
}
