import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/state/onboarding.dart';
import 'package:provider/provider.dart';

// screens
import 'package:pay_app/screens/home/screen.dart';
import 'package:pay_app/screens/onboarding/screen.dart';
import 'package:pay_app/screens/account/view/screen.dart';
import 'package:pay_app/screens/account/edit/screen.dart';
import 'package:pay_app/screens/interactions/place/screen.dart';
import 'package:pay_app/screens/interactions/place/menu/screen.dart';
import 'package:pay_app/screens/interactions/user/screen.dart';

// state
import 'package:pay_app/state/checkout.dart';
import 'package:pay_app/state/orders_with_place/orders_with_place.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/state/interactions/interactions.dart';
import 'package:pay_app/state/transactions_with_user/transactions_with_user.dart';

GoRouter createRouter(
  GlobalKey<NavigatorState> rootNavigatorKey,
  GlobalKey<NavigatorState> shellNavigatorKey,
  List<NavigatorObserver> observers, {
  String? userId,
}) =>
    GoRouter(
      initialLocation: userId != null ? '/$userId' : '/',
      debugLogDiagnostics: kDebugMode,
      navigatorKey: rootNavigatorKey,
      observers: observers,
      routes: [
        GoRoute(
          name: 'Onboarding',
          path: '/',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (_) => OnboardingState(),
              child: const OnboardingScreen(),
            );
          },
        ),
        GoRoute(
          name: 'Home',
          path: '/:account', // user id from supabase
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final myAddress = state.pathParameters['account']!;

            final walletState = context.read<WalletState>();

            return ChangeNotifierProvider(
              create: (_) => InteractionState(
                account: myAddress,
                walletState: walletState,
              ),
              child: const HomeScreen(),
            );
          },
          routes: [
            GoRoute(
              name: 'MyAccount',
              path: '/my-account',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) {
                return const MyAccount();
              },
              routes: [
                GoRoute(
                  name: 'EditMyAccount',
                  path: '/edit',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    return const EditAccountScreen();
                  },
                ),
              ],
            ),
            GoRoute(
              name: 'InteractionWithPlace',
              path: '/place/:slug',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) {
                final myAddress = state.pathParameters['account']!;
                final slug = state.pathParameters['slug']!;

                return ChangeNotifierProvider(
                  create: (_) => OrdersWithPlaceState(
                    slug: slug,
                    myAddress: myAddress,
                  ),
                  child: const InteractionWithPlaceScreen(),
                );
              },
              routes: [
                GoRoute(
                  name: 'PlaceMenu',
                  path: '/menu',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final userId = int.parse(state.pathParameters['id']!);
                    final slug = state.pathParameters['slug']!;

                    return ChangeNotifierProvider(
                      key: Key('menu-$userId-$slug'),
                      create: (_) => CheckoutState(
                        userId: userId,
                        slug: slug,
                      ),
                      child: const PlaceMenuScreen(),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              name: 'InteractionWithUser',
              path: '/user/:withUser',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) {
                final myAddress = state.pathParameters['account']!;
                final userAddress = state.pathParameters['withUser']!;

                final walletState = context.read<WalletState>();

                return ChangeNotifierProvider(
                  create: (_) => TransactionsWithUserState(
                    withUserAddress: userAddress,
                    myAddress: myAddress,
                    walletState: walletState,
                  ),
                  child: const InteractionWithUserScreen(),
                );
              },
            ),
          ],
        ),
      ],
    );
