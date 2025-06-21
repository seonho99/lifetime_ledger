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
}