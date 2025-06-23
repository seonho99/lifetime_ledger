import '../../core/errors/failure.dart';
import '../../core/result/result.dart';
import '../repository/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase({
    required AuthRepository repository,
  }) : _repository = repository;

  Future<Result<void>> call({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    // 비즈니스 규칙 검증
    if (currentPassword.trim().isEmpty) {
      return Error(ValidationFailure('현재 비밀번호를 입력해주세요'));
    }

    if (newPassword.trim().isEmpty) {
      return Error(ValidationFailure('새 비밀번호를 입력해주세요'));
    }

    if (confirmNewPassword.trim().isEmpty) {
      return Error(ValidationFailure('새 비밀번호 확인을 입력해주세요'));
    }

    // 새 비밀번호 길이 검증
    if (newPassword.length < 6) {
      return Error(ValidationFailure('새 비밀번호는 6자 이상이어야 합니다'));
    }

    // 새 비밀번호 확인 검증
    if (newPassword != confirmNewPassword) {
      return Error(ValidationFailure('새 비밀번호가 일치하지 않습니다'));
    }

    // 현재 비밀번호와 새 비밀번호 동일성 검증
    if (currentPassword == newPassword) {
      return Error(ValidationFailure('새 비밀번호는 현재 비밀번호와 달라야 합니다'));
    }

    // 새 비밀번호 복잡성 검증
    if (!_isPasswordStrong(newPassword)) {
      return Error(ValidationFailure('새 비밀번호는 영문, 숫자를 포함해야 합니다'));
    }

    // Repository를 통한 비밀번호 변경 실행
    return await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
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