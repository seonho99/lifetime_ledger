import '../../../core/result/result.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../core/errors/failure.dart';
import '../../domain/model/user_model.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_datasource.dart';
import '../mapper/user_model_mapper.dart';

/// Auth Repository 구현체
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl({
    required AuthDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 입력 값 검증
      if (email.trim().isEmpty) {
        return Error(ValidationFailure('이메일은 필수입니다'));
      }
      if (password.trim().isEmpty) {
        return Error(ValidationFailure('비밀번호는 필수입니다'));
      }

      // Firebase Auth 로그인
      final uid = await _dataSource.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Firestore에서 사용자 정보 조회
      final userDto = await _dataSource.getUser(uid);
      final user = userDto.toModel();

      if (user == null) {
        return Error(ServerFailure('사용자 정보를 변환할 수 없습니다'));
      }

      return Success(user);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // 입력 값 검증
      if (email.trim().isEmpty) {
        return Error(ValidationFailure('이메일은 필수입니다'));
      }
      if (password.trim().isEmpty) {
        return Error(ValidationFailure('비밀번호는 필수입니다'));
      }
      if (password.length < 6) {
        return Error(ValidationFailure('비밀번호는 6자 이상이어야 합니다'));
      }

      // Firebase Auth 회원가입
      final uid = await _dataSource.signUpWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // UserModel 생성
      final user = uid.toUserModelWithUid(
        email: email.trim().toLowerCase(),
        displayName: displayName?.trim(),
        isEmailVerified: false,
      );

      // Firestore에 사용자 정보 저장 (비동기로 처리하여 실패해도 회원가입은 성공으로 처리)
      final userDto = user.toDto();
      print('🔥 회원가입: Firestore에 사용자 정보 저장 시작 - UID: ${user.id}');
      
      // Firestore 저장을 백그라운드에서 실행 (실패해도 회원가입은 성공)
      _dataSource.saveUser(userDto).then((_) {
        print('✅ 회원가입: Firestore 저장 완료 (백그라운드)');
      }).catchError((e) {
        print('⚠️ 회원가입: Firestore 저장 실패하지만 회원가입은 성공: $e');
      });
      
      print('🎯 회원가입: Firebase Auth 성공, 즉시 Success 반환');
      return Success(user);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      // 입력 값 검증
      if (email.trim().isEmpty) {
        return Error(ValidationFailure('이메일은 필수입니다'));
      }

      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email.trim())) {
        return Error(ValidationFailure('유효하지 않은 이메일 형식입니다'));
      }

      await _dataSource.sendPasswordResetEmail(email.trim());
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await _dataSource.sendEmailVerification();
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // 입력 값 검증
      if (currentPassword.trim().isEmpty) {
        return Error(ValidationFailure('현재 비밀번호는 필수입니다'));
      }
      if (newPassword.trim().isEmpty) {
        return Error(ValidationFailure('새 비밀번호는 필수입니다'));
      }
      if (newPassword.length < 6) {
        return Error(ValidationFailure('새 비밀번호는 6자 이상이어야 합니다'));
      }
      if (currentPassword == newPassword) {
        return Error(ValidationFailure('새 비밀번호는 현재 비밀번호와 달라야 합니다'));
      }

      await _dataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    try {
      final currentUserId = _dataSource.currentUserId;
      if (currentUserId == null) {
        return Error(UnauthorizedFailure('로그인된 사용자가 없습니다'));
      }

      // Firestore에서 사용자 정보 조회
      final userDto = await _dataSource.getUser(currentUserId);
      final user = userDto.toModel();

      if (user == null) {
        return Error(ServerFailure('사용자 정보를 변환할 수 없습니다'));
      }

      return Success(user);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> updateProfile({
    String? displayName,
  }) async {
    try {
      final currentUserId = _dataSource.currentUserId;
      if (currentUserId == null) {
        return Error(UnauthorizedFailure('로그인된 사용자가 없습니다'));
      }

      // 입력 값 검증
      if (displayName != null && displayName.trim().isEmpty) {
        return Error(ValidationFailure('표시 이름은 비어있을 수 없습니다'));
      }

      await _dataSource.updateUserProfile(
        uid: currentUserId,
        displayName: displayName?.trim(),
      );

      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> deleteAccount(String password) async {
    try {
      // 입력 값 검증
      if (password.trim().isEmpty) {
        return Error(ValidationFailure('비밀번호는 필수입니다'));
      }

      await _dataSource.deleteAccount(password);
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  bool get isSignedIn => _dataSource.isSignedIn;

  @override
  String? get currentUserId => _dataSource.currentUserId;

  @override
  Stream<UserModel?> get authStateChanges {
    return _dataSource.authStateChanges.asyncMap((uid) async {
      if (uid == null) return null;

      try {
        final userDto = await _dataSource.getUser(uid);
        return userDto.toModel();
      } catch (e) {
        // 스트림에서는 예외를 던지지 않고 null 반환
        return null;
      }
    });
  }
}