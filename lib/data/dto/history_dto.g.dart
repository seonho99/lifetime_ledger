// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryDto _$HistoryDtoFromJson(Map<String, dynamic> json) => HistoryDto(
  id: json['id'] as String?,
  title: json['title'] as String?,
  amount: json['amount'] as num?,
  type: json['type'] as String?,
  categoryId: json['category_id'] as String?,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  description: json['description'] as String?,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$HistoryDtoToJson(HistoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'type': instance.type,
      'category_id': instance.categoryId,
      'date': instance.date?.toIso8601String(),
      'description': instance.description,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
