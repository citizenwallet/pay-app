import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/widgets/scan_qr_circle.dart';

import 'profile_bar.dart';
import 'search_bar.dart';
import 'interaction_list_item.dart';

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

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(_searchListener);
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // make initial requests here
    });
  }

  @override
  void dispose() {
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

  void goToChatHistory(Interaction interaction) {
    if (interaction.isPlace && interaction.placeId != null) {
      _goToChatWithPlaceId(interaction.placeId!);
    } else {
      _goToChatWithUserId(interaction.accountAddress);
    }
  }

  void _goToChatWithPlaceId(int placeId) {
    final navigator = GoRouter.of(context);

    final myUserId = navigator.state?.pathParameters['id'];

    // TODO: replace with full path
    navigator.pushNamed('ChatWithPlace',
        pathParameters: {'placeId': placeId.toString(), 'id': myUserId!});
  }

  void _goToChatWithUserId(String accountAddress) {
    final navigator = GoRouter.of(context);

    final myUserId = GoRouter.of(context).state?.pathParameters['id'];

    // TODO: replace with full path
    navigator.pushNamed('ChatWithUser',
        pathParameters: {'accountAddress': accountAddress, 'id': myUserId!});
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // TODO: order by descending lastMessageAt
  final List<Interaction> interactions = [
    // place with no previous interactions
    Interaction(
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1661883237884-263e8de8869b?q=80&w=2689&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      name: 'Fat Duck',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: false,
      location: 'Broadwalk, London',
      lastMessageAt: null,
      placeId: 1,
      amount: null,
      description: null,
    ),

    // place with previous interactions. No unread messages
    Interaction(
      imageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      name: 'Neptune',
      accountAddress: '0x1234567891',
      isPlace: true,
      hasUnreadMessages: false,
      location: 'Lester, London',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      placeId: 2,
      amount: 12.34,
      description: 'This is a test description',
    ),

    // place with previous interactions. With unread messages
    Interaction(
      imageUrl:
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      name: 'Brew',
      accountAddress: '0x1234567892',
      isPlace: true,
      hasUnreadMessages: true,
      location: 'Mackenzie, London',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 2)),
      placeId: 3,
      amount: 12.34,
      description: 'This is a test description',
    ),

    // user with previous interactions. No unread messages
    Interaction(
      imageUrl: 'https://i.pravatar.cc/300',
      name: 'John Doe',
      accountAddress: '0x1234567893',
      isPlace: false,
      hasUnreadMessages: false,
      location: null,
      lastMessageAt: DateTime.now().subtract(const Duration(days: 3)),
      placeId: null,
      amount: 4.5,
      description: 'This is a test description',
    ),

    // user with previous interactions. With unread messages
    Interaction(
      imageUrl: 'https://i.pravatar.cc/301',
      name: 'Foo Bar',
      accountAddress: '0x1234567894',
      isPlace: false,
      hasUnreadMessages: true,
      location: null,
      lastMessageAt: DateTime.now().subtract(const Duration(days: 4)),
      placeId: null,
      amount: 4.5,
      description: 'This is a test description',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double heightFactor = 1 - (_scrollOffset / _maxScrollOffset);

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
                  // TODO: https://api.flutter.dev/flutter/material/SliverAppBar-class.html
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
  double get maxExtent => 80.0; // Maximum height of header

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
  double get maxExtent => 74.0; // Height of your SearchBar

  @override
  double get minExtent => 74.0; // Same as maxExtent for fixed height

  @override
  bool shouldRebuild(covariant SearchBarDelegate oldDelegate) => true;
}
