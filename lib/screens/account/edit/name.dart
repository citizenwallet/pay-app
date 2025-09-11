import 'package:flutter/cupertino.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/utils/formatters.dart';
import 'package:pay_app/l10n/app_localizations.dart';
import 'package:pay_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

class Name extends StatefulWidget {
  final String? name;

  const Name({super.key, this.name});

  @override
  State<Name> createState() => _NameState();
}

class _NameState extends State<Name> {
  final TextEditingController _nameController = TextEditingController();
  final NameFormatter nameFormatter = NameFormatter();

  late ProfileState _profileState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileState = context.read<ProfileState>();
      _nameController.text = widget.name ?? '';
    });
  }

  @override
  void didUpdateWidget(Name oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.name != oldWidget.name) {
      _nameController.text = widget.name ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _profileState.resetName();
    super.dispose();
  }

  void handleNameChange(String name) {
    _profileState.setName(name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.name,
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
          placeholder: AppLocalizations.of(context)!.enterYourName,
          onChanged: handleNameChange,
        ),
      ],
    );
  }
}
