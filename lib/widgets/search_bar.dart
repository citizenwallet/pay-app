import 'package:flutter/cupertino.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String placeholder;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool searching;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.placeholder = '',
    this.onTap,
    this.autofocus = false,
    this.searching = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    final defaultPlaceholderStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFFB7ADC4),
    );

    final defaultTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1D1D1D),
    );

    final defaultBorderRadius = BorderRadius.circular(100);

    final EdgeInsetsGeometry defaultPadding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12);

    final BoxDecoration defaultDecoration = BoxDecoration(
      border: Border.all(
        color: theme.primaryColor,
        width: 2,
      ),
      borderRadius: defaultBorderRadius,
      color: const Color(0xFFF7F7F8),
    );

    return CupertinoSearchTextField(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      placeholderStyle: defaultPlaceholderStyle,
      decoration: defaultDecoration,
      padding: defaultPadding,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      autofocus: autofocus,
      suffixInsets: EdgeInsets.only(right: 16),
      suffixIcon: searching
          ? const Icon(
              CupertinoIcons.hourglass_bottomhalf_fill,
              color: Color(0xFF4D4D4D),
            )
          : const Icon(
              CupertinoIcons.search,
              color: Color(0xFF4D4D4D),
            ),
      suffixMode: OverlayVisibilityMode.always,
      prefixIcon: const Icon(
        CupertinoIcons.search,
        color: Color(0xFF4D4D4D),
        size: 0,
      ),
      prefixInsets: EdgeInsets.only(left: 2),
      style: defaultTextStyle,
    );
  }
}
