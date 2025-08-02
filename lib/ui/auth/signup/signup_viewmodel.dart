import 'package:flutter/material.dart';

import '../../../core/result/result.dart';
import '../../../core/errors/failure.dart';
import '../../../domain/usecase/signup_usecase.dart';
import 'signup_state.dart';

/// SignUp ViewModel (ChangeNotifier 기반)
class SignUpViewModel extends ChangeNotifier {
  final SignUpUseCase _signUpUseCase;

  SignUpViewModel({
    required SignUpUseCase signUpUseCase,
  }) : _signUpUseCase = signUpUseCase;

  // ========================================
  // 상태 관리
  // ========================================

  SignUpState _state = SignUpState.initial();
  SignUpState get state => _state;

  // 편의 Getters
  String get email => _state.email;
  String get password => _state.password;
  String get confirmPassword => _state.confirmPassword;
  String get displayName => _state.displayName;
  bool get isLoading => _state.isLoading;
  bool get obscurePassword => _state.obscurePassword;
  bool get agreeToTerms => _state.agreeToTerms;
  bool get hasError => _state.hasError;
  bool get hasSuccess => _state.hasSuccess;
  String? get errorMessage => _state.errorMessage;
  String? get successMessage => _state.successMessage;
  bool get isValid => _state.isValid;

  // 개별 필드 에러 메시지 Getters
  String? get emailError => _state.emailError;
  String? get passwordError => _state.passwordError;
  String? get confirmPasswordError => _state.confirmPasswordError;
  String? get displayNameError => _state.displayNameError;

  /// 상태 업데이트
  void _updateState(SignUpState newState) {
    _state = newState;
    notifyListeners();
  }

  // ========================================
  // UI 이벤트 처리
  // ========================================

  /// 이메일 입력 변경
  void onEmailChanged(String email) {
    _updateState(_state.copyWith(
      email: email,
      errorMessage: null, // 입력 시 에러 초기화
    ));
  }

  /// 비밀번호 입력 변경
  void onPasswordChanged(String password) {
    _updateState(_state.copyWith(
      password: password,
      errorMessage: null, // 입력 시 에러 초기화
    ));
  }

  /// 비밀번호 확인 입력 변경
  void onConfirmPasswordChanged(String confirmPassword) {
    _updateState(_state.copyWith(
      confirmPassword: confirmPassword,
      errorMessage: null, // 입력 시 에러 초기화
    ));
  }

  /// 이름 입력 변경
  void onDisplayNameChanged(String displayName) {
    _updateState(_state.copyWith(
      displayName: displayName,
      errorMessage: null, // 입력 시 에러 초기화
    ));
  }

  /// 비밀번호 표시/숨김 토글
  void togglePasswordVisibility() {
    _updateState(_state.copyWith(
      obscurePassword: !_state.obscurePassword,
    ));
  }

  /// 약관 동의 토글
  void toggleAgreeToTerms() {
    _updateState(_state.copyWith(
      agreeToTerms: !_state.agreeToTerms,
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

  // ========================================
  // 비즈니스 로직
  // ========================================

  /// 회원가입 실행
  Future<void> signUp() async {
    print('🚀 SignUpViewModel: 회원가입 시작');
    
    // 폼 유효성 검증
    if (!_state.isValid) {
      print('❌ SignUpViewModel: 폼 유효성 검증 실패');
      String errorMsg = '모든 필드를 올바르게 입력해주세요';

      if (!_state.agreeToTerms) {
        errorMsg = '서비스 이용약관에 동의해주세요';
      } else if (_state.emailError != null) {
        errorMsg = _state.emailError!;
      } else if (_state.passwordError != null) {
        errorMsg = _state.passwordError!;
      } else if (_state.confirmPasswordError != null) {
        errorMsg = _state.confirmPasswordError!;
      } else if (_state.displayNameError != null) {
        errorMsg = _state.displayNameError!;
      }

      print('❌ SignUpViewModel: 유효성 검증 에러 메시지: $errorMsg');
      _updateState(_state.copyWith(errorMessage: errorMsg));
      return;
    }

    print('✅ SignUpViewModel: 폼 유효성 검증 통과');

    // 로딩 시작
    print('⏳ SignUpViewModel: 로딩 상태 시작');
    _updateState(_state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      print('📞 SignUpViewModel: UseCase 호출 시작');
      // UseCase 호출
      final result = await _signUpUseCase(
        email: _state.email.trim(),
        password: _state.password,
        confirmPassword: _state.confirmPassword,
        displayName: _state.displayName.trim(),
      );

      print('📞 SignUpViewModel: UseCase 호출 완료, 결과 처리 시작');

      // 결과 처리 (Result.when 패턴)
      result.when(
        success: (user) {
          print('🎉 SignUpViewModel: 회원가입 성공! - User: ${user.displayName}');
          _updateState(_state.copyWith(
            isLoading: false,
            successMessage: '회원가입이 완료되었습니다! 환영합니다, ${user.displayName}',
            errorMessage: null,
          ));
          print('✅ SignUpViewModel: 성공 상태 업데이트 완료');
        },
        error: (failure) {
          print('❌ SignUpViewModel: 회원가입 실패! - Error: $failure');
          _updateState(_state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
            successMessage: null,
          ));
          print('❌ SignUpViewModel: 에러 상태 업데이트 완료');
        },
      );
    } catch (e, stackTrace) {
      print('💥 SignUpViewModel: 예외 발생! - $e');
      print('💥 StackTrace: $stackTrace');
      _updateState(_state.copyWith(
        isLoading: false,
        errorMessage: '회원가입 중 오류가 발생했습니다: $e',
        successMessage: null,
      ));
    }

    print('🏁 SignUpViewModel: signUp 메서드 완료');
  }

  /// Failure를 사용자 친화적 메시지로 변환
  String _getErrorMessage(Failure failure) {
    // 구체적인 Failure 타입에 따른 메시지 분기
    if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return '인터넷 연결을 확인해주세요';
    } else if (failure is ServerFailure) {
      return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
    } else if (failure is UnauthorizedFailure) {
      return '이미 사용 중인 이메일입니다';
    } else {
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