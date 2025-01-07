import 'package:flutter/cupertino.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/text_field.dart';
class Footer extends StatefulWidget {
  final Function(double, String?) onSend;
  final FocusNode amountFocusNode;
  final FocusNode messageFocusNode;

  const Footer({
    super.key,
    required this.onSend,
    required this.amountFocusNode,
    required this.messageFocusNode,
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
                onTap: () => widget.onSend(
                  double.parse(_amountController.text),
                  _messageController.text,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          CurrentBalance(),
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

  const AmountFieldWithMessageToggle({
    super.key,
    required this.onToggle,
    required this.amountController,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            focusNode: focusNode,
            controller: amountController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            placeholder: 'Enter amount',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: CoinLogo(size: 33),
            ),
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

  const MessageFieldWithAmountToggle({
    super.key,
    required this.onToggle,
    required this.messageController,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            focusNode: focusNode,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.sentences,
            controller: messageController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            placeholder: 'Add a message',
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
  const CurrentBalance({super.key});

  @override
  Widget build(BuildContext context) {
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
            '12.00',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF171717),
            ),
          ),
          SizedBox(width: 10),
          TopUpButton(),
        ],
      ),
    );
  }
}

class TopUpButton extends StatelessWidget {
  const TopUpButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: theme.primaryColor,
      borderRadius: BorderRadius.circular(8),
      minSize: 0,
      onPressed: () {
        // TODO: add a button to navigate to the top up screen
        debugPrint('Top up');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.plus,
            color: Color(0xFFFFFFFF),
            size: 16,
          ),
          const SizedBox(width: 4),
          const Text(
            'Top up',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}
