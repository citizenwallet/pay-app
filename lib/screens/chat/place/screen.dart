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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // make initial requests here
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void goBack() {
    Navigator.pop(context);
  }

  final Transaction transaction = Transaction(
    id: 'tx_123456789',
    txHash:
        '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    createdAt: DateTime.now(),
    fromAccountAddress: '0xUserWallet123',
    toAccountAddress: '0xPlaceWallet456',
    amount: 42.50,
    description: 'Coffee and Pastries',
    status: TransactionStatus.success,
    // Place-specific fields
    orderId: 1,
    paymentMode: PaymentMode.app,
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Column(
          children: [
            ChatHeader(
              imageUrl:
                  'https://plus.unsplash.com/premium_photo-1661883237884-263e8de8869b?q=80&w=2689&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              placeName: 'Fat Duck',
              placeDescription: 'Broadwalk, London',
            ),
            TransactionListItem(
              transaction: transaction,
            ),
            Footer(),
          ],
        ),
      ),
    );
  }
}
