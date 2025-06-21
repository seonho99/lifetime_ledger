import '../../domain/model/history.dart';
import '../dto/history_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// History DTO ↔ Entity 변환 Mapper
class HistoryMapper {
  HistoryMapper._(); // 인스턴스 생성 방지

  /// DTO → Entity 변환
  static History toEntity(HistoryDto dto) {
    return History(
      id: dto.id ?? '',
      title: dto.title ?? '',
      amount: (dto.amount ?? 0.0).toDouble(),
      type: _mapHistoryType(dto.type),
      categoryId: dto.categoryId ?? '',
      date: dto.date ?? DateTime.now(),
      description: dto.description,
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
    );
  }

  /// Entity → DTO 변환
  static HistoryDto toDto(History entity) {
    return HistoryDto(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      type: _mapHistoryTypeToString(entity.type),
      categoryId: entity.categoryId,
      date: entity.date,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// DTO List → Entity List 변환
  static List<History> toEntityList(List<HistoryDto>? dtoList) {
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => toEntity(dto)).toList();
  }

  /// Entity List → DTO List 변환
  static List<HistoryDto> toDtoList(List<History>? entityList) {
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => toDto(entity)).toList();
  }

  /// 문자열 → HistoryType 변환
  static HistoryType _mapHistoryType(String? type) {
    switch (type?.toLowerCase()) {
      case 'income':
        return HistoryType.income;
      case 'expense':
        return HistoryType.expense;
      default:
        return HistoryType.expense; // 기본값
    }
  }

  /// HistoryType → 문자열 변환
  static String _mapHistoryTypeToString(HistoryType type) {
    switch (type) {
      case HistoryType.income:
        return 'income';
      case HistoryType.expense:
        return 'expense';
    }
  }

  /// Firebase Firestore Document → Entity 변환
  static History fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return History(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: _mapHistoryType(data['type']),
      categoryId: data['categoryId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Entity → Firebase Firestore Map 변환
  static Map<String, dynamic> toFirestore(History entity) {
    return {
      'title': entity.title,
      'amount': entity.amount,
      'type': _mapHistoryTypeToString(entity.type),
      'categoryId': entity.categoryId,
      'date': Timestamp.fromDate(entity.date),
      'description': entity.description,
      'createdAt': Timestamp.fromDate(entity.createdAt),
      'updatedAt': Timestamp.fromDate(entity.updatedAt),
    };
  }
}