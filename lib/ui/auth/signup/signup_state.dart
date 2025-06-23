import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_state.freezed.dart';

/// SignUp 화면 상태 (Freezed 3.0 방식)
@freezed
class SignUpState with _$SignUpState {
  const SignUpState({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.displayName,
    required this.isLoading,
    required this.obscurePassword,
    required this.agreeToTerms,
    this.errorMessage,
    this.successMessage,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String displayName;
  final bool isLoading;
  final bool obscurePassword;
  final bool agreeToTerms;
  final String? errorMessage;
  final String? successMessage;

  /// 초기 상태
  factory SignUpState.initial() {
    return const SignUpState(
      email: '',
      password: '',
      confirmPassword: '',
      displayName: '',
      isLoading: false,
      obscurePassword: true,
      agreeToTerms: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// 로딩 상태
  factory SignUpState.loading() {
    return const SignUpState(
      email: '',
      password: '',
      confirmPassword: '',
      displayName: '',
      isLoading: true,
      obscurePassword: true,
      agreeToTerms: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// 폼 유효성 검증
  bool get isValid =>
      email.trim().isNotEmpty &&
          password.trim().isNotEmpty &&
          confirmPassword.trim().isNotEmpty &&
          displayName.trim().isNotEmpty &&
          _isValidEmail(email.trim()) &&
          _isValidPassword(password) &&
          _isPasswordMatch() &&
          agreeToTerms;

  /// 에러 상태 확인
  bool get hasError => errorMessage != null;

  /// 성공 상태 확인
  bool get hasSuccess => successMessage != null;

  /// 이메일 형식 검증
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// 비밀번호 강도 검증 (6자 이상)
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  /// 비밀번호 일치 검증
  bool _isPasswordMatch() {
    return password == confirmPassword;
  }

  /// 개별 필드 유효성 검증 메서드들
  String? get emailError {
    if (email.trim().isEmpty) return null; // 입력 전에는 에러 표시 안함
    if (!_isValidEmail(email.trim())) return '유효하지 않은 이메일 형식입니다';
    return null;
  }

  String? get passwordError {
    if (password.isEmpty) return null; // 입력 전에는 에러 표시 안함
    if (!_isValidPassword(password)) return '비밀번호는 6자 이상이어야 합니다';
    return null;
  }

  String? get confirmPasswordError {
    if (confirmPassword.isEmpty) return null; // 입력 전에는 에러 표시 안함
    if (!_isPasswordMatch()) return '비밀번호가 일치하지 않습니다';
    return null;
  }

  String? get displayNameError {
    if (displayName.trim().isEmpty) return null; // 입력 전에는 에러 표시 안함
    if (displayName.trim().length < 2) return '이름은 2자 이상이어야 합니다';
    return null;
  }
}