import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/models/order.dart';
import 'package:pay_app/screens/account/settings/screen.dart';
import 'package:pay_app/screens/account/settings/language_screen.dart';
import 'package:pay_app/screens/interactions/place/order/screen.dart';
import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/state/onboarding.dart';
import 'package:pay_app/state/state.dart';
import 'package:provider/provider.dart';

// screens
import 'package:pay_app/screens/home/screen.dart';
import 'package:pay_app/screens/onboarding/screen.dart';
import 'package:pay_app/screens/account/edit/screen.dart';
import 'package:pay_app/screens/interactions/place/screen.dart';
import 'package:pay_app/screens/interactions/place/menu/screen.dart';
import 'package:pay_app/screens/interactions/user/screen.dart';

// state
import 'package:pay_app/state/transactions_with_user/transactions_with_user.dart';
import 'package:web3dart/web3dart.dart';

String addTimestampToUrl(String url) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  if (url.contains('?')) {
    return '$url&timestamp=$timestamp';
  }

  return '$url?timestamp=$timestamp';
}

Future<String?> redirectHandler(
    BuildContext context, GoRouterState state) async {
  final url = state.uri.toString();
  final deeplinkDomains = dotenv.get('DEEPLINK_DOMAINS').split(',');

  final connectedAccountAddress =
      context.read<OnboardingState>().connectedAccountAddress;

  for (final deeplinkDomain in deeplinkDomains) {
    if (url.contains(deeplinkDomain) && !url.contains('?deepLink=')) {
      if (connectedAccountAddress == null) {
        return '/';
      }

      // add timestamp to url to make it unique
      final uniqueUrl = addTimestampToUrl(url);
      return '/${connectedAccountAddress.hexEip55}?deepLink=${Uri.encodeComponent(uniqueUrl)}';
    }
  }

  return url;
}

GoRouter createRouter(
  GlobalKey<NavigatorState> rootNavigatorKey,
  GlobalKey<NavigatorState> appShellNavigatorKey,
  GlobalKey<NavigatorState> placeShellNavigatorKey,
  List<NavigatorObserver> observers, {
  required Config config,
  EthereumAddress? accountAddress,
}) =>
    GoRouter(
      initialLocation:
          accountAddress != null ? '/${accountAddress.hexEip55}' : '/',
      debugLogDiagnostics: kDebugMode,
      navigatorKey: rootNavigatorKey,
      observers: observers,
      redirect: redirectHandler,
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
          name: 'CardOrder',
          path: '/order/:orderId',
          builder: (context, state) {
            final order = state.extra! as Order;

            return OrderScreen(order: order);
          },
        ),
        ShellRoute(
          navigatorKey: appShellNavigatorKey,
          builder: (context, state, child) =>
              provideAccountState(context, state, config, child),
          routes: [
            GoRoute(
              name: 'Home',
              path: '/:account',
              builder: (context, state) {
                final accountAddress = state.pathParameters['account']!;
                final deepLink = state.uri.queryParameters['deepLink'];

                return HomeScreen(
                  accountAddress: accountAddress,
                  deepLink: deepLink,
                );
              },
            ),
            GoRoute(
              name: 'MyAccountSettings',
              path: '/:account/my-account/settings',
              builder: (context, state) {
                final accountAddress = state.pathParameters['account']!;

                return MyAccountSettings(accountAddress: accountAddress);
              },
              routes: [
                GoRoute(
                  name: 'LanguageSettings',
                  path: '/language',
                  builder: (context, state) {
                    return const LanguageScreen();
                  },
                ),
              ],
            ),
            GoRoute(
              name: 'EditMyAccount',
              path: '/:account/my-account/edit',
              builder: (context, state) {
                final accountAddress = state.pathParameters['account']!;

                return const EditAccountScreen();
              },
            ),
            ShellRoute(
              navigatorKey: placeShellNavigatorKey,
              builder: (context, state, child) =>
                  providePlaceState(context, state, config, child),
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
