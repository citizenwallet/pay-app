import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/state/community.dart';
import 'package:pay_app/state/interactions/interactions.dart';
import 'package:pay_app/state/places/places.dart';
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
    ],
    child: child,
  );
}
