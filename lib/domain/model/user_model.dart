import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';

/// 사용자 도메인 모델
@freezed
class UserModel with _$UserModel {
  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 팩토리 생성자 (검증 포함)
  factory UserModel.create({
    required String email,
    String? displayName,
  }) {
    // 이메일 검증
    if (email.trim().isEmpty) {
      throw ArgumentError('이메일은 비어있을 수 없습니다');
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      throw ArgumentError('유효하지 않은 이메일 형식입니다');
    }

    final now = DateTime.now();
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    return UserModel(
      id: id,
      email: email.trim().toLowerCase(),
      displayName: displayName?.trim(),
      isEmailVerified: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  // 비즈니스 로직 메서드들
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;
  bool get isComplete => hasDisplayName && isEmailVerified;

  String get displayNameOrEmail => displayName ?? email;

  // 검증 메서드
  bool get isValid =>
      email.isNotEmpty &&
          id.isNotEmpty &&
          _isValidEmail(email);

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  // 사용자 정보 업데이트 (새 인스턴스 반환)
  UserModel updateDisplayName(String newDisplayName) {
    if (newDisplayName.trim().isEmpty) {
      throw ArgumentError('표시 이름은 비어있을 수 없습니다');
    }
    return copyWith(
      displayName: newDisplayName.trim(),
      updatedAt: DateTime.now(),
    );
  }

  UserModel verifyEmail() {
    return copyWith(
      isEmailVerified: true,
      updatedAt: DateTime.now(),
    );
  }
}