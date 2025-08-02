import '../dto/history_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// History DataSource 인터페이스
abstract class HistoryDataSource {
  Future<List<HistoryDto>> getHistories();
  Future<HistoryDto> getHistoryById(String id);
  Future<void> addHistory(HistoryDto history);
  Future<void> updateHistory(HistoryDto history);
  Future<void> deleteHistory(String id);

  // 기존 메서드들
  Future<List<HistoryDto>> getHistoriesByMonth(int year, int month);
  Future<List<HistoryDto>> getHistoriesByDateRange(
      DateTime startDate,
      DateTime endDate,
      );
  Future<List<HistoryDto>> getHistoriesByCategory(String categoryId);
  
  // ✅ 페이지네이션 지원 메서드 추가
  Future<({List<HistoryDto> histories, DocumentSnapshot? lastDocument})> getHistoriesPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  });
  
  Future<({List<HistoryDto> histories, DocumentSnapshot? lastDocument})> getHistoriesByMonthPaginated({
    required int year,
    required int month,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  });
  
  // ✅ 실시간 리스너 지원 (옵션)
  Stream<List<HistoryDto>> watchHistoriesByMonth(int year, int month);
}