import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/exceptions.dart';
import '../dto/user_model_dto.dart';
import 'auth_datasource.dart';

/// Firebase 기반 Auth DataSource 구현체
class AuthFirebaseDataSourceImpl implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  AuthFirebaseDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw ServerException('로그인에 실패했습니다');
      }

      return credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw ServerException('로그인 중 알 수 없는 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<String> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw ServerException('회원가입에 실패했습니다');
      }

      return credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw ServerException('회원가입 중 알 수 없는 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw ServerException('비밀번호 재설정 이메일 전송 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw UnauthorizedException('로그인된 사용자가 없습니다');
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw ServerException('이메일 인증 전송 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw UnauthorizedException('로그인된 사용자가 없습니다');
      }

      // 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 비밀번호 변경
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw ServerException('비밀번호 변경 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw UnauthorizedException('로그인된 사용자가 없습니다');
      }

      // 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Firestore 사용자 데이터 삭제
      await _firestore.collection(_usersCollection).doc(user.uid).delete();

      // Firebase Auth 계정 삭제
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw ServerException('계정 삭제 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> saveUser(UserModelDto user) async {
    try {
      print('💾 Firestore 저장 시작: ${user.id}');
      print('💾 저장할 데이터: ${user.toFirestore()}');
      
      // 타임아웃 추가 (30초)
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toFirestore())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('⏰ Firestore 저장 타임아웃 발생');
              throw ServerException('Firestore 저장 시간이 초과되었습니다');
            },
          );
          
      print('💾 Firestore 저장 성공!');
    } catch (e) {
      print('❌ Firestore 저장 실패: $e');
      throw ServerException('사용자 정보 저장 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<UserModelDto> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        // 사용자 문서가 없으면 자동으로 생성
        print('🔧 사용자 문서가 없어서 자동 생성 중: $uid');
        
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser == null) {
          throw ServerException('현재 로그인된 사용자가 없습니다');
        }
        
        final newUserDto = UserModelDto(
          id: uid,
          email: currentUser.email ?? '',
          displayName: currentUser.displayName ?? '사용자',
          isEmailVerified: currentUser.emailVerified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Firestore에 사용자 문서 생성
        await _firestore
            .collection(_usersCollection)
            .doc(uid)
            .set(newUserDto.toFirestore());
            
        print('✅ 사용자 문서 자동 생성 완료');
        return newUserDto;
      }

      return UserModelDto.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('사용자 정보 조회 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) {
        updateData['displayName'] = displayName;
      }

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update(updateData);
    } catch (e) {
      throw ServerException('사용자 프로필 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      throw ServerException('사용자 존재 확인 중 오류가 발생했습니다: $e');
    }
  }

  @override
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  UserModelDto? get currentUserData {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return UserModelDto(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      isEmailVerified: user.emailVerified,
      createdAt: DateTime.now(), // Firebase Auth에서는 createdAt이 직접 제공되지 않음
      updatedAt: DateTime.now(),
    );
  }

  @override
  Stream<String?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  /// FirebaseAuthException을 앱 예외로 변환
  Exception _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UnauthorizedException('해당 이메일로 등록된 계정이 없습니다');
      case 'wrong-password':
        return UnauthorizedException('비밀번호가 올바르지 않습니다');
      case 'invalid-email':
        return ValidationException('유효하지 않은 이메일 형식입니다');
      case 'user-disabled':
        return UnauthorizedException('이 계정은 비활성화되었습니다');
      case 'email-already-in-use':
        return ValidationException('이미 사용 중인 이메일입니다');
      case 'weak-password':
        return ValidationException('비밀번호가 너무 약합니다');
      case 'requires-recent-login':
        return UnauthorizedException('보안을 위해 다시 로그인해주세요');
      case 'too-many-requests':
        return NetworkException('너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요');
      default:
        return ServerException('Firebase 인증 오류: ${e.message}');
    }
  }
}