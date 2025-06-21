import '../../../core/result/result.dart';
import '../model/history.dart';

/// History Repository 인터페이스
abstract class HistoryRepository {
  Future<Result<List<History>>> getHistories();
  Future<Result<History>> getHistoryById(String id);
  Future<Result<void>> addHistory(History history);
  Future<Result<void>> updateHistory(History history);
  Future<Result<void>> deleteHistory(String id);

  // 검색 및 필터링
  Future<Result<List<History>>> getHistoriesByMonth(int year, int month);
  Future<Result<List<History>>> getHistoriesByDateRange(
      DateTime startDate,
      DateTime endDate,
      );
  Future<Result<List<History>>> getHistoriesByCategory(String categoryId);

  // 통계 관련
  Future<Result<double>> getTotalIncome();
  Future<Result<double>> getTotalExpense();
  Future<Result<double>> getMonthlyIncome(int year, int month);
  Future<Result<double>> getMonthlyExpense(int year, int month);
}