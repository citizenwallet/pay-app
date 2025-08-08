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
          create: (_) => AppState(),
        ),
        ChangeNotifierProvider(
          create: (_) => CommunityState(),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletState(config),
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

  return MultiProvider(
    key: Key('account-$account'),
    providers: [
      ChangeNotifierProvider(
        key: Key('interactions-$account'),
        create: (_) => InteractionState(
          account: account,
        ),
      ),
      ChangeNotifierProvider(
        key: Key('places-$account'),
        create: (_) => PlacesState(),
      ),
      ChangeNotifierProvider(
        key: Key('profile-$account'),
        create: (_) => ProfileState(account, config),
      ),
      ChangeNotifierProvider(
        key: Key('contacts'),
        create: (_) => ContactsState(config),
      ),
      ChangeNotifierProvider(
        key: Key('topup'),
        create: (_) => TopupState(),
      ),
      ChangeNotifierProvider(
        key: Key('account-$account'),
        create: (_) => AccountState(config),
      ),
      ChangeNotifierProvider(
        key: Key('cards-$account'),
        create: (_) => CardsState(config),
      ),
    ],
    child: child,
  );
}

Widget providePlaceState(
  BuildContext context,
  GoRouterState state,
  Config config,
  Widget child,
) {
  final slug = state.pathParameters['slug']!;
  final account = state.pathParameters['account']!;

  return MultiProvider(
    key: Key('place-$account-$slug'),
    providers: [
      ChangeNotifierProvider(
        key: Key('orders-with-place-$account-$slug'),
        create: (_) => OrdersWithPlaceState(
          config,
          slug: slug,
          myAddress: account,
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
