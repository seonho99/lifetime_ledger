# Result 패턴

## 개요
Result 패턴은 비동기 작업의 성공/실패를 명확하게 처리하기 위한 패턴입니다.
이 패턴을 통해 에러 처리를 더 명확하고 타입 안전하게 할 수 있습니다.

## Result 클래스 구조
```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
```

## Failure 클래스 구조
```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}
```

## 사용 예시

### Repository 레벨
```dart
abstract class TransactionRepository {
  Future<Result<List<Transaction>>> getTransactions();
  Future<Result<void>> addTransaction(Transaction transaction);
}
```

### UseCase 레벨
```dart
class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Result<List<Transaction>>> call() async {
    return await repository.getTransactions();
  }
}
```

### BLoC 레벨
```dart
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;

  TransactionBloc(this.getTransactionsUseCase) {
    on<LoadTransactions>(_onLoadTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    
    final result = await getTransactionsUseCase();
    
    result.when(
      success: (transactions) => emit(TransactionLoaded(transactions)),
      error: (failure) => emit(TransactionError(failure.message)),
    );
  }
}
```

## Result 패턴의 장점
1. 타입 안전성
   - 컴파일 타임에 에러 처리 확인
   - null 안전성 보장

2. 명확한 에러 처리
   - 에러 타입별 구분
   - 에러 메시지 표준화

3. 코드 가독성
   - 성공/실패 케이스 명확한 구분
   - 패턴 매칭을 통한 간결한 처리

4. 테스트 용이성
   - 성공/실패 케이스 테스트 용이
   - 모킹이 간단

## Best Practices
1. 모든 비동기 작업에 Result 패턴 적용
2. 구체적인 Failure 타입 정의
3. 에러 메시지의 일관성 유지
4. Result 처리 시 when 메서드 사용
5. 적절한 에러 로깅 추가
