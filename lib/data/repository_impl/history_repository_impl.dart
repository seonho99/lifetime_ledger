import '../../../core/result/result.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../domain/model/history.dart';
import '../../domain/repository/history_repository.dart';
import '../datasource/history_datasource.dart';
import '../mapper/history_mapper.dart';

/// History Repository 구현체
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDataSource _dataSource;

  HistoryRepositoryImpl({
    required HistoryDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<List<History>>> getHistories() async {
    try {
      final historyDtos = await _dataSource.getHistories();
      final histories = historyDtos.toModelList();

      return Success(histories);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<History>> getHistoryById(String id) async {
    try {
      // 입력 값 검증
      if (id.trim().isEmpty) {
        return Error(ValidationFailure('내역 ID는 필수입니다'));
      }

      final historyDto = await _dataSource.getHistoryById(id);
      final history = historyDto.toModel();

      if (history == null) {
        return Error(ServerFailure('내역 데이터를 변환할 수 없습니다'));
      }

      return Success(history);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> addHistory(History history) async {
    try {
      // 비즈니스 규칙 검증
      if (!history.isValid) {
        return Error(ValidationFailure('유효하지 않은 내역 정보입니다'));
      }

      final historyDto = history.toDto();
      await _dataSource.addHistory(historyDto);

      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> updateHistory(History history) async {
    try {
      // 비즈니스 규칙 검증
      if (!history.isValid) {
        return Error(ValidationFailure('유효하지 않은 내역 정보입니다'));
      }

      final historyDto = history.toDto();
      await _dataSource.updateHistory(historyDto);

      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> deleteHistory(String id) async {
    try {
      // 입력 값 검증
      if (id.trim().isEmpty) {
        return Error(ValidationFailure('내역 ID는 필수입니다'));
      }

      await _dataSource.deleteHistory(id);

      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<List<History>>> getHistoriesByMonth(int year, int month) async {
    try {
      // 입력 값 검증
      if (year < 1900 || year > 2100) {
        return Error(ValidationFailure('유효하지 않은 연도입니다'));
      }
      if (month < 1 || month > 12) {
        return Error(ValidationFailure('유효하지 않은 월입니다'));
      }

      final historyDtos = await _dataSource.getHistoriesByMonth(year, month);
      final histories = historyDtos.toModelList();

      return Success(histories);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<List<History>>> getHistoriesByDateRange(
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      // 비즈니스 규칙 검증
      if (endDate.isBefore(startDate)) {
        return Error(ValidationFailure('종료일은 시작일보다 늦어야 합니다'));
      }

      final daysDifference = endDate.difference(startDate).inDays;
      if (daysDifference > 365) {
        return Error(ValidationFailure('조회 기간은 1년을 초과할 수 없습니다'));
      }

      final historyDtos = await _dataSource.getHistoriesByDateRange(startDate, endDate);
      final histories = historyDtos.toModelList();

      return Success(histories);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<List<History>>> getHistoriesByCategory(String categoryId) async {
    try {
      // 입력 값 검증
      if (categoryId.trim().isEmpty) {
        return Error(ValidationFailure('카테고리 ID는 필수입니다'));
      }

      final historyDtos = await _dataSource.getHistoriesByCategory(categoryId);
      final histories = historyDtos.toModelList();

      return Success(histories);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<double>> getTotalIncome() async {
    try {
      final historyDtos = await _dataSource.getHistories();
      final histories = historyDtos.toModelList();

      final totalIncome = histories
          .where((h) => h.isIncome)
          .map((h) => h.amount)
          .fold(0.0, (sum, amount) => sum + amount);

      return Success(totalIncome);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<double>> getTotalExpense() async {
    try {
      final historyDtos = await _dataSource.getHistories();
      final histories = historyDtos.toModelList();

      final totalExpense = histories
          .where((h) => h.isExpense)
          .map((h) => h.amount)
          .fold(0.0, (sum, amount) => sum + amount);

      return Success(totalExpense);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<double>> getMonthlyIncome(int year, int month) async {
    try {
      final result = await getHistoriesByMonth(year, month);

      return result.fold(
        onSuccess: (histories) {
          final monthlyIncome = histories
              .where((h) => h.isIncome)
              .map((h) => h.amount)
              .fold(0.0, (sum, amount) => sum + amount);

          return Success(monthlyIncome);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<double>> getMonthlyExpense(int year, int month) async {
    try {
      final result = await getHistoriesByMonth(year, month);

      return result.fold(
        onSuccess: (histories) {
          final monthlyExpense = histories
              .where((h) => h.isExpense)
              .map((h) => h.amount)
              .fold(0.0, (sum, amount) => sum + amount);

          return Success(monthlyExpense);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }
}