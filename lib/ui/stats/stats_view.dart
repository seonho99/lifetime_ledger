import 'package:flutter/material.dart';

/// 통계 화면 (미구현)
class StatsView extends StatelessWidget {
  const StatsView({super.key});

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
          ),
          
          // Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '통계 기능 준비 중',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      fontFamily: 'Noto Sans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '곧 멋진 차트와 분석을 제공할 예정입니다!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontFamily: 'Noto Sans',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        _buildFeatureItem('📊', '월별 지출/수입 차트'),
                        const SizedBox(height: 12),
                        _buildFeatureItem('📈', '카테고리별 분석'),
                        const SizedBox(height: 12),
                        _buildFeatureItem('💰', '예산 대비 지출 현황'),
                        const SizedBox(height: 12),
                        _buildFeatureItem('🎯', '절약 목표 설정'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontFamily: 'Noto Sans',
              ),
            ),
          ),
          Icon(
            Icons.schedule,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}