import 'package:flutter/cupertino.dart';

class Description extends StatefulWidget {
  const Description({super.key});

  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  final TextEditingController _descriptionController = TextEditingController();
  int _descriptionLength = 0;

  @override
  void initState() {
    super.initState();
    _descriptionLength = _descriptionController.text.length;
    _descriptionController.addListener(_updateCharacterCount);
  }

  void _updateCharacterCount() {
    setState(() {
      _descriptionLength = _descriptionController.text.length;
    });
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateCharacterCount);
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 10),
        CupertinoTextField(
          controller: _descriptionController,
          minLines: 4,
          maxLines: 8,
          maxLength: 200,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.newline,
          textAlignVertical: TextAlignVertical.top,
          placeholder: 'Description',
          placeholderStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB7ADC4),
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF3431C4),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$_descriptionLength / 200',
              style: TextStyle(
                color: Color(0xFFB7ADC4),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
