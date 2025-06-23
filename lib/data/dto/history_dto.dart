import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'history_dto.g.dart';

@JsonSerializable()
class HistoryDto {
  const HistoryDto({
    this.id,
    this.title,
    this.amount,
    this.type,
    this.categoryId,
    this.date,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? title;
  final num? amount;
  final String? type;

  @JsonKey(name: 'category_id')
  final String? categoryId;

  final DateTime? date;
  final String? description;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  factory HistoryDto.fromJson(Map<String, dynamic> json) =>
      _$HistoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryDtoToJson(this);

  /// Firebase Firestore Document에서 생성
  factory HistoryDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HistoryDto(
      id: doc.id,
      title: data['title'],
      amount: data['amount'],
      type: data['type'],
      categoryId: data['categoryId'],
      date: (data['date'] as Timestamp?)?.toDate(),
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Firebase Firestore에 저장할 Map 생성
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'description': description,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// copyWith 메서드 (업데이트용)
  HistoryDto copyWith({
    String? id,
    String? title,
    num? amount,
    String? type,
    String? categoryId,
    DateTime? date,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HistoryDto(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}