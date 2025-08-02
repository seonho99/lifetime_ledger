import 'package:cloud_firestore/cloud_firestore.dart';
import '../dto/history_dto.dart';
import 'history_datasource.dart';

/// 캐싱 기능이 있는 History DataSource 래퍼
class CachedHistoryDataSource implements HistoryDataSource {
  final HistoryDataSource _remoteDataSource;
  
  // 캐시 저장소
  final Map<String, List<HistoryDto>> _monthlyCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, HistoryDto> _individualCache = {};
  
  // 캐시 설정
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static const int _maxCacheSize = 50; // 최대 50개 월 데이터 캐싱

  CachedHistoryDataSource({
    required HistoryDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<HistoryDto>> getHistories() async {
    // 전체 조회는 캐싱하지 않음 (너무 자주 변경됨)
    return _remoteDataSource.getHistories();
  }

  @override
  Future<HistoryDto> getHistoryById(String id) async {
    // 개별 아이템 캐싱
    if (_individualCache.containsKey(id)) {
      print('✅ 개별 캐시 히트: $id');
      return _individualCache[id]!;
    }
    
    print('📡 개별 캐시 미스: $id - 서버에서 가져옴');
    final history = await _remoteDataSource.getHistoryById(id);
    _individualCache[id] = history;
    
    // 캐시 크기 제한
    if (_individualCache.length > 100) {
      final oldestKey = _individualCache.keys.first;
      _individualCache.remove(oldestKey);
    }
    
    return history;
  }

  @override
  Future<void> addHistory(HistoryDto history) async {
    await _remoteDataSource.addHistory(history);
    
    // 캐시 무효화 (해당 월 데이터 삭제)
    if (history.date != null) {
      final monthKey = '${history.date!.year}_${history.date!.month}';
      _invalidateMonthCache(monthKey);
      print('🗑️ 월별 캐시 무효화: $monthKey');
    }
    
    if (history.id != null) {
      _individualCache[history.id!] = history;
    }
  }

  @override
  Future<void> updateHistory(HistoryDto history) async {
    await _remoteDataSource.updateHistory(history);
    
    // 캐시 업데이트
    if (history.date != null) {
      final monthKey = '${history.date!.year}_${history.date!.month}';
      _invalidateMonthCache(monthKey);
      print('🗑️ 월별 캐시 무효화: $monthKey');
    }
    
    if (history.id != null) {
      _individualCache[history.id!] = history;
    }
  }

  @override
  Future<void> deleteHistory(String id) async {
    await _remoteDataSource.deleteHistory(id);
    
    // 캐시에서 제거
    final deletedHistory = _individualCache.remove(id);
    if (deletedHistory != null && deletedHistory.date != null) {
      final monthKey = '${deletedHistory.date!.year}_${deletedHistory.date!.month}';
      _invalidateMonthCache(monthKey);
      print('🗑️ 월별 캐시 무효화: $monthKey');
    }
  }

  @override
  Future<List<HistoryDto>> getHistoriesByMonth(int year, int month) async {
    final cacheKey = '${year}_$month';
    
    // 캐시 확인
    if (_isValidCache(cacheKey)) {
      print('✅ 월별 캐시 히트: $cacheKey');
      return _monthlyCache[cacheKey]!;
    }
    
    print('📡 월별 캐시 미스: $cacheKey - 서버에서 가져옴');
    
    // 서버에서 데이터 가져오기
    final histories = await _remoteDataSource.getHistoriesByMonth(year, month);
    
    // 캐시에 저장
    _cacheData(cacheKey, histories);
    
    return histories;
  }

  @override
  Future<List<HistoryDto>> getHistoriesByDateRange(DateTime startDate, DateTime endDate) async {
    // 날짜 범위 조회는 캐싱하지 않음 (다양한 범위로 인한 복잡성)
    return _remoteDataSource.getHistoriesByDateRange(startDate, endDate);
  }

  @override
  Future<List<HistoryDto>> getHistoriesByCategory(String categoryId) async {
    // 카테고리별 조회는 캐싱하지 않음 (변경 빈도가 높음)
    return _remoteDataSource.getHistoriesByCategory(categoryId);
  }

  @override
  Future<({List<HistoryDto> histories, DocumentSnapshot? lastDocument})> getHistoriesPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    // 페이지네이션은 캐싱하지 않음 (복잡성)
    return _remoteDataSource.getHistoriesPaginated(
      lastDocument: lastDocument,
      limit: limit,
    );
  }

  @override
  Future<({List<HistoryDto> histories, DocumentSnapshot? lastDocument})> getHistoriesByMonthPaginated({
    required int year,
    required int month,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    // 페이지네이션은 캐싱하지 않음 (복잡성)
    return _remoteDataSource.getHistoriesByMonthPaginated(
      year: year,
      month: month,
      lastDocument: lastDocument,
      limit: limit,
    );
  }

  /// 캐시가 유효한지 확인
  bool _isValidCache(String key) {
    if (!_monthlyCache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    
    final timestamp = _cacheTimestamps[key]!;
    final isExpired = DateTime.now().difference(timestamp) > _cacheExpiry;
    
    if (isExpired) {
      _invalidateMonthCache(key);
      return false;
    }
    
    return true;
  }

  /// 캐시에 데이터 저장
  void _cacheData(String key, List<HistoryDto> data) {
    // 캐시 크기 제한
    if (_monthlyCache.length >= _maxCacheSize) {
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _invalidateMonthCache(oldestKey);
    }
    
    _monthlyCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    
    print('💾 캐시 저장: $key (${data.length}개 항목)');
  }

  /// 특정 월의 캐시 무효화
  void _invalidateMonthCache(String key) {
    _monthlyCache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// 전체 캐시 정리
  void clearCache() {
    _monthlyCache.clear();
    _cacheTimestamps.clear();
    _individualCache.clear();
    print('🧹 전체 캐시 정리 완료');
  }

  @override
  Stream<List<HistoryDto>> watchHistoriesByMonth(int year, int month) {
    // 실시간 리스너는 캐싱하지 않고 직접 전달
    // (실시간 데이터는 항상 최신이어야 하므로)
    return _remoteDataSource.watchHistoriesByMonth(year, month);
  }

  /// 캐시 통계
  Map<String, dynamic> getCacheStats() {
    return {
      'monthlyCache': _monthlyCache.length,
      'individualCache': _individualCache.length,
      'totalCachedItems': _monthlyCache.values.fold(0, (sum, list) => sum + list.length),
    };
  }
}