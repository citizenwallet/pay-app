import 'package:flutter/cupertino.dart';

// TODO: https://www.youtube.com/watch?v=vM2dC8OCZoY

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      color: CupertinoColors.systemBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CupertinoTextField(
        focusNode: focusNode,
        controller: controller,
        placeholder: 'Search for people or places',
        placeholderStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFFB7ADC4),
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4338CA), width: 2),
          borderRadius: BorderRadius.circular(100),
        ),
        suffix: const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(
            CupertinoIcons.search,
            color: Color(0xFF4338CA),
          ),
        ),
      ),
    );
  }
}
