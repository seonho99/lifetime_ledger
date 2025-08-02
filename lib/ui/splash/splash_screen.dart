import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    _navigateToSignIn();
  }

  Future<void> _navigateToSignIn() async {
    try {
      // 3초 대기 (스플래시 효과)
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      // 로그인 화면으로 이동
      print('🚀 Splash: Navigating to ${Routes.signIn}');
      context.go(Routes.signIn);
    } catch (e) {
      print('❌ Splash Error: $e');
      // 에러가 발생해도 로그인 화면으로 이동 시도
      if (mounted) {
        context.go(Routes.signIn);
      }
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
            // 앱 로고 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),

            // 앱 이름
            const Text(
              'Lifetime Ledger',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Noto Sans',
              ),
            ),
            const SizedBox(height: 12),

            // 부제목
            Text(
              '평생 가계부',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 60),

            // 로딩 점 3개 (정적)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLoadingDot(0),
                const SizedBox(width: 12),
                _buildLoadingDot(1),
                const SizedBox(width: 12),
                _buildLoadingDot(2),
              ],
            ),
            const SizedBox(height: 100),

            // 하단 텍스트
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontFamily: 'Noto Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDot(int index) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}