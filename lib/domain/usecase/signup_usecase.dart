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
    // 비즈니스 규칙 검증
    if (email.trim().isEmpty) {
      return Error(ValidationFailure('이메일을 입력해주세요'));
    }

    if (password.trim().isEmpty) {
      return Error(ValidationFailure('비밀번호를 입력해주세요'));
    }

    if (confirmPassword.trim().isEmpty) {
      return Error(ValidationFailure('비밀번호 확인을 입력해주세요'));
    }

    // 이메일 형식 검증
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return Error(ValidationFailure('유효하지 않은 이메일 형식입니다'));
    }

    // 비밀번호 길이 검증
    if (password.length < 6) {
      return Error(ValidationFailure('비밀번호는 6자 이상이어야 합니다'));
    }

    // 비밀번호 확인 검증
    if (password != confirmPassword) {
      return Error(ValidationFailure('비밀번호가 일치하지 않습니다'));
    }

    // 표시 이름 검증 (선택적)
    if (displayName != null && displayName.trim().isEmpty) {
      return Error(ValidationFailure('표시 이름은 비어있을 수 없습니다'));
    }

    // 비밀번호 복잡성 검증 (추가 보안)
    if (!_isPasswordStrong(password)) {
      return Error(ValidationFailure('비밀번호는 영문, 숫자를 포함해야 합니다'));
    }

    // Repository를 통한 회원가입 실행
    return await _repository.signUpWithEmailAndPassword(
      email: email.trim(),
      password: password,
      displayName: displayName?.trim(),
    );
  }

  /// 비밀번호 복잡성 검증
  bool _isPasswordStrong(String password) {
    // 최소 6자, 영문과 숫자 포함
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    return password.length >= 6 && hasLetters && hasNumbers;
  }
}