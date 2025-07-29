import 'package:flutter/cupertino.dart';
import 'package:pay_app/widgets/search_bar.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearch;
  final Color? backgroundColor;

  final bool isFocused;
  const SearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    this.isFocused = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57,
      decoration: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.systemBackground,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: CustomSearchBar(
        controller: controller,
        focusNode: focusNode,
        placeholder: 'Search for people or places',
        onChanged: onSearch,
        isFocused: isFocused,
      ),
    );
  }
}
