import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/transaction_input_row.dart';
import 'package:provider/provider.dart';

class Footer extends StatefulWidget {
  final void Function(String, String, String?) onSend;
  final Function(String) onTopUpPressed;
  final FocusNode amountFocusNode;
  final FocusNode messageFocusNode;
  final Function(String) onAmountChange;
  final double amount;
  final bool loading;

  const Footer({
    super.key,
    required this.onSend,
    required this.onTopUpPressed,
    required this.amountFocusNode,
    required this.messageFocusNode,
    required this.onAmountChange,
    required this.amount,
    required this.loading,
  });

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _showAmountField = true;

  Future<void> sendTransaction(
      String tokenAddress, String amount, String? message) async {
    HapticFeedback.heavyImpact();

    widget.amountFocusNode.unfocus();
    widget.messageFocusNode.unfocus();

    widget.onSend(tokenAddress, amount.replaceAll(',', '.'), message);

    _amountController.clear();
    _messageController.clear();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _updateAmount(double amount) {
    widget.onAmountChange(amount.toString().replaceAll(',', '.'));
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

    final config = context.select<WalletState, Config>(
      (state) => state.config,
    );
    final tokenConfig = context.select<AppState, TokenConfig>(
      (state) => state.currentTokenConfig,
    );

    final balance =
        context.watch<WalletState>().tokenBalances[tokenConfig.address] ??
            '0.0';

    final topUpPlugin = config.getTopUpPlugin(
      tokenAddress: tokenConfig.address,
    );

    final primaryColor = context.select<AppState, Color>(
      (state) => state.tokenPrimaryColor,
    );

    final error = widget.amount > double.parse(balance);
    final disabled = widget.amount == 0.0 || error;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: whiteColor,
        border: Border(
          top: BorderSide(
            color: Color(0xFFD9D9D9),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          TransactionInputRow(
            showAmountField: _showAmountField,
            amountController: _amountController,
            messageController: _messageController,
            amountFocusNode: widget.amountFocusNode,
            messageFocusNode: widget.messageFocusNode,
            onAmountChange: _updateAmount,
            color: primaryColor,
            onToggleField: _toggleField,
            onSend: () => widget.onSend(tokenConfig.address,
                _amountController.text, _messageController.text),
            disabled: disabled,
            error: error,
            onTopUpPressed: topUpPlugin != null
                ? () => widget.onTopUpPressed(topUpPlugin.url)
                : null,
            loading: widget.loading,
          ),
        ],
      ),
    );
  }
}
