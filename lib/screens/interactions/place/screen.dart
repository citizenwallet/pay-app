import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/models/checkout.dart';

import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/place.dart';
import 'package:pay_app/screens/interactions/place/external_order_modal.dart';
import 'package:pay_app/state/orders_with_place/orders_with_place.dart';
import 'package:pay_app/state/topup.dart';
import 'package:pay_app/widgets/webview/connected_webview_modal.dart';
import 'package:provider/provider.dart';
import 'header.dart';
import 'order_list_item.dart';
import 'footer.dart';

class InteractionWithPlaceScreen extends StatefulWidget {
  final String slug;
  final String myAddress;
  final bool openMenu;
  final String? orderId;

  const InteractionWithPlaceScreen({
    super.key,
    required this.slug,
    required this.myAddress,
    this.openMenu = false,
    this.orderId,
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
  late TopupState _topupState;

  @override
  void initState() {
    super.initState();

    amountFocusNode.addListener(_onAmountFocus);
    messageFocusNode.addListener(_onMessageFocus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ordersWithPlaceState = context.read<OrdersWithPlaceState>();
      _topupState = context.read<TopupState>();

      onLoad();
    });
  }

  void onLoad() async {
    final placeWithMenu = await _ordersWithPlaceState.fetchPlaceAndMenu();

    if (widget.orderId != null) {
      _ordersWithPlaceState.loadExternalOrder(widget.slug, widget.orderId!);

      if (!mounted) {
        return;
      }

      // open modal
      showCupertinoModalPopup<String?>(
        useRootNavigator: false,
        barrierDismissible: false,
        context: context,
        builder: (modalContext) => ExternalOrderModal(onPay: onPay),
      );

      return;
    }

    if (widget.openMenu &&
        placeWithMenu != null &&
        (placeWithMenu.place.display == Display.menu ||
            placeWithMenu.place.display == Display.amountAndMenu) &&
        placeWithMenu.items.isNotEmpty) {
      handleMenuPressed();
    }
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

  Future<void> onPay(Order order) async {
    HapticFeedback.heavyImpact();

    final newOrder = await _ordersWithPlaceState.confirmOrder(order);

    HapticFeedback.lightImpact();

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        scrollToTop();
      },
    );

    if (newOrder != null) {
      handleOrderPressed(newOrder);
    }
  }

  Future<Order?> sendMessage(double amount, String? message) async {
    HapticFeedback.heavyImpact();

    final checkout = Checkout(
      items: [],
      manualAmount: amount,
      message: message,
    );

    final order = await _ordersWithPlaceState.payOrder(checkout);

    HapticFeedback.lightImpact();

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        scrollToTop();
      },
    );

    if (order != null) {
      handleOrderPressed(order);
    }

    return order;
  }

  void handleMenuPressed() async {
    final navigator = GoRouter.of(context);

    final checkout = await navigator.push<Checkout?>(
      '/${widget.myAddress}/place/${widget.slug}/menu',
    );

    if (checkout == null) {
      return;
    }

    final order = await _ordersWithPlaceState.payOrder(checkout);

    HapticFeedback.lightImpact();

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        scrollToTop();
      },
    );

    if (order != null) {
      handleOrderPressed(order);
    }
  }

  void handleTopUp() async {
    await _topupState.generateTopupUrl();

    if (!mounted) {
      return;
    }

    await showCupertinoModalPopup<String?>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (modalContext) {
        final topupUrl =
            modalContext.select((TopupState state) => state.topupUrl);

        if (topupUrl.isEmpty) {
          return const SizedBox.shrink();
        }

        final redirectDomain = dotenv.env['APP_REDIRECT_DOMAIN'];

        return ConnectedWebViewModal(
          modalKey: 'connected-webview',
          url: topupUrl,
          redirectUrl: redirectDomain != null ? 'https://$redirectDomain' : '',
        );
      },
    );
  }

  final List<Order> orders = [
]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void handleOrderPressed(Order order) {
    final navigator = GoRouter.of(context);

    navigator.push(
      '/${widget.myAddress}/place/${widget.slug}/order/${order.id}',
      extra: order,
    );
  }

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
                imageUrl: place?.place.imageUrl ?? place?.profile?.imageUrl,
                placeName: place?.place.name ?? place?.profile?.name ?? '',
                placeDescription: place?.place.description ??
                    place?.profile?.description ??
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
                        onPressed: handleOrderPressed,
                      ),
                  ],
                ),
              ),
              Footer(
                myAddress: widget.myAddress,
                slug: widget.slug,
                onSend: sendMessage,
                onTopUpPressed: handleTopUp,
                onMenuPressed: handleMenuPressed,
                amountFocusNode: amountFocusNode,
                messageFocusNode: messageFocusNode,
                display: place?.place.display,
                place: place?.place,
                autoFocusAmount: widget.orderId == null && !widget.openMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
