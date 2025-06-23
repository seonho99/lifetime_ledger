import '../../../core/errors/failure.dart';
import '../../../core/result/result.dart';
import '../repository/history_repository.dart';

class DeleteHistoryUseCase {
  final HistoryRepository _repository;

  DeleteHistoryUseCase({
    required HistoryRepository repository,
  }) : _repository = repository;

  Future<Result<void>> call(String id) async {
    // 입력 값 검증
    if (id.trim().isEmpty) {
      return Error(ValidationFailure('내역 ID는 필수입니다'));
    }

    return await _repository.deleteHistory(id);
  }
}