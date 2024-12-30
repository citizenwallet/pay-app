import 'package:flutter/cupertino.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CategoryScroll extends StatefulWidget {
  final List<String> categories;
  final ItemScrollController tabScrollController;
  final ItemPositionsListener tabPositionsListener;
  final ScrollOffsetController tabScrollOffsetController;

  final int selectedIndex;
  final Function(int) onSelected;

  const CategoryScroll({
    super.key,
    required this.categories,
    required this.tabScrollController,
    required this.tabPositionsListener,
    required this.tabScrollOffsetController,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<CategoryScroll> createState() => _CategoryScrollState();
}

class _CategoryScrollState extends State<CategoryScroll> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 1,
          ),
        ),
      ),
      child: ScrollablePositionedList.builder(
        itemCount: widget.categories.length,
        scrollDirection: Axis.horizontal,
        itemScrollController: widget.tabScrollController,
        itemPositionsListener: widget.tabPositionsListener,
        scrollOffsetController: widget.tabScrollOffsetController,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final isSelected = index == widget.selectedIndex;
          return GestureDetector(
            onTap: () => widget.onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF171717)
                      : const Color(0xFFD9D9D9),
                ),
                borderRadius: BorderRadius.circular(20),
                color: isSelected
                    ? const Color(0xFF171717)
                    : const Color(0xFFD9D9D9),
              ),
              child: Text(
                widget.categories[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF171717),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
