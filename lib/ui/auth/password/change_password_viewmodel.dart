import 'package:flutter/material.dart';

import '../../../core/result/result.dart';
import '../../../core/errors/failure.dart';
import '../../../domain/usecase/change_password_usecase.dart';
import 'change_password_state.dart';

/// ChangePassword ViewModel (ChangeNotifier 기반)
class ChangePasswordViewModel extends ChangeNotifier {
  final ChangePasswordUseCase _changePasswordUseCase;

  ChangePasswordViewModel({
    required ChangePasswordUseCase changePasswordUseCase,
  }) : _changePasswordUseCase = changePasswordUseCase;

  // ========================================
  // 상태 관리
  // ========================================

  ChangePasswordState _state = ChangePasswordState.initial();
  ChangePasswordState get state => _state;

  // 편의 Getters
  String get currentPassword => _state.currentPassword;
  String get newPassword => _state.newPassword;
  String get confirmNewPassword => _state.confirmNewPassword;
  bool get isLoading => _state.isLoading;
  bool get obscureCurrentPassword => _state.obscureCurrentPassword;
  bool get obscureNewPassword => _state.obscureNewPassword;
  bool get obscureConfirmPassword => _state.obscureConfirmPassword;
  bool get hasError => _state.hasError;
  bool get hasSuccess => _state.hasSuccess;
  String? get errorMessage => _state.errorMessage;
  String? get successMessage => _state.successMessage;
  bool get isValid => _state.isValid;

  // 개별 필드 에러 메시지 Getters
  String? get currentPasswordError => _state.currentPasswordError;
  String? get newPasswordError => _state.newPasswordError;
  String? get confirmPasswordError => _state.confirmPasswordError;

  /// 상태 업데이트
  void _updateState(ChangePasswordState newState) {
    _state = newState;
    notifyListeners();
  }

  // ========================================
  // UI 이벤트 처리
  // ========================================

  /// 현재 비밀번호 입력 변경
  void onCurrentPasswordChanged(String currentPassword) {
    _updateState(_state.copyWith(
      currentPassword: currentPassword,
      errorMessage: null, // 입력 시 에러 초기화
      currentPasswordError: null,
    ));
  }

  /// 새 비밀번호 입력 변경
  void onNewPasswordChanged(String newPassword) {
    String? newPasswordError;

    // 실시간 유효성 검증
    if (newPassword.isNotEmpty) {
      if (newPassword.length < 6) {
        newPasswordError = '비밀번호는 6자 이상이어야 합니다';
      } else if (!_state.isNewPasswordStrong) {
        newPasswordError = '영문과 숫자를 포함해주세요';
      } else if (newPassword == _state.currentPassword) {
        newPasswordError = '현재 비밀번호와 달라야 합니다';
      }
    }

    _updateState(_state.copyWith(
      newPassword: newPassword,
      newPasswordError: newPasswordError,
      errorMessage: null, // 입력 시 에러 초기화
      // 새 비밀번호가 변경되면 확인 비밀번호도 재검증
      confirmPasswordError: _state.confirmNewPassword.isNotEmpty &&
          newPassword != _state.confirmNewPassword
          ? '비밀번호가 일치하지 않습니다'
          : null,
    ));
  }

  /// 새 비밀번호 확인 입력 변경
  void onConfirmNewPasswordChanged(String confirmNewPassword) {
    String? confirmPasswordError;

    // 실시간 유효성 검증
    if (confirmNewPassword.isNotEmpty) {
      if (confirmNewPassword != _state.newPassword) {
        confirmPasswordError = '비밀번호가 일치하지 않습니다';
      }
    }

    _updateState(_state.copyWith(
      confirmNewPassword: confirmNewPassword,
      confirmPasswordError: confirmPasswordError,
      errorMessage: null, // 입력 시 에러 초기화
    ));
  }

  /// 현재 비밀번호 표시/숨김 토글
  void toggleCurrentPasswordVisibility() {
    _updateState(_state.copyWith(
      obscureCurrentPassword: !_state.obscureCurrentPassword,
    ));
  }

  /// 새 비밀번호 표시/숨김 토글
  void toggleNewPasswordVisibility() {
    _updateState(_state.copyWith(
      obscureNewPassword: !_state.obscureNewPassword,
    ));
  }

  /// 비밀번호 확인 표시/숨김 토글
  void toggleConfirmPasswordVisibility() {
    _updateState(_state.copyWith(
      obscureConfirmPassword: !_state.obscureConfirmPassword,
    ));
  }

  /// 에러 메시지 초기화
  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }

  /// 성공 메시지 초기화
  void clearSuccess() {
    _updateState(_state.copyWith(successMessage: null));
  }

  /// 모든 필드 초기화
  void clearAllFields() {
    _updateState(_state.copyWith(
      currentPassword: '',
      newPassword: '',
      confirmNewPassword: '',
      currentPasswordError: null,
      newPasswordError: null,
      confirmPasswordError: null,
      errorMessage: null,
      successMessage: null,
    ));
  }

  // ========================================
  // 비즈니스 로직
  // ========================================

  /// 비밀번호 변경 실행
  Future<void> changePassword({
    Function()? onSuccess,
    Function(String)? onError,
  }) async {
    // 폼 유효성 검증
    if (!_state.isValid) {
      String errorMsg = '모든 필드를 올바르게 입력해주세요';

      if (_state.currentPasswordError != null) {
        errorMsg = _state.currentPasswordError!;
      } else if (_state.newPasswordError != null) {
        errorMsg = _state.newPasswordError!;
      } else if (_state.confirmPasswordError != null) {
        errorMsg = _state.confirmPasswordError!;
      }

      _updateState(_state.copyWith(errorMessage: errorMsg));
      onError?.call(errorMsg);
      return;
    }

    // 로딩 시작
    _updateState(_state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    ));

    // UseCase 호출
    final result = await _changePasswordUseCase(
      currentPassword: _state.currentPassword,
      newPassword: _state.newPassword,
      confirmNewPassword: _state.confirmNewPassword,
    );

    // 결과 처리 (Result.when 패턴)
    result.when(
      success: (_) {
        _updateState(_state.copyWith(
          isLoading: false,
          successMessage: '비밀번호가 성공적으로 변경되었습니다',
          // 성공 시 필드 초기화
          currentPassword: '',
          newPassword: '',
          confirmNewPassword: '',
        ));
        onSuccess?.call();
      },
      error: (failure) {
        String errorMessage = _mapFailureToMessage(failure);

        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ));
        onError?.call(errorMessage);
      },
    );
  }

  // ========================================
  // Helper 메서드
  // ========================================

  /// Failure를 사용자 친화적 메시지로 변환
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure:
        return failure.message;
      case FirebaseFailure:
      // Firebase Auth 에러에 따른 구체적 메시지
        if (failure.message.contains('wrong-password') ||
            failure.message.contains('현재 비밀번호')) {
          return '현재 비밀번호가 올바르지 않습니다';
        } else if (failure.message.contains('weak-password')) {
          return '새 비밀번호가 너무 약합니다';
        } else if (failure.message.contains('requires-recent-login')) {
          return '보안을 위해 다시 로그인 후 시도해주세요';
        }
        return failure.message;
      case UnauthorizedFailure:
        return '인증이 필요합니다. 다시 로그인해 주세요';
      case NetworkFailure:
        return '네트워크 연결을 확인해주세요';
      case ServerFailure:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
      default:
        return '알 수 없는 오류가 발생했습니다';
    }
  }

  // ========================================
  // 생명주기 관리
  // ========================================

  @override
  void dispose() {
    super.dispose();
  }
}