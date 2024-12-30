import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:pay_app/models/menu_item.dart';
import 'package:pay_app/models/place_menu.dart';
import 'package:pay_app/screens/chat/place/header.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:pay_app/state/checkout.dart';

import './footer.dart';
import './menu_list_item.dart';
import './catergory_scroll.dart';

// reference: https://github.com/AmirBayat0/flutter_scroll_animation

class PlaceMenuScreen extends StatefulWidget {
  const PlaceMenuScreen({super.key});

  @override
  State<PlaceMenuScreen> createState() => _PlaceMenuScreenState();
}

class _PlaceMenuScreenState extends State<PlaceMenuScreen> {
  final ScrollController _menuScrollController = ScrollController();

  final ItemScrollController tabScrollController = ItemScrollController();
  final ItemPositionsListener tabPositionsListener =
      ItemPositionsListener.create();

  final ScrollOffsetController tabScrollOffsetController =
      ScrollOffsetController();

  int _selectedIndex = 0;

  List<GlobalKey> categoryKeys = [];
  PlaceMenu placeMenu = PlaceMenu(menuItems: []);

  String _currentVisibleCategory = '';
  Timer? _scrollThrottle;

  static const double headerHeight = _StickyHeaderDelegate.height;
  static const double detectionSensitivity = 0.5; // 0.5 = half header height

  double get _scrollThreshold => headerHeight * (1 + detectionSensitivity);

