import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/screens/home/card_modal/footer.dart';
import 'package:pay_app/state/topup.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/widgets/orders/order_list_item.dart';
import 'package:pay_app/services/db/app/cards.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/state/card.dart';
import 'package:pay_app/theme/card_colors.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/button.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/modals/dismissible_modal_popup.dart';
import 'package:pay_app/widgets/webview/connected_webview_modal.dart';
import 'package:provider/provider.dart';

class CardModal extends StatefulWidget {
  final String? project;

  const CardModal({super.key, this.project});

  @override
  State<CardModal> createState() => _CardModalState();
}

class _CardModalState extends State<CardModal> {
  FocusNode amountFocusNode = FocusNode();
  FocusNode messageFocusNode = FocusNode();

  late CardState _cardState;
  late TopupState _topupState;

  ScrollController scrollController = ScrollController();

  bool _showFooter = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardState = context.read<CardState>();
      _topupState = context.read<TopupState>();

      amountFocusNode.addListener(onFocus);
      messageFocusNode.addListener(onFocus);
      scrollController.addListener(onScrollUpdate);

      onLoad();
    });
  }

  @override
  void dispose() {
    amountFocusNode.removeListener(onFocus);
    messageFocusNode.removeListener(onFocus);
    scrollController.removeListener(onScrollUpdate);
    super.dispose();
  }

  void onLoad() async {
    await _cardState.fetchCardDetails();
  }

  void onFocus() {
    setState(() {
      _showFooter = amountFocusNode.hasFocus || messageFocusNode.hasFocus;
    });
  }

  void onScrollUpdate() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 80) {
      final hasMore = context.read<CardState>().hasMoreOrders;
      final ordersLoading = context.read<CardState>().ordersLoading;

      print('hasMore: $hasMore');
      print('ordersLoading: $ordersLoading');

      if (!hasMore || ordersLoading) {
        return;
      }

      _cardState.fetchOrders();
    }
  }

  Future<void> handleFetchOrders() async {
    return _cardState.fetchOrders(refresh: true);
  }

  void handleTopUpCard() async {
    HapticFeedback.heavyImpact();

    setState(() {
      _showFooter = true;
    });
  }

  void handleSaveCard() async {
    await _cardState.saveCard(widget.project);
  }

  void handleClose(BuildContext context) {
    final navigator = GoRouter.of(context);
    navigator.pop();
  }

  void handleOrderPressed(String address, String slug, Order order) {
    final navigator = GoRouter.of(context);

    navigator.push(
      '/$address/place/$slug/order/${order.id}',
      extra: order,
    );
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage(double amount, String? message) {
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        scrollToTop();
      },
    );
  }

  void handleTopUp(String baseUrl) async {
    await _topupState.generateTopupUrl(baseUrl);

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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final card = context.select<CardState, DBCard?>((state) => state.card);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DismissibleModalPopup(
        modalKey: 'card_modal',
        maxHeight: card == null ? 400 : height * 0.9,
        paddingSides: 16,
        paddingTopBottom: 0,
        topRadius: 12,
        onDismissed: (dir) {
          handleClose(context);
        },
        child: _buildContent(
          context,
          card,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DBCard? card,
  ) {
    final cardColor = projectCardColor(widget.project);

    final orders = context.watch<CardState>().orders;

    return SafeArea(
      top: _showFooter,
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card == null ? 'New Card' : 'My Card',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: whiteColor,
                borderRadius: BorderRadius.circular(8),
                onPressed: () => handleClose(context),
                child: Icon(
                  CupertinoIcons.xmark,
                  color: textColor,
                ),
              ),
            ],
          ),
          _buildCard(context, card),
          if (card == null) const SizedBox(height: 24),
          if (card == null)
            Button(
              onPressed: handleSaveCard,
              text: 'Save Card',
              labelColor: whiteColor,
              color: cardColor,
            ),
          if (card != null)
            _buildOrders(
              context,
              orders,
              card,
            ),
          if (_showFooter)
            Footer(
              onSend: sendMessage,
              amountFocusNode: amountFocusNode,
              messageFocusNode: messageFocusNode,
              onTopUpPressed: handleTopUp,
            ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, DBCard? card) {
    final balance = context.select<CardState, double>((state) => state.balance);
    final profile =
        context.select<CardState, ProfileV1?>((state) => state.profile);

    final cardColor = projectCardColor(widget.project);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.white),
        boxShadow: [
          BoxShadow(
            color: blackColor.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  profile?.username != null
                      ? '@${profile?.username}'
                      : 'anonymous',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Image.asset(
                  'assets/icons/nfc.png',
                  color: CupertinoColors.white,
                  width: 24,
                  height: 24,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(8),
                  minSize: 0,
                  onPressed: handleTopUpCard,
                  child: SizedBox(
                    width: 100,
                    height: 28,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.plus,
                          color: cardColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'add funds',
                          style: TextStyle(
                            color: cardColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CoinLogo(size: 20),
                        const SizedBox(width: 4),
                        Text(
                          balance.toStringAsFixed(2),
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 20,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildOrders(BuildContext context, List<Order> orders, DBCard card) {
    final ordersLoading =
        context.select<CardState, bool>((state) => state.ordersLoading);

    return Expanded(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: handleFetchOrders,
            builder: (
              context,
              mode,
              pulledExtent,
              refreshTriggerPullDistance,
              refreshIndicatorExtent,
            ) =>
                Container(
              color: whiteColor,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: CupertinoSliverRefreshControl.buildRefreshIndicator(
                context,
                mode,
                pulledExtent,
                refreshTriggerPullDistance,
                refreshIndicatorExtent,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: orders.length,
              (context, index) => OrderListItem(
                key: Key('order-${orders[index].id}'),
                order: orders[index],
                // mappedItems: place?.mappedItems ?? {},
                mappedItems: {},
                onPressed: (order) =>
                    handleOrderPressed(card.account, card.project, order),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ordersLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: const CupertinoActivityIndicator(),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
