// lib/ui/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/route/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // 2초 대기 (스플래시 효과)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 인증 상태 확인
    final authViewModel = context.read<AuthViewModel>();
    final isLoggedIn = authViewModel.isLoggedIn;

    if (isLoggedIn) {
      // 로그인되어 있으면 메인으로
      context.go(Routes.history);
    } else {
      // 로그인되어 있지 않으면 로그인 화면으로
      context.go(Routes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고
            Icon(
              Icons.account_balance_wallet,
              size: 100,
              color: Colors.blue.shade600,
            ),
            const SizedBox(height: 24),

            // 앱 이름
            const Text(
              'Lifetime Ledger',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // 부제목
            Text(
              '평생 가계부',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 50),

            // 로딩 인디케이터
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ],
        ),
      ),
    );
  }
}