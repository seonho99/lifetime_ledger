import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/route/routes.dart';

/// Main Screen (메인 가계부 화면)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 24,
                      color: Color(0xFF141414),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(right: 48),
                      child: const Text(
                        'Lifetime Ledger',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF141414),
                          fontFamily: 'Noto Sans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Account Info Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(64),
                            color: Colors.blue.shade100,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // User Info
                        Column(
                          children: const [
                            Text(
                              '나의 가계부',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF141414),
                                fontFamily: 'Noto Sans',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '오늘도 알뜰하게!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF737373),
                                fontFamily: 'Noto Sans',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '총 자산: ₩1,234,567',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF141414),
                                fontFamily: 'Noto Sans',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats Cards Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDBDBDB)),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '이번 달 지출',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF141414),
                              fontFamily: 'Noto Sans',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '₩234,567',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                              fontFamily: 'Noto Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDBDBDB)),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '이번 달 수입',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF141414),
                              fontFamily: 'Noto Sans',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '₩1,469,000',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                              fontFamily: 'Noto Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Recent Transactions Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              alignment: Alignment.centerLeft,
              child: const Text(
                '최근 거래내역',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF141414),
                  fontFamily: 'Noto Sans',
                ),
              ),
            ),

            // Transactions List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildTransactionItem(
                    name: '카페 아메리카노',
                    type: '식비',
                    amount: '-₩4,500',
                    color: Colors.orange,
                    icon: Icons.local_cafe,
                  ),
                  _buildTransactionItem(
                    name: '월급',
                    type: '수입',
                    amount: '+₩2,500,000',
                    color: Colors.green,
                    icon: Icons.work,
                  ),
                  _buildTransactionItem(
                    name: '지하철 교통비',
                    type: '교통',
                    amount: '-₩1,450',
                    color: Colors.blue,
                    icon: Icons.train,
                  ),
                  _buildTransactionItem(
                    name: '점심 식사',
                    type: '식비',
                    amount: '-₩12,000',
                    color: Colors.orange,
                    icon: Icons.restaurant,
                  ),
                ],
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          // 수입 추가 기능
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '수입 추가',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Noto Sans',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          // 지출 추가 기능
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '지출 추가',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Noto Sans',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFEDEDED),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    label: '홈',
                    isActive: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _buildNavItem(
                    icon: Icons.list_alt_outlined,
                    label: '내역',
                    isActive: _selectedIndex == 1,
                    onTap: () {
                      setState(() => _selectedIndex = 1);
                      context.go(Routes.history);
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.bar_chart_outlined,
                    label: '통계',
                    isActive: _selectedIndex == 2,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    label: '설정',
                    isActive: _selectedIndex == 3,
                    onTap: () {
                      setState(() => _selectedIndex = 3);
                      _showSettingsMenu(context);
                    },
                  ),
                ],
              ),
            ),

            // Bottom spacing
            Container(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String name,
    required String type,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF141414),
                      fontFamily: 'Noto Sans',
                    ),
                  ),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF737373),
                      fontFamily: 'Noto Sans',
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: amount.startsWith('+') ? Colors.green : Colors.red,
              fontFamily: 'Noto Sans',
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

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                '설정',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Noto Sans',
                ),
              ),
              const SizedBox(height: 20),
              
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: '비밀번호 변경',
                onTap: () {
                  Navigator.pop(context);
                  context.go(Routes.changePassword);
                },
              ),
              
              _buildSettingItem(
                icon: Icons.logout_outlined,
                title: '로그아웃',
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Noto Sans',
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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