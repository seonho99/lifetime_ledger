# 레이어 구조

## Clean Architecture 레이어

### 1. Presentation Layer
- UI 관련 코드를 포함
- Provider 패턴을 사용한 상태 관리
- 사용자 입력 처리
- 화면 구성 및 네비게이션

#### 주요 컴포넌트
- ViewModels (ChangeNotifier 기반)
- Views/Screens

### 2. Domain Layer
- 비즈니스 로직을 포함
- 외부 의존성이 없는 순수한 Dart 코드
- 엔티티와 유스케이스 정의

#### 주요 컴포넌트
- Entities
- UseCases
- Repository Interfaces
- Value Objects

### 3. Data Layer
- 데이터 소스와 리포지토리 구현
- 외부 서비스와의 통신
- 데이터 변환 및 매핑

#### 주요 컴포넌트
- Repositories
- DataSources
- DTOs (Data Transfer Objects)
- Mappers

## 레이어 간 통신

### Presentation → Domain
- UseCase 호출
- Entity 사용
- Repository 인터페이스 참조

### Domain → Data
- Repository 구현체 사용
- DTO 변환
- 데이터 소스 접근

### Data → External
- API 호출
- 로컬 저장소 접근
- 외부 서비스 통신

## Provider 기반 MVVM 패턴

### State 구조
```dart
@freezed
class TransactionState with _$TransactionState {
  TransactionState({
    required this.transactions,
    required this.isLoading,
    this.errorMessage,
  });

  final List<Transaction> transactions;
  final bool isLoading;
  final String? errorMessage;
}

// State 확장 메서드
extension TransactionStateX on TransactionState {
  bool get hasError => errorMessage != null;
  bool get isEmpty => transactions.isEmpty;
  int get transactionCount => transactions.length;

  // 특정 조건의 거래만 필터링
  List<Transaction> get incomeTransactions =>
      transactions.where((t) => t.type == TransactionType.income).toList();

  List<Transaction> get expenseTransactions =>
      transactions.where((t) => t.type == TransactionType.expense).toList();

  // 계산된 속성들
  double get totalIncome => incomeTransactions
      .map((t) => t.amount)
      .fold(0.0, (sum, amount) => sum + amount);

  double get totalExpense => expenseTransactions
      .map((t) => t.amount)
      .fold(0.0, (sum, amount) => sum + amount);

  double get balance => totalIncome - totalExpense;
}

// 초기 상태 생성 헬퍼
extension TransactionStateHelpers on TransactionState {
  static TransactionState initial() {
    return TransactionState(
      transactions: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  static TransactionState loading() {
    return TransactionState(
      transactions: [],
      isLoading: true,
      errorMessage: null,
    );
  }
}
```

### ViewModel 구조
```dart
class TransactionViewModel extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;

  TransactionViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase;

  // 상태
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // 비즈니스 로직
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getTransactionsUseCase();
    result.when(
      success: (transactions) {
        _transactions = transactions;
        _isLoading = false;
        notifyListeners();
      },
      error: (failure) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
```


### Screen 구조 (Provider 설정 + UI 구현 통합)
```dart
class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(
        getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
      )..loadTransactions(),
      child: Scaffold(
        appBar: AppBar(title: const Text('거래 내역')),
        body: Consumer<TransactionViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: viewModel.transactions.length,
              itemBuilder: (context, index) {
                final transaction = viewModel.transactions[index];
                return ListTile(
                  title: Text(transaction.title),
                  subtitle: Text('₩${transaction.amount}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
```

## 의존성 규칙
1. 외부 레이어는 내부 레이어에 의존할 수 없음
2. 내부 레이어는 외부 레이어의 구현 세부사항을 알 수 없음
3. 의존성은 항상 안쪽을 향함

## 데이터 흐름
1. UI 이벤트 발생 (View)
2. ViewModel에서 이벤트 처리
3. UseCase 호출
4. Repository를 통한 데이터 접근
5. 데이터 소스에서 데이터 조회
6. DTO → Entity 변환
7. ViewModel 상태 업데이트 (notifyListeners())
8. UI 상태 업데이트 (Consumer/Selector)

## 상태 관리 최적화

### Selector 사용
```dart
// 특정 상태만 구독하여 불필요한 리빌드 방지
Selector<TransactionViewModel, bool>(
selector: (context, viewModel) => viewModel.isLoading,
builder: (context, isLoading, child) {
return isLoading
? const CircularProgressIndicator()
    : const SomeWidget();
},
)
```

### MultiProvider 사용
```dart
MultiProvider(
providers: [
ChangeNotifierProvider(
create: (context) => TransactionViewModel(
getTransactionsUseCase: context.read(),
addTransactionUseCase: context.read(),
),
),
ChangeNotifierProvider(
create: (context) => CategoryViewModel(
getCategoriesUseCase: context.read(),
),
),
],
child: const MyApp(),
)
```

## 에러 처리
- 각 레이어에서 적절한 에러 처리
- 도메인 레이어에서 커스텀 예외 정의
- ViewModel에서 에러 상태 관리
- View에서 사용자 친화적 에러 표시

## Best Practices

### ViewModel
- 하나의 ViewModel은 하나의 화면 또는 기능 담당
- UI 로직과 비즈니스 로직 분리
- 적절한 생명주기 관리 (dispose)
- 에러 상태와 로딩 상태 관리

### View
- Consumer와 Selector 적절히 사용
- 불필요한 리빌드 방지
- UI 상태만 관리
- ViewModel에 비즈니스 로직 위임

### 성능 최적화
- Selector를 사용한 부분 구독
- const 생성자 활용
- RepaintBoundary 적절히 사용
- 메모리 누수 방지

## 폴더 구조 예시
```
lib/
├── features/
│   └── transaction/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── viewmodels/
│           ├── views/
│           └── widgets/
├── core/
└── shared/
```