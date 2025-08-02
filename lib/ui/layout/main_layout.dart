import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/route/routes.dart';

/// 바텀 네비게이션을 포함한 메인 레이아웃
class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    int selectedIndex = _getSelectedIndex(location);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(
            color: Color(0xFFEDEDED),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Row(
        children: [
          Expanded(
            child: _buildNavItem(
              icon: Icons.home_outlined,
              label: '홈',
              isActive: selectedIndex == 0,
              onTap: () => context.go(Routes.home),
            ),
          ),
          Expanded(
            child: _buildNavItem(
              icon: Icons.savings_outlined,
              label: '내역',
              isActive: selectedIndex == 1,
              onTap: () => context.go(Routes.history),
            ),
          ),
          Expanded(
            child: _buildNavItem(
              icon: Icons.receipt_long_outlined,
              label: '통계',
              isActive: selectedIndex == 2,
              onTap: () => context.go(Routes.stats),
            ),
          ),
          Expanded(
            child: _buildNavItem(
              icon: Icons.person_outline,
              label: '설정',
              isActive: selectedIndex == 3,
              onTap: () => context.go(Routes.settings),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              color: isActive ? Colors.blue.shade50 : Colors.transparent,
            ),
            child: Column(
              children: [
                Container(
                  height: 32,
                  child: Icon(
                    icon,
                    size: 24,
                    color: isActive ? Colors.blue.shade600 : const Color(0xFF737373),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.blue.shade600 : const Color(0xFF737373),
                    fontFamily: 'Noto Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/home':
        return 0;
      case '/history':
        return 1;
      case '/stats':
        return 2;
      case '/settings':
        return 3;
      default:
        return 0;
    }
  }
}