# 에러 처리

## 에러 처리 전략

### 1. 도메인 레이어 에러
```dart
abstract class DomainException implements Exception {
  final String message;
  const DomainException(this.message);
}

class ValidationException extends DomainException {
  const ValidationException(String message) : super(message);
}

class BusinessRuleException extends DomainException {
  const BusinessRuleException(String message) : super(message);
}
```

### 2. 데이터 레이어 에러
```dart
abstract class DataException implements Exception {
  final String message;
  const DataException(this.message);
}

class NetworkException extends DataException {
  const NetworkException(String message) : super(message);
}

class CacheException extends DataException {
  const CacheException(String message) : super(message);
}

class ServerException extends DataException {
  const ServerException(String message) : super(message);
}
```

### 3. 프레젠테이션 레이어 에러
```dart
abstract class UIException implements Exception {
  final String message;
  const UIException(this.message);
}

class NavigationException extends UIException {
  const NavigationException(String message) : super(message);
}

class FormValidationException extends UIException {
  const FormValidationException(String message) : super(message);
}
```

## 에러 처리 흐름

### 1. 데이터 소스 레벨
```dart
class RemoteDataSource {
  Future<Result<T>> getData() async {
    try {
      // API 호출
      return Success(data);
    } on DioException catch (e) {
      return Error(NetworkException(e.message));
    } catch (e) {
      return Error(ServerException(e.toString()));
    }
  }
}
```

### 2. 리포지토리 레벨
```dart
class RepositoryImpl implements Repository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  Future<Result<T>> getData() async {
    try {
      final result = await remoteDataSource.getData();
      return result;
    } on DataException catch (e) {
      return Error(e);
    }
  }
}
```

### 3. 유스케이스 레벨
```dart
class GetDataUseCase {
  final Repository repository;

  Future<Result<T>> call() async {
    try {
      return await repository.getData();
    } on DomainException catch (e) {
      return Error(e);
    }
  }
}
```

### 4. BLoC 레벨
```dart
class DataBloc extends Bloc<DataEvent, DataState> {
  final GetDataUseCase getDataUseCase;

  Future<void> _onGetData(
    GetData event,
    Emitter<DataState> emit,
  ) async {
    emit(DataLoading());
    
    final result = await getDataUseCase();
    
    result.when(
      success: (data) => emit(DataLoaded(data)),
      error: (failure) => emit(DataError(failure.message)),
    );
  }
}
```

## 에러 처리 Best Practices

### 1. 에러 계층화
- 도메인 에러
- 데이터 에러
- UI 에러
- 각 계층별 명확한 에러 정의

### 2. 에러 전파
- Result 패턴을 통한 에러 전파
- 각 레이어에서 적절한 에러 변환
- 에러 메시지의 일관성 유지

### 3. 에러 로깅
- 중요 에러의 로깅
- 에러 컨텍스트 정보 포함
- 로깅 레벨 구분

### 4. 사용자 피드백
- 사용자 친화적인 에러 메시지
- 에러 복구 방법 제시
- 적절한 UI 피드백

### 5. 에러 복구
- 자동 재시도 메커니즘
- 폴백 옵션 제공
- 오프라인 모드 지원

## 에러 처리 패턴

### 1. Try-Catch 패턴
```dart
try {
  // 위험한 작업
} on SpecificException catch (e) {
  // 특정 예외 처리
} catch (e) {
  // 일반 예외 처리
} finally {
  // 정리 작업
}
```

### 2. Result 패턴
```dart
Future<Result<T>> getData() async {
  try {
    return Success(data);
  } catch (e) {
    return Error(failure);
  }
}
```

### 3. Either 패턴
```dart
Future<Either<Failure, T>> getData() async {
  try {
    return Right(data);
  } catch (e) {
    return Left(failure);
  }
}
```

## 에러 처리 체크리스트

### 1. 에러 정의
- [ ] 모든 가능한 에러 케이스 정의
- [ ] 에러 메시지의 일관성
- [ ] 에러 코드 체계

### 2. 에러 처리
- [ ] 각 레이어별 에러 처리
- [ ] 에러 전파 메커니즘
- [ ] 에러 복구 전략

### 3. 사용자 경험
- [ ] 사용자 친화적인 에러 메시지
- [ ] 적절한 UI 피드백
- [ ] 에러 복구 방법 제시

### 4. 테스트
- [ ] 에러 케이스 테스트
- [ ] 에러 처리 로직 테스트
- [ ] 에러 복구 메커니즘 테스트
