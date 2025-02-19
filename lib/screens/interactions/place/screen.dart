import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/models/checkout.dart';

import 'package:pay_app/models/order.dart';
import 'package:pay_app/state/orders_with_place/orders_with_place.dart';
import 'package:provider/provider.dart';
import 'header.dart';
import 'order_list_item.dart';
import 'footer.dart';

class InteractionWithPlaceScreen extends StatefulWidget {
  final String slug;
  final String myAddress;

  const InteractionWithPlaceScreen({
    super.key,
    required this.slug,
    required this.myAddress,
  });

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

    // setState(() {
    //   orders.add(Order(
    //     type: OrderType.app,
    //     id: last.id + 1,
    //     txHash:
    //         '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    //     createdAt: DateTime.now(),
    //     account: EthereumAddress.fromHex('0xUserWallet123'),
    //     description: message,
    //     status: OrderStatus.success,
    //   ));
    // });

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        scrollToTop();
      },
    );
  }

  void handleMenuPressed() async {
    final navigator = GoRouter.of(context);

    final checkout = await navigator.push<Checkout?>(
      '/${widget.myAddress}/place/${widget.slug}/menu',
    );

    if (checkout == null) {
      return;
    }

    _ordersWithPlaceState.payOrder(checkout);
  }

  final List<Order> orders = [
]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final place = context.select((OrdersWithPlaceState state) => state.place);

    final orders = context.select((OrdersWithPlaceState state) => state.orders);

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
                placeName: place?.profile.name ?? place?.place.name ?? '',
                placeDescription: place?.profile.description ??
                    place?.place.description ??
                    '',
              ),
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    for (var order in orders)
                      OrderListItem(
                        key: Key('order-${order.id}'),
                        order: order,
                        mappedItems: place?.mappedItems ?? {},
                      ),
                  ],
                ),
              ),
              Footer(
                myAddress: widget.myAddress,
                slug: widget.slug,
                onSend: sendMessage,
                onMenuPressed: handleMenuPressed,
                amountFocusNode: amountFocusNode,
                messageFocusNode: messageFocusNode,
                display: place?.place.display,
                place: place?.place,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
