import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/state/onboarding.dart';
import 'package:pay_app/state/state.dart';
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
        ShellRoute(
          builder: (context, state, child) =>
              provideAccountState(context, state, child),
          routes: [
            GoRoute(
              name: 'Home',
              path: '/:account',
              builder: (context, state) {
                return const HomeScreen();
              },
            ),
            GoRoute(
              name: 'MyAccount',
              path: '/:account/my-account',
              builder: (context, state) {
                return const MyAccount();
              },
              routes: [
                GoRoute(
                  name: 'EditMyAccount',
                  path: '/edit',
                  builder: (context, state) {
                    return const EditAccountScreen();
                  },
                ),
              ],
            ),
            ShellRoute(
              builder: (context, state, child) =>
                  providePlaceState(context, state, child),
              routes: [
                GoRoute(
                  name: 'InteractionWithPlace',
                  path: '/:account/place/:slug',
                  builder: (context, state) {
                    final myAddress = state.pathParameters['account']!;
                    final slug = state.pathParameters['slug']!;

                    return InteractionWithPlaceScreen(
                      slug: slug,
                      myAddress: myAddress,
                    );
                  },
                  routes: [
                    GoRoute(
                      name: 'PlaceMenu',
                      path: '/menu',
                      builder: (context, state) {
                        return const PlaceMenuScreen();
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              name: 'InteractionWithUser',
              path: '/:account/user/:withUser',
              builder: (context, state) {
                final myAddress = state.pathParameters['account']!;
                final userAddress = state.pathParameters['withUser']!;

                return ChangeNotifierProvider(
                  create: (_) => TransactionsWithUserState(
                    withUserAddress: userAddress,
                    myAddress: myAddress,
                  ),
                  child: const InteractionWithUserScreen(),
                );
              },
            ),
          ],
        ),
      ],
    );
