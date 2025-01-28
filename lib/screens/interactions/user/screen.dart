import 'package:flutter/cupertino.dart';
import 'package:pay_app/state/transactions_with_user/selector.dart';
import 'package:pay_app/state/transactions_with_user/transactions_with_user.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:provider/provider.dart';

import 'header.dart';
import 'transaction_list_item.dart';
import 'footer.dart';

class InteractionWithUserScreen extends StatefulWidget {
  const InteractionWithUserScreen({super.key});

  @override
  State<InteractionWithUserScreen> createState() =>
      _InteractionWithUserScreenState();
}

class _InteractionWithUserScreenState extends State<InteractionWithUserScreen> {
  FocusNode amountFocusNode = FocusNode();
  FocusNode messageFocusNode = FocusNode();

  ScrollController scrollController = ScrollController();

  late TransactionsWithUserState _transactionsWithUserState;
  late WalletState _walletState;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transactionsWithUserState = context.read<TransactionsWithUserState>();
      _walletState = context.read<WalletState>();
      onLoad();
    });
  }

  void onLoad() async {
    await _transactionsWithUserState.getProfileOfWithUser();
    await _transactionsWithUserState.getTransactionsWithUser();
    _transactionsWithUserState.startPolling(
        updateBalance: _walletState.updateBalance);
  }

  void _scrollListener() {
    if (amountFocusNode.hasFocus) {
      amountFocusNode.unfocus();
    }

    if (messageFocusNode.hasFocus) {
      messageFocusNode.unfocus();
    }
  }

  // list is shown in reverse order, so we need to scroll to the top
  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    amountFocusNode.dispose();
    messageFocusNode.dispose();
    scrollController.dispose();
    _transactionsWithUserState.stopPolling();
    super.dispose();
  }

  void goBack() {
    Navigator.pop(context);
  }

  void sendMessage(double amount, String? message) {
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        scrollToTop();
      },
    );
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = context.watch<TransactionsWithUserState>();
    final withUser = transactionState.withUser;

    final transactions = selectUserTransactions(transactionState);

    return CupertinoPageScaffold(
      backgroundColor: whiteColor,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ChatHeader(
                onTapLeading: goBack,
                imageUrl: withUser?.imageUrl,
                name: withUser?.name,
                username: withUser?.username ?? '',
              ),
              Expanded(
                child: Container(
                  color: backgroundColor,
                  child: CustomScrollView(
                    controller: scrollController,
                    scrollBehavior: const CupertinoScrollBehavior(),
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    reverse: true,
                    slivers: [
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: transactions.length,
                          (context, index) {
                            final transaction = transactions[index];

                            return TransactionListItem(
                              key: Key(transaction.id),
                              transaction: transaction,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Footer(
                onSend: sendMessage,
                amountFocusNode: amountFocusNode,
                messageFocusNode: messageFocusNode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
