import '../../core/errors/failure.dart';
import '../../core/result/result.dart';
import '../repository/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase({
    required AuthRepository repository,
  }) : _repository = repository;

  Future<Result<void>> call({
    String? displayName,
  }) async {
    // 비즈니스 규칙 검증

    // 표시 이름이 제공된 경우 검증
    if (displayName != null) {
      // 빈 문자열 검증
      if (displayName.trim().isEmpty) {
        return Error(ValidationFailure('표시 이름은 비어있을 수 없습니다'));
      }

      // 길이 검증 (2자 이상 20자 이하)
      if (displayName.trim().length < 2) {
        return Error(ValidationFailure('표시 이름은 2자 이상이어야 합니다'));
      }

      if (displayName.trim().length > 20) {
        return Error(ValidationFailure('표시 이름은 20자 이하여야 합니다'));
      }

      // 특수문자 검증 (한글, 영문, 숫자, 공백만 허용)
      final validNameRegex = RegExp(r'^[가-힣a-zA-Z0-9\s]+$');
      if (!validNameRegex.hasMatch(displayName.trim())) {
        return Error(ValidationFailure('표시 이름은 한글, 영문, 숫자, 공백만 사용할 수 있습니다'));
      }
    }

    // 실제로 업데이트할 내용이 있는지 확인
    if (displayName == null) {
      return Error(ValidationFailure('업데이트할 정보를 입력해주세요'));
    }

    // Repository를 통한 프로필 업데이트 실행
    return await _repository.updateProfile(
      displayName: displayName.trim(),
    );
  }
}