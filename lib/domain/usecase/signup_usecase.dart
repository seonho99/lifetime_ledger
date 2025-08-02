import '../../core/errors/failure.dart';
import '../../core/result/result.dart';
import '../model/user_model.dart';
import '../repository/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase({
    required AuthRepository repository,
  }) : _repository = repository;

  Future<Result<UserModel>> call({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    print('🔄 SignUpUseCase: 회원가입 UseCase 호출 시작');
    print('📝 SignUpUseCase: email=$email, displayName=$displayName');
    
    // 비즈니스 규칙 검증
    if (email.trim().isEmpty) {
      print('❌ SignUpUseCase: 이메일이 비어있음');
      return Error(ValidationFailure('이메일을 입력해주세요'));
    }

    if (password.trim().isEmpty) {
      print('❌ SignUpUseCase: 비밀번호가 비어있음');
      return Error(ValidationFailure('비밀번호를 입력해주세요'));
    }

    if (confirmPassword.trim().isEmpty) {
      print('❌ SignUpUseCase: 비밀번호 확인이 비어있음');
      return Error(ValidationFailure('비밀번호 확인을 입력해주세요'));
    }

    // 이메일 형식 검증
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      print('❌ SignUpUseCase: 이메일 형식 유효하지 않음');
      return Error(ValidationFailure('유효하지 않은 이메일 형식입니다'));
    }

    // 비밀번호 길이 검증
    if (password.length < 6) {
      print('❌ SignUpUseCase: 비밀번호가 너무 짧음');
      return Error(ValidationFailure('비밀번호는 6자 이상이어야 합니다'));
    }

    // 비밀번호 확인 검증
    if (password != confirmPassword) {
      print('❌ SignUpUseCase: 비밀번호가 일치하지 않음');
      return Error(ValidationFailure('비밀번호가 일치하지 않습니다'));
    }

    // 표시 이름 검증 (선택적)
    if (displayName != null && displayName.trim().isEmpty) {
      print('❌ SignUpUseCase: 표시 이름이 비어있음');
      return Error(ValidationFailure('표시 이름은 비어있을 수 없습니다'));
    }

    print('✅ SignUpUseCase: 모든 유효성 검증 통과');

    // 비밀번호 복잡성 검증 (추가 보안) - 임시로 주석 처리
    // if (!_isPasswordStrong(password)) {
    //   return Error(ValidationFailure('비밀번호는 영문, 숫자를 포함해야 합니다'));
    // }

    print('🏪 SignUpUseCase: Repository 호출 시작');
    try {
      // Repository를 통한 회원가입 실행
      final result = await _repository.signUpWithEmailAndPassword(
        email: email.trim(),
        password: password,
        displayName: displayName?.trim(),
      );
      
      print('🏪 SignUpUseCase: Repository 호출 완료');
      return result;
    } catch (e, stackTrace) {
      print('💥 SignUpUseCase: Repository 호출 중 예외 발생: $e');
      print('💥 StackTrace: $stackTrace');
      return Error(ServerFailure('회원가입 중 오류가 발생했습니다: $e'));
    }
  }

  /// 비밀번호 복잡성 검증
  bool _isPasswordStrong(String password) {
    // 최소 6자, 영문과 숫자 포함
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    return password.length >= 6 && hasLetters && hasNumbers;
  }
}