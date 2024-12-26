import 'package:flutter/cupertino.dart';

import 'package:pay_app/utils/formatters.dart';

class Username extends StatefulWidget {
  const Username({super.key});

  @override
  State<Username> createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  final UsernameFormatter usernameFormatter = UsernameFormatter();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  bool _hasError = false;

  BoxDecoration _getDecoration() {
    return BoxDecoration(
      border: Border.all(
        // Change border color based on error state
        color: _hasError ? CupertinoColors.systemRed : const Color(0xFF3431C4),
        width: 2,
      ),
      borderRadius: BorderRadius.circular(100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 10),
        CupertinoTextField(
          controller: _usernameController,
          maxLines: 1,
          maxLength: 30,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.next,
          inputFormatters: [usernameFormatter],
          placeholder: 'Enter your username',
          placeholderStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB7ADC4),
          ),
          padding: const EdgeInsets.all(16),
          decoration: _getDecoration(),
          prefix: const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(
              CupertinoIcons.at,
              color: Color(0xFF3431C4),
            ),
          ),
        ),
        if (_hasError) // Show error message conditionally
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Invalid username',
              style: TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
