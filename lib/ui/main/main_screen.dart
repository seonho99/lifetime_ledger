import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/route/routes.dart';

/// Main Screen (메인 홈 화면)
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Lifetime Ledger',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: 'Noto Sans',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              // 환영 메시지
              const Text(
                '환영합니다!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Noto Sans',
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                '평생 가계부 앱입니다.\n아직 개발 중인 화면입니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'Noto Sans',
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 60),

              // 네비게이션 버튼들
              Column(
                children: [
                  _buildNavigationButton(
                    context,
                    icon: Icons.history,
                    title: '거래 내역',
                    subtitle: '수입과 지출 기록을 확인해보세요',
                    onTap: () => context.go(Routes.history),
                    color: Colors.green,
                  ),

                  const SizedBox(height: 16),

                  _buildNavigationButton(
                    context,
                    icon: Icons.settings,
                    title: '설정',
                    subtitle: '앱 설정을 변경해보세요',
                    onTap: () => context.go(Routes.settings),
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 16),

                  _buildNavigationButton(
                    context,
                    icon: Icons.lock,
                    title: '비밀번호 변경',
                    subtitle: '계정 보안을 강화해보세요',
                    onTap: () => context.go(Routes.changePassword),
                    color: Colors.red,
                  ),
                ],
              ),

              const Spacer(),

              // 로그아웃 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // 로그아웃 처리 (임시)
                    _showLogoutDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontFamily: 'Noto Sans',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        required Color color,
      }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'Noto Sans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: 'Noto Sans',
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '로그아웃',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            '정말 로그아웃하시겠습니까?',
            style: TextStyle(
              fontFamily: 'Noto Sans',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Noto Sans',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 로그인 화면으로 이동
                context.go(Routes.signIn);
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}