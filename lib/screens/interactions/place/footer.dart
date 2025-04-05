import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/models/place.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/utils/formatters.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/text_field.dart';
import 'package:pay_app/widgets/wide_button.dart';
import 'package:provider/provider.dart';

class Footer extends StatefulWidget {
  final String myAddress;
  final String slug;
  final Function(double, String?) onSend;
  final Function() onTopUpPressed;
  final Function() onMenuPressed;
  final FocusNode amountFocusNode;
  final FocusNode messageFocusNode;
  final Place? place;
  final Display? display;

  const Footer({
    super.key,
    required this.myAddress,
    required this.slug,
    required this.onSend,
    required this.onTopUpPressed,
    required this.onMenuPressed,
    required this.amountFocusNode,
    required this.messageFocusNode,
    this.place,
    this.display,
  });

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _showAmountField = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _toggleField() {
    setState(() {
      _showAmountField = !_showAmountField;
      if (_showAmountField) {
        widget.amountFocusNode.requestFocus();
      } else {
        widget.messageFocusNode.requestFocus();
      }
    });
  }

  void handleSend(double amount, String? message) {
    widget.amountFocusNode.unfocus();
    widget.messageFocusNode.unfocus();

    widget.onSend(amount, message);
  }

  // void _onMenuPressed() {
  //   final navigator = GoRouter.of(context);

  //   navigator.push('/${widget.myAddress}/place/${widget.slug}/menu');
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
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
          if (widget.display == null)
            SizedBox(
              height: 50,
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
          if (widget.display == Display.menu ||
              widget.display == Display.amountAndMenu)
            WideButton(
              onPressed: widget.onMenuPressed,
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          if (widget.display == Display.amountAndMenu) SizedBox(height: 10),
          if (widget.display == Display.amount ||
              widget.display == Display.amountAndMenu)
            Row(
              children: [
                Expanded(
                  child: _showAmountField
                      ? AmountFieldWithMessageToggle(
                          onToggle: _toggleField,
                          amountController: _amountController,
                          focusNode: widget.amountFocusNode,
                        )
                      : MessageFieldWithAmountToggle(
                          onToggle: _toggleField,
                          messageController: _messageController,
                          focusNode: widget.messageFocusNode,
                        ),
                ),
                SizedBox(width: 10),
                SendButton(
                  amountController: _amountController,
                  messageController: _messageController,
                  onTap: () => handleSend(
                    double.parse(_amountController.text),
                    _messageController.text,
                  ),
                ),
              ],
            ),
          SizedBox(height: 10),
          CurrentBalance(onTopUpPressed: widget.onTopUpPressed),
        ],
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final VoidCallback onTap;
  final TextEditingController amountController;
  final TextEditingController messageController;

  const SendButton({
    super.key,
    required this.onTap,
    required this.amountController,
    required this.messageController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        onTap();
        amountController.clear();
        messageController.clear();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.primaryColor,
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
  final VoidCallback onToggle;
  final AmountFormatter amountFormatter = AmountFormatter();
  final bool isSending;

  AmountFieldWithMessageToggle({
    super.key,
    required this.onToggle,
    required this.amountController,
    required this.focusNode,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: amountController,
            enabled: !isSending,
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
            // TODO: onChanged
          ),
        ),
        SizedBox(width: 10),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onToggle,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.text_bubble,
                color: theme.primaryColor,
                size: 35,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class MessageFieldWithAmountToggle extends StatelessWidget {
  final VoidCallback onToggle;
  final TextEditingController messageController;
  final FocusNode focusNode;
  final bool isSending;

  MessageFieldWithAmountToggle({
    super.key,
    required this.onToggle,
    required this.messageController,
    required this.focusNode,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
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
            // TODO: onChanged
          ),
        ),
        SizedBox(width: 10),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onToggle,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.back,
                color: theme.primaryColor,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class CurrentBalance extends StatelessWidget {
  final Function() onTopUpPressed;

  const CurrentBalance({
    super.key,
    required this.onTopUpPressed,
  });

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<WalletState>().balance;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Current balance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF000000),
            ),
          ),
          SizedBox(width: 10),
          CoinLogo(size: 22),
          SizedBox(width: 4),
          Text(
            balance.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF171717),
            ),
          ),
          SizedBox(width: 10),
          TopUpButton(onTopUpPressed: onTopUpPressed),
        ],
      ),
    );
  }
}

class TopUpButton extends StatelessWidget {
  final Function() onTopUpPressed;

  const TopUpButton({
    super.key,
    required this.onTopUpPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: theme.primaryColor,
      borderRadius: BorderRadius.circular(8),
      minSize: 0,
      onPressed: onTopUpPressed,
      child: SizedBox(
        width: 70,
        height: 28,
        child: Center(
          child: Text(
            '+ top up',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
