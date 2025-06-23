import '../../core/errors/failure.dart';
import '../../core/result/result.dart';
import '../repository/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository _repository;

  DeleteAccountUseCase({
    required AuthRepository repository,
  }) : _repository = repository;

  Future<Result<void>> call({
    required String password,
    required String confirmationText,
  }) async {
    // 비즈니스 규칙 검증
    if (password.trim().isEmpty) {
      return Error(ValidationFailure('비밀번호를 입력해주세요'));
    }

    // 계정 삭제 확인 텍스트 검증 (보안 강화)
    if (confirmationText.trim().isEmpty) {
      return Error(ValidationFailure('계정 삭제 확인 텍스트를 입력해주세요'));
    }

    // 정확한 확인 텍스트 검증
    const requiredConfirmation = '계정삭제';
    if (confirmationText.trim() != requiredConfirmation) {
      return Error(ValidationFailure('"$requiredConfirmation"를 정확히 입력해주세요'));
    }

    // 로그인 상태 확인
    if (!_repository.isSignedIn) {
      return Error(UnauthorizedFailure('계정 삭제를 위해서는 로그인이 필요합니다'));
    }

    // Repository를 통한 계정 삭제 실행
    return await _repository.deleteAccount(password);
  }
}