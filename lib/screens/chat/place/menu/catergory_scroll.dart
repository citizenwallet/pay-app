import 'package:flutter/cupertino.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CategoryScroll extends StatefulWidget {
  final List<String> categories;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final int selectedIndex;
  final Function(int) onSelected;

  const CategoryScroll({
    super.key,
    required this.categories,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<CategoryScroll> createState() => _CategoryScrollState();
}

class _CategoryScrollState extends State<CategoryScroll> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ScrollablePositionedList.builder(
        itemCount: widget.categories.length,
        scrollDirection: Axis.horizontal,
        itemScrollController: widget.itemScrollController,
        itemPositionsListener: widget.itemPositionsListener,
        itemBuilder: (context, index) {
          final isSelected = index == widget.selectedIndex;
          return GestureDetector(
            onTap:  widget.onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.separator,
                    width: isSelected ? 2 : 1,
                  ),
                ),
              ),
              child: Text(
                widget.categories[index],
                style: TextStyle(
                  color: isSelected
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.label,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
