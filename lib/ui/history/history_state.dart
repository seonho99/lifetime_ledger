import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/history.dart';

part 'history_state.freezed.dart';

@freezed
class HistoryState with _$HistoryState {
  const HistoryState({
    required this.histories,
    required this.isLoading,
    this.errorMessage,
    this.selectedMonth,
    this.selectedYear,
    this.filterType,
  });

  final List<History> histories;
  final bool isLoading;
  final String? errorMessage;
  final int? selectedMonth;
  final int? selectedYear;
  final HistoryType? filterType;

  /// 초기 상태 생성
  factory HistoryState.initial() {
    final now = DateTime.now();
    return HistoryState(
      histories: [],
      isLoading: false,
      errorMessage: null,
      selectedMonth: now.month,
      selectedYear: now.year,
      filterType: null,
    );
  }

  /// 로딩 상태 생성
  factory HistoryState.loading() {
    final now = DateTime.now();
    return HistoryState(
      histories: [],
      isLoading: true,
      errorMessage: null,
      selectedMonth: now.month,
      selectedYear: now.year,
      filterType: null,
    );
  }

  /// 에러 상태 생성
  factory HistoryState.error(String message) {
    final now = DateTime.now();
    return HistoryState(
      histories: [],
      isLoading: false,
      errorMessage: message,
      selectedMonth: now.month,
      selectedYear: now.year,
      filterType: null,
    );
  }

  // 계산된 속성들
  bool get hasError => errorMessage != null;
  bool get isEmpty => histories.isEmpty && !isLoading;
  bool get hasData => histories.isNotEmpty;
  int get historyCount => histories.length;

  // 필터링된 내역들
  List<History> get filteredHistories {
    if (filterType == null) return histories;
    return histories.where((h) => h.type == filterType).toList();
  }

  // 총 수입
  double get totalIncome => histories
      .where((h) => h.isIncome)
      .map((h) => h.amount)
      .fold(0.0, (sum, amount) => sum + amount);

  // 총 지출
  double get totalExpense => histories
      .where((h) => h.isExpense)
      .map((h) => h.amount)
      .fold(0.0, (sum, amount) => sum + amount);

  // 잔액
  double get balance => totalIncome - totalExpense;

  // 선택된 월 문자열
  String get selectedMonthString {
    if (selectedMonth == null || selectedYear == null) return '';
    return '${selectedYear}년 ${selectedMonth}월';
  }
}