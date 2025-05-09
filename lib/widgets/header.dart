import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/blurry_child.dart';

class Header extends StatefulWidget {
  final String? title;
  final Color? titleColor;
  final double fontSize;
  final TextAlign? textAlign;
  final Widget? titleWidget;
  final String? subTitle;
  final Widget? subTitleWidget;
  final Widget? actionButton;
  final bool showBackButton;
  final bool transparent;
  final bool blur;
  final bool showBorder;
  final Color? color;
  final double safePadding;

  const Header({
    super.key,
    this.title,
    this.titleColor,
    this.fontSize = 32,
    this.textAlign,
    this.titleWidget,
    this.subTitleWidget,
    this.subTitle,
    this.actionButton,
    this.showBackButton = false,
    this.transparent = false,
    this.blur = false,
    this.showBorder = false,
    this.color,
    this.safePadding = 0,
  });

  @override
  HeaderState createState() => HeaderState();
}

class HeaderState extends State<Header> {
  void handleDismiss(BuildContext context) {
    GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final headerContainer = Container(
      height: 60 + widget.safePadding,
      decoration: BoxDecoration(
        color: widget.transparent
            ? transparentColor
            : widget.color ?? backgroundColor,
        border: widget.showBorder
            ? Border(
                bottom: BorderSide(color: dividerColor),
              )
            : null,
      ),
      padding: EdgeInsets.fromLTRB(15, widget.safePadding, 15, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.showBackButton)
                CupertinoButton(
                  padding: const EdgeInsets.all(5),
                  onPressed: () => handleDismiss(context),
                  child: const Icon(
                    CupertinoIcons.back,
                  ),
                ),
              if (widget.titleWidget == null && widget.title != null)
                Expanded(
                  child: Text(
                    widget.title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: widget.textAlign,
                    style: TextStyle(
                      color: widget.titleColor,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Expanded(
              //   child: Row(
              //     children: [
              //       Flexible(
              //         child: FittedBox(
              //           fit: BoxFit.fitWidth,
              //           child: Text(
              //             widget.title!,
              //             maxLines: 1,
              //             overflow: TextOverflow.ellipsis,
              //             textAlign: widget.textAlign,
              //             style: TextStyle(
              //               fontSize: widget.fontSize,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              if (widget.titleWidget != null)
                Expanded(child: widget.titleWidget!),
              if (widget.actionButton != null)
                Container(
                  height: 60.0,
                  constraints: const BoxConstraints(
                    minWidth: 60,
                  ),
                  child: Center(
                    child: widget.actionButton,
                  ),
                ),
            ],
          ),
          if (widget.subTitleWidget != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 20),
                child: widget.subTitleWidget,
              ),
            ),
          if (widget.subTitle != null && widget.subTitle!.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 20),
                child: Text(
                  widget.subTitle ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: textMutedColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (!widget.blur) {
      return headerContainer;
    }

    return BlurryChild(child: headerContainer);
  }
}
