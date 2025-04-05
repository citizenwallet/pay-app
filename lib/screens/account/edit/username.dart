import 'package:dart_debouncer/dart_debouncer.dart';
import 'package:flutter/cupertino.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/formatters.dart';
import 'package:pay_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

class Username extends StatefulWidget {
  final String? username;

  const Username({super.key, this.username});

  @override
  State<Username> createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  final UsernameFormatter usernameFormatter = UsernameFormatter();
  final TextEditingController _usernameController = TextEditingController();

  late ProfileState _profileState;

  final Debouncer _debouncer =
      Debouncer(timerDuration: const Duration(milliseconds: 300));

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _usernameController.text = widget.username ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileState = context.read<ProfileState>();
    });
  }

  @override
  void didUpdateWidget(Username oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.username != oldWidget.username) {
      _usernameController.text = widget.username ?? '';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void handleUsernameChange(String username) {
    if (username == widget.username || username.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _debouncer.resetDebounce(() async {
      await _profileState.checkUsernameTaken(username);
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final usernameTaken = context.select((ProfileState p) => p.usernameTaken);
    print('usernameTaken: $usernameTaken');

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
          onChanged: handleUsernameChange,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: _isLoading
                ? CupertinoActivityIndicator(
                    color: textMutedColor,
                  )
                : Icon(
                    CupertinoIcons.at,
                    color: textMutedColor,
                  ),
          ),
          isError: usernameTaken,
          errorText: 'Username already taken',
        ),
      ],
    );
  }
}
