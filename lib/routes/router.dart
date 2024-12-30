import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// screens
import 'package:pay_app/screens/home/screen.dart';
import 'package:pay_app/screens/onboarding/screen.dart';
import 'package:pay_app/screens/account/view/screen.dart';
import 'package:pay_app/screens/account/edit/screen.dart';
import 'package:pay_app/screens/chat/place/screen.dart';
import 'package:pay_app/screens/chat/place/menu/screen.dart';
import 'package:pay_app/screens/chat/user/screen.dart';

// state
import 'package:pay_app/state/checkout.dart';

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
            return const OnboardingScreen();
          },
        ),
        GoRoute(
          name: 'Home',
          path: '/:id', // user id from supabase
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            // state.pathParameters['id']!
            return const HomeScreen();
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
              name: 'ChatWithPlace',
              path: '/place/:placeId',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) {
                return const ChatWithPlaceScreen();
              },
              routes: [
                GoRoute(
                  name: 'PlaceMenu',
                  path: '/menu',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final userId = int.parse(state.pathParameters['id']!);
                    final placeId = int.parse(state.pathParameters['placeId']!);

                    return ChangeNotifierProvider(
                      key: Key('menu-$userId-$placeId'),
                      create: (_) => CheckoutState(
                        userId: userId,
                        placeId: placeId,
                      ),
                      child: const PlaceMenuScreen(),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              name: 'ChatWithUser',
              path: '/user/:accountAddress',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) {
                return const ChatWithUserScreen();
              },
            ),
          ],
        ),
      ],
    );
