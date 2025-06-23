import '../../domain/model/history.dart';
import '../dto/history_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// HistoryDto -> History 변환
extension HistoryDtoMapper on HistoryDto? {
  History? toModel() {
    final dto = this;
    if (dto == null) return null;

    return History(
      id: dto.id ?? '',
      title: dto.title ?? '',
      amount: (dto.amount ?? 0.0).toDouble(),
      type: _stringToHistoryType(dto.type),
      categoryId: dto.categoryId ?? '',
      date: dto.date ?? DateTime.now(),
      description: dto.description,
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
    );
  }

  /// 문자열을 HistoryType으로 변환하는 내부 헬퍼 메서드
  HistoryType _stringToHistoryType(String? type) {
    switch (type?.toLowerCase()) {
      case 'income':
        return HistoryType.income;
      case 'expense':
        return HistoryType.expense;
      default:
        return HistoryType.expense; // 기본값
    }
  }
}

/// History -> HistoryDto 변환
extension HistoryMapper on History {
  HistoryDto toDto() {
    return HistoryDto(
      id: id,
      title: title,
      amount: amount,
      type: type.toStringValue(),
      categoryId: categoryId,
      date: date,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Firebase Firestore에 저장할 Map 생성
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'type': type.toStringValue(),
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// HistoryType을 문자열로 변환하는 extension
extension HistoryTypeExtension on HistoryType {
  String toStringValue() {
    switch (this) {
      case HistoryType.income:
        return 'income';
      case HistoryType.expense:
        return 'expense';
    }
  }
}

/// List<HistoryDto> -> List<History> 변환
extension HistoryDtoListMapper on List<HistoryDto>? {
  List<History> toModelList() {
    final dtoList = this;
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => dto.toModel()).whereType<History>().toList();
  }
}

/// List<History> -> List<HistoryDto> 변환
extension HistoryListMapper on List<History>? {
  List<HistoryDto> toDtoList() {
    final entityList = this;
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => entity.toDto()).toList();
  }
}

/// Firebase Firestore Document -> History 변환
extension FirestoreDocumentMapper on DocumentSnapshot {
  History? toHistoryModel() {
    if (!exists) return null;

    final data = this.data() as Map<String, dynamic>;

    return History(
      id: id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: _stringToHistoryType(data['type']),
      categoryId: data['categoryId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 문자열을 HistoryType으로 변환하는 내부 헬퍼 메서드
  HistoryType _stringToHistoryType(String? type) {
    switch (type?.toLowerCase()) {
      case 'income':
        return HistoryType.income;
      case 'expense':
        return HistoryType.expense;
      default:
        return HistoryType.expense; // 기본값
    }
  }
}