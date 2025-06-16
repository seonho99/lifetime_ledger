# 레이어 구조

## Clean Architecture + MVVM + Provider 패턴

### 1. 전체 아키텍처 흐름

```
MainActivity -> [MultiProvider] -> Screen -> [ChangeNotifierProvider] -> View -> [Consumer] -> ViewModel -> UseCase -> Repository -> DataSource
     ↓              ↓                ↓              ↓                      ↓         ↓          ↓          ↓          ↓           ↓
   앱 진입점      의존성 주입         화면 단위    ViewModel 제공           UI 구성   상태 구독   상태 관리   비즈니스    데이터 추상화  데이터 소스
```

### 2. Clean Architecture 레이어

#### Presentation Layer (UI + ViewModel)
- **ViewModel**: ChangeNotifier 기반 상태 관리
- **Screen**: ChangeNotifierProvider 설정
- **View**: Consumer/Selector로 상태 구독
- **State**: freezed 기반 불변 상태 객체

#### Domain Layer (비즈니스 로직)
- **Entities**: 순수 도메인 모델
- **UseCases**: 비즈니스 로직 실행
- **Repository Interfaces**: 데이터 계층 추상화

#### Data Layer (데이터 처리)
- **Repository Implementations**: 데이터 소스 조합
- **DataSources**: 실제 데이터 접근
- **DTOs**: 데이터 전송 객체

### 3. Provider 통합 방식

#### 전역 Provider 설정 (main.dart) - 프로덕션 레벨
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

        Provider<BudgetRepository>(
          create: (context) => BudgetRepositoryImpl(
            remoteDataSource: context.read<BudgetRemoteDataSource>(),
            localDataSource: context.read<BudgetLocalDataSource>(),
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

        // Domain Layer - UseCases (Budget)
        Provider<GetBudgetsUseCase>(
          create: (context) => GetBudgetsUseCase(
            repository: context.read<BudgetRepository>(),
          ),
        ),

        Provider<CreateBudgetUseCase>(
          create: (context) => CreateBudgetUseCase(
            repository: context.read<BudgetRepository>(),
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
      child: MaterialApp(
        title: 'Lifetime Ledger',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
```

#### 화면별 ViewModel Provider 설정
```dart
// Screen - ChangeNotifierProvider 설정
class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(
        getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
        addTransactionUseCase: context.read<AddTransactionUseCase>(),
      )..loadTransactions(), // 초기 데이터 로드
      child: const TransactionView(),
    );
  }
}

// View - Consumer로 상태 구독
class TransactionView extends StatelessWidget {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('거래 내역')),
      body: Consumer<TransactionViewModel>(
        builder: (context, viewModel, child) {
          // 상태별 UI 처리 (간단한 예시)
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (viewModel.hasError) {
            return Center(child: Text(viewModel.errorMessage!));
          }
          
          return ListView.builder(
            itemCount: viewModel.transactions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(viewModel.transactions[index].title),
                subtitle: Text('₩${viewModel.transactions[index].amount}'),
              );
            },
          );
        },
      ),
    );
  }
}
```

### 4. ViewModel과 State 연동

#### 간단한 State 예시
```dart
// State 객체 (상세 내용은 state.md 참조)
@freezed
sealed class TransactionState with _$TransactionState {
  TransactionState({
    required this.transactions,
    required this.isLoading,
    this.errorMessage,
  });
  
  final List<Transaction> transactions;
  final bool isLoading;
  final String? errorMessage;
}
```

#### ViewModel 구현 (아키텍처 통합)

```dart
class TransactionViewModel extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final AddTransactionUseCase _addTransactionUseCase;

  TransactionViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
    required AddTransactionUseCase addTransactionUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase,
       _addTransactionUseCase = addTransactionUseCase;

  // State 객체로 상태 관리 (상세 구현은 state.md 참조)
  TransactionState _state = TransactionState.initial();

  TransactionState get state => _state;
  List<Transaction> get transactions => _state.transactions;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;

  // 상태 업데이트 (Provider 알림)
  void _updateState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  // 비즈니스 로직 (간단한 에러 처리)
  Future<void> loadTransactions() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await _getTransactionsUseCase();
    
    switch (result) {
      case Success(data: final transactions):
        _updateState(_state.copyWith(transactions: transactions, isLoading: false));
      case Error(failure: final failure):
        _updateState(_state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }
  
  // 다른 CRUD 메서드들...
  // 상세 구현은 관련 가이드 문서 참조
}
```

> **구현 세부사항 참조**:
> - **State 설계**: `state.md` 참조
> - **Result 패턴**: `result.md` 참조
> - **에러 처리**: `error.md` 참조
> - **Provider 사용법**: `provider.md` 참조
```

### 5. 레이어 간 데이터 흐름

#### UI 이벤트 → ViewModel → UseCase → Repository
```dart
// 1. UI 이벤트 발생
onPressed: () => context.read<TransactionViewModel>().loadTransactions(),

// 2. ViewModel에서 UseCase 호출
Future<void> loadTransactions() async {
  final result = await _getTransactionsUseCase();
  // 결과 처리...
}

// 3. UseCase에서 Repository 호출
class GetTransactionsUseCase {
  Future<Result<List<Transaction>>> call() async {
    return await repository.getTransactions();
  }
}

// 4. Repository에서 DataSource 접근
class TransactionRepositoryImpl implements TransactionRepository {
  Future<Result<List<Transaction>>> getTransactions() async {
    final result = await remoteDataSource.getTransactions();
    // DTO → Entity 변환 후 반환
  }
}
```

### 6. Provider 최적화

#### Selector를 활용한 부분 구독
```dart
// 특정 상태만 구독하여 불필요한 리빌드 방지
Selector<TransactionViewModel, bool>(
  selector: (context, viewModel) => viewModel.isLoading,
  builder: (context, isLoading, child) {
    return isLoading 
      ? const CircularProgressIndicator()
      : const SizedBox.shrink();
  },
)

// 거래 개수만 구독
Selector<TransactionViewModel, int>(
  selector: (context, viewModel) => viewModel.transactions.length,
  builder: (context, count, child) {
    return Text('총 $count개의 거래');
  },
)
```

## 의존성 규칙
1. 외부 레이어는 내부 레이어에 의존할 수 없음
2. Provider는 의존성 주입만 담당, 비즈니스 로직 포함 안 함
3. ViewModel은 UseCase만 호출, Repository 직접 접근 금지
4. State는 불변 객체로 관리, ViewModel에서만 변경

## 데이터 흐름 요약
1. **MultiProvider**: 전역 의존성 주입 (Repository, UseCase)
2. **ChangeNotifierProvider**: 화면별 ViewModel 제공
3. **Consumer/Selector**: UI에서 상태 구독 및 업데이트
4. **ViewModel**: State 관리 + UseCase 호출
5. **Result 패턴**: 성공/실패 처리 및 UI 상태 업데이트