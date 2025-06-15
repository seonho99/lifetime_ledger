# 상태 관리 가이드

## 1. BLoC 패턴

### 1. 이벤트 정의
```dart
abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final Transaction transaction;
  AddTransaction(this.transaction);
}

class UpdateTransaction extends TransactionEvent {
  final Transaction transaction;
  UpdateTransaction(this.transaction);
}

class DeleteTransaction extends TransactionEvent {
  final String id;
  DeleteTransaction(this.id);
}
```

### 2. 상태 정의
```dart
abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  TransactionLoaded(this.transactions);
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}
```

### 3. BLoC 구현
```dart
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;

  TransactionBloc(this.repository) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await repository.getTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await repository.addTransaction(event.transaction);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  // ... 다른 이벤트 핸들러
}
```

## 2. Provider 패턴

### 1. 상태 클래스
```dart
class TransactionProvider extends ChangeNotifier {
  final TransactionRepository repository;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  TransactionProvider(this.repository);

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await repository.getTransactions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await repository.addTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

### 2. Provider 사용
```dart
class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(
        TransactionRepository(),
      ),
      child: TransactionView(),
    );
  }
}

class TransactionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const CircularProgressIndicator();
        }

        if (provider.error != null) {
          return ErrorWidget(
            message: provider.error!,
            onRetry: () => provider.loadTransactions(),
          );
        }

        return ListView.builder(
          itemCount: provider.transactions.length,
          itemBuilder: (context, index) {
            final transaction = provider.transactions[index];
            return TransactionCard(transaction: transaction);
          },
        );
      },
    );
  }
}
```

## 3. Riverpod 패턴

### 1. 상태 정의
```dart
final transactionProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionNotifier(ref.read(transactionRepositoryProvider));
});

class TransactionNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final TransactionRepository repository;

  TransactionNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await repository.getTransactions();
      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await repository.addTransaction(transaction);
      await loadTransactions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

### 2. Riverpod 사용
```dart
class TransactionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionProvider);

    return transactionsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(
        message: error.toString(),
        onRetry: () => ref.read(transactionProvider.notifier).loadTransactions(),
      ),
      data: (transactions) => ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return TransactionCard(transaction: transaction);
        },
      ),
    );
  }
}
```

## 4. Best Practices

### 1. 상태 관리 선택
- 앱 규모 고려
- 팀 경험 고려
- 성능 요구사항
- 유지보수성

### 2. 상태 구조화
- 명확한 책임
- 재사용 가능한 상태
- 테스트 가능한 구조
- 디버깅 용이성

### 3. 성능 최적화
- 불필요한 리빌드 방지
- 상태 분리
- 메모리 관리
- 비동기 처리

## 5. 체크리스트

### 1. 상태 관리
- [ ] 적절한 패턴 선택
- [ ] 상태 구조화
- [ ] 이벤트 처리
- [ ] 에러 처리

### 2. 구현
- [ ] 상태 정의
- [ ] 이벤트 정의
- [ ] 비즈니스 로직
- [ ] UI 연동

### 3. 성능
- [ ] 리빌드 최적화
- [ ] 메모리 관리
- [ ] 비동기 처리
- [ ] 에러 처리

### 4. 테스트
- [ ] 단위 테스트
- [ ] 통합 테스트
- [ ] UI 테스트
- [ ] 성능 테스트 