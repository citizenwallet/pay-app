import 'package:flutter/cupertino.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

class Description extends StatefulWidget {
  final String? description;
  final Function() onFocused;

  const Description({
    super.key,
    this.description,
    required this.onFocused,
  });

  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _descriptionLength = 0;

  late ProfileState _profileState;

  @override
  void initState() {
    super.initState();
    _descriptionLength = _descriptionController.text.length;
    _descriptionController.addListener(_updateCharacterCount);
    _focusNode.addListener(_handleFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _descriptionController.text = widget.description ?? '';
      _profileState = context.read<ProfileState>();
    });
  }

  @override
  void didUpdateWidget(Description oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.description != oldWidget.description) {
      _descriptionController.text = widget.description ?? '';
    }
  }

  void _updateCharacterCount() {
    setState(() {
      _descriptionLength = _descriptionController.text.length;
    });
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      widget.onFocused();
    }
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateCharacterCount);
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void handleDescriptionChange(String description) {
    _profileState.setDescription(description);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;

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
        CustomTextField(
          controller: _descriptionController,
          textInputAction: TextInputAction.newline,
          placeholder: 'Description',
          onChanged: handleDescriptionChange,
          focusNode: _focusNode,
          minLines: 4,
          maxLines: 8,
          maxLength: 200,
          autocorrect: true,
          enableSuggestions: true,
          textCapitalization: TextCapitalization.sentences,
          textAlignVertical: TextAlignVertical.top,
          decoration: BoxDecoration(
            border: Border.all(
              color: primaryColor,
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
                color: textMutedColor,
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
