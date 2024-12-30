import 'package:flutter/cupertino.dart';

import 'package:pay_app/screens/chat/place/header.dart';
import 'package:pay_app/screens/chat/place/transaction_list_item.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/screens/chat/place/footer.dart';

class ChatWithPlaceScreen extends StatefulWidget {
  const ChatWithPlaceScreen({super.key});

  @override
  State<ChatWithPlaceScreen> createState() => _ChatWithPlaceScreenState();
}

class _ChatWithPlaceScreenState extends State<ChatWithPlaceScreen> {
  FocusNode amountFocusNode = FocusNode();
  FocusNode messageFocusNode = FocusNode();

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    amountFocusNode.addListener(_onAmountFocus);
    messageFocusNode.addListener(_onMessageFocus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // make initial requests here
    });
  }

  void _onAmountFocus() {
    if (amountFocusNode.hasFocus) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          scrollToBottom();
        },
      );
    }
  }

  void _onMessageFocus() {
    if (messageFocusNode.hasFocus) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          scrollToBottom();
        },
      );
    }
  }

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
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

    print(last.orderId);

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
        scrollToBottom();
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
      description: 'Coffee and Pastries',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 1,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now(),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now(),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now(),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now(),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now(),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now(),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now(),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
    Transaction(
      id: 'tx_123456789',
      txHash:
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      createdAt: DateTime.now(),
      fromAccountAddress: '0xUserWallet123',
      toAccountAddress: '0xPlaceWallet456',
      amount: 12.23,
      description: 'Coffee and Pastries',
      status: TransactionStatus.success,
      // Place-specific fields
      orderId: 2,
      paymentMode: PaymentMode.app,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Column(
          children: [
            ChatHeader(
              onTapLeading: goBack,
              imageUrl:
                  'https://plus.unsplash.com/premium_photo-1661883237884-263e8de8869b?q=80&w=2689&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              placeName: 'Fat Duck',
              placeDescription: 'Broadwalk, London',
            ),
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollController,
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
              hasMenu: true,
            ),
          ],
        ),
      ),
    );
  }
}
