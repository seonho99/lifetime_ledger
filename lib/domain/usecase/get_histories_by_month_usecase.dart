import '../../../core/errors/failure.dart';
import '../../../core/result/result.dart';
import '../model/history.dart';
import '../repository/history_repository.dart';

class GetHistoriesByMonthUseCase {
  final HistoryRepository _repository;

  GetHistoriesByMonthUseCase({
    required HistoryRepository repository,
  }) : _repository = repository;

  Future<Result<List<History>>> call({
    required int year,
    required int month,
  }) async {
    // 입력 값 검증
    if (year < 1900 || year > 2100) {
      return Error(ValidationFailure('유효하지 않은 연도입니다'));
    }
    if (month < 1 || month > 12) {
      return Error(ValidationFailure('유효하지 않은 월입니다'));
    }

    return await _repository.getHistoriesByMonth(year, month);
  }
}