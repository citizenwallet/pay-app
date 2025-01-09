import 'package:flutter/cupertino.dart';
import 'package:pay_app/utils/formatters.dart';
import 'package:pay_app/widgets/text_field.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    
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
        CustomTextField(
          controller: _usernameController,
          textInputAction: TextInputAction.next,
          inputFormatters: [usernameFormatter],
          placeholder: 'Enter your username',
          prefix: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Icon(
              CupertinoIcons.at,
              color: Color(0xFF4D4D4D),
            ),
          ),
        ),
      ],
    );
  }
}
