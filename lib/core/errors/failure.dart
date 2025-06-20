/// Failure 추상 클래스
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'Failure(message: $message)';
}

/// 서버 에러
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);

  @override
  String toString() => 'ServerFailure(message: $message)';
}

/// 네트워크 에러
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);

  @override
  String toString() => 'NetworkFailure(message: $message)';
}

/// 캐시 에러
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);

  @override
  String toString() => 'CacheFailure(message: $message)';
}

/// 검증 에러
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);

  @override
  String toString() => 'ValidationFailure(message: $message)';
}

/// 권한 에러
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(String message) : super(message);

  @override
  String toString() => 'UnauthorizedFailure(message: $message)';
}

/// Firebase 에러
class FirebaseFailure extends Failure {
  const FirebaseFailure(String message) : super(message);

  @override
  String toString() => 'FirebaseFailure(message: $message)';
}

/// 알 수 없는 오류
class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);

  @override
  String toString() => 'UnknownFailure(message: $message)';
}