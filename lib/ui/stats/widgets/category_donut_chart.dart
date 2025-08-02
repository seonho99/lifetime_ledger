import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';

class CategoryData {
  final String category;
  final double amount;
  final Color color;

  CategoryData({
    required this.category,
    required this.amount,
    required this.color,
  });
}

class CategoryDonutChart extends StatelessWidget {
  final List<CategoryData> data;
  final double totalAmount;

  const CategoryDonutChart({
    super.key,
    required this.data,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || totalAmount <= 0) {
      return _buildEmptyChart();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 도넛 차트
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: DonutChartPainter(data: data, totalAmount: totalAmount),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 범례
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '지출 데이터가 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final numberFormat = NumberFormat('#,###', 'ko_KR');
    
    return Column(
      children: data.map((item) {
        final percentage = (item.amount / totalAmount * 100).toStringAsFixed(1);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // 색상 표시
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              
              // 카테고리명
              Expanded(
                child: Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF141414),
                  ),
                ),
              ),
              
              // 퍼센트
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 금액
              Text(
                '${numberFormat.format(item.amount)}원',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF141414),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<CategoryData> data;
  final double totalAmount;

  DonutChartPainter({
    required this.data,
    required this.totalAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final innerRadius = radius * 0.6; // 도넛 구멍 크기

    double startAngle = -pi / 2; // 12시 방향부터 시작

    for (final item in data) {
      final sweepAngle = (item.amount / totalAmount) * 2 * pi;
      
      // 외부 원호
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      final path = Path();
      
      // 외부 호 그리기
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      );
      
      // 내부 호로 연결
      final endAngle = startAngle + sweepAngle;
      final innerEndX = center.dx + innerRadius * cos(endAngle);
      final innerEndY = center.dy + innerRadius * sin(endAngle);
      path.lineTo(innerEndX, innerEndY);
      
      // 내부 호 그리기 (역방향)
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        endAngle,
        -sweepAngle,
        false,
      );
      
      path.close();
      
      canvas.drawPath(path, paint);
      
      startAngle += sweepAngle;
    }

    // 중앙 텍스트 (총 지출액)
    final numberFormat = NumberFormat('#,###', 'ko_KR');
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          const TextSpan(
            text: '총 지출\n',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF737373),
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: '${numberFormat.format(totalAmount)}원',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF141414),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}