import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/failure_mapper.dart';
import '../../core/result/result.dart';
import '../../domain/usecase/signin_usecase.dart';
import '../../domain/usecase/signup_usecase.dart';
import '../../domain/usecase/signout_usecase.dart';
import '../../domain/usecase/send_password_reset_email_usecase.dart';
import '../../domain/usecase/change_password_usecase.dart';
import '../../domain/usecase/update_profile_usecase.dart';
import '../../domain/usecase/send_email_verification_usecase.dart';
import '../../domain/usecase/delete_account_usecase.dart';
import 'auth_state.dart';

class AuthViewModel extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmailUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  StreamSubscription<User?>? _authSubscription;

  AuthViewModel({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required SendEmailVerificationUseCase sendEmailVerificationUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
  }) : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _sendPasswordResetEmailUseCase = sendPasswordResetEmailUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _sendEmailVerificationUseCase = sendEmailVerificationUseCase,
        _deleteAccountUseCase = deleteAccountUseCase {
    _initializeAuthState();
  }

  // ========================================
  // 상태 관리
  // ========================================

  AuthState _state = AuthState.initial();
  AuthState get state => _state;

  // 편의 Getters
  User? get currentUser => _state.user;
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  bool get hasSuccess => _state.hasSuccess;
  String? get errorMessage => _state.errorMessage;
  String? get successMessage => _state.successMessage;
  bool get isEmailVerified => _state.isEmailVerified;
  String get userDisplayName => _state.userDisplayName;
  String get userEmail => _state.userEmail;

  void _updateState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  // ========================================
  // Firebase Auth 상태 모니터링
  // ========================================

  void _initializeAuthState() {
    // 현재 사용자 상태로 초기화
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _updateState(AuthState.authenticated(currentUser));
    }

    // Firebase Auth 상태 변화 리스닝
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
          (User? user) {
        if (user != null) {
          _updateState(AuthState.authenticated(user));
        } else {
          _updateState(AuthState.initial());
        }
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // ========================================
  // 메시지 관리
  // ========================================

  void clearMessages() {
    _updateState(_state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }

  // ========================================
  // 인증 기능들
  // ========================================

  /// 로그인
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    final result = await _signInUseCase(
      email: email,
      password: password,
    );

    result.when(
      success: (user) {
        // Firebase authStateChanges가 자동으로 상태 업데이트함
        _updateState(_state.copyWith(
          isLoading: false,
          successMessage: '로그인되었습니다',
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  /// 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    final result = await _signUpUseCase(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      displayName: displayName,
    );

    result.when(
      success: (user) {
        // Firebase authStateChanges가 자동으로 상태 업데이트함
        _updateState(_state.copyWith(
          isLoading: false,
          successMessage: '회원가입이 완료되었습니다',
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  /// 로그아웃
  Future<void> signOut() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    final result = await _signOutUseCase();

    result.when(
      success: (_) {
        // Firebase authStateChanges가 자동으로 상태 업데이트함
        _updateState(_state.copyWith(
          isLoading: false,
          successMessage: '로그아웃되었습니다',
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    final result = await _sendPasswordResetEmailUseCase(email);

    result.when(
      success: (_) {
        _updateState(_state.copyWith(
          isLoading: false,
          successMessage: '비밀번호 재설정 이메일이 전송되었습니다',
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  /// 이메일 인증 전송
  Future<void> sendEmailVerification() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    final result = await _sendEmailVerificationUseCase();

    result.when(
      success: (_) {
        _updateState(_state.copyWith(
          isLoading: false,
          successMessage: '인증 이메일이 전송되었습니다',
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  /// 프로필 업데이트
  Future<void> updateProfile({String? displayName}) async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    final result = await _updateProfileUseCase(displayName: displayName);

    result.when(
      success: (_) {
        // Firebase에서 사용자 정보를 다시 로드하여 최신 상태 반영
        FirebaseAuth.instance.currentUser?.reload();
        _updateState(_state.copyWith(
          isLoading: false,
          successMessage: '프로필이 업데이트되었습니다',
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  /// 비밀번호 변경
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    final result = await _changePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    result.when(
      success: (_) {
        _updateState(_state.copyWith(
          isLoading: false,
          successMessage: '비밀번호가 변경되었습니다',
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  /// 계정 삭제
  Future<void> deleteAccount({
    required String password,
    required String confirmationText,
  }) async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    final result = await _deleteAccountUseCase(
      password: password,
      confirmationText: confirmationText,
    );

    result.when(
      success: (_) {
        // Firebase authStateChanges가 자동으로 상태 업데이트함
        _updateState(_state.copyWith(
          isLoading: false,
          successMessage: '계정이 삭제되었습니다',
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  // ========================================
  // 유틸리티 메서드들
  // ========================================

  /// Failure를 사용자 친화적 메시지로 변환
  String _getErrorMessage(failure) {
    if (FailureMapper.isNetworkError(failure)) {
      return '인터넷 연결을 확인해주세요';
    } else if (FailureMapper.isServerError(failure)) {
      return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
    } else if (FailureMapper.isValidationError(failure)) {
      return failure.message;
    } else if (FailureMapper.isAuthError(failure)) {
      return failure.message;
    } else {
      return '알 수 없는 오류가 발생했습니다';
    }
  }

  /// 사용자 정보 새로고침 (Firebase에서 최신 정보 가져오기)
  Future<void> refreshUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser != null) {
        _updateState(AuthState.authenticated(refreshedUser));
      }
    }
  }
}