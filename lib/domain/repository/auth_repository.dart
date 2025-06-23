import '../../core/result/result.dart';
import '../model/user_model.dart';

/// Auth Repository 인터페이스
abstract class AuthRepository {
  // 인증 관련
  Future<Result<UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> sendEmailVerification();

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  // 사용자 정보 관리
  Future<Result<UserModel>> getCurrentUser();

  Future<Result<void>> updateProfile({
    String? displayName,
  });

  Future<Result<void>> deleteAccount(String password);

  // 상태 확인
  bool get isSignedIn;
  String? get currentUserId;

  // 실시간 인증 상태 스트림
  Stream<UserModel?> get authStateChanges;
}