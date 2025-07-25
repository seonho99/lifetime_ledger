import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_state.freezed.dart';

/// SignIn 화면 상태 (Freezed 3.0 방식)
@freezed
class SignInState with _$SignInState {
  SignInState({
    required this.email,
    required this.password,
    required this.isLoading,
    required this.obscurePassword,
    this.errorMessage,
    this.successMessage,
  });

  final String email;
  final String password;
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;
  final String? successMessage;

  /// 초기 상태
  factory SignInState.initial() {
    return SignInState(
      email: '',
      password: '',
      isLoading: false,
      obscurePassword: true,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// 로딩 상태
  factory SignInState.loading() {
    return SignInState(
      email: '',
      password: '',
      isLoading: true,
      obscurePassword: true,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// 폼 유효성 검증
  bool get isValid =>
      email.trim().isNotEmpty &&
          password.trim().isNotEmpty &&
          _isValidEmail(email.trim());

  /// 에러 상태 확인
  bool get hasError => errorMessage != null;

  /// 성공 상태 확인
  bool get hasSuccess => successMessage != null;

  /// 이메일 형식 검증
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}