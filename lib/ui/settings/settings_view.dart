import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/route/routes.dart';

/// 설정 화면
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                    Icons.settings,
                    size: 24,
                    color: Color(0xFF141414),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(right: 48),
                    child: const Text(
                      '설정',
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
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 프로필 섹션
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '사용자',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF141414),
                                  fontFamily: 'Noto Sans',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'user@example.com',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontFamily: 'Noto Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 설정 메뉴들
                  _buildSettingsSection(
                    title: '계정',
                    items: [
                      _SettingsItem(
                        icon: Icons.lock_outline,
                        title: '비밀번호 변경',
                        onTap: () => context.go(Routes.changePassword),
                      ),
                      _SettingsItem(
                        icon: Icons.notifications_outlined,
                        title: '알림 설정',
                        onTap: () => _showComingSoon(context),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSettingsSection(
                    title: '가계부',
                    items: [
                      _SettingsItem(
                        icon: Icons.category_outlined,
                        title: '카테고리 관리',
                        onTap: () => _showComingSoon(context),
                      ),
                      _SettingsItem(
                        icon: Icons.backup_outlined,
                        title: '데이터 백업',
                        onTap: () => _showComingSoon(context),
                      ),
                      _SettingsItem(
                        icon: Icons.file_download_outlined,
                        title: '데이터 내보내기',
                        onTap: () => _showComingSoon(context),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSettingsSection(
                    title: '정보',
                    items: [
                      _SettingsItem(
                        icon: Icons.info_outline,
                        title: '앱 정보',
                        subtitle: 'v1.0.0',
                        onTap: () => _showAppInfo(context),
                      ),
                      _SettingsItem(
                        icon: Icons.privacy_tip_outlined,
                        title: '개인정보 처리방침',
                        onTap: () => _showComingSoon(context),
                      ),
                      _SettingsItem(
                        icon: Icons.description_outlined,
                        title: '이용약관',
                        onTap: () => _showComingSoon(context),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 로그아웃 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        '로그아웃',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Noto Sans',
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontFamily: 'Noto Sans',
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Noto Sans',
                      ),
                    ),
                    subtitle: item.subtitle != null
                        ? Text(
                            item.subtitle!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: 'Noto Sans',
                            ),
                          )
                        : null,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 72,
                      color: Colors.grey.shade200,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '곧 제공될 예정입니다!',
          style: TextStyle(fontFamily: 'Noto Sans'),
        ),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Lifetime Ledger',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            '평생을 함께하는 가계부 앱\n\n버전: 1.0.0\n개발자: Your Team',
            style: TextStyle(
              fontFamily: 'Noto Sans',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                ),
              ),
            ),
          ],
        );
      },
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

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}