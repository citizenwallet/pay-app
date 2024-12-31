import 'package:flutter/cupertino.dart';
import 'package:pay_app/utils/formatters.dart';
import 'package:pay_app/widgets/text_field.dart';

class Name extends StatefulWidget {
  const Name({super.key});

  @override
  State<Name> createState() => _NameState();
}

class _NameState extends State<Name> {
  final TextEditingController _nameController = TextEditingController();
  final NameFormatter nameFormatter = NameFormatter();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
        CustomTextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          inputFormatters: [nameFormatter],
          placeholder: 'Enter your name',
        ),
      ],
    );
  }
}
