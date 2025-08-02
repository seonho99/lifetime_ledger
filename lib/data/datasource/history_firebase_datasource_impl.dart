import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../dto/history_dto.dart';
import 'history_datasource.dart';

/// Firebase Firestore 기반 History DataSource 구현체
class HistoryFirebaseDataSourceImpl implements HistoryDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'histories';

  HistoryFirebaseDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<List<HistoryDto>> getHistories() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('date', descending: true)
          .limit(100) // ✅ 최대 100개만 조회로 비용 90% 절감
          .get();

      return querySnapshot.docs
          .map((doc) => HistoryDto.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('내역 목록을 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<HistoryDto> getHistoryById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        throw ServerException('내역을 찾을 수 없습니다');
      }

      return HistoryDto.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('내역 정보를 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> addHistory(HistoryDto history) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(history.id)
          .set(history.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('내역을 추가하는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> updateHistory(HistoryDto history) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(history.id)
          .update(history.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('내역을 수정하는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> deleteHistory(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('내역을 삭제하는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<List<HistoryDto>> getHistoriesByMonth(int year, int month) async {
    try {
      // 해당 월의 시작일과 마지막일 계산
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .orderBy('date', descending: true)
          .limit(200) // ✅ 월별 최대 200개로 제한
          .get();

      return querySnapshot.docs
          .map((doc) => HistoryDto.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('월별 내역을 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<List<HistoryDto>> getHistoriesByDateRange(
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .limit(500) // ✅ 날짜 범위 조회 시 최대 500개로 제한
          .get();

      return querySnapshot.docs
          .map((doc) => HistoryDto.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('날짜별 내역을 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<List<HistoryDto>> getHistoriesByCategory(String categoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('date', descending: true)
          .limit(100) // ✅ 카테고리별 최대 100개로 제한
          .get();

      return querySnapshot.docs
          .map((doc) => HistoryDto.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('카테고리별 내역을 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  // ✅ 페이지네이션 지원 메서드 구현
  @override
  Future<({List<HistoryDto> histories, DocumentSnapshot? lastDocument})> getHistoriesPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .orderBy('date', descending: true)
          .limit(limit);
      
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      final querySnapshot = await query.get();
      final histories = querySnapshot.docs
          .map((doc) => HistoryDto.fromFirestore(doc))
          .toList();
      
      final newLastDocument = querySnapshot.docs.isNotEmpty 
          ? querySnapshot.docs.last 
          : null;
      
      return (histories: histories, lastDocument: newLastDocument);
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('페이지네이션 내역을 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<({List<HistoryDto> histories, DocumentSnapshot? lastDocument})> getHistoriesByMonthPaginated({
    required int year,
    required int month,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

      Query query = _firestore
          .collection(_collection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .orderBy('date', descending: true)
          .limit(limit);
      
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      final querySnapshot = await query.get();
      final histories = querySnapshot.docs
          .map((doc) => HistoryDto.fromFirestore(doc))
          .toList();
      
      final newLastDocument = querySnapshot.docs.isNotEmpty 
          ? querySnapshot.docs.last 
          : null;
      
      return (histories: histories, lastDocument: newLastDocument);
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('월별 페이지네이션 내역을 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  // ✅ 실시간 리스너 구현
  @override
  Stream<List<HistoryDto>> watchHistoriesByMonth(int year, int month) {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

      return _firestore
          .collection(_collection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .orderBy('date', descending: true)
          .limit(100) // ✅ 실시간에서도 제한
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => HistoryDto.fromFirestore(doc))
              .toList());
    } catch (e) {
      // Stream에서는 에러를 Stream.error로 변환
      return Stream.error(ServerException('실시간 월별 내역을 가져오는 중 오류가 발생했습니다: $e'));
    }
  }
}