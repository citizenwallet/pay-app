import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/screens/home/screen.dart';
import 'package:pay_app/screens/onboarding/screen.dart';

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
          path: '/:id',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            // state.pathParameters['id']!
            return const HomeScreen();
          },
        ),
      ],
    );
