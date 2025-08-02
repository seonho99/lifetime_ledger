import 'package:flutter/material.dart';
import 'package:lifetime_ledger/core/result/result.dart';

import '../../domain/model/history.dart';
import '../../domain/usecase/add_history_usecase.dart';
import '../../domain/usecase/delete_history_usecase.dart';
import '../../domain/usecase/get_histories_by_month_usecase.dart';
import '../../domain/usecase/get_histories_usecase.dart';
import '../../domain/usecase/update_history_usecase.dart';
import 'state.dart';


class HistoryViewModel extends ChangeNotifier {
  final GetHistoriesUseCase _getHistoriesUseCase;
  final AddHistoryUseCase _addHistoryUseCase;
  final UpdateHistoryUseCase _updateHistoryUseCase;
  final DeleteHistoryUseCase _deleteHistoryUseCase;
  final GetHistoriesByMonthUseCase _getHistoriesByMonthUseCase;

  HistoryViewModel({
    required GetHistoriesUseCase getHistoriesUseCase,
    required AddHistoryUseCase addHistoryUseCase,
    required UpdateHistoryUseCase updateHistoryUseCase,
    required DeleteHistoryUseCase deleteHistoryUseCase,
    required GetHistoriesByMonthUseCase getHistoriesByMonthUseCase,
  }) : _getHistoriesUseCase = getHistoriesUseCase,
        _addHistoryUseCase = addHistoryUseCase,
        _updateHistoryUseCase = updateHistoryUseCase,
        _deleteHistoryUseCase = deleteHistoryUseCase,
        _getHistoriesByMonthUseCase = getHistoriesByMonthUseCase;

  HistoryState _state = HistoryState.initial();
  HistoryState get state => _state;

  // 편의 Getters
  List<History> get histories => _state.filteredHistories;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  String? get errorMessage => _state.errorMessage;
  double get totalIncome => _state.totalIncome;
  double get totalExpense => _state.totalExpense;
  double get balance => _state.balance;
  String get selectedMonthString => _state.selectedMonthString;
  
  // ✅ 전체 자산 계산 (모든 거래 내역 기준)
  double _totalAssets = 0.0;
  double get totalAssets => _totalAssets;

  void _updateState(HistoryState newState) {
    _state = newState;
    notifyListeners();
  }

  /// 모든 내역 로드
  Future<void> loadHistories() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    final result = await _getHistoriesUseCase();

