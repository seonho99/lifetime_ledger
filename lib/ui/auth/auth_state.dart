import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const AuthState({
    this.user,
    required this.isLoading,
    this.errorMessage,
    this.successMessage,
  });

  final User? user; // Firebase User 직접 사용
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  /// 초기 상태 생성
  factory AuthState.initial() {
    return const AuthState(
      user: null,
      isLoading: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// 로딩 상태 생성
  factory AuthState.loading() {
    return const AuthState(
      user: null,
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// 인증됨 상태 생성
  factory AuthState.authenticated(User user) {
    return AuthState(
      user: user,
      isLoading: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// 에러 상태 생성
  factory AuthState.error(String message) {
    return AuthState(
      user: null,
      isLoading: false,
      errorMessage: message,
      successMessage: null,
    );
  }

  /// 성공 상태 생성
  factory AuthState.success(String message, {User? user}) {
    return AuthState(
      user: user,
      isLoading: false,
      errorMessage: null,
      successMessage: message,
    );
  }

  // 계산된 속성들
  bool get isAuthenticated => user != null;
  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get isEmailVerified => user?.emailVerified ?? false;

  // 사용자 정보 관련
  String get userDisplayName => user?.displayName ?? user?.email ?? '';
  String get userEmail => user?.email ?? '';
  String? get userId => user?.uid;
}