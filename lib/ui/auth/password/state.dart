import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

/// 비밀번호 변경 화면의 상태 관리
@freezed
class ChangePasswordState with _$ChangePasswordState {
  const ChangePasswordState({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
    required this.isLoading,
    required this.obscureCurrentPassword,
    required this.obscureNewPassword,
    required this.obscureConfirmPassword,
    this.errorMessage,
    this.successMessage,
    this.currentPasswordError,
    this.newPasswordError,
    this.confirmPasswordError,
  });

  /// 현재 비밀번호
  final String currentPassword;

  /// 새 비밀번호
  final String newPassword;

  /// 새 비밀번호 확인
  final String confirmNewPassword;

  /// 로딩 상태
  final bool isLoading;

  /// 현재 비밀번호 숨김 여부
  final bool obscureCurrentPassword;

  /// 새 비밀번호 숨김 여부
  final bool obscureNewPassword;

  /// 비밀번호 확인 숨김 여부
  final bool obscureConfirmPassword;

  /// 전체 에러 메시지
  final String? errorMessage;

  /// 성공 메시지
  final String? successMessage;

  /// 현재 비밀번호 필드별 에러
  final String? currentPasswordError;

  /// 새 비밀번호 필드별 에러
  final String? newPasswordError;

  /// 비밀번호 확인 필드별 에러
  final String? confirmPasswordError;

  /// 초기 상태
  factory ChangePasswordState.initial() {
    return const ChangePasswordState(
      currentPassword: '',
      newPassword: '',
      confirmNewPassword: '',
      isLoading: false,
      obscureCurrentPassword: true,
      obscureNewPassword: true,
      obscureConfirmPassword: true,
      errorMessage: null,
      successMessage: null,
      currentPasswordError: null,
      newPasswordError: null,
      confirmPasswordError: null,
    );
  }
}

extension ChangePasswordStateX on ChangePasswordState {
  /// 에러 상태 여부
  bool get hasError => errorMessage != null;

  /// 성공 상태 여부
  bool get hasSuccess => successMessage != null;

  /// 필드별 에러 여부
  bool get hasFieldErrors =>
      currentPasswordError != null ||
          newPasswordError != null ||
          confirmPasswordError != null;

  /// 폼 유효성 검증
  bool get isValid =>
      currentPassword.trim().isNotEmpty &&
          newPassword.trim().isNotEmpty &&
          confirmNewPassword.trim().isNotEmpty &&
          newPassword.length >= 6 &&
          newPassword == confirmNewPassword &&
          currentPassword != newPassword &&
          !hasFieldErrors;

  /// 새 비밀번호 복잡성 검증
  bool get isNewPasswordStrong {
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(newPassword);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(newPassword);
    return newPassword.length >= 6 && hasLetters && hasNumbers;
  }
}