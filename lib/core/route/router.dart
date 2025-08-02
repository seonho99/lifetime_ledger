// lib/core/route/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/auth/signin/signin_screen.dart';
import '../../ui/auth/signup/signup_screen.dart';
import '../../ui/auth/password/change_password_screen.dart';
import '../../ui/history/history_view.dart';
import '../../ui/home/home_view.dart';
import '../../ui/stats/stats_view.dart';
import '../../ui/settings/settings_view.dart';
import '../../ui/layout/main_layout.dart';
import '../../ui/splash/splash_screen.dart';
import '../../ui/income/add_income_screen.dart';
import '../../ui/expense/add_expense_screen.dart';
import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.splash,
  routes: [
    // 스플래시 화면
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // 인증 관련 라우트들 (독립된 라우트로 분리)
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) => const SignInScreen(),
    ),

    GoRoute(
      path: Routes.signUp,
      builder: (context, state) => const SignUpScreen(),
    ),

    // 비밀번호 변경
    GoRoute(
      path: Routes.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),

    // 수입 추가 (모달 형태)
    GoRoute(
      path: Routes.addIncome,
      builder: (context, state) => const AddIncomeScreen(),
    ),

    // 지출 추가 (모달 형태)
    GoRoute(
      path: Routes.addExpense,
      builder: (context, state) => const AddExpenseScreen(),
    ),

    // 메인 앱 ShellRoute (바텀 네비게이션 포함)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        // 홈 화면
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const HomeView(),
        ),
        
        // 내역 화면
        GoRoute(
          path: Routes.history,
          builder: (context, state) => const HistoryView(),
        ),
        
        // 통계 화면
        GoRoute(
          path: Routes.stats,
          builder: (context, state) => const StatsView(),
        ),
        
        // 설정 화면
        GoRoute(
          path: Routes.settings,
          builder: (context, state) => const SettingsView(),
        ),
      ],
    ),
  ],
);