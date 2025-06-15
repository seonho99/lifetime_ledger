# 상태 관리

## ViewState 패턴

### 기본 구조
```dart
abstract class ViewState {
  const ViewState();
}

class Initial extends ViewState {
  const Initial();
}

class Loading extends ViewState {
  const Loading();
}

class Loaded<T> extends ViewState {
  final T data;
  const Loaded(this.data);
}

class Error extends ViewState {
  final String message;
  const Error(this.message);
}
```

## BLoC 상태 관리

### 이벤트 정의
```dart
abstract class TransactionEvent {
  const TransactionEvent();
}

class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

class AddTransaction extends TransactionEvent {
  final Transaction transaction;
  const AddTransaction(this.transaction);
}
```

### 상태 정의
```dart
abstract class TransactionState {
  const TransactionState();
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  const TransactionLoaded(this.transactions);
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);
}
```

### BLoC 구현
```dart
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;

  TransactionBloc({
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
  }) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    
    final result = await getTransactionsUseCase();
    
    result.when(
      success: (transactions) => emit(TransactionLoaded(transactions)),
      error: (failure) => emit(TransactionError(failure.message)),
    );
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await addTransactionUseCase(event.transaction);
    
    result.when(
      success: (_) => add(LoadTransactions()),
      error: (failure) => emit(TransactionError(failure.message)),
    );
  }
}
```

## 상태 관리 Best Practices

### 1. 상태 분리
- UI 상태와 비즈니스 로직 상태 분리
- 각 기능별로 독립적인 상태 관리
- 상태 변경의 추적 가능성 보장

### 2. 상태 불변성
- 상태 객체는 불변(immutable)으로 유지
- 상태 변경은 새로운 객체 생성으로 처리
- 상태 복사 시 깊은 복사 사용

### 3. 상태 업데이트
- 상태 변경은 BLoC을 통해서만 수행
- 상태 변경 시 이전 상태 보존
- 상태 변경 로직의 중앙화

### 4. 에러 처리
- 에러 상태의 명확한 정의
- 사용자 친화적인 에러 메시지
- 에러 복구 메커니즘 구현

### 5. 성능 최적화
- 불필요한 상태 업데이트 방지
- 상태 변경 시 필요한 부분만 리빌드
- 메모리 누수 방지

## 상태 관리 패턴 선택 기준

### BLoC 패턴 사용 시기
- 복잡한 상태 관리가 필요한 경우
- 비즈니스 로직이 많은 경우
- 상태 변경이 빈번한 경우
- 테스트가 중요한 경우

### Provider 패턴 사용 시기
- 간단한 상태 관리가 필요한 경우
- 위젯 트리 내에서 상태 공유가 필요한 경우
- 빠른 프로토타이핑이 필요한 경우

### Riverpod 사용 시기
- 타입 안전성이 중요한 경우
- 의존성 주입이 필요한 경우
- 테스트 용이성이 중요한 경우
