import 'package:flutter/cupertino.dart';
import 'package:pay_app/utils/formatters.dart';

class Name extends StatefulWidget {
  const Name({super.key});

  @override
  State<Name> createState() => _NameState();
}

class _NameState extends State<Name> {
  final TextEditingController _nameController = TextEditingController();
  final NameFormatter nameFormatter = NameFormatter();

  bool _hasError = true;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
          'Name',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 10),
        CupertinoTextField(
          controller: _nameController,
          maxLines: 1,
          maxLength: 50,
          placeholder: 'Enter your name',
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.next,
          inputFormatters: [nameFormatter],
          placeholderStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB7ADC4),
          ),
          padding: const EdgeInsets.all(16),
          decoration: _getDecoration(),
        ),
        if (_hasError) // Show error message conditionally
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Invalid name',
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
