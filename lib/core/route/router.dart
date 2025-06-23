// lib/core/route/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) {
        return SignInScreen();
      },
      routes: [
        GoRoute(
          path: Routes.signUp,
          builder: (context, state) {
            return SignUpScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: Routes.password,
      builder: (context, state) {
        return PasswordResetScreen();
      },
    ),
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state, navigationShell) {
        return NavigationWidget(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.main,
              builder: (context, state) {
                return ();
              },
              routes: [


              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [

              ],
            ),
          ],
        ),
      ],
    ),
  ],
);