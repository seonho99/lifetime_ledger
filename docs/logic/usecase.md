# ⚙️ UseCase 설계 가이드

---

## ✅ 목적

UseCase는 하나의 명확한 도메인 동작을 수행하는 단위다.  
Repository를 통해 데이터를 요청하고,  
ViewModel에서 처리할 수 있도록  
**Result<T>를 그대로 반환하는 책임**을 가진다.

---

## 🧱 설계 원칙

- 하나의 UseCase는 하나의 목적(도메인 동작)만 수행한다.
- Repository에서 받은 `Result<T>`를 그대로 반환한다.
- **비즈니스 로직 실행** 및 **Repository 호출**이 주요 책임이다.
- UseCase는 상태를 직접 관리하지 않고,  
  **Repository 호출 및 비즈니스 규칙 실행**만 담당한다.
- **Provider 패턴**으로 ViewModel에 주입된다.

---

## ✅ 파일 구조 및 위치

```text
lib/
└── features/
    └── transaction/
        └── domain/
            └── usecases/
                ├── get_transactions_usecase.dart
                ├── add_transaction_usecase.dart
                ├── update_transaction_usecase.dart
                └── delete_transaction_usecase.dart
```

---

## ✅ 기본 작성 예시

### GetTransactionsUseCase

```dart
class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase({
    required TransactionRepository repository,
  }) : _repository = repository;

  Future<Result<List<Transaction>>> call() async {
    return await _repository.getTransactions();
  }
}
```

### AddTransactionUseCase

```dart
class AddTransactionUseCase {
  final TransactionRepository _repository;

  AddTransactionUseCase({
    required TransactionRepository repository,
  }) : _repository = repository;

  Future<Result<void>> call(Transaction transaction) async {
    // 비즈니스 규칙 검증
    if (!transaction.isValid) {
      return Error(ValidationFailure('유효하지 않은 거래 정보입니다'));
    }

    return await _repository.addTransaction(transaction);
  }
}
```

### GetTransactionsByDateRangeUseCase (비즈니스 로직 포함)

```dart
class GetTransactionsByDateRangeUseCase {
  final TransactionRepository _repository;

  GetTransactionsByDateRangeUseCase({
    required TransactionRepository repository,
  }) : _repository = repository;

  Future<Result<List<Transaction>>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 비즈니스 규칙 검증
    if (endDate.isBefore(startDate)) {
      return Error(ValidationFailure('종료일은 시작일보다 늦어야 합니다'));
    }

    final daysDifference = endDate.difference(startDate).inDays;
    if (daysDifference > 365) {
      return Error(ValidationFailure('조회 기간은 1년을 초과할 수 없습니다'));
    }

    return await _repository.getTransactionsByDateRange(startDate, endDate);
  }
}
```

### CalculateMonthlyStatisticsUseCase (복합 비즈니스 로직)

```dart
class CalculateMonthlyStatisticsUseCase {
  final TransactionRepository _repository;

  CalculateMonthlyStatisticsUseCase({
    required TransactionRepository repository,
  }) : _repository = repository;

  Future<Result<MonthlyStatistics>> call(DateTime month) async {
    // 해당 월의 시작일과 종료일 계산
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);

    final result = await _repository.getTransactionsByDateRange(startDate, endDate);

    return result.fold(
      onSuccess: (transactions) {
        // 비즈니스 로직: 통계 계산
        final statistics = _calculateStatistics(transactions, month);
        return Success(statistics);
      },
      onError: (failure) => Error(failure),
    );
  }

  MonthlyStatistics _calculateStatistics(List<Transaction> transactions, DateTime month) {
    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> categoryExpenses = {};
    final Map<int, double> dailyExpenses = {};

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
        
        // 카테고리별 지출 계산
        categoryExpenses[transaction.categoryId] = 
            (categoryExpenses[transaction.categoryId] ?? 0) + transaction.amount;
        
        // 일별 지출 계산
        final day = transaction.date.day;
        dailyExpenses[day] = (dailyExpenses[day] ?? 0) + transaction.amount;
      }
    }

    return MonthlyStatistics(
      month: month,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      categoryExpenses: categoryExpenses,
      dailyExpenses: dailyExpenses,
      transactionCount: transactions.length,
    );
  }
}
```

✅ **주요 포인트**
- Repository에서 받은 `Result<T>`를 그대로 반환
- 비즈니스 규칙 검증 및 복합 로직 실행
- `call()` 메서드를 사용하여 함수 객체 패턴 적용

---

## 📌 흐름 요약

```text
ViewModel → UseCase 호출
UseCase → Repository 호출 + 비즈니스 로직 실행
UseCase → Result<T> 반환
ViewModel → Result<T> 처리 + State 업데이트 + notifyListeners()
```

> UseCase는 Repository 호출과 비즈니스 로직을 담당하고,  
> ViewModel이 Result<T>를 받아서 UI 상태로 변환한다.

---

## 🔥 ViewModel에서 UseCase 사용 예시

```dart
class TransactionViewModel extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final AddTransactionUseCase _addTransactionUseCase;

  TransactionViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
    required AddTransactionUseCase addTransactionUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase,
       _addTransactionUseCase = addTransactionUseCase;

  TransactionState _state = TransactionState.initial();
  TransactionState get state => _state;

  void _updateState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await _getTransactionsUseCase();
    
    result.when(
      success: (transactions) {
        _updateState(_state.copyWith(
          transactions: transactions,
          isLoading: false,
          errorMessage: null,
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
    );
  }

  Future<void> addTransaction(Transaction transaction) async {
    final result = await _addTransactionUseCase(transaction);
    
    result.when(
      success: (_) {
        // 성공 시 목록 새로고침
        loadTransactions();
      },
      error: (failure) {
        _updateState(_state.copyWith(errorMessage: failure.message));
      },
    );
  }
}
```

