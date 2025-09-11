import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/models/place_menu.dart';
import 'package:pay_app/state/orders_with_place/orders_with_place.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/modals/dismissible_modal_popup.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ExternalOrderModal extends StatelessWidget {
  final Function(Order) onPay;

  const ExternalOrderModal({
    super.key,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final order = context
        .select((OrdersWithPlaceState state) => state.payingExternalOrder);

    final placeMenu =
        context.select((OrdersWithPlaceState state) => state.placeMenu);

    final loading = context
        .select((OrdersWithPlaceState state) => state.loadingExternalOrder);

    return DismissibleModalPopup(
      modalKey: 'external_order_modal',
      maxHeight: 400,
      paddingSides: 16,
      paddingTopBottom: 16,
      topRadius: 12,
      blockDismiss: true,
      child: loading
          ? _buildLoadingIndicator()
          : order == null
              ? _buildErrorState(context)
              : _buildContent(context, order, placeMenu),
    );
  }

  void handleCancel(BuildContext context) {
    final navigator = GoRouter.of(context);
    navigator.pop();
  }

  void handlePay(BuildContext context, Order order) {
    final navigator = GoRouter.of(context);
    navigator.pop();
    onPay(order);
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          AppLocalizations.of(context)!.orderNotFound,
          style: TextStyle(
            fontSize: 16,
            color: textMutedColor,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, Order order, PlaceMenu? placeMenu) {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, order),
          const SizedBox(height: 16),
          _buildOrderDetails(context, order, placeMenu),
          const SizedBox(height: 16),
          _buildTotals(context, order),
          const SizedBox(height: 24),
          _buildActions(context, order),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.confirmOrder,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Order #${order.id}',
          style: TextStyle(
            fontSize: 14,
            color: textMutedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(
      BuildContext context, Order order, PlaceMenu? placeMenu) {
    final menuItemsById = placeMenu?.menuItemsById ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.items,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        if (order.items.isEmpty &&
            (order.description == null || order.description!.trim().isEmpty))
          Text(
            AppLocalizations.of(context)!.noItems,
            style: TextStyle(
              fontSize: 14,
              color: textMutedColor,
            ),
          )
        else if (order.items.isEmpty &&
            order.description != null &&
            order.description!.isNotEmpty)
          Text(
            order.description!,
            style: TextStyle(
              fontSize: 14,
              color: textMutedColor,
            ),
          )
        else
          ...order.items.map(
            (item) {
              final menuItem = menuItemsById[item.id];
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${menuItem?.name ?? item.id} x ${item.quantity}',
                  style: TextStyle(
                    fontSize: 14,
                    color: textMutedColor,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTotals(BuildContext context, Order order) {
    // Calculate VAT (assuming 20% for this example)
    final vatRate = 0.20;
    final totalExcludingVat = order.total / (1 + vatRate);
    final vatAmount = order.total - totalExcludingVat;

    return Column(
      children: [
        _buildTotalRow(
            AppLocalizations.of(context)!.subtotal, totalExcludingVat),
        const SizedBox(height: 8),
        _buildTotalRow(AppLocalizations.of(context)!.vat, vatAmount),
        const SizedBox(height: 8),
        _buildTotalRow(AppLocalizations.of(context)!.total, order.total,
            isBold: true),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: textColor,
          ),
        ),
        Row(
          children: [
            const CoinLogo(size: 16),
            const SizedBox(width: 4),
            Text(
              amount.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, Order order) {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(8),
            onPressed: () => handleCancel(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: CupertinoTheme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8),
            onPressed: () => handlePay(context, order),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.pay} ',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const CoinLogo(size: 16),
                const SizedBox(width: 4),
                Text(
                  order.total.toStringAsFixed(2),
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
