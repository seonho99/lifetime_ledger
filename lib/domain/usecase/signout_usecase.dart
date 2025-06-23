import '../../core/result/result.dart';
import '../repository/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase({
    required AuthRepository repository,
  }) : _repository = repository;

  Future<Result<void>> call() async {
    // 로그아웃은 비즈니스 규칙이 단순하므로 바로 Repository 호출
    return await _repository.signOut();
  }
}