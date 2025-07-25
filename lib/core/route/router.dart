// lib/core/route/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/auth/signin/signin_screen.dart';
import '../../ui/auth/signup/signup_screen.dart';
import '../../ui/auth/password/change_password_screen.dart';
import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) {
        return const SignInScreen();
      },
      routes: [
        GoRoute(
          path: Routes.signUp,
          builder: (context, state) {
            return const SignUpScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: Routes.password,
      builder: (context, state) {
        return const PasswordResetScreen();
      },
    ),
    // 새로 추가: 비밀번호 변경 라우트
    GoRoute(
      path: Routes.changePassword,
      builder: (context, state) {
        return const ChangePasswordScreen();
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
                return const MainScreen();
              },
              routes: [
                // 메인 화면의 하위 라우트들
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            // 다른 브랜치의 라우트들
          ],
        ),
      ],
    ),
  ],
);