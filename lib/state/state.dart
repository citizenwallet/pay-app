import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/state/checkout.dart';
import 'package:pay_app/state/community.dart';
import 'package:pay_app/state/contacts/contacts.dart';
import 'package:pay_app/state/interactions/interactions.dart';
import 'package:pay_app/state/onboarding.dart';
import 'package:pay_app/state/orders_with_place/orders_with_place.dart';
import 'package:pay_app/state/places/places.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/state/topup.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:provider/provider.dart';

Widget provideAppState(
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
          create: (_) => WalletState(),
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingState(),
        ),
      ],
      builder: builder,
      child: child,
    );

Widget provideAccountState(
  BuildContext context,
  GoRouterState state,
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
        create: (_) => ProfileState(account),
      ),
      ChangeNotifierProvider(
        key: Key('contacts'),
        create: (_) => ContactsState(),
      ),
      ChangeNotifierProvider(
        key: Key('topup'),
        create: (_) => TopupState(),
      ),
    ],
    child: child,
  );
}

Widget providePlaceState(
  BuildContext context,
  GoRouterState state,
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
