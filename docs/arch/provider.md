# 🧩 Provider 의존성 주입 설계 가이드

---

## ✅ 목적

- **Provider 패턴**을 통해 앱의 의존성 주입을 체계적으로 관리
- Clean Architecture 계층별 의존성을 명확히 구분하여 관리
- **MultiProvider**와 **ChangeNotifierProvider**를 활용한 효율적인 상태 관리
- 테스트 가능성과 확장성을 고려한 의존성 구조 설계

---

## 🧱 설계 원칙

- **main.dart**에서 **MultiProvider**로 전역 의존성 설정 (Repository, UseCase)
- **Screen**에서 **ChangeNotifierProvider**로 ViewModel 제공
- 계층별 의존성은 하향식으로만 주입 (UI → UseCase → Repository → DataSource)
- **context.read()**로 의존성 주입, **Consumer/Selector**로 상태 구독
- Provider 생명주기는 Provider 패턴이 자동으로 관리

---

## ✅ 파일 구조 및 위치

```
lib/
├── main.dart                           # MultiProvider 전역 설정
├── features/
│   └── {기능}/
│       ├── data/
│       │   ├── datasources/
│       │   └── repositories/
│       ├── domain/
│       │   ├── usecases/
│       │   └── repositories/
│       └── presentation/
│           ├── viewmodels/
│           └── screens/
└── core/
    └── di/
        └── injection_container.dart    # 의존성 컨테이너 (선택적)
```

---

## ✅ main.dart에서 전역 Provider 설정

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core Services
        Provider<StorageService>(
          create: (context) => StorageServiceImpl(),
        ),

        Provider<ApiService>(
          create: (context) => ApiServiceImpl(),
        ),

        Provider<NetworkInfo>(
          create: (context) => NetworkInfoImpl(),
        ),

        // Data Layer - DataSources
        Provider<TransactionRemoteDataSource>(
          create: (context) => TransactionRemoteDataSourceImpl(
            apiService: context.read<ApiService>(),
          ),
        ),

        Provider<TransactionLocalDataSource>(
          create: (context) => TransactionLocalDataSourceImpl(
            storageService: context.read<StorageService>(),
          ),
        ),

        Provider<CategoryRemoteDataSource>(
          create: (context) => CategoryRemoteDataSourceImpl(
            apiService: context.read<ApiService>(),
          ),
        ),

        Provider<CategoryLocalDataSource>(
          create: (context) => CategoryLocalDataSourceImpl(
            storageService: context.read<StorageService>(),
          ),
        ),

        // Data Layer - Repositories
        Provider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(
            remoteDataSource: context.read<TransactionRemoteDataSource>(),
            localDataSource: context.read<TransactionLocalDataSource>(),
            networkInfo: context.read<NetworkInfo>(),
          ),
        ),

        Provider<CategoryRepository>(
          create: (context) => CategoryRepositoryImpl(
            remoteDataSource: context.read<CategoryRemoteDataSource>(),
            localDataSource: context.read<CategoryLocalDataSource>(),
            networkInfo: context.read<NetworkInfo>(),
          ),
        ),

        // Domain Layer - UseCases (Transaction)
        Provider<GetTransactionsUseCase>(
          create: (context) => GetTransactionsUseCase(
            repository: context.read<TransactionRepository>(),
          ),
        ),

        Provider<GetTransactionByIdUseCase>(
          create: (context) => GetTransactionByIdUseCase(
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

        // Domain Layer - UseCases (Category)
        Provider<GetCategoriesUseCase>(
          create: (context) => GetCategoriesUseCase(
            repository: context.read<CategoryRepository>(),
          ),
        ),

        Provider<AddCategoryUseCase>(
          create: (context) => AddCategoryUseCase(
            repository: context.read<CategoryRepository>(),
          ),
        ),

        // Domain Layer - UseCases (Statistics)
        Provider<GetExpensesByCategoryUseCase>(
          create: (context) => GetExpensesByCategoryUseCase(
            transactionRepository: context.read<TransactionRepository>(),
            categoryRepository: context.read<CategoryRepository>(),
          ),
        ),

        Provider<GetMonthlyReportUseCase>(
          create: (context) => GetMonthlyReportUseCase(
            transactionRepository: context.read<TransactionRepository>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Lifetime Ledger',
        routerConfig: router,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
      ),
    );
  }
}
```

---

## ✅ Screen에서 ViewModel Provider 설정

### 기본 Screen 패턴

```dart
class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(
        getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
        addTransactionUseCase: context.read<AddTransactionUseCase>(),
        updateTransactionUseCase: context.read<UpdateTransactionUseCase>(),
        deleteTransactionUseCase: context.read<DeleteTransactionUseCase>(),
      )..loadTransactions(), // 초기 데이터 로드
      child: const TransactionView(),
    );
  }
}

