// lib/core/route/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/auth/signin/signin_screen.dart';
import '../../ui/auth/signup/signup_screen.dart';
import '../../ui/auth/password/change_password_screen.dart';
import '../../ui/history/history_screen.dart';
import '../../ui/main/main_screen.dart';
import '../../ui/splash/splash_screen.dart';
import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.splash,
  routes: [
    // 스플래시 화면
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // 인증 관련 라우트
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) => const SignInScreen(),
      routes: [
        // signIn의 하위 라우트로 signUp 설정
        GoRoute(
          path: Routes.signUp, // 'sign_up' (상대 경로)
          builder: (context, state) => const SignUpScreen(),
        ),
      ],
    ),

    // 비밀번호 재설정
    GoRoute(
      path: Routes.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),

    // 비밀번호 변경
    GoRoute(
      path: Routes.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),

    // 메인 앱 라우트들
    GoRoute(
      path: Routes.main,
      builder: (context, state) => const MainScreen(),
    ),

    GoRoute(
      path: Routes.history,
      builder: (context, state) => const HistoryScreen(),
    ),


  ],


);

