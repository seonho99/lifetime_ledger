/// 앱에서 사용하는 커스텀 예외들
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => 'AppException(message: $message)';
}

/// 네트워크 예외
class NetworkException extends AppException {
  const NetworkException(String message) : super(message);

  @override
  String toString() => 'NetworkException(message: $message)';
}

/// 서버 예외
class ServerException extends AppException {
  const ServerException(String message) : super(message);

  @override
  String toString() => 'ServerException(message: $message)';
}

/// 캐시 예외
class CacheException extends AppException {
  const CacheException(String message) : super(message);

  @override
  String toString() => 'CacheException(message: $message)';
}

/// 검증 예외
class ValidationException extends AppException {
  const ValidationException(String message) : super(message);

  @override
  String toString() => 'ValidationException(message: $message)';
}

/// 권한 예외
class UnauthorizedException extends AppException {
  const UnauthorizedException(String message) : super(message);

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}