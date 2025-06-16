# 상태 관리

## Provider 기반 상태 관리 개요

Provider 패턴에서는 ChangeNotifier를 사용하여 상태를 관리합니다.
상태는 불변 객체(freezed)로 정의하고, ViewModel에서 상태 변경을 관리합니다.

## 상태 객체 정의 (freezed 3.0)

### 기본 State 구조
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
  
  // 계산된 속성들
  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .map((t) => t.amount)
      .fold(0.0, (sum, amount) => sum + amount);
      
  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .map((t) => t.amount)
      .fold(0.0, (sum, amount) => sum + amount);
      
  double get balance => totalIncome - totalExpense;
}
```

### 상태 헬퍼 메서드
```dart
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
  
  static TransactionState error(String message) {
    return TransactionState(
      transactions: [],
      isLoading: false,
      errorMessage: message,
    );
  }
}
```

## ViewModel에서 상태 관리

### 기본 ViewModel 패턴
```dart
class TransactionViewModel extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;

  TransactionViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase;

  // 상태 객체
  TransactionState _state = TransactionState(
    transactions: [],
    isLoading: false,
    errorMessage: null,
  );

  // 상태 접근자
  TransactionState get state => _state;

  // 편의 Getters
  List<Transaction> get transactions => _state.transactions;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;
  bool get hasError => _state.hasError;
  bool get isEmpty => _state.isEmpty;

  // 상태 업데이트 메서드
  void _updateState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  // 비즈니스 로직
  Future<void> loadTransactions() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await _getTransactionsUseCase();
    
    result.when(
      success: (transactions) {
        _updateState(_state.copyWith(
          transactions: transactions,
          isLoading: false,
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

  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }
}
```

### 간단한 ViewModel 패턴 (상태 객체 없이)
```dart
class SimpleTransactionViewModel extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;

  SimpleTransactionViewModel(this._getTransactionsUseCase);

  // 개별 상태 변수들
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // 상태 업데이트 메서드들
  Future<void> loadTransactions() async {
    _setLoading(true);
    _clearError();
    
    final result = await _getTransactionsUseCase();
    
    result.when(
      success: (transactions) {
        _transactions = transactions;
        _setLoading(false);
      },
      error: (failure) {
        _setError(failure.message);
        _setLoading(false);
      },
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

## UI에서 상태 구독

### Consumer 사용
```dart
class TransactionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        // 에러 상태
        if (viewModel.hasError) {
          return ErrorWidget(
            message: viewModel.errorMessage!,
            onRetry: () => viewModel.loadTransactions(),
          );
        }

        // 로딩 상태
        if (viewModel.isLoading) {
          return LoadingWidget();
        }

        // 빈 상태
        if (viewModel.isEmpty) {
          return EmptyWidget();
        }

        // 데이터 상태
        return TransactionList(
          transactions: viewModel.transactions,
        );
      },
    );
  }
}
```

### Selector를 활용한 최적화
```dart
// 특정 상태만 구독
class TransactionCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<TransactionViewModel, int>(
      selector: (context, viewModel) => viewModel.transactionCount,
      builder: (context, count, child) {
        return Text('총 $count개의 거래');
      },
    );
  }
}

// 로딩 상태만 구독
class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<TransactionViewModel, bool>(
      selector: (context, viewModel) => viewModel.isLoading,
      builder: (context, isLoading, child) {
        return isLoading 
          ? LinearProgressIndicator()
          : SizedBox.shrink();
      },
    );
  }
}

// 에러 상태만 구독
class ErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<TransactionViewModel, String?>(
      selector: (context, viewModel) => viewModel.errorMessage,
      builder: (context, errorMessage, child) {
        if (errorMessage == null) return SizedBox.shrink();
        
        return MaterialBanner(
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => context.read<TransactionViewModel>().clearError(),
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}
```

## 복합 상태 관리

### 여러 ViewModel 조합
```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TransactionViewModel(
            getTransactionsUseCase: context.read(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryViewModel(
            getCategoriesUseCase: context.read(),
          ),
        ),
      ],
      child: HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 거래 요약
          Consumer<TransactionViewModel>(
            builder: (context, transactionVM, child) {
              return TransactionSummary(
                totalIncome: transactionVM.state.totalIncome,
                totalExpense: transactionVM.state.totalExpense,
              );
            },
          ),
          
          // 카테고리 차트
          Consumer<CategoryViewModel>(
            builder: (context, categoryVM, child) {
              return CategoryChart(
                categories: categoryVM.categories,
              );
            },
          ),
          
          // 최근 거래 목록
          Expanded(
            child: Consumer<TransactionViewModel>(
              builder: (context, transactionVM, child) {
                return RecentTransactionList(
                  transactions: transactionVM.transactions,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### 상호 의존적인 ViewModel
```dart
class StatisticsViewModel extends ChangeNotifier {
  final TransactionViewModel _transactionViewModel;
  final CategoryViewModel _categoryViewModel;

  StatisticsViewModel({
    required TransactionViewModel transactionViewModel,
    required CategoryViewModel categoryViewModel,
  }) : _transactionViewModel = transactionViewModel,
       _categoryViewModel = categoryViewModel {
    
    // 다른 ViewModel 변경 사항 구독
    _transactionViewModel.addListener(_onTransactionChanged);
    _categoryViewModel.addListener(_onCategoryChanged);
  }

  Map<String, double> _categoryExpenses = {};
  Map<String, double> get categoryExpenses => _categoryExpenses;

  void _onTransactionChanged() {
    _calculateCategoryExpenses();
  }

  void _onCategoryChanged() {
    _calculateCategoryExpenses();
  }

  void _calculateCategoryExpenses() {
    final transactions = _transactionViewModel.transactions;
    final categories = _categoryViewModel.categories;
    
    // 카테고리별 지출 계산
    _categoryExpenses = {};
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        _categoryExpenses[transaction.category] = 
            (_categoryExpenses[transaction.category] ?? 0) + transaction.amount;
      }
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    _transactionViewModel.removeListener(_onTransactionChanged);
    _categoryViewModel.removeListener(_onCategoryChanged);
    super.dispose();
  }
}
```

## 상태 영속화

### SharedPreferences를 이용한 상태 저장
```dart
class TransactionViewModel extends ChangeNotifier {
  static const String _stateKey = 'transaction_state';
  
  TransactionViewModel() {
    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_stateKey);
      
      if (stateJson != null) {
        final stateMap = jsonDecode(stateJson);
        _state = TransactionState.fromJson(stateMap);
        notifyListeners();
      }
    } catch (e) {
      // 로딩 실패 시 초기 상태 유지
    }
  }

  void _updateState(TransactionState newState) {
    _state = newState;
    notifyListeners();
    _persistState();
  }

  Future<void> _persistState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = jsonEncode(_state.toJson());
      await prefs.setString(_stateKey, stateJson);
    } catch (e) {
      // 저장 실패는 무시 (메모리 상태는 유지)
    }
  }
}
```

## 상태 관리 Best Practices

### 1. 상태 설계 원칙
- **불변성**: freezed로 상태 객체 정의
- **단일 책임**: 각 ViewModel은 하나의 기능만 담당
- **명확한 구조**: 상태의 구조를 명확히 정의

### 2. 성능 최적화
- **Selector 사용**: 필요한 상태만 구독
- **적절한 분리**: 상태를 적절히 분리하여 불필요한 리빌드 방지
- **메모이제이션**: 계산 비용이 높은 getter는 캐싱 고려

### 3. 메모리 관리
- **dispose 구현**: 리소스 정리
- **리스너 해제**: 다른 ViewModel 구독 시 해제 필수
- **약한 참조**: 순환 참조 방지

### 4. 테스트 용이성
- **상태 분리**: 비즈니스 로직과 UI 로직 분리
- **의존성 주입**: 테스트용 UseCase 주입 가능
- **명확한 인터페이스**: 예측 가능한 상태 변화

## 체크리스트

### 상태 설계
- [ ] freezed로 상태 객체 정의
- [ ] Extension으로 계산된 속성 추가
- [ ] 헬퍼 메서드로 초기 상태 생성

### ViewModel 구현
- [ ] ChangeNotifier 상속
- [ ] 상태 업데이트 메서드 구현
- [ ] 적절한 notifyListeners() 호출
- [ ] dispose에서 리소스 정리

### UI 연동
- [ ] Consumer로 상태 구독
- [ ] Selector로 성능 최적화
- [ ] 적절한 상태별 UI 처리

### 성능 및 메모리
- [ ] 불필요한 리빌드 방지
- [ ] 메모리 누수 방지
- [ ] 적절한 상태 영속화