import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pay_app/state/transactions_with_user/transactions_with_user.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/utils/formatters.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/text_field.dart';
import 'package:provider/provider.dart';

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

  late TransactionsWithUserState _transactionsWithUserState;
  late WalletState _walletState;

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
    _walletState = context.watch<WalletState>();
    final balance = _walletState.wallet?.formattedBalance ?? 0.00;

    return Container(
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
          Row(
            children: [
              Expanded(
                child: _showAmountField
                    ? AmountFieldWithMessageToggle(
                        onToggle: _toggleField,
                        amountController: _amountController,
                        focusNode: widget.amountFocusNode,
                        onChange: updateAmount,
                      )
                    : MessageFieldWithAmountToggle(
                        onToggle: _toggleField,
                        messageController: _messageController,
                        focusNode: widget.messageFocusNode,
                        onChange: updateMessage,
                      ),
              ),
              SizedBox(width: 10),
              SendButton(
                onTap: sendTransaction,
              ),
            ],
          ),
          SizedBox(height: 10),
          CurrentBalance(balance: balance),
        ],
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final VoidCallback onTap;

  const SendButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
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
  final Function(double) onChange;
  final bool isSending;

  AmountFieldWithMessageToggle({
    super.key,
    required this.onToggle,
    required this.amountController,
    required this.focusNode,
    required this.onChange,
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
            onChanged: (value) {
              if (value.isEmpty) {
                onChange(0);
                return;
              }
              onChange(double.tryParse(value) ?? 0);
            },
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
  final Function(String) onChange;
  final bool isSending;

  const MessageFieldWithAmountToggle({
    super.key,
    required this.onToggle,
    required this.messageController,
    required this.focusNode,
    required this.onChange,
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
            onChanged: onChange,
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
  final double balance;
  const CurrentBalance({super.key, required this.balance});

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
            balance.toString(),
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
      padding: EdgeInsets.zero,
      color: theme.barBackgroundColor,
      borderRadius: BorderRadius.circular(8),
      minSize: 0,
      onPressed: () {
        // TODO: add a button to navigate to the top up screen
        debugPrint('Top up');
      },
      child: Container(
        width: 60,
        height: 28,
        decoration: BoxDecoration(
          color: theme.barBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.primaryColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '+ add',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
