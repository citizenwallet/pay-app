import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/screens/interactions/place/order/screen.dart';
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
import 'package:pay_app/state/transactions_with_user/transactions_with_user.dart';

GoRouter createRouter(
  GlobalKey<NavigatorState> rootNavigatorKey,
  GlobalKey<NavigatorState> shellNavigatorKey,
  List<NavigatorObserver> observers, {
  String? accountAddress,
}) =>
    GoRouter(
      initialLocation: accountAddress != null ? '/$accountAddress' : '/',
      debugLogDiagnostics: kDebugMode,
      navigatorKey: rootNavigatorKey,
      observers: observers,
      routes: [
        GoRoute(
          name: 'Onboarding',
          path: '/',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            return const OnboardingScreen();
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
                final accountAddress = state.pathParameters['account']!;

                return MyAccount(accountAddress: accountAddress);
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
                    GoRoute(
                      name: 'PlaceOrder',
                      path: '/order/:orderId',
                      builder: (context, state) {
                        final order = state.extra! as Order;

                        return OrderScreen(order: order);
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

                final extra = state.extra as Map<String, dynamic>;

                final customName = extra['name'] ?? '';
                final customPhone = extra['phone'] ?? '';
                final customPhoto = extra['photo'] as Uint8List?;
                final customImageUrl = extra['imageUrl'] as String?;

                return ChangeNotifierProvider(
                  create: (_) => TransactionsWithUserState(
                    withUserAddress: userAddress,
                    myAddress: myAddress,
                  ),
                  child: InteractionWithUserScreen(
                    customName: customName,
                    customPhone: customPhone,
                    customPhoto: customPhoto,
                    customImageUrl: customImageUrl,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
