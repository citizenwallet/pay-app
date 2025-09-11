import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/l10n/app_localizations.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/button.dart';
import 'package:pay_app/widgets/modals/dismissible_modal_popup.dart';

class ActionsModal extends StatefulWidget {
  const ActionsModal({
    super.key,
  });

  @override
  State<ActionsModal> createState() => _TokenModalState();
}

class _TokenModalState extends State<ActionsModal> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLoad();
    });
  }

  Future<void> onLoad() async {
    //
  }

  void handleAddCard(BuildContext context) {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();
    navigator.pop('add-card');
  }

  void handleSettings(BuildContext context) {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();
    navigator.pop('settings');
  }

  void handleClose(BuildContext context) {
    final navigator = GoRouter.of(context);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DismissibleModalPopup(
        modalKey: 'actions_modal',
        maxHeight: 240,
        paddingSides: 16,
        paddingTopBottom: 0,
        topRadius: 12,
        onDismissed: (dir) {
          handleClose(context);
        },
        child: _buildContent(
          context,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Button(
              text: AppLocalizations.of(context)!.addCard,
              labelColor: whiteColor,
              color: primaryColor,
              onPressed: () => handleAddCard(context),
              suffix: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Image.asset(
                  'assets/icons/nfc.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Button(
              text: AppLocalizations.of(context)!.settings,
              labelColor: whiteColor,
              color: primaryColor,
              onPressed: () => handleSettings(context),
              suffix: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  CupertinoIcons.settings,
                  color: whiteColor,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Button(
              text: AppLocalizations.of(context)!.close,
              labelColor: blackColor,
              color: neutralColor,
              onPressed: () => handleClose(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
