import '../../core/errors/failure.dart';
import '../../core/result/result.dart';
import '../repository/auth_repository.dart';

class SendEmailVerificationUseCase {
  final AuthRepository _repository;

  SendEmailVerificationUseCase({
    required AuthRepository repository,
  }) : _repository = repository;

  Future<Result<void>> call() async {
    // 로그인 상태 확인
    if (!_repository.isSignedIn) {
      return Error(UnauthorizedFailure('이메일 인증을 위해서는 로그인이 필요합니다'));
    }

    // Repository를 통한 이메일 인증 전송
    return await _repository.sendEmailVerification();
  }

  /// 현재 로그인 상태 확인
  bool get isSignedIn => _repository.isSignedIn;
}