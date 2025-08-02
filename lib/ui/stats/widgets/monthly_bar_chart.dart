import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../stats_viewmodel.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<MonthlyStats> data;
  final double maxAmount;

  const MonthlyBarChart({
    super.key,
    required this.data,
    required this.maxAmount,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###', 'ko_KR');
    
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 범례
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('수입', Colors.green),
              const SizedBox(width: 20),
              _buildLegendItem('지출', Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          
          // 차트
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((stat) => _buildBarGroup(stat, numberFormat)).toList(),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 월 라벨
          Row(
            children: data.map((stat) => _buildMonthLabel(stat.monthName)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF737373),
          ),
        ),
      ],
    );
  }

  Widget _buildBarGroup(MonthlyStats stat, NumberFormat numberFormat) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 수입 바
            if (stat.income > 0)
              Tooltip(
                message: '수입: ${numberFormat.format(stat.income)}원',
                child: Container(
                  width: double.infinity,
                  height: maxAmount > 0 ? (stat.income / maxAmount) * 200 : 0,
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            
            // 지출 바
            if (stat.expense > 0)
              Tooltip(
                message: '지출: ${numberFormat.format(stat.expense)}원',
                child: Container(
                  width: double.infinity,
                  height: maxAmount > 0 ? (stat.expense / maxAmount) * 200 : 0,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthLabel(String monthName) {
    return Expanded(
      child: Center(
        child: Text(
          monthName,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF737373),
          ),
        ),
      ),
    );
  }
}