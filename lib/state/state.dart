import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/state/account.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/state/card.dart';
import 'package:pay_app/state/cards.dart';
import 'package:pay_app/state/checkout.dart';
import 'package:pay_app/state/community.dart';
import 'package:pay_app/state/contacts/contacts.dart';
import 'package:pay_app/state/interactions/interactions.dart';
import 'package:pay_app/state/onboarding.dart';
import 'package:pay_app/state/orders_with_place/orders_with_place.dart';
import 'package:pay_app/state/places/places.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/state/scanner.dart';
import 'package:pay_app/state/sending.dart';
import 'package:pay_app/state/topup.dart';
import 'package:pay_app/state/transactions/transactions.dart';
import 'package:pay_app/state/transactions_with_user/transactions_with_user.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/state/locale_state.dart';
import 'package:provider/provider.dart';

Widget provideAppState(
  Config config,
  Widget? child, {
  Widget Function(BuildContext, Widget?)? builder,
}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppState(config),
        ),
        ChangeNotifierProvider(
          create: (_) => CommunityState(),
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingState(config),
        ),
        ChangeNotifierProvider(
          create: (_) => ScanState(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleState(),
        ),
        ChangeNotifierProvider(
          key: Key('topup'),
          create: (_) => TopupState(),
        ),
        ChangeNotifierProvider(
          key: Key('profile'),
          create: (_) => ProfileState(config),
        ),
        ChangeNotifierProvider(
          key: Key('cards'),
          create: (_) => CardsState(config),
        ),
        ChangeNotifierProvider(
          key: Key('wallet'),
          create: (_) => WalletState(config),
        ),
      ],
      builder: builder,
      child: child,
    );

Widget provideAccountState(
  BuildContext context,
  GoRouterState state,
  Config config,
  Widget child,
) {
  final account = state.pathParameters['account']!;
  final token = state.uri.queryParameters['token'];

  return MultiProvider(
    key: Key('account-$account-$token'),
    providers: [
      ChangeNotifierProvider(
        key: Key('interactions-$account-$token'),
        create: (_) => InteractionState(
          account,
        ),
      ),
      ChangeNotifierProvider(
        key: Key('places-$account-$token'),
        create: (_) => PlacesState(),
      ),
      ChangeNotifierProvider(
        key: Key('contacts'),
        create: (_) => ContactsState(config),
      ),
      ChangeNotifierProvider(
        key: Key('account-$account'),
        create: (_) => AccountState(config),
      ),
      ChangeNotifierProvider(
        key: Key('transactions-$account-$token'),
        create: (_) => TransactionsState(accountAddress: account),
      ),
    ],
    child: child,
  );
}

Widget provideWalletState(
  BuildContext context,
  Config config,
  String account,
  Widget child,
) {
  return MultiProvider(
    key: Key('account-$account'),
    providers: [
      ChangeNotifierProvider(
        key: Key('wallet-$account'),
        create: (_) => WalletState(config),
      ),
    ],
    child: child,
  );
}

Widget providePlaceState(
  BuildContext context,
  Config config,
  String slug,
  String account,
  Widget child,
) {
  return MultiProvider(
    key: Key('place-$account-$slug'),
    providers: [
      ChangeNotifierProvider(
        key: Key('orders-with-place-$account-$slug'),
        create: (_) => OrdersWithPlaceState(
          config,
          slug: slug,
          account: account,
        ),
      ),
      ChangeNotifierProvider(
        key: Key('checkout-$account-$slug'),
        create: (_) => CheckoutState(
          account: account,
          slug: slug,
        ),
      ),
    ],
    child: child,
  );
}

Widget provideCardState(
  BuildContext context,
  Config config,
  String cardId,
  String cardAddress,
  String myAddress,
  Widget child,
) {
  return MultiProvider(
    key: Key('card-$cardId'),
    providers: [
      ChangeNotifierProvider(
        key: Key('card-$cardId'),
        create: (_) => CardState(config, cardId: cardId),
      ),
      ChangeNotifierProvider(
        key: Key('transactions-with-user-$cardId'),
        create: (_) => TransactionsWithUserState(
          withUserAddress: cardAddress,
          myAddress: myAddress,
        ),
      ),
    ],
    child: child,
  );
}

Widget provideSendingState(
  BuildContext context,
  Config config,
  String initialAddress,
  Widget child,
) {
  return MultiProvider(
    key: Key('sending-$initialAddress'),
    providers: [
      ChangeNotifierProvider(
        key: Key('wallet-$initialAddress'),
        create: (_) => WalletState(config),
      ),
      ChangeNotifierProvider(
        key: Key('sending-$initialAddress'),
        create: (_) => SendingState(
          config: config,
          initialAddress: initialAddress,
        ),
      ),
    ],
    child: child,
  );
}
