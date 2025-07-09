import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/state/card.dart';
import 'package:pay_app/theme/card_colors.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/modals/dismissible_modal_popup.dart';
import 'package:provider/provider.dart';

class CardModal extends StatefulWidget {
  final String? project;

  const CardModal({super.key, this.project});

  @override
  State<CardModal> createState() => _CardModalState();
}

class _CardModalState extends State<CardModal> {
  late CardState _cardState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardState = context.read<CardState>();
      onLoad();
    });
  }

  void onLoad() async {
    await _cardState.init();
    _cardState.fetchCardDetails();
  }

  void handleViewCard() async {
    final success = await _cardState.viewCard();

    if (!success) {
      return;
    }

    if (!mounted) {
      return;
    }

    handleClose(context);
  }

  void handleClose(BuildContext context) {
    final navigator = GoRouter.of(context);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return DismissibleModalPopup(
      modalKey: 'card_modal',
      maxHeight: 400,
      paddingSides: 16,
      paddingTopBottom: 16,
      topRadius: 12,
      onDismissed: (dir) {
        handleClose(context);
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCard(context),
          const SizedBox(height: 24),
          _buildMessage(),
          const SizedBox(height: 24),
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final balance = context.select<CardState, double>((state) => state.balance);
    final profile =
        context.select<CardState, ProfileV1?>((state) => state.profile);

    final cardColor = projectCardColor(widget.project);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.white),
        boxShadow: [
          BoxShadow(
            color: blackColor.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  profile?.username != null
                      ? '@${profile?.username}'
                      : 'anonymous',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Image.asset(
                  'assets/icons/nfc.png',
                  color: CupertinoColors.white,
                  width: 24,
                  height: 24,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(8),
                  minSize: 0,
                  onPressed: handleViewCard,
                  child: SizedBox(
                    width: 70,
                    height: 28,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.search,
                          color: cardColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'view',
                          style: TextStyle(
                            color: cardColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CoinLogo(size: 20),
                        const SizedBox(width: 4),
                        Text(
                          balance.toStringAsFixed(2),
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 20,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Center(
      child: Text(
        'Card support coming soon',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: CupertinoColors.systemGrey5,
      borderRadius: BorderRadius.circular(8),
      onPressed: () => handleClose(context),
      child: Text(
        'Close',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
