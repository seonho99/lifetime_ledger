import '../../../core/errors/failure.dart';
import '../../../core/result/result.dart';
import '../model/history.dart';
import '../repository/history_repository.dart';

class UpdateHistoryUseCase {
  final HistoryRepository _repository;

  UpdateHistoryUseCase({
    required HistoryRepository repository,
  }) : _repository = repository;

  Future<Result<void>> call(History history) async {
    // 비즈니스 규칙 검증
    if (!history.isValid) {
      return Error(ValidationFailure('유효하지 않은 내역 정보입니다'));
    }

    return await _repository.updateHistory(history);
  }
}