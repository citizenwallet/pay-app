import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/button.dart';
import 'package:pay_app/widgets/header.dart';
import 'package:pay_app/widgets/modals/dismissible_modal_popup.dart';

const List<String> emptyDetails = [];

class ConfirmModal extends StatelessWidget {
  final String? title;
  final List<String> details;
  final String? cancelText;
  final String? confirmText;
  final Color? confirmColor;
  final Color? labelColor;

  const ConfirmModal({
    super.key,
    this.title,
    this.details = emptyDetails,
    this.cancelText,
    this.confirmText,
    this.confirmColor,
    this.labelColor,
  });

  void handleDismiss(BuildContext context) {
    GoRouter.of(context).pop(false);
  }

  void handleConfirm(BuildContext context) {
    GoRouter.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return DismissibleModalPopup(
      modalKey: 'confirm-modal',
      maxHeight: 300,
      paddingSides: 10,
      onUpdate: (details) {
        if (details.direction == DismissDirection.down &&
            FocusManager.instance.primaryFocus?.hasFocus == true) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      onDismissed: (_) => handleDismiss(context),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: CupertinoPageScaffold(
          child: SafeArea(
            top: false,
            child: Flex(
              direction: Axis.vertical,
              children: [
                Header(
                  title: title,
                  color: whiteColor,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...details.map(
                        (d) => Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Button(
                            text: cancelText ?? 'Cancel',
                            minWidth: 140,
                            maxWidth: 140,
                            color: neutralColor,
                            onPressed: () => handleDismiss(context),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Button(
                            text: confirmText ?? 'Confirm',
                            minWidth: 140,
                            maxWidth: 140,
                            color: confirmColor ?? primaryColor,
                            labelColor: labelColor ?? whiteColor,
                            onPressed: () => handleConfirm(context),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
