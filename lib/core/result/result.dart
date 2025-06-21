import '../errors/failure.dart';

/// 비동기 작업의 성공/실패를 타입 안전하게 처리하기 위한 Result 패턴
sealed class Result<T> {
  const Result();
}

/// 성공 결과
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

/// 실패 결과
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Error<T> && other.failure == failure;
  }

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Error(failure: $failure)';
}

/// Result 패턴 확장 메서드
extension ResultExtension<T> on Result<T> {
  /// when 패턴 - 성공/실패에 따른 처리
  void when({
    required Function(T data) success,
    required Function(Failure failure) error,
  }) {
    switch (this) {
      case Success<T> successResult:
        success(successResult.data);
      case Error<T> errorResult:
        error(errorResult.failure);
    }
  }

  /// fold 패턴 - 성공/실패를 다른 타입으로 변환
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    switch (this) {
      case Success<T> successResult:
        return onSuccess(successResult.data);
      case Error<T> errorResult:
        return onError(errorResult.failure);
    }
  }

  /// 성공 여부 확인
  bool get isSuccess => this is Success<T>;

  /// 실패 여부 확인
  bool get isError => this is Error<T>;

  /// 성공 시 데이터 반환, 실패 시 null
  T? get dataOrNull {
    switch (this) {
      case Success<T> successResult:
        return successResult.data;
      case Error<T>():
        return null;
    }
  }

  /// 실패 시 Failure 반환, 성공 시 null
  Failure? get failureOrNull {
    switch (this) {
      case Success<T>():
        return null;
      case Error<T> errorResult:
        return errorResult.failure;
    }
  }

  /// 성공 시 데이터 반환, 실패 시 예외 던지기
  T get dataOrThrow {
    switch (this) {
      case Success<T> successResult:
        return successResult.data;
      case Error<T> errorResult:
        throw Exception('Result failed: ${errorResult.failure.message}');
    }
  }

  /// 데이터 변환 (성공인 경우에만)
  Result<R> map<R>(R Function(T data) transform) {
    switch (this) {
      case Success<T> successResult:
        try {
          return Success(transform(successResult.data));
        } catch (e) {
          // core/errors/failure.dart의 UnknownFailure 사용
          return Error(UnknownFailure('Transformation failed: $e'));
        }
      case Error<T> errorResult:
        return Error(errorResult.failure);
    }
  }

  /// 비동기 데이터 변환 (성공인 경우에만)
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    switch (this) {
      case Success<T> successResult:
        try {
          final result = await transform(successResult.data);
          return Success(result);
        } catch (e) {
          return Error(UnknownFailure('Async transformation failed: $e'));
        }
      case Error<T> errorResult:
        return Error(errorResult.failure);
    }
  }

  /// 성공인 경우에만 추가 작업 수행
  Result<T> onSuccess(void Function(T data) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }

  /// 실패인 경우에만 추가 작업 수행
  Result<T> onError(void Function(Failure failure) action) {
    if (this is Error<T>) {
      action((this as Error<T>).failure);
    }
    return this;
  }
}