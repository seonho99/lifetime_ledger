import 'package:firebase_auth/firebase_auth.dart';
import '../dto/user_model_dto.dart';

/// Auth DataSource 인터페이스
abstract class AuthDataSource {
  // Firebase Auth 관련
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<String> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteAccount(String password);

  // Firebase Auth 사용자 정보
  Future<User?> getCurrentUser();

  // Firestore 사용자 정보 관리
  Future<void> saveUser(UserModelDto user);

  Future<UserModelDto> getUser(String uid);

  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
  });

  Future<bool> checkUserExists(String uid);

  // 상태 확인
  bool get isSignedIn;
  String? get currentUserId;
  UserModelDto? get currentUserData;

  // 실시간 인증 상태 스트림
  Stream<String?> get authStateChanges;
}