class TransactionView extends StatelessWidget {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('거래 내역'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.read<TransactionViewModel>().navigateToAdd(context),
          ),
        ],
      ),
      body: Consumer<TransactionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage!),
                  ElevatedButton(
                    onPressed: () => viewModel.retryLastAction(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: viewModel.transactions.length,
            itemBuilder: (context, index) {
              return TransactionCard(
                transaction: viewModel.transactions[index],
                onTap: () => viewModel.navigateToDetail(
                  context,
                  viewModel.transactions[index].id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

### Parameter가 있는 Screen

```dart
class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;
  
  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionDetailViewModel(
        transactionId: transactionId,
        getTransactionUseCase: context.read<GetTransactionByIdUseCase>(),
        updateTransactionUseCase: context.read<UpdateTransactionUseCase>(),
        deleteTransactionUseCase: context.read<DeleteTransactionUseCase>(),
      )..loadTransaction(),
      child: const TransactionDetailView(),
    );
  }
}
```

---

## ✅ ViewModel 의존성 주입 패턴

```dart
class TransactionViewModel extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final AddTransactionUseCase _addTransactionUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;

  TransactionViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
    required AddTransactionUseCase addTransactionUseCase,
    required UpdateTransactionUseCase updateTransactionUseCase,
    required DeleteTransactionUseCase deleteTransactionUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase,
       _addTransactionUseCase = addTransactionUseCase,
       _updateTransactionUseCase = updateTransactionUseCase,
       _deleteTransactionUseCase = deleteTransactionUseCase;

  // 상태 관리 로직...
  
  Future<void> loadTransactions() async {
    final result = await _getTransactionsUseCase();
    // Result 처리...
  }

  Future<void> addTransaction(Transaction transaction) async {
    final result = await _addTransactionUseCase(transaction);
    // Result 처리...
  }
}
```

---

## ✅ UseCase 의존성 주입 패턴

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

---

## ✅ Repository 의존성 주입 패턴

```dart
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;
  final TransactionLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  TransactionRepositoryImpl({
    required TransactionRemoteDataSource remoteDataSource,
    required TransactionLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Result<List<Transaction>>> getTransactions() async {
    if (await _networkInfo.isConnected) {
      try {
        final transactions = await _remoteDataSource.getTransactions();
        return Success(transactions.map((dto) => dto.toEntity()).toList());
      } catch (e) {
        return Error(FailureMapper.mapExceptionToFailure(e));
      }
    } else {
      try {
        final transactions = await _localDataSource.getTransactions();
        return Success(transactions.map((dto) => dto.toEntity()).toList());
      } catch (e) {
        return Error(CacheFailure('로컬 데이터를 불러올 수 없습니다'));
      }
    }
  }
}
```

---

## 🔄 Provider 생명주기 관리

### Provider 타입별 생명주기

| Provider 타입 | 생명주기 | 사용 사례 |
|--------------|---------|-----------|
| **Provider** | 앱 생명주기 동안 유지 | Repository, UseCase, Service |
| **ChangeNotifierProvider** | 화면 생명주기와 연동 | ViewModel |
| **Consumer** | 위젯 리빌드 시 호출 | 상태 구독 |
| **Selector** | 선택된 상태 변경 시만 호출 | 성능 최적화 |

### 메모리 관리 고려사항

```dart
// ✅ 좋은 예: 필요한 곳에서만 ViewModel 생성
class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(...),
      child: TransactionView(),
    );
  }
}

// ❌ 나쁜 예: 너무 상위에서 ViewModel 생성
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 다른 Provider들...
        ChangeNotifierProvider(
          create: (context) => TransactionViewModel(...), // 전역으로 생성
        ),
      ],
      child: MaterialApp(...),
    );
  }
}
```

---

## 🧪 테스트 전략

### Provider Override를 이용한 테스트

```dart
testWidgets('TransactionScreen 위젯 테스트', (WidgetTester tester) async {
  // Mock 객체들
  final mockRepository = MockTransactionRepository();
  final mockUseCase = MockGetTransactionsUseCase();
  
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<TransactionRepository>.value(value: mockRepository),
        Provider<GetTransactionsUseCase>.value(value: mockUseCase),
      ],
      child: MaterialApp(
        home: TransactionScreen(),
      ),
    ),
  );

  // 테스트 로직...
});
```

### ViewModel 단위 테스트

```dart
group('TransactionViewModel 테스트', () {
  late TransactionViewModel viewModel;
  late MockGetTransactionsUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetTransactionsUseCase();
    viewModel = TransactionViewModel(
      getTransactionsUseCase: mockUseCase,
      // 다른 UseCase들...
    );
  });

  test('loadTransactions 성공 시 상태 업데이트', () async {
    // Given
    final transactions = [Transaction.create(...)];
    when(() => mockUseCase()).thenAnswer((_) async => Success(transactions));

    // When
    await viewModel.loadTransactions();

    // Then
    expect(viewModel.transactions, equals(transactions));
    expect(viewModel.isLoading, false);
    expect(viewModel.hasError, false);
  });
});
```

---

## 📋 의존성 주입 흐름

```
main.dart (MultiProvider)
    ↓
전역 Provider 등록 (Repository, UseCase, Service)
    ↓
Screen (ChangeNotifierProvider)
    ↓
ViewModel 생성 및 의존성 주입 (context.read<UseCase>())
    ↓
UI (Consumer/Selector)
    ↓
상태 구독 및 UI 업데이트
```

---

## ✅ Best Practices

### 1. Provider 설정
- **전역**: Repository, UseCase, Service (main.dart)
- **지역**: ViewModel (Screen별 ChangeNotifierProvider)
- **접근**: read() vs watch() vs Consumer 적절히 선택

### 2. 의존성 관리
- **단방향 의존성**: 상위 → 하위로만 의존
- **인터페이스 활용**: 구현체가 아닌 인터페이스에 의존
- **생명주기 고려**: Provider가 객체 생명주기 자동 관리

### 3. 성능 고려사항
- **Selector 활용**: 필요한 상태만 구독
- **적절한 범위**: Provider를 필요한 곳에만 배치
- **메모리 관리**: 불필요한 글로벌 Provider 생성 지양

---
