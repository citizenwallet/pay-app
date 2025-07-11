import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/formatters.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/text_field.dart';

class TransactionInputRow extends StatelessWidget {
  final bool showAmountField;
  final TokenConfig? token;
  final Color? color;
  final TextEditingController amountController;
  final TextEditingController messageController;
  final FocusNode amountFocusNode;
  final FocusNode messageFocusNode;
  final Function(double)? onAmountChange;
  final Function(String)? onMessageChange;
  final VoidCallback onToggleField;
  final VoidCallback onSend;
  final bool loading;
  final bool disabled;
  final bool error;
  final Function()? onTopUpPressed;

  const TransactionInputRow({
    super.key,
    required this.showAmountField,
    this.token,
    this.color,
    required this.amountController,
    required this.messageController,
    required this.amountFocusNode,
    required this.messageFocusNode,
    this.onAmountChange,
    this.onMessageChange,
    required this.onToggleField,
    required this.onSend,
    this.loading = false,
    this.disabled = false,
    this.error = false,
    this.onTopUpPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final primaryColor = color ?? theme.primaryColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!showAmountField) CoinLogo(size: 22, logo: token?.logo),
        if (!showAmountField) SizedBox(width: 4),
        if (!showAmountField)
          Text(
            amountController.text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: error ? CupertinoColors.systemRed : Color(0xFF171717),
            ),
          ),
        if (!showAmountField)
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: disabled ? null : onToggleField,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.back,
                  color: disabled ? mutedColor : primaryColor,
                  size: 35,
                ),
              ),
            ),
          ),
        Expanded(
          child: showAmountField
              ? AmountFieldWithMessageToggle(
                  disabled: disabled || loading,
                  error: error,
                  logo: token?.logo,
                  amountController: amountController,
                  focusNode: amountFocusNode,
                  onChange: onAmountChange ?? (_) {},
                  onTopUpPressed: onTopUpPressed,
                )
              : MessageFieldWithAmountToggle(
                  messageController: messageController,
                  focusNode: messageFocusNode,
                  onChange: onMessageChange ?? (_) {},
                  isSending: loading,
                ),
        ),
        SizedBox(width: 10),
        SendButton(
          loading: loading,
          disabled: disabled,
          showingAmountField: showAmountField,
          onToggle: onToggleField,
          onTap: onSend,
        ),
      ],
    );
  }
}

class SendButton extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final bool showingAmountField;
  final bool loading;
  final bool disabled;

  const SendButton({
    super.key,
    required this.onTap,
    required this.onToggle,
    this.disabled = false,
    this.showingAmountField = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;

    if (disabled) {
      return SizedBox.shrink();
    }

    if (loading) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: disabled ? mutedColor : primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: CupertinoActivityIndicator(
            color: whiteColor,
          ),
        ),
      );
    }

    if (showingAmountField) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: disabled ? null : onToggle,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              CupertinoIcons.forward,
              color: disabled ? mutedColor : primaryColor,
              size: 35,
            ),
          ),
        ),
      );
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: disabled ? null : onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: disabled ? mutedColor : primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.arrow_up,
            color: CupertinoColors.white,
            size: 35,
          ),
        ),
      ),
    );
  }
}

class AmountFieldWithMessageToggle extends StatelessWidget {
  final TextEditingController amountController;
  final FocusNode focusNode;
  final AmountFormatter amountFormatter = AmountFormatter();
  final Function(double) onChange;
  final Function()? onTopUpPressed;
  final bool isSending;
  final bool disabled;
  final bool error;
  final String? logo;

  AmountFieldWithMessageToggle({
    super.key,
    required this.amountController,
    required this.focusNode,
    required this.onChange,
    this.isSending = false,
    this.disabled = false,
    this.error = false,
    this.logo,
    this.onTopUpPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;

    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              CustomTextField(
                controller: amountController,
                enabled: !isSending,
                isError: error,
                placeholder: 'Enter amount',
                placeholderStyle: TextStyle(
                  color: Color(0xFFB7ADC4),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 12.0),
                maxLines: 1,
                maxLength: 25,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: [amountFormatter],
                focusNode: focusNode,
                textInputAction: TextInputAction.done,
                prefix: Padding(
                  padding: EdgeInsets.only(left: 11.0),
                  child: CoinLogo(size: 33, logo: logo),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    onChange(0);
                    return;
                  }
                  onChange(double.tryParse(value.replaceAll(',', '.')) ?? 0);
                },
              ),
              if (error && onTopUpPressed != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onTopUpPressed,
                      child: Text(
                        '+ top up',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}

class MessageFieldWithAmountToggle extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final Function(String) onChange;
  final bool isSending;

  const MessageFieldWithAmountToggle({
    super.key,
    required this.messageController,
    required this.focusNode,
    required this.onChange,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: messageController,
            enabled: !isSending,
            placeholder: 'Add a message',
            placeholderStyle: TextStyle(
              color: Color(0xFFB7ADC4),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            textAlignVertical: TextAlignVertical.top,
            focusNode: focusNode,
            autocorrect: true,
            enableSuggestions: true,
            keyboardType: TextInputType.multiline,
            onChanged: onChange,
          ),
        ),
      ],
    );
  }
}
