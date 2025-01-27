import 'package:flutter/cupertino.dart';

import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/transaction.dart';
import 'package:pay_app/state/orders_with_place/orders_with_place.dart';
import 'package:provider/provider.dart';
import 'header.dart';
import 'order_list_item.dart';
import 'footer.dart';

class InteractionWithPlaceScreen extends StatefulWidget {
  const InteractionWithPlaceScreen({super.key});

  @override
  State<InteractionWithPlaceScreen> createState() =>
      _InteractionWithPlaceScreenState();
}

class _InteractionWithPlaceScreenState
    extends State<InteractionWithPlaceScreen> {
  FocusNode amountFocusNode = FocusNode();
  FocusNode messageFocusNode = FocusNode();

  ScrollController scrollController = ScrollController();

  late OrdersWithPlaceState _ordersWithPlaceState;

  @override
  void initState() {
    super.initState();

    amountFocusNode.addListener(_onAmountFocus);
    messageFocusNode.addListener(_onMessageFocus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ordersWithPlaceState = context.read<OrdersWithPlaceState>();

      onLoad();
    });
  }

  void onLoad() async {
    _ordersWithPlaceState.fetchPlaceAndMenu();
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
    final last = orders.last;

    debugPrint(last.orderId.toString());

    setState(() {
      orders.add(Order(
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

  final List<Order> orders = [
    Order(
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
    Order(
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
    Order(
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
    Order(
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
    Order(
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
    Order(
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
    Order(
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
    Order(
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
    Order(
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
    final place = context.select((OrdersWithPlaceState state) => state.place);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        child: SafeArea(
          child: Column(
            children: [
              ChatHeader(
                onTapLeading: goBack,
                imageUrl: place?.profile.imageUrl ?? place?.place.imageUrl,
                placeName: place?.place.name ?? '',
                placeDescription: place?.place.description ?? '',
              ),
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    for (var order in orders) OrderListItem(order: order),
                  ],
                ),
              ),
              Footer(
                onSend: sendMessage,
                amountFocusNode: amountFocusNode,
                messageFocusNode: messageFocusNode,
                hasMenu: place?.place.hasMenu ?? false,
                place: place?.place,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
