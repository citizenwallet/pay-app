import 'package:flutter/cupertino.dart';
import 'package:pay_app/state/transactions_with_user/selector.dart';
import 'package:pay_app/state/transactions_with_user/transactions_with_user.dart';
import 'package:provider/provider.dart';

import './header.dart';
import './transaction_list_item.dart';
import './footer.dart';

class ChatWithUserScreen extends StatefulWidget {
  const ChatWithUserScreen({super.key});

  @override
  State<ChatWithUserScreen> createState() => _ChatWithUserScreenState();
}

class _ChatWithUserScreenState extends State<ChatWithUserScreen> {
  FocusNode amountFocusNode = FocusNode();
  FocusNode messageFocusNode = FocusNode();

  ScrollController scrollController = ScrollController();

  late TransactionsWithUserState _transactionsWithUserState;

  @override
  void initState() {
    super.initState();

    amountFocusNode.addListener(_onAmountFocus);
    messageFocusNode.addListener(_onMessageFocus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transactionsWithUserState = context.read<TransactionsWithUserState>();
      onLoad();
    });
  }

  void onLoad() async {
    await _transactionsWithUserState.getProfileOfWithUser();
    await _transactionsWithUserState.getTransactionsWithUser();
    _transactionsWithUserState.startPolling();
  }

  void _onAmountFocus() {
    if (amountFocusNode.hasFocus) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          scrollToTop();
        },
      );
    }
  }

  void _onMessageFocus() {
    if (messageFocusNode.hasFocus) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          scrollToTop();
        },
      );
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
    amountFocusNode.removeListener(_onAmountFocus);
    messageFocusNode.removeListener(_onMessageFocus);
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
    final withUser =
        context.select((TransactionsWithUserState state) => state.withUser);


    final transactions = context.select(reverseChronologicalOrder);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ChatHeader(
                onTapLeading: goBack,
                imageUrl: withUser.imageUrl,
                name: withUser.name,
                username: withUser.username,
              ),
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    for (var transaction in transactions)
                      TransactionListItem(transaction: transaction),
                  ],
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
