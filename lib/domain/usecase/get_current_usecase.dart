import '../../core/result/result.dart';
import '../model/user_model.dart';
import '../repository/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase({
    required AuthRepository repository,
  }) : _repository = repository;

  Future<Result<UserModel>> call() async {
    // 현재 사용자 정보 조회는 단순하므로 바로 Repository 호출
    return await _repository.getCurrentUser();
  }

  /// 현재 로그인 상태 확인 (동기)
  bool get isSignedIn => _repository.isSignedIn;

  /// 현재 사용자 ID 조회 (동기)
  String? get currentUserId => _repository.currentUserId;

  /// 실시간 인증 상태 스트림
  Stream<UserModel?> get authStateChanges => _repository.authStateChanges;
}