import 'package:flutter/material.dart';
import '../../domain/model/history.dart';
import '../../domain/usecase/get_histories_by_month_usecase.dart';
import '../../core/result/result.dart';
import 'widgets/category_donut_chart.dart';

class StatsViewModel extends ChangeNotifier {
  final GetHistoriesByMonthUseCase _getHistoriesByMonthUseCase;

  StatsViewModel({
    required GetHistoriesByMonthUseCase getHistoriesByMonthUseCase,
  }) : _getHistoriesByMonthUseCase = getHistoriesByMonthUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  List<MonthlyStats> _monthlyStats = [];
  List<History> _currentMonthHistories = [];
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  bool _isYearlyView = true; // true: 년도별, false: 월별

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MonthlyStats> get monthlyStats => _monthlyStats;
  List<History> get currentMonthHistories => _currentMonthHistories;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  bool get isYearlyView => _isYearlyView;

  Future<void> loadYearlyStats(int year) async {
    _selectedYear = year;
    _isYearlyView = true;
    _isLoading = true;
    _errorMessage = null;
    _currentMonthHistories = []; // 연간 뷰에서는 히스토리 초기화
    notifyListeners();

    try {
      final List<MonthlyStats> stats = [];
      
      for (int month = 1; month <= 12; month++) {
        final result = await _getHistoriesByMonthUseCase(year: year, month: month);
        
        switch (result) {
          case Success<List<History>>():
            final histories = result.data;
            double totalIncome = 0;
            double totalExpense = 0;
            
            for (final history in histories) {
              if (history.type == HistoryType.income) {
                totalIncome += history.amount;
              } else {
                totalExpense += history.amount;
              }
            }
            
            stats.add(MonthlyStats(
              month: month,
              income: totalIncome,
              expense: totalExpense,
            ));
            
          case Error<List<History>>():
            _errorMessage = result.failure.message;
            break;
        }
      }
      
      _monthlyStats = stats;
    } catch (e) {
      _errorMessage = '데이터를 불러오는 중 오류가 발생했습니다';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeYear(int year) {
    if (_isYearlyView) {
      loadYearlyStats(year);
    } else {
      loadMonthlyStats(year, _selectedMonth);
    }
  }

  void changeMonth(int month) {
    loadMonthlyStats(_selectedYear, month);
  }

  void goToPreviousYear() {
    changeYear(_selectedYear - 1);
  }

  void goToNextYear() {
    changeYear(_selectedYear + 1);
  }

  void goToPreviousMonth() {
    int newMonth = _selectedMonth - 1;
    int newYear = _selectedYear;
    
    if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }
    
    loadMonthlyStats(newYear, newMonth);
  }

  void goToNextMonth() {
    int newMonth = _selectedMonth + 1;
    int newYear = _selectedYear;
    
    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    }
    
    loadMonthlyStats(newYear, newMonth);
  }

  void toggleViewMode() {
    _isYearlyView = !_isYearlyView;
    if (_isYearlyView) {
      loadYearlyStats(_selectedYear);
    } else {
      loadMonthlyStats(_selectedYear, _selectedMonth);
    }
  }

  Future<void> loadMonthlyStats(int year, int month) async {
    _selectedYear = year;
    _selectedMonth = month;
    _isYearlyView = false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _getHistoriesByMonthUseCase(year: year, month: month);
      
      switch (result) {
        case Success<List<History>>():
          final histories = result.data;
          _currentMonthHistories = histories; // 현재 월 히스토리 저장
          
          double totalIncome = 0;
          double totalExpense = 0;
          
          for (final history in histories) {
            if (history.type == HistoryType.income) {
              totalIncome += history.amount;
            } else {
              totalExpense += history.amount;
            }
          }
          
          // 단일 월의 통계를 monthlyStats에 저장
          _monthlyStats = [MonthlyStats(
            month: month,
            income: totalIncome,
            expense: totalExpense,
          )];
          
        case Error<List<History>>():
          _errorMessage = result.failure.message;
          _monthlyStats = [];
          _currentMonthHistories = [];
      }
    } catch (e) {
      _errorMessage = '데이터를 불러오는 중 오류가 발생했습니다';
      _monthlyStats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double get maxAmount {
    if (_monthlyStats.isEmpty) return 0;
    
    double max = 0;
    for (final stat in _monthlyStats) {
      if (stat.income > max) max = stat.income;
      if (stat.expense > max) max = stat.expense;
    }
    return max;
  }

  double get totalYearlyIncome {
    if (_isYearlyView) {
      return _monthlyStats.fold(0, (sum, stat) => sum + stat.income);
    } else {
      return _monthlyStats.isNotEmpty ? _monthlyStats.first.income : 0;
    }
  }

  double get totalYearlyExpense {
    if (_isYearlyView) {
      return _monthlyStats.fold(0, (sum, stat) => sum + stat.expense);
    } else {
      return _monthlyStats.isNotEmpty ? _monthlyStats.first.expense : 0;
    }
  }

  double get yearlyBalance {
    return totalYearlyIncome - totalYearlyExpense;
  }

  String get selectedPeriodString {
    if (_isYearlyView) {
      return '${_selectedYear}년';
    } else {
      return '${_selectedYear}년 ${_selectedMonth}월';
    }
  }

  List<CategoryData> get expenseCategoryData {
    if (_isYearlyView || _currentMonthHistories.isEmpty) {
      return [];
    }

    // 지출 항목만 필터링
    final expenseHistories = _currentMonthHistories
        .where((history) => history.type == HistoryType.expense)
        .toList();

    if (expenseHistories.isEmpty) {
      return [];
    }

    // 카테고리별 금액 집계
    final Map<String, double> categoryAmounts = {};
    
    for (final history in expenseHistories) {
      final category = _normalizeCategory(history.categoryId ?? '기타');
      categoryAmounts[category] = (categoryAmounts[category] ?? 0) + history.amount;
    }

    // CategoryData 리스트 생성
    final List<CategoryData> categoryData = [];
    final colors = _getCategoryColors();
    
    categoryAmounts.forEach((category, amount) {
      if (amount > 0) {
        categoryData.add(CategoryData(
          category: category,
          amount: amount,
          color: colors[category] ?? Colors.grey,
        ));
      }
    });

    // 금액 기준 내림차순 정렬
    categoryData.sort((a, b) => b.amount.compareTo(a.amount));
    
    return categoryData;
  }

  double get totalExpenseAmount {
    if (_isYearlyView || _currentMonthHistories.isEmpty) {
      return 0;
    }

    return _currentMonthHistories
        .where((history) => history.type == HistoryType.expense)
        .fold(0, (sum, history) => sum + history.amount);
  }

  String _normalizeCategory(String category) {
    // 지출 카테고리명 정규화
    final normalized = category.toLowerCase().trim();
    
    if (normalized.contains('식비') || normalized.contains('음식') || normalized.contains('food')) {
      return '식비';
    } else if (normalized.contains('교통') || normalized.contains('transport')) {
      return '교통';
    } else if (normalized.contains('쇼핑') || normalized.contains('shopping')) {
      return '쇼핑';
    } else if (normalized.contains('주거') || normalized.contains('집') || normalized.contains('housing')) {
      return '주거';
    } else if (normalized.contains('의료') || normalized.contains('건강') || normalized.contains('medical')) {
      return '의료';
    } else if (normalized.contains('교육') || normalized.contains('education')) {
      return '교육';
    } else if (normalized.contains('문화') || normalized.contains('여가') || normalized.contains('entertainment')) {
      return '문화/여가';
    } else {
      return '기타';
    }
  }

  Map<String, Color> _getCategoryColors() {
    return {
      '식비': const Color(0xFFFF6B6B),      // 빨강
      '교통': const Color(0xFF4ECDC4),      // 민트
      '쇼핑': const Color(0xFFFFE66D),      // 노랑
      '주거': const Color(0xFFA8E6CF),      // 연두
      '의료': const Color(0xFFFFB4B4),      // 분홍
      '교육': const Color(0xFFB4B4FF),      // 연보라
      '문화/여가': const Color(0xFFFFB347),  // 주황
      '기타': const Color(0xFF95A5A6),      // 회색
    };
  }
}

class MonthlyStats {
  final int month;
  final double income;
  final double expense;

  MonthlyStats({
    required this.month,
    required this.income,
    required this.expense,
  });

  double get balance => income - expense;
  
  String get monthName {
    const months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    return months[month - 1];
  }
}