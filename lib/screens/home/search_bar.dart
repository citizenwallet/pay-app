import 'package:flutter/cupertino.dart';
import 'package:pay_app/widgets/text_field.dart';

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
    final theme = CupertinoTheme.of(context);

    return Container(
      height: 74,
      color: theme.barBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomTextField(
        controller: controller,
        focusNode: focusNode,
        placeholder: 'Search for people or places',
        suffix: Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(
            CupertinoIcons.search,
            color: theme.primaryColor,
          ),
        ),
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
