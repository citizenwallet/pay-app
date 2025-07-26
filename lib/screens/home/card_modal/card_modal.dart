import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/screens/home/card_modal/footer.dart';
import 'package:pay_app/state/cards.dart';
import 'package:pay_app/state/topup.dart';
import 'package:pay_app/widgets/orders/order_list_item.dart';
import 'package:pay_app/services/db/app/cards.dart';
import 'package:pay_app/services/wallet/contracts/profile.dart';
import 'package:pay_app/state/card.dart';
import 'package:pay_app/theme/card_colors.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/button.dart';
import 'package:pay_app/widgets/modals/dismissible_modal_popup.dart';
import 'package:pay_app/widgets/webview/connected_webview_modal.dart';
import 'package:pay_app/widgets/card.dart' show Card;
import 'package:provider/provider.dart';

class CardModal extends StatefulWidget {
  final String? uid;
  final String? address;
  final String? project;
  final String? tokenAddress;

  const CardModal(
      {super.key, this.uid, this.address, this.project, this.tokenAddress});

  @override
  State<CardModal> createState() => _CardModalState();
}

class _CardModalState extends State<CardModal> {
  FocusNode amountFocusNode = FocusNode();
  FocusNode messageFocusNode = FocusNode();

  late CardState _cardState;
  late CardsState _cardsState;
  late TopupState _topupState;

  ScrollController scrollController = ScrollController();

  bool _showFooter = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardState = context.read<CardState>();
      _cardsState = context.read<CardsState>();
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
    await _cardState.fetchCardDetails(widget.address, widget.tokenAddress);
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

      if (!hasMore || ordersLoading) {
        return;
      }

      _cardState.fetchOrders(tokenAddress: widget.tokenAddress);
    }
  }

  Future<void> handleFetchOrders() async {
    return _cardState.fetchOrders(
      refresh: true,
      tokenAddress: widget.tokenAddress,
    );
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

  void handleUnclaimCard() async {
    final uid = widget.uid;

    if (uid == null) {
      return;
    }

    final navigator = GoRouter.of(context);

    // confirm modal
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Remove Card'),
        content: Text('Are you sure you want to remove this card?'),
        actions: [
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == null || !confirmed) {
      return;
    }

    await _cardsState.unclaim(uid);

    if (!mounted) {
      return;
    }

    navigator.pop();
  }

  Future<void> handleUpdateCardName(String name, String originalName) async {
    final uid = widget.uid;

    if (uid == null) {
      return;
    }

    await _cardsState.updateCardName(uid, name, originalName);
  }

  Future<void> handleEditProfile() async {
    final navigator = GoRouter.of(context);

    await navigator.push('/${widget.address}/my-account/edit');

    if (!mounted) {
      return;
    }

    onLoad();
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

    final claimingCard = context.watch<CardsState>().claimingCard;
    final updatingCardName = context.watch<CardsState>().updatingCardName;

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
          _buildCard(context),
          if (card == null) const SizedBox(height: 24),
          if (card == null)
            Button(
              onPressed:
                  claimingCard || updatingCardName ? null : handleSaveCard,
              text: 'Save Card',
              labelColor: whiteColor,
              color: cardColor,
              suffix: claimingCard || updatingCardName
                  ? const CupertinoActivityIndicator()
                  : null,
            ),
          if (card == null) const SizedBox(height: 24),
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

  Widget _buildCard(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final balance = context.select<CardState, double>((state) => state.balance);
    final profile =
        context.select<CardState, ProfileV1?>((state) => state.profile);

    final cardColor = projectCardColor(widget.project);

    final uid = widget.uid;
    final address = widget.address;

    if (uid == null && address == null) {
      return const SizedBox.shrink();
    }

    return Card(
      width: width * 0.8,
      uid: uid ?? address!,
      color: cardColor,
      profile: profile,
      balance: balance,
      icon: uid == null ? CupertinoIcons.device_phone_portrait : null,
      onTopUpPressed: uid == null ? null : handleTopUpCard,
      onCardNameTapped: uid == null ? handleEditProfile : null,
      onCardNameUpdated: uid == null
          ? null
          : (name) => handleUpdateCardName(name, profile?.name ?? ''),
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
          SliverToBoxAdapter(
            child: const SizedBox(height: 24),
          ),
          if (widget.uid != null)
            SliverToBoxAdapter(
              child: _buildCardActions(context),
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
          if (orders.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('No orders found'),
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

  Widget _buildCardActions(BuildContext context) {
    final unclaimingCard = context.watch<CardsState>().unclaimingCard;
    final updatingCardName = context.watch<CardsState>().updatingCardName;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Button(
          onPressed:
              unclaimingCard || updatingCardName ? null : handleUnclaimCard,
          text: 'Remove Card',
          labelColor: whiteColor,
          color: dangerColor,
          suffix: unclaimingCard || updatingCardName
              ? const CupertinoActivityIndicator()
              : null,
        ),
      ],
    );
  }
}
