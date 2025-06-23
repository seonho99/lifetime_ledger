import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model_dto.g.dart';

@JsonSerializable()
class UserModelDto {
  const UserModelDto({
    this.id,
    this.email,
    this.displayName,
    this.isEmailVerified,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? email;

  @JsonKey(name: 'display_name')
  final String? displayName;

  @JsonKey(name: 'is_email_verified')
  final bool? isEmailVerified;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  factory UserModelDto.fromJson(Map<String, dynamic> json) =>
      _$UserModelDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelDtoToJson(this);

  /// Firebase Firestore Document에서 생성
  factory UserModelDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModelDto(
      id: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      isEmailVerified: data['isEmailVerified'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Firebase Firestore에 저장할 Map 생성
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// copyWith 메서드 (업데이트용)
  UserModelDto copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModelDto(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}