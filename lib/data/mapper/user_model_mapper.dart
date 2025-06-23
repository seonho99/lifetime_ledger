import '../../domain/model/user_model.dart';
import '../dto/user_model_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// UserModelDto -> UserModel 변환
extension UserModelDtoMapper on UserModelDto? {
  UserModel? toModel() {
    final dto = this;
    if (dto == null) return null;

    return UserModel(
      id: dto.id ?? '',
      email: dto.email ?? '',
      displayName: dto.displayName,
      isEmailVerified: dto.isEmailVerified ?? false,
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
    );
  }
}

/// UserModel -> UserModelDto 변환
extension UserModelMapper on UserModel {
  UserModelDto toDto() {
    return UserModelDto(
      id: id,
      email: email,
      displayName: displayName,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Firebase Firestore에 저장할 Map 생성
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// List<UserModelDto> -> List<UserModel> 변환
extension UserModelDtoListMapper on List<UserModelDto>? {
  List<UserModel> toModelList() {
    final dtoList = this;
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => dto.toModel()).whereType<UserModel>().toList();
  }
}

/// List<UserModel> -> List<UserModelDto> 변환
extension UserModelListMapper on List<UserModel>? {
  List<UserModelDto> toDtoList() {
    final entityList = this;
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => entity.toDto()).toList();
  }
}

/// Firebase Firestore Document -> UserModel 변환
extension FirestoreDocumentMapper on DocumentSnapshot {
  UserModel? toUserModel() {
    if (!exists) return null;

    final data = this.data() as Map<String, dynamic>;

    return UserModel(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// String UID에서 UserModel 생성 (Firebase Auth 연동용)
extension UidToUserModelMapper on String {
  UserModel toUserModelWithUid({
    required String email,
    String? displayName,
    bool isEmailVerified = false,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: this, // UID
      email: email,
      displayName: displayName,
      isEmailVerified: isEmailVerified,
      createdAt: now,
      updatedAt: now,
    );
  }
}