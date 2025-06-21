import '../dto/history_dto.dart';

/// History DataSource 인터페이스
abstract class HistoryDataSource {
  Future<List<HistoryDto>> getHistories();
  Future<HistoryDto> getHistoryById(String id);
  Future<void> addHistory(HistoryDto history);
  Future<void> updateHistory(HistoryDto history);
  Future<void> deleteHistory(String id);

  // 추가 메서드들
  Future<List<HistoryDto>> getHistoriesByMonth(int year, int month);
  Future<List<HistoryDto>> getHistoriesByDateRange(
      DateTime startDate,
      DateTime endDate,
      );
  Future<List<HistoryDto>> getHistoriesByCategory(String categoryId);
}