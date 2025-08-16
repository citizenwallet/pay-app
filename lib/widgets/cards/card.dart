import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/profile_circle.dart';
import 'package:pay_app/widgets/text_input_modal.dart';
import 'package:pay_app/l10n/app_localizations.dart';

enum TapDepth {
  none,
  active,
  tapping,
}

class Card extends StatefulWidget {
  final String uid;
  final double width;
  final Color color;
  final EdgeInsets? margin;
  final ProfileV1? profile;
  final String usernamePrefix;
  final String? logo;
  final String? balance;
  final IconData? icon;
  final VoidCallback? onTopUpPressed;
  final Future<void> Function()? onCardNameTapped;
  final Future<void> Function(String)? onCardNameUpdated;
  final Future<void> Function(String)? onCardPressed;
  final Future<void> Function()? onCardBalanceTapped;

  const Card({
    super.key,
    required this.uid,
    this.width = 200,
    required this.color,
    this.margin,
    this.profile,
    this.usernamePrefix = '@',
    this.logo,
    this.balance,
    this.icon,
    this.onTopUpPressed,
    this.onCardNameTapped,
    this.onCardNameUpdated,
    this.onCardPressed,
    this.onCardBalanceTapped,
  });

  @override
  State<Card> createState() => _CardState();
}

class _CardState extends State<Card> {
  TapDepth tapDepth = TapDepth.none;

  FocusNode nameFocusNode = FocusNode();
  ScrollController nameScrollController = ScrollController();

  void handleCardTap() async {
    if (widget.onCardPressed == null) {
      return;
    }

    await widget.onCardPressed?.call(widget.uid);

    setState(() {
      tapDepth = TapDepth.none;
    });
  }

  void handleTapUp(TapUpDetails details) {
    if (widget.onCardPressed == null) {
      return;
    }

    setState(() {
      tapDepth = TapDepth.tapping;
    });
  }

  void handleTapDown(TapDownDetails details) {
    if (widget.onCardPressed == null) {
      return;
    }

    setState(() {
      tapDepth = TapDepth.active;
    });
  }

  void handleNameTap() async {
    if (widget.onCardNameTapped != null) {
      HapticFeedback.heavyImpact();

      await widget.onCardNameTapped?.call();
      return;
    }

    if (widget.onCardNameUpdated == null) {
      return;
    }

    HapticFeedback.lightImpact();

    final newName = await showCupertinoModalPopup<String?>(
      context: context,
      barrierDismissible: true,
      builder: (modalContext) => TextInputModal(
        title: AppLocalizations.of(context)!.edit,
        placeholder: AppLocalizations.of(context)!.enterText,
        initialValue: widget.profile?.name ?? '',
      ),
    );

    if (newName == null || newName.isEmpty) {
      return;
    }

    if (newName == widget.profile?.name) {
      return;
    }

    HapticFeedback.heavyImpact();

    await widget.onCardNameUpdated?.call(newName);
  }

  void handleBalanceTap() async {
    if (widget.onCardBalanceTapped == null) {
      return;
    }

    HapticFeedback.lightImpact();

    await widget.onCardBalanceTapped?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Standard credit card proportions: 1.586 (width:height ratio)
    double cardWidth = switch (tapDepth) {
      TapDepth.tapping => widget.width * 1.1,
      TapDepth.active => widget.width * 1.05,
      _ => widget.width,
    };

    double cardHeight = cardWidth / 1.586;

    final balanceTappable = widget.onCardBalanceTapped != null;

    final container = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      width: cardWidth,
      height: cardHeight,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.white.withAlpha(160)),
        boxShadow: [
          BoxShadow(
            color: blackColor.withAlpha(60),
            blurRadius: 10,
            offset: const Offset(0, 6),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ProfileCircle(
                            size: 24,
                            imageUrl: widget.profile?.imageSmall,
                            borderColor: whiteColor,
                            borderWidth: 2,
                          ),
                          const SizedBox(width: 4),
                          (widget.onCardNameUpdated != null ||
                                  widget.onCardNameTapped != null)
                              ? GestureDetector(
                                  onTap: handleNameTap,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: whiteColor.withAlpha(10),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: whiteColor.withAlpha(100),
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          widget.profile != null
                                              ? widget.profile!.name
                                              : 'anonymous',
                                          style: const TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          CupertinoIcons.pen,
                                          color: whiteColor,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Text(
                                  widget.profile != null
                                      ? widget.profile!.name
                                      : 'anonymous',
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ],
                      ),
                      if (widget.profile != null) const SizedBox(height: 4),
                      if (widget.profile != null)
                        Text(
                          '${widget.usernamePrefix}${widget.profile!.username}',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                widget.icon != null
                    ? Icon(
                        widget.icon,
                        color: CupertinoColors.white,
                        size: 24,
                      )
                    : Image.asset(
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
                if (widget.onTopUpPressed != null)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(8),
                    minimumSize: Size.zero,
                    onPressed: widget.onTopUpPressed,
                    child: SizedBox(
                      width: 80,
                      height: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.plus,
                            color: widget.color,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.addFunds,
                            style: TextStyle(
                              color: widget.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (widget.balance != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: balanceTappable ? handleBalanceTap : null,
                        child: Container(
                          decoration: balanceTappable
                              ? BoxDecoration(
                                  color: whiteColor.withAlpha(10),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: whiteColor.withAlpha(100),
                                    width: 1,
                                  ),
                                )
                              : null,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CoinLogo(size: 20, logo: widget.logo),
                              const SizedBox(width: 4),
                              Text(
                                widget.balance!,
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 20,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (balanceTappable) const SizedBox(width: 4),
                              if (balanceTappable)
                                Icon(
                                  CupertinoIcons.chevron_down,
                                  color: CupertinoColors.white,
                                  size: 14,
                                ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (widget.onCardPressed == null) {
      return container;
    }

    return GestureDetector(
      onTap: handleCardTap,
      onTapDown: handleTapDown,
      onTapUp: handleTapUp,
      child: container,
    );
  }
}