✅ UseCase는 Result<T>를 반환하므로  
✅ ViewModel에서 Result.when()으로 처리하여 상태 업데이트

---

## 🔥 실패(Failure) 처리 전략

- Repository 단계에서 Exception을 **Failure 객체**로 변환
- UseCase 단계에서는 이 Result<T>를 그대로 반환
- ViewModel에서는 `Result.when()` 또는 `switch`를 통해  
  **Failure.message**를 표시하거나, 필요한 추가 분기를 진행한다.

> 예외(Exception)를 직접 다루지 않고, 항상 **Failure 기준**으로 관리한다.

---

## 📋 책임 구분

| 계층 | 역할 |
|:---|:---|
| **Repository** | 외부 통신 및 데이터 반환, 실패 시 Failure 포장 |
| **UseCase** | Repository 호출 + 비즈니스 로직 실행 + Result<T> 반환 |
| **ViewModel** | UseCase 호출 + Result<T> 처리 + State 업데이트 + notifyListeners() |

---

## ✅ Provider 설정

### main.dart에서 UseCase Provider 등록

```dart
MultiProvider(
  providers: [
    // Repository
    Provider<TransactionRepository>(
      create: (context) => TransactionRepositoryImpl(
        remoteDataSource: context.read<TransactionRemoteDataSource>(),
        localDataSource: context.read<TransactionLocalDataSource>(),
      ),
    ),

    // UseCases
    Provider<GetTransactionsUseCase>(
      create: (context) => GetTransactionsUseCase(
        repository: context.read<TransactionRepository>(),
      ),
    ),
    Provider<AddTransactionUseCase>(
      create: (context) => AddTransactionUseCase(
        repository: context.read<TransactionRepository>(),
      ),
    ),
    Provider<UpdateTransactionUseCase>(
      create: (context) => UpdateTransactionUseCase(
        repository: context.read<TransactionRepository>(),
      ),
    ),
    Provider<DeleteTransactionUseCase>(
      create: (context) => DeleteTransactionUseCase(
        repository: context.read<TransactionRepository>(),
      ),
    ),
  ],
  child: MyApp(),
)
```

### Screen에서 ViewModel에 UseCase 주입

```dart
class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(
        getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
        addTransactionUseCase: context.read<AddTransactionUseCase>(),
        updateTransactionUseCase: context.read<UpdateTransactionUseCase>(),
        deleteTransactionUseCase: context.read<DeleteTransactionUseCase>(),
      ),
      child: const TransactionView(),
    );
  }
}
```

---

## 🧪 테스트 전략

### UseCase 단위 테스트

```dart
group('GetTransactionsUseCase 테스트', () {
  late GetTransactionsUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetTransactionsUseCase(repository: mockRepository);
  });

  test('Repository 성공 시 Success<List<Transaction>> 반환', () async {
    // Given
    final transactions = [
      Transaction.create(
        title: '커피',
        amount: 4500,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime.now(),
      ),
    ];
    when(() => mockRepository.getTransactions())
        .thenAnswer((_) async => Success(transactions));

    // When
    final result = await useCase();

    // Then
    expect(result, isA<Success<List<Transaction>>>());
    final data = result.dataOrNull!;
    expect(data.length, 1);
    expect(data.first.title, '커피');
  });

  test('Repository 실패 시 Error<Failure> 반환', () async {
    // Given
    final failure = NetworkFailure('네트워크 오류');
    when(() => mockRepository.getTransactions())
        .thenAnswer((_) async => Error(failure));

    // When
    final result = await useCase();

    // Then
    expect(result, isA<Error<List<Transaction>>>());
    final error = result.failureOrNull!;
    expect(error, isA<NetworkFailure>());
    expect(error.message, '네트워크 오류');
  });
});

group('AddTransactionUseCase 테스트', () {
  late AddTransactionUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = AddTransactionUseCase(repository: mockRepository);
  });

  test('유효한 Transaction 추가 성공', () async {
    // Given
    final transaction = Transaction.create(
      title: '커피',
      amount: 4500,
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime.now(),
    );
    when(() => mockRepository.addTransaction(any()))
        .thenAnswer((_) async => Success(null));

    // When
    final result = await useCase(transaction);

    // Then
    expect(result, isA<Success<void>>());
    verify(() => mockRepository.addTransaction(transaction)).called(1);
  });

  test('유효하지 않은 Transaction은 ValidationFailure 반환', () async {
    // Given
    final invalidTransaction = Transaction(
      id: '1',
      title: '', // 빈 제목 (유효하지 않음)
      amount: 0, // 0 금액 (유효하지 않음)
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // When
    final result = await useCase(invalidTransaction);

    // Then
    expect(result, isA<Error<void>>());
    final failure = result.failureOrNull!;
    expect(failure, isA<ValidationFailure>());
    verifyNever(() => mockRepository.addTransaction(any()));
  });
});
```

✅ **성공/실패 상황 모두 명확히 테스트 가능**

---

# ✅ 문서 요약

- UseCase는 Repository를 호출하고 비즈니스 로직을 실행한다.
- Repository에서 받은 Result<T>를 그대로 반환한다.
- 상태 관리는 ViewModel이 담당하고, UseCase는 비즈니스 로직에만 집중한다.
- 실패 처리는 항상 Failure 객체 기준으로 일관성 있게 다룬다.
- Provider 패턴으로 의존성을 주입받고, Dart의 `call()` 메서드로 함수 객체처럼 사용한다.

---