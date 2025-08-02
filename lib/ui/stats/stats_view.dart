import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/route/routes.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header Section
          _buildHeader(),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '통계 기능',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF141414),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '다양한 방식으로 가계부 데이터를 분석해보세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF737373),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Statistics Menu Items
                  _buildMenuItems(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            height: 48,
            child: const Icon(
              Icons.bar_chart,
              size: 24,
              color: Color(0xFF141414),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(right: 48),
              child: const Text(
                '가계부 통계',
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
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          icon: Icons.bar_chart,
          emoji: '📊',
          title: '월별 지출/수입 차트',
          subtitle: '연간 월별 수입과 지출을 차트로 확인',
          onTap: () => context.push(Routes.monthlyChart),
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          context,
          icon: Icons.pie_chart,
          emoji: '📈',
          title: '카테고리별 분석',
          subtitle: '지출 카테고리별 상세 분석',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('곧 출시될 기능입니다!')),
            );
          },
          isComingSoon: true,
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          context,
          icon: Icons.savings,
          emoji: '🎯',
          title: '예산 관리 및 절약 목표',
          subtitle: '예산 설정과 절약 목표 달성 현황',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('곧 출시될 기능입니다!')),
            );
          },
          isComingSoon: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDBDBDB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isComingSoon 
                    ? Colors.grey.shade100 
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 24,
                    color: isComingSoon ? Colors.grey : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isComingSoon 
                                ? Colors.grey.shade600 
                                : const Color(0xFF141414),
                          ),
                        ),
                      ),
                      if (isComingSoon)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '준비중',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isComingSoon 
                          ? Colors.grey.shade500 
                          : const Color(0xFF737373),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right,
              color: isComingSoon 
                  ? Colors.grey.shade400 
                  : const Color(0xFF737373),
            ),
          ],
        ),
      ),
    );
  }
}