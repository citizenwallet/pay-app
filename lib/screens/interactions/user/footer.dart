import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pay_app/state/transactions_with_user/transactions_with_user.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/formatters.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/text_field.dart';
import 'package:pay_app/widgets/wide_button.dart';
import 'package:provider/provider.dart';

class Footer extends StatefulWidget {
  final Function(double, String?) onSend;
  final Function() onTopUpPressed;
  final FocusNode amountFocusNode;
  final FocusNode messageFocusNode;
  final String? phoneNumber;

  const Footer({
    super.key,
    required this.onSend,
    required this.onTopUpPressed,
    required this.amountFocusNode,
    required this.messageFocusNode,
    this.phoneNumber,
  });

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _showAmountField = true;

  late TransactionsWithUserState _transactionsWithUserState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.amountFocusNode.requestFocus();
      _transactionsWithUserState = context.read<TransactionsWithUserState>();
    });
  }

  Future<void> sendTransaction() async {
    HapticFeedback.heavyImpact();

    widget.amountFocusNode.unfocus();
    widget.messageFocusNode.unfocus();

    _transactionsWithUserState.sendTransaction();
    _amountController.clear();
    _messageController.clear();
    setState(() {
      _showAmountField = true;
    });
  }

  void shareInviteLink(String phoneNumber) {
    _transactionsWithUserState.shareInviteLink(phoneNumber);
  }

  updateAmount(double amount) {
    _transactionsWithUserState.updateAmount(amount);
  }

  updateMessage(String message) {
    _transactionsWithUserState.updateMessage(message);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _toggleField() async {
    setState(() {
      _showAmountField = !_showAmountField;
      if (_showAmountField) {
        widget.amountFocusNode.requestFocus();
      } else {
        widget.messageFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final balance = context.watch<WalletState>().balance;

    final toSendAmount =
        context.watch<TransactionsWithUserState>().toSendAmount;

    final error = toSendAmount > balance;
    final disabled = toSendAmount == 0.0 || error;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFD9D9D9),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (widget.phoneNumber == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!_showAmountField) CoinLogo(size: 22),
                if (!_showAmountField) SizedBox(width: 4),
                if (!_showAmountField)
                  Text(
                    _amountController.value.text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color:
                          error ? CupertinoColors.systemRed : Color(0xFF171717),
                    ),
                  ),
                if (!_showAmountField)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: disabled ? null : _toggleField,
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
                  child: _showAmountField
                      ? AmountFieldWithMessageToggle(
                          disabled: disabled,
                          error: error,
                          amountController: _amountController,
                          focusNode: widget.amountFocusNode,
                          onChange: updateAmount,
                          onTopUpPressed: widget.onTopUpPressed,
                        )
                      : MessageFieldWithAmountToggle(
                          messageController: _messageController,
                          focusNode: widget.messageFocusNode,
                          onChange: updateMessage,
                        ),
                ),
                SizedBox(width: 10),
                SendButton(
                  disabled: disabled,
                  showingAmountField: _showAmountField,
                  onToggle: _toggleField,
                  onTap: sendTransaction,
                ),
              ],
            ),
          if (widget.phoneNumber != null)
            WideButton(
              child: Text(
                'Share invite link',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                ),
              ),
              onPressed: () => shareInviteLink(widget.phoneNumber!),
            ),
          if (widget.phoneNumber != null) SizedBox(height: 10),
        ],
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final bool showingAmountField;
  final bool disabled;

  const SendButton({
    super.key,
    required this.onTap,
    required this.onToggle,
    this.disabled = false,
    this.showingAmountField = true,
  });

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return SizedBox.shrink();
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
  final Function() onTopUpPressed;
  final bool isSending;
  final bool disabled;
  final bool error;

  AmountFieldWithMessageToggle({
    super.key,
    required this.amountController,
    required this.focusNode,
    required this.onChange,
    this.isSending = false,
    this.disabled = false,
    this.error = false,
    required this.onTopUpPressed,
  });

  @override
  Widget build(BuildContext context) {
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
                  child: CoinLogo(size: 33),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    onChange(0);
                    return;
                  }
                  onChange(double.tryParse(value) ?? 0);
                },
              ),
              if (error)
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
