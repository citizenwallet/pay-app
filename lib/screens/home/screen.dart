import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

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

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  final List<Interaction> interactions = [
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
      description: 'This is a test description',
    ),
    Interaction(
      imageUrl: 'https://robohash.org/AAA.png?set=set2',
      name: 'John Doe',
      accountAddress: '0x1234567890',
      isPlace: true,
      hasUnreadMessages: true,
      location: '1000 Brussels',
      lastMessageAt: DateTime.now(),
      placeId: 1,
      amount: 100,
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
                      (context, index) =>
                          InteractionListItem(interaction: interactions[index]),
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
