import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../stats_viewmodel.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/category_donut_chart.dart';

class MonthlyChartView extends StatefulWidget {
  const MonthlyChartView({super.key});

  @override
  State<MonthlyChartView> createState() => _MonthlyChartViewState();
}

class _MonthlyChartViewState extends State<MonthlyChartView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<StatsViewModel>(context, listen: false);
      viewModel.loadYearlyStats(DateTime.now().year);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFAFAFA),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF141414)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              '월별 지출/수입 차트',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF141414),
                fontFamily: 'Noto Sans',
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Loading Indicator
              if (viewModel.isLoading)
                const LinearProgressIndicator(
                  backgroundColor: Color(0xFFEDEDED),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF141414)),
                ),
              
              // Error Message
              if (viewModel.errorMessage != null)
                _buildErrorMessage(viewModel.errorMessage!),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Year Selector
                      _buildYearSelector(viewModel),
                      
                      const SizedBox(height: 16),
                      
                      // Month Selector
                      _buildMonthSelector(viewModel),
                      
                      const SizedBox(height: 20),
                      
                      // Summary Cards
                      _buildSummaryCards(viewModel),
                      
                      const SizedBox(height: 20),
                      
                      // Monthly Chart
                      _buildMonthlyChart(viewModel),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(StatsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '년도 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF141414),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: viewModel.goToPreviousYear,
                icon: const Icon(Icons.chevron_left, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFDBDBDB)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showYearPicker(context, viewModel),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDBDBDB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${viewModel.selectedYear}년',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF141414),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: viewModel.goToNextYear,
                icon: const Icon(Icons.chevron_right, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFDBDBDB)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(StatsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '월 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF141414),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDBDBDB)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 13, // 12개월 + "전체" 옵션
            itemBuilder: (context, index) {
              if (index == 0) {
                // "전체" 옵션
                final isSelected = viewModel.isYearlyView;
                return GestureDetector(
                  onTap: () => viewModel.loadYearlyStats(viewModel.selectedYear),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.blue : const Color(0xFFDBDBDB),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '전체',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF737373),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                // 1-12월
                final month = index;
                final isSelected = !viewModel.isYearlyView && viewModel.selectedMonth == month;
                return GestureDetector(
                  onTap: () => viewModel.loadMonthlyStats(viewModel.selectedYear, month),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.blue : const Color(0xFFDBDBDB),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${month}월',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF737373),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(StatsViewModel viewModel) {
    final numberFormat = NumberFormat('#,###', 'ko_KR');
    final periodLabel = viewModel.isYearlyView ? '연간' : '월간';
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            '$periodLabel 수입',
            '${numberFormat.format(viewModel.totalYearlyIncome)}원',
            Colors.green,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            '$periodLabel 지출',
            '${numberFormat.format(viewModel.totalYearlyExpense)}원',
            Colors.red,
            Icons.trending_down,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon) {
    return Container(
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF737373),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(StatsViewModel viewModel) {
    final chartTitle = viewModel.isYearlyView ? '월별 차트' : '선택된 월 요약';
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.bar_chart,
                  color: Color(0xFF141414),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  chartTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF141414),
                  ),
                ),
              ],
            ),
          ),
          if (viewModel.isYearlyView) 
            // 연간 차트 표시
            if (viewModel.monthlyStats.isNotEmpty)
              MonthlyBarChart(
                data: viewModel.monthlyStats,
                maxAmount: viewModel.maxAmount,
              )
            else
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.bar_chart_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '데이터가 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '선택한 연도에 거래 내역이 없습니다',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
          else
            // 월간 보기일 때는 지출 카테고리 도넛 차트
            CategoryDonutChart(
              data: viewModel.expenseCategoryData,
              totalAmount: viewModel.totalExpenseAmount,
            ),
        ],
      ),
    );
  }

  void _showYearPicker(BuildContext context, StatsViewModel viewModel) {
    final currentYear = DateTime.now().year;
    final years = List.generate(21, (index) => currentYear - 10 + index);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('년도 선택'),
          content: Container(
            width: 300,
            height: 400,
            child: ListView.builder(
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                final isSelected = year == viewModel.selectedYear;
                
                return ListTile(
                  title: Text(
                    '${year}년',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.blue : const Color(0xFF141414),
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    viewModel.changeYear(year);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }
}