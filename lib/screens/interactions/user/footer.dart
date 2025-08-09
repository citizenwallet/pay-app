import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/state/transactions_with_user/transactions_with_user.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/widgets/transaction_input_row.dart';
import 'package:pay_app/widgets/wide_button.dart';
import 'package:pay_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class Footer extends StatefulWidget {
  final Function(double, String?) onSend;
  final Function(String) onTopUpPressed;
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

  Future<void> sendTransaction(String tokenAddress) async {
    HapticFeedback.heavyImpact();

    widget.amountFocusNode.unfocus();
    widget.messageFocusNode.unfocus();

    _transactionsWithUserState.sendTransaction(tokenAddress);
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

    final config = context.select<WalletState, Config?>(
      (state) => state.config,
    );
    final tokenConfig = context.select<AppState, TokenConfig>(
      (state) => state.currentTokenConfig,
    );

    final balance =
        context.watch<WalletState>().tokenBalances[tokenConfig.address] ??
            '0.0';

    final tokenPrimaryColor =
        context.select<AppState, Color>((state) => state.tokenPrimaryColor);

    final topUpPlugin = config?.getTopUpPlugin(
      tokenAddress: tokenConfig.address,
    );

    final toSendAmount =
        context.watch<TransactionsWithUserState>().toSendAmount;

    final error = toSendAmount > double.parse(balance);
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
            TransactionInputRow(
              showAmountField: _showAmountField,
              token: tokenConfig,
              color: tokenPrimaryColor,
              amountController: _amountController,
              messageController: _messageController,
              amountFocusNode: widget.amountFocusNode,
              messageFocusNode: widget.messageFocusNode,
              onAmountChange: updateAmount,
              onMessageChange: updateMessage,
              onToggleField: _toggleField,
              onSend: () => sendTransaction(tokenConfig.address),
              disabled: disabled,
              error: error,
              onTopUpPressed: topUpPlugin != null
                  ? () => widget.onTopUpPressed(topUpPlugin.url)
                  : null,
            ),
          if (widget.phoneNumber != null)
            WideButton(
              child: Text(
                AppLocalizations.of(context)!.shareInviteLink,
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
