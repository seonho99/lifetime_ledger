import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'exceptions.dart';
import 'failure.dart';

/// Exception을 Failure로 매핑하는 유틸리티
class FailureMapper {
  FailureMapper._(); // 인스턴스 생성 방지

  /// Exception을 Failure로 변환
  static Failure mapExceptionToFailure(Object error, [StackTrace? stackTrace]) {
    // 디버그 모드에서만 상세 로깅
    if (kDebugMode) {
      debugPrint('❌ Exception occurred: $error');
      if (stackTrace != null) {
        debugPrintStack(label: 'Exception StackTrace', stackTrace: stackTrace);
      }
    }

    // 커스텀 예외들
    if (error is NetworkException) {
      return NetworkFailure(error.message);
    } else if (error is ServerException) {
      return ServerFailure(error.message);
    } else if (error is CacheException) {
      return CacheFailure(error.message);
    } else if (error is ValidationException) {
      return ValidationFailure(error.message);
    } else if (error is UnauthorizedException) {
      return UnauthorizedFailure(error.message);
    } else if (error is FirebaseException) {
      return FirebaseFailure(error.message);
    }

    // Firebase 예외들 (패키지의 FirebaseException 사용)
    else if (error is firestore.FirebaseException) {
      return _mapFirestoreException(error);
    }

    // 시스템 예외들
    else if (error is TimeoutException) {
      return NetworkFailure('요청 시간이 초과되었습니다');
    } else if (error is SocketException) {
      return NetworkFailure('인터넷 연결을 확인해주세요');
    } else if (error is HttpException) {
      return ServerFailure('서버와의 통신 중 오류가 발생했습니다');
    } else if (error is FormatException) {
      return ServerFailure('데이터 형식 오류입니다');
    }

    // ArgumentError (주로 검증 오류)
    else if (error is ArgumentError) {
      return ValidationFailure(error.message?.toString() ?? '잘못된 입력입니다');
    }

    // 기타 예외
    else {
      return UnknownFailure('알 수 없는 오류가 발생했습니다: ${error.toString()}');
    }
  }

  /// Firestore 예외를 Failure로 매핑
  static Failure _mapFirestoreException(firestore.FirebaseException error) {
    // Firebase 에러 코드에 따른 분류
    final errorCode = error.code;
    final errorMessage = error.message ?? '알 수 없는 Firebase 오류';

    switch (errorCode) {
      case 'permission-denied':
        return UnauthorizedFailure('접근 권한이 없습니다');
      case 'unavailable':
        return NetworkFailure('서비스를 일시적으로 사용할 수 없습니다');
      case 'deadline-exceeded':
        return NetworkFailure('요청 시간이 초과되었습니다');
      case 'not-found':
        return ServerFailure('요청한 데이터를 찾을 수 없습니다');
      case 'already-exists':
        return ValidationFailure('이미 존재하는 데이터입니다');
      case 'resource-exhausted':
        return ServerFailure('요청 한도를 초과했습니다');
      case 'failed-precondition':
        return ValidationFailure('요청 조건이 충족되지 않았습니다');
      case 'aborted':
        return ServerFailure('작업이 중단되었습니다');
      case 'out-of-range':
        return ValidationFailure('유효하지 않은 범위입니다');
      case 'unimplemented':
        return ServerFailure('지원되지 않는 기능입니다');
      case 'internal':
        return ServerFailure('내부 서버 오류가 발생했습니다');
      case 'data-loss':
        return ServerFailure('데이터 손실이 발생했습니다');
      case 'unauthenticated':
        return UnauthorizedFailure('인증이 필요합니다');
      default:
        return FirebaseFailure('Firebase 오류: $errorMessage');
    }
  }

  /// 네트워크 관련 오류인지 확인
  static bool isNetworkError(Failure failure) {
    return failure is NetworkFailure;
  }

  /// 권한 관련 오류인지 확인
  static bool isAuthError(Failure failure) {
    return failure is UnauthorizedFailure;
  }

  /// 서버 관련 오류인지 확인
  static bool isServerError(Failure failure) {
    return failure is ServerFailure || failure is FirebaseFailure;
  }

  /// 검증 관련 오류인지 확인
  static bool isValidationError(Failure failure) {
    return failure is ValidationFailure;
  }

  /// 재시도 가능한 오류인지 확인
  static bool isRetryable(Failure failure) {
    return failure is NetworkFailure ||
        failure is ServerFailure ||
        (failure is FirebaseFailure &&
            (failure.message.contains('unavailable') ||
                failure.message.contains('deadline-exceeded')));
  }
}