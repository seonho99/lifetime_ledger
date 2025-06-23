import '../../core/errors/failure.dart';
import '../../core/result/result.dart';
import '../model/user_model.dart';
import '../repository/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase({
    required AuthRepository repository,
  }) : _repository = repository;

  Future<Result<UserModel>> call({
    required String email,
    required String password,
  }) async {
    // 비즈니스 규칙 검증
    if (email.trim().isEmpty) {
      return Error(ValidationFailure('이메일을 입력해주세요'));
    }

    if (password.trim().isEmpty) {
      return Error(ValidationFailure('비밀번호를 입력해주세요'));
    }

    // 이메일 형식 검증
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return Error(ValidationFailure('유효하지 않은 이메일 형식입니다'));
    }

    // Repository를 통한 로그인 실행
    return await _repository.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }
}