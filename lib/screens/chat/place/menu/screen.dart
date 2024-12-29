import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/menu_item.dart';
import 'package:pay_app/screens/chat/place/header.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  final ItemScrollController _tabScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  int _selectedIndex = 0;
  final Map<String, double> _categoryOffsets = {};
  double _lastPixels = 0;

  @override
  void initState() {
    super.initState();
    _menuScrollController.addListener(_onScroll);
    _itemPositionsListener.itemPositions.addListener(_onItemPositionsChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateCategoryOffsets();
    });
  }

  void _calculateCategoryOffsets() {
    // Calculate and store the offset for each category
    double offset = 0;
    for (var category in placeMenu.categories) {
      _categoryOffsets[category] = offset;

      // Add header height
      offset += 56; // Header height

      // Add items height
      final itemsInCategory =
          placeMenu.menuItems.where((item) => item.category == category).length;
      offset += itemsInCategory * 100; // Assuming each item is 100 pixels tall
    }
  }

  @override
  void dispose() {
    _menuScrollController.removeListener(_onScroll);
    _itemPositionsListener.itemPositions.removeListener(_onItemPositionsChange);
    _menuScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pixels = _menuScrollController.position.pixels;

    // Determine which category is currently most visible
    String? currentCategory;
    double smallestDifference = double.infinity;

    for (var entry in _categoryOffsets.entries) {
      final difference = (pixels - entry.value).abs();
      if (difference < smallestDifference) {
        smallestDifference = difference;
        currentCategory = entry.key;
      }
    }

    if (currentCategory != null) {
      final newIndex = placeMenu.categories.indexOf(currentCategory);
      if (newIndex != _selectedIndex) {
        setState(() {
          _selectedIndex = newIndex;
        });

        // Only scroll the tab if we're actually scrolling (not when tapping)
        if ((pixels - _lastPixels).abs() > 1) {
          _tabScrollController.scrollTo(
            index: newIndex,
            duration: const Duration(milliseconds: 300),
            alignment: 0.5,
          );
        }
      }
    }

    _lastPixels = pixels;
  }

  void _onItemPositionsChange() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // Find the item closest to the middle of the viewport
    final middle = positions.first;
    final newIndex = middle.index;

    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  void _scrollToCategory(int index) {
    final category = placeMenu.categories[index];
    final offset = _categoryOffsets[category] ?? 0;

    // Scroll main content
    _menuScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Scroll tabs
    _tabScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 300),
      alignment: 0.5,
    );
  }

  // Optional: Add this helper method for smoother scrolling
  double _getScrollOffset(int index) {
    final viewportHeight = MediaQuery.of(context).size.height;
    final itemHeight = 100.0; // Assuming each item is 100 pixels tall
    return index * itemHeight - (viewportHeight - itemHeight) / 2;
  }

  PlaceMenu placeMenu = PlaceMenu(menuItems: [
    MenuItem(
      id: 5,
      placeId: 2,
      imageUrl:
          'https://ounjigiydhimruivuxjv.supabase.co/storage/v1/object/public/uploads/Diavola%20Pizza.jpg',
      price: 1400,
      name: 'Diavola',
      description: 'Tomato, mozzarella, nduja',
      category: 'Pizza',
      vat: 21,
      emoji: null,
      orderId: 0,
    ),
    MenuItem(
      id: 6,
      placeId: 2,
      imageUrl:
          'https://ounjigiydhimruivuxjv.supabase.co/storage/v1/object/public/uploads/Margherita%20Pizza.jpg',
      price: 1100,
      name: 'Margarita',
      description: 'Tomato, mozzarella, parmigiano',
      category: 'Pizza',
      vat: 21,
      emoji: null,
      orderId: 1,
    ),
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
      id: 8,
      placeId: 2,
      imageUrl:
          'https://ounjigiydhimruivuxjv.supabase.co/storage/v1/object/public/uploads/San%20Pellegrino%20Bottle.jpeg',
      price: 250,
      name: 'San Pellegrino',
      description: 'Sparkling water',
      category: 'Drinks',
      vat: 6,
      emoji: null,
      orderId: 3,
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Column(
          children: [
            const ChatHeader(
              imageUrl:
                  'https://plus.unsplash.com/premium_photo-1661883237884-263e8de8869b?q=80&w=2689&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              placeName: 'Fat Duck',
              placeDescription: 'Broadwalk, London',
            ),
          
            CategoryScroll(
              categories: placeMenu.categories,
              itemScrollController: _tabScrollController,
              itemPositionsListener: _itemPositionsListener,
              onSelected: _scrollToCategory,
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
                          pinned: true,
                          delegate: _StickyHeaderDelegate(
                            child: Container(
                              color: CupertinoColors.systemBackground
                                  .withOpacity(0.95),
                              padding: const EdgeInsets.all(16),
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
                              return MenuListItem(menuItem: items[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({
    required this.child,
    this.height = 56.0,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return true;
  }
}
