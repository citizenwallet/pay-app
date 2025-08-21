import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/l10n/app_localizations.dart';
import 'package:pay_app/models/card.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/button.dart';
import 'package:pay_app/widgets/modals/dismissible_modal_popup.dart';
import 'package:pay_app/widgets/cards/card.dart' as cardWidget;
import 'package:provider/provider.dart';

class CardActionsModal extends StatefulWidget {
  final CardInfo card;

  const CardActionsModal({
    super.key,
    required this.card,
  });

  @override
  State<CardActionsModal> createState() => _TokenModalState();
}

class _TokenModalState extends State<CardActionsModal> {
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

  void handleReleaseCard(BuildContext context) {
    final navigator = GoRouter.of(context);
    HapticFeedback.heavyImpact();
    navigator.pop('release');
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
        maxHeight: 440,
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
    final width = MediaQuery.of(context).size.width;

    final color = context.select<AppState, Color>(
      (state) => state.currentTokenConfig.color ?? primaryColor,
    );

    final tokenConfig = context.select<AppState, TokenConfig>(
      (state) => state.currentTokenConfig,
    );

    double cardWidth = (width < 360 ? 360 : width) * 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              key: Key(widget.card.uid),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: cardWidget.Card(
                width: cardWidth,
                uid: widget.card.uid,
                color: color,
                profile: widget.card.profile,
                usernamePrefix: '#',
                logo: tokenConfig.logo,
                balance: widget.card.balance,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Button(
              text: AppLocalizations.of(context)!.releaseCard,
              labelColor: whiteColor,
              color: dangerColor,
              onPressed: () => handleReleaseCard(context),
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
