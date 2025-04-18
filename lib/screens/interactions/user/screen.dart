import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay_app/state/topup.dart';
import 'package:pay_app/state/transactions_with_user/selector.dart';
import 'package:pay_app/state/transactions_with_user/transactions_with_user.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/profile_circle.dart';
import 'package:pay_app/widgets/webview/connected_webview_modal.dart';
import 'package:provider/provider.dart';

import 'header.dart';
import 'transaction_list_item.dart';
import 'footer.dart';

class InteractionWithUserScreen extends StatefulWidget {
  final String customName;
  final String customPhone;
  final Uint8List? customPhoto;
  final String? customImageUrl;

  const InteractionWithUserScreen({
    super.key,
    required this.customName,
    required this.customPhone,
    this.customPhoto,
    this.customImageUrl,
  });

  @override
  State<InteractionWithUserScreen> createState() =>
      _InteractionWithUserScreenState();
}

class _InteractionWithUserScreenState extends State<InteractionWithUserScreen> {
  FocusNode amountFocusNode = FocusNode();
  FocusNode messageFocusNode = FocusNode();

  ScrollController scrollController = ScrollController();

  late TransactionsWithUserState _transactionsWithUserState;
  late WalletState _walletState;
  late TopupState _topupState;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transactionsWithUserState = context.read<TransactionsWithUserState>();
      _walletState = context.read<WalletState>();
      _topupState = context.read<TopupState>();
      onLoad();
    });
  }

  void onLoad() async {
    await _transactionsWithUserState.getProfileOfWithUser();
    await _transactionsWithUserState.getTransactionsWithUser();
    _transactionsWithUserState.startPolling(
        updateBalance: _walletState.updateBalance);
  }

  void _scrollListener() {
    if (amountFocusNode.hasFocus) {
      amountFocusNode.unfocus();
    }

    if (messageFocusNode.hasFocus) {
      messageFocusNode.unfocus();
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
    scrollController.removeListener(_scrollListener);
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

  void retryTransaction(String id) {
    HapticFeedback.heavyImpact();
    _transactionsWithUserState.sendTransaction(retryId: id);
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = context.watch<TransactionsWithUserState>();
    final withUser = transactionState.withUser;

    final transactions = context.select(selectUserTransactions);

    final noUserAccount = withUser == null &&
        widget.customName.isNotEmpty &&
        widget.customPhone.isNotEmpty;
    return CupertinoPageScaffold(
      backgroundColor: whiteColor,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ChatHeader(
                onTapLeading: goBack,
                imageUrl: widget.customImageUrl ?? withUser?.imageUrl,
                photo: widget.customPhoto,
                name: withUser?.name ?? widget.customName,
                username: withUser?.username,
                phone: withUser?.username == null ? widget.customPhone : null,
              ),
              Expanded(
                child: Container(
                  color: backgroundColor,
                  child: CustomScrollView(
                    controller: scrollController,
                    scrollBehavior: const CupertinoScrollBehavior(),
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    reverse: true,
                    slivers: [
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                      if (noUserAccount)
                        const SliverToBoxAdapter(
                          child: SizedBox(
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'This user does not have an account yet.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: textMutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (!noUserAccount)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: transactions.length,
                            (context, index) {
                              final transaction = transactions[index];

                              return TransactionListItem(
                                key: Key(transaction.id),
                                transaction: transaction,
                                onRetry: retryTransaction,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Footer(
                onSend: sendMessage,
                onTopUpPressed: handleTopUp,
                amountFocusNode: amountFocusNode,
                messageFocusNode: messageFocusNode,
                phoneNumber: noUserAccount ? widget.customPhone : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
