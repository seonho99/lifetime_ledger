import '../../core/errors/failure.dart';
import '../../core/result/result.dart';
import '../repository/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository _repository;

  SendPasswordResetEmailUseCase({
    required AuthRepository repository,
  }) : _repository = repository;

  Future<Result<void>> call(String email) async {
    // 비즈니스 규칙 검증
    if (email.trim().isEmpty) {
      return Error(ValidationFailure('이메일을 입력해주세요'));
    }

    // 이메일 형식 검증
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return Error(ValidationFailure('유효하지 않은 이메일 형식입니다'));
    }

    // Repository를 통한 비밀번호 재설정 이메일 전송
    return await _repository.sendPasswordResetEmail(email.trim());
  }
}