import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/state/transactions_with_user.dart';
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
    // TODO: get transactions
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
    super.dispose();
  }

  void goBack() {
    Navigator.pop(context);
  }

  void sendMessage(double amount, String? message) {
    final last = transactions.last;

    debugPrint(last.orderId.toString());

    setState(() {
      transactions.add(Transaction(
        paymentMode: PaymentMode.app,
        orderId: last.orderId ?? 0 + 1,
        id: 'tx_123456789',
        txHash:
            '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
        createdAt: DateTime.now(),
        fromAccountAddress: '0xUserWallet123',
        toAccountAddress: '0xPlaceWallet456',
        amount: amount,
        description: message,
        status: TransactionStatus.success,
      ));
    });

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        scrollToTop();
      },
    );
  }

  final List<Transaction> transactions = [
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now(),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries (Now)',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 1,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries (Yesterday)',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries (2 days ago)',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries (3 days ago)',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries (4 days ago)  ',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries (5 days ago)',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 4,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries (6 days ago)',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 3,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries (7 days ago)',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries (8 days ago)',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 1,
      paymentMode: PaymentMode.app,
    ),
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final withUser =
        context.select((TransactionsWithUserState state) => state.withUser);

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