  @override
  void initState() {
    super.initState();

    placeMenu = PlaceMenu(menuItems: [
      MenuItem(
        id: 7,
        placeId: 2,
        imageUrl:
            'https://ounjigiydhimruivuxjv.supabase.co/storage/v1/object/public/uploads/Quattro%20Fromaggi%20Pizza.jpeg',
        price: 1350,
        name: 'Quattro Formaggi',
        description: 'Tomato, mozzarella, parmigiano, gorgonzola, taleggio',
        category: 'Pizza',
        vat: 21,
        emoji: null,
        orderId: 2,
      ),

      MenuItem(
        id: 9,
        placeId: 2,
        imageUrl:
            'https://ounjigiydhimruivuxjv.supabase.co/storage/v1/object/public/uploads/Peroni%20Nastro%20Azzurro%20330ml.jpg',
        price: 350,
        name: 'Peroni',
        description: 'Beer',
        category: 'Drinks',
        vat: 6,
        emoji: null,
        orderId: 4,
      ),
      MenuItem(
        id: 11,
        placeId: 2,
        imageUrl:
            'https://ounjigiydhimruivuxjv.supabase.co/storage/v1/object/public/uploads/Zinnebir.jpg',
        price: 350,
        name: 'Zinnebir',
        description: 'Beer',
        category: 'Drinks',
        vat: 21,
        emoji: null,
        orderId: 0,
      ),
      MenuItem(
        id: 12,
        placeId: 2,
        imageUrl:
            'https://ounjigiydhimruivuxjv.supabase.co/storage/v1/object/public/uploads/Spa%20Water.jpg',
        price: 200,
        name: 'Water',
        description: 'Water',
        category: 'Drinks',
        vat: 21,
        emoji: null,
        orderId: 1,
      ),
      // Starters
      MenuItem(
        id: 1,
        placeId: 2,
        imageUrl: 'https://example.com/bruschetta.jpg',
        price: 800,
        name: 'Bruschetta',
        description: 'Grilled bread with tomatoes, garlic and basil',
        category: 'Starters',
        vat: 21,
        emoji: '🍅',
        orderId: 0,
      ),
      MenuItem(
        id: 2,
        placeId: 2,
        imageUrl: 'https://example.com/calamari.jpg',
        price: 1200,
        name: 'Calamari Fritti',
        description: 'Crispy fried squid with lemon aioli',
        category: 'Starters',
        vat: 21,
        emoji: '🦑',
        orderId: 0,
      ),

      // Pizza (existing items plus new ones)
      MenuItem(
        id: 5,
        placeId: 2,
        imageUrl: 'https://example.com/diavola.jpg',
        price: 1400,
        name: 'Diavola',
        description: 'Tomato, mozzarella, spicy salami',
        category: 'Pizza',
        vat: 21,
        emoji: '🌶️',
        orderId: 0,
      ),
      MenuItem(
        id: 6,
        placeId: 2,
        imageUrl: 'https://example.com/margherita.jpg',
        price: 1100,
        name: 'Margherita',
        description: 'Tomato, mozzarella, basil',
        category: 'Pizza',
        vat: 21,
        emoji: '🍕',
        orderId: 0,
      ),

      // Pasta
      MenuItem(
        id: 15,
        placeId: 2,
        imageUrl: 'https://example.com/carbonara.jpg',
        price: 1600,
        name: 'Carbonara',
        description: 'Spaghetti with eggs, pecorino, guanciale',
        category: 'Pasta',
        vat: 21,
        emoji: '🍝',
        orderId: 0,
      ),
      MenuItem(
        id: 16,
        placeId: 2,
        imageUrl: 'https://example.com/pesto.jpg',
        price: 1500,
        name: 'Pesto Genovese',
        description: 'Trofie with basil pesto, potatoes, green beans',
        category: 'Pasta',
        vat: 21,
        emoji: '🌿',
        orderId: 0,
      ),

      // Main Courses
      MenuItem(
        id: 20,
        placeId: 2,
        imageUrl: 'https://example.com/saltimbocca.jpg',
        price: 2200,
        name: 'Saltimbocca',
        description: 'Veal with prosciutto and sage, white wine sauce',
        category: 'Main Courses',
        vat: 21,
        emoji: '🥩',
        orderId: 0,
      ),
      MenuItem(
        id: 21,
        placeId: 2,
        imageUrl: 'https://example.com/seabass.jpg',
        price: 2400,
        name: 'Branzino',
        description: 'Grilled sea bass with herbs and lemon',
        category: 'Main Courses',
        vat: 21,
        emoji: '🐟',
        orderId: 0,
      ),

      // Drinks (existing plus new ones)
      MenuItem(
        id: 8,
        placeId: 2,
        imageUrl: 'https://example.com/pellegrino.jpg',
        price: 250,
        name: 'San Pellegrino',
        description: 'Sparkling mineral water',
        category: 'Drinks',
        vat: 6,
        emoji: '💧',
        orderId: 0,
      ),
      MenuItem(
        id: 25,
        placeId: 2,
        imageUrl: 'https://example.com/negroni.jpg',
        price: 1200,
        name: 'Negroni',
        description: 'Gin, Campari, sweet vermouth',
        category: 'Cocktails',
        vat: 21,
        emoji: '🍸',
        orderId: 0,
      ),

      // Desserts
      MenuItem(
        id: 30,
        placeId: 2,
        imageUrl: 'https://example.com/tiramisu.jpg',
        price: 900,
        name: 'Tiramisù',
        description: 'Coffee-flavored dessert with mascarpone',
        category: 'Desserts',
        vat: 21,
        emoji: '🍰',
        orderId: 0,
      ),
      MenuItem(
        id: 31,
        placeId: 2,
        imageUrl: 'https://example.com/cannoli.jpg',
        price: 800,
        name: 'Cannoli',
        description: 'Sicilian pastry tubes with ricotta filling',
        category: 'Desserts',
        vat: 21,
        emoji: '🍪',
        orderId: 0,
      ),

      // Sides
      MenuItem(
        id: 35,
        placeId: 2,
        imageUrl: 'https://example.com/salad.jpg',
        price: 600,
        name: 'Insalata Mista',
        description: 'Mixed green salad with balsamic dressing',
        category: 'Sides',
        vat: 21,
        emoji: '🥗',
        orderId: 0,
      ),
      MenuItem(
        id: 36,
        placeId: 2,
        imageUrl: 'https://example.com/fries.jpg',
        price: 500,
        name: 'Truffle Fries',
        description: 'French fries with truffle oil and parmesan',
        category: 'Sides',
        vat: 21,
        emoji: '🍟',
        orderId: 0,
      ),
    ]);

    categoryKeys = placeMenu.categories.map((category) => GlobalKey()).toList();
    _currentVisibleCategory = placeMenu.categories[0];

    _menuScrollController.addListener(_throttledOnScroll);

    tabPositionsListener.itemPositions.addListener(_onItemPositionsChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    tabPositionsListener.itemPositions.removeListener(_onItemPositionsChange);

    _scrollThrottle?.cancel();
    _menuScrollController.removeListener(_throttledOnScroll);
    _menuScrollController.dispose();

    super.dispose();
  }

  void goBack() {
    Navigator.pop(context);
  }

  void _onScroll() {
    final headerContexts =
        categoryKeys.map((key) => key.currentContext).toList();

    for (int i = 0; i < headerContexts.length; i++) {
      if (headerContexts[i] == null) continue;

      final RenderObject? renderObject = headerContexts[i]!.findRenderObject();
      if (renderObject == null) continue;

      // Get the viewport position using RenderSliver instead of RenderBox
      final RenderAbstractViewport viewport =
          RenderAbstractViewport.of(renderObject);
      final double viewportOffset =
          viewport.getOffsetToReveal(renderObject, 0.0).offset;
      final double scrollOffset = _menuScrollController.offset;

      // Check if this header is near the top of the viewport
      if ((scrollOffset - viewportOffset).abs() < _scrollThreshold) {
        // adjust threshold as needed
        final category = placeMenu.categories[i];
        if (_currentVisibleCategory != category) {
          setState(() {
            _currentVisibleCategory = category;
            _selectedIndex = i;
          });
          tabScrollController.scrollTo(
              index: i, duration: const Duration(milliseconds: 600));
        }
        break;
      }
    }
  }

  void _throttledOnScroll() {
    if (_scrollThrottle?.isActive ?? false) return;
    _scrollThrottle = Timer(const Duration(milliseconds: 100), () {
      _onScroll();
    });
  }

  void _onItemPositionsChange() {
    tabPositionsListener.itemPositions.value.first.index;
  }

  void onCategorySelected(int index) async {
    _menuScrollController.removeListener(_onScroll);
    setState(() {
      _selectedIndex = index;
    });

    tabScrollController.scrollTo(
        index: index, duration: const Duration(milliseconds: 600));

    final categories = categoryKeys[index].currentContext!;
    await Scrollable.ensureVisible(
      categories,
      duration: const Duration(milliseconds: 600),
    );

    _menuScrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = context.watch<CheckoutState>();
    final checkout = checkoutState.checkout;
    final checkoutTotal = checkout.total;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Column(
          children: [
            ChatHeader(
              imageUrl:
                  'https://plus.unsplash.com/premium_photo-1661883237884-263e8de8869b?q=80&w=2689&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              placeName: 'Fat Duck',
              placeDescription: 'Broadwalk, London',
              onTapLeading: goBack,
            ),

            CategoryScroll(
              categories: placeMenu.categories,
              tabScrollController: tabScrollController,
              tabPositionsListener: tabPositionsListener,
              tabScrollOffsetController: tabScrollOffsetController,
              onSelected: onCategorySelected,
              selectedIndex: _selectedIndex,
            ),

            // Menu items grouped by category
            Expanded(
              child: CustomScrollView(
                controller: _menuScrollController,
                slivers: [
                  for (var category in placeMenu.categories)
                    SliverMainAxisGroup(
                      slivers: [
                        SliverPersistentHeader(
                          key: categoryKeys[
                              placeMenu.categories.indexOf(category)],
                          pinned: true,
                          delegate: _StickyHeaderDelegate(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              color: CupertinoColors.systemBackground
                                  .withOpacity(0.95),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final items = placeMenu.menuItems
                                  .where((item) => item.category == category)
                                  .toList();
                              if (index >= items.length) return null;
                              return MenuListItem(
                                menuItem: items[index],
                                checkoutState: checkoutState,
                              );
                            },
                            childCount: placeMenu.menuItems
                                .where((item) => item.category == category)
                                .length,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Footer(
              checkoutTotal: checkoutTotal,
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  static const double height = 42.0; // Fixed height constant

  _StickyHeaderDelegate({
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: height,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return true;
  }
}
