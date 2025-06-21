import '../../../core/result/result.dart';
import '../model/history.dart';
import '../repository/history_repository.dart';

class GetHistoriesUseCase {
  final HistoryRepository _repository;

  GetHistoriesUseCase({
    required HistoryRepository repository,
  }) : _repository = repository;

  Future<Result<List<History>>> call() async {
    return await _repository.getHistories();
  }
}