    result.when(
      success: (histories) {
        _updateState(_state.copyWith(
          histories: histories,
          isLoading: false,
          errorMessage: null,
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  /// 월별 내역 로드
  Future<void> loadHistoriesByMonth(int year, int month) async {
    _updateState(_state.copyWith(
      isLoading: true,
      errorMessage: null,
      selectedYear: year,
      selectedMonth: month,
    ));

    final result = await _getHistoriesByMonthUseCase(year: year, month: month);

    result.when(
      success: (histories) {
        _updateState(_state.copyWith(
          histories: histories,
          isLoading: false,
          errorMessage: null,
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  /// 내역 추가
  Future<void> addHistory(History history) async {
    final result = await _addHistoryUseCase(history);

    result.when(
      success: (_) async {
        // 성공 시 현재 월 내역 새로고침
        final currentYear = _state.selectedYear ?? DateTime.now().year;
        final currentMonth = _state.selectedMonth ?? DateTime.now().month;
        await loadHistoriesByMonth(currentYear, currentMonth);
        // ✅ 전체 자산 재계산
        await calculateTotalAssets();
      },
      error: (failure) {
        _updateState(_state.copyWith(errorMessage: _getErrorMessage(failure)));
      },
    );
  }

  /// 내역 수정
  Future<void> updateHistory(History history) async {
    final result = await _updateHistoryUseCase(history);

    result.when(
      success: (_) async {
        // 성공 시 현재 월 내역 새로고침
        final currentYear = _state.selectedYear ?? DateTime.now().year;
        final currentMonth = _state.selectedMonth ?? DateTime.now().month;
        await loadHistoriesByMonth(currentYear, currentMonth);
        // ✅ 전체 자산 재계산
        await calculateTotalAssets();
      },
      error: (failure) {
        _updateState(_state.copyWith(errorMessage: _getErrorMessage(failure)));
      },
    );
  }

  /// 내역 삭제
  Future<void> deleteHistory(String id) async {
    final result = await _deleteHistoryUseCase(id);

    result.when(
      success: (_) async {
        // 성공 시 현재 월 내역 새로고침
        final currentYear = _state.selectedYear ?? DateTime.now().year;
        final currentMonth = _state.selectedMonth ?? DateTime.now().month;
        await loadHistoriesByMonth(currentYear, currentMonth);
        // ✅ 전체 자산 재계산
        await calculateTotalAssets();
      },
      error: (failure) {
        _updateState(_state.copyWith(errorMessage: _getErrorMessage(failure)));
      },
    );
  }

  /// 이전 달로 이동
  void goToPreviousMonth() {
    final currentYear = _state.selectedYear ?? DateTime.now().year;
    final currentMonth = _state.selectedMonth ?? DateTime.now().month;

    if (currentMonth == 1) {
      // 1월이면 전년 12월로
      loadHistoriesByMonth(currentYear - 1, 12);
    } else {
      // 이전 달로
      loadHistoriesByMonth(currentYear, currentMonth - 1);
    }
  }

  /// 다음 달로 이동
  void goToNextMonth() {
    final currentYear = _state.selectedYear ?? DateTime.now().year;
    final currentMonth = _state.selectedMonth ?? DateTime.now().month;

    if (currentMonth == 12) {
      // 12월이면 내년 1월로
      loadHistoriesByMonth(currentYear + 1, 1);
    } else {
      // 다음 달로
      loadHistoriesByMonth(currentYear, currentMonth + 1);
    }
  }

  /// 필터 설정
  void setFilter(HistoryType? filterType) {
    _updateState(_state.copyWith(filterType: filterType));
  }

  /// 에러 메시지 클리어
  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }

  /// 마지막 작업 재시도
  void retryLastAction() {
    clearError();
    final currentYear = _state.selectedYear ?? DateTime.now().year;
    final currentMonth = _state.selectedMonth ?? DateTime.now().month;
    loadHistoriesByMonth(currentYear, currentMonth);
  }

  /// Failure를 사용자 친화적 메시지로 변환
  String _getErrorMessage(failure) {
    // FailureMapper의 타입 확인 메서드들을 사용할 수 있지만
    // 여기서는 간단하게 failure의 message를 사용
    return failure.message ?? '알 수 없는 오류가 발생했습니다.';
  }

  /// ✅ 전체 자산 계산 (모든 거래 내역 기준)
  Future<void> calculateTotalAssets() async {
    try {
      print('💰 전체 자산 계산 시작');
      
      final result = await _getHistoriesUseCase.call();
      
      result.when(
        success: (allHistories) {
          double totalIncome = 0.0;
          double totalExpense = 0.0;
          
          for (final history in allHistories) {
            if (history.isIncome) {
              totalIncome += history.amount;
            } else if (history.isExpense) {
              totalExpense += history.amount;
            }
          }
          
          _totalAssets = totalIncome - totalExpense;
          print('💰 전체 자산 계산 완료: $_totalAssets (수입: $totalIncome, 지출: $totalExpense)');
          notifyListeners();
        },
        error: (failure) {
          print('❌ 전체 자산 계산 실패: ${_getErrorMessage(failure)}');
          _totalAssets = 0.0;
          notifyListeners();
        },
      );
    } catch (e) {
      print('❌ 전체 자산 계산 중 예외 발생: $e');
      _totalAssets = 0.0;
      notifyListeners();
    }
  }

  /// 포맷된 자산 문자열 반환
  String get formattedTotalAssets {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = _totalAssets.abs().toInt().toString().replaceAllMapped(formatter, (Match m) => '${m[1]},');
    
    if (_totalAssets >= 0) {
      return '현재 자산: $formatted 원';
    } else {
      return '현재 자산: -$formatted 원';
    }
  }
}