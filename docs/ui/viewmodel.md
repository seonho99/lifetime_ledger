# 🧩 ViewModel 설계 가이드

---

## ✅ 목적

ViewModel은 앱의 상태를 보존하고, 사용자 액션을 처리하는  
**상태 관리 계층**입니다.

이 프로젝트에서는 **ChangeNotifier**를 기반으로  
모든 화면의 상태를 일관성 있게 관리하며,  
**Provider 패턴**을 통해 UI와 연결됩니다.

---

## 📚 MVVM 아키텍처에서의 역할

- **Model**: Entity, UseCase, Repository
- **View**: Screen, Widget
- **ViewModel**: 상태 관리, UseCase 호출, UI 로직 처리

ViewModel은 View와 Model 사이의 중재자 역할을 수행하며,  
UI 상태 관리와 비즈니스 로직 실행을 담당합니다.

---

# ⚙️ 기본 구조 예시

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

  // 상태 관리
  TransactionState _state = TransactionState.initial();
  TransactionState get state => _state;

  // 편의 Getters
  List<Transaction> get transactions => _state.transactions;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.errorMessage != null;
  String? get errorMessage => _state.errorMessage;

  // 상태 업데이트
  void _updateState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  // 비즈니스 메서드
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
          errorMessage: _getErrorMessage(failure),
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

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return '인터넷 연결을 확인해주세요.';
      case ServerFailure:
        return '서버 오류가 발생했습니다.';
      default:
        return failure.message;
    }
  }

  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }

  void retryLastAction() {
    clearError();
    loadTransactions();
  }
}
```

✅ `ChangeNotifier`를 상속하여 상태 변경을 UI에 알립니다.  
✅ 생성자에서 UseCase들을 주입받습니다.  
✅ 데이터 호출은 반드시 UseCase를 통해 수행합니다.

---

# 🏗️ 파일 구조 및 명명 규칙

```text
lib/
└── features/
    └── transaction/
        └── presentation/
            ├── viewmodels/
            │   └── transaction_viewmodel.dart
            └── states/
                └── transaction_state.dart
```

| 항목 | 규칙 |
|:---|:---|
| 파일 경로 | `lib/features/{기능}/presentation/viewmodels/` |
| 파일명 | `{기능}_viewmodel.dart` |
| 클래스명 | `{기능}ViewModel` |

---

# 🔥 ViewModel 초기화 패턴

## ✅ 기본 초기화

```dart
class TransactionViewModel extends ChangeNotifier {
  TransactionViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase;

  TransactionState _state = TransactionState.initial();
  
  // 초기 데이터 로드는 Screen에서 호출
  Future<void> initialize() async {
    await loadTransactions();
  }
}
```

## ✅ Screen에서 ViewModel 사용

```dart
class TransactionScreen extends StatelessWidget {
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
```

---

# 🧠 State 관리 패턴

## ✅ State 객체 기반 관리

```dart
class TransactionViewModel extends ChangeNotifier {
  TransactionState _state = TransactionState.initial();
  TransactionState get state => _state;

  // 편의 Getters (선택적)
  List<Transaction> get transactions => _state.transactions;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.errorMessage != null;

  void _updateState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }
}
```

## ✅ 개별 속성 관리 (간단한 경우)

```dart
class SimpleViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<Item> _items = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Item> get items => _items;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
}
```

---

# 👁️ UI에서 ViewModel 사용

## ✅ Consumer 패턴

```dart
class TransactionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.hasError) {
          return ErrorWidget(message: viewModel.errorMessage!);
        }
        
        if (viewModel.isLoading) {
          return const LoadingWidget();
        }
        
        return TransactionList(transactions: viewModel.transactions);
      },
    );
  }
}
```

## ✅ Selector 패턴 (성능 최적화)

```dart
// 특정 상태만 구독
Selector<TransactionViewModel, bool>(
  selector: (context, viewModel) => viewModel.isLoading,
  builder: (context, isLoading, child) {
    return isLoading 
        ? const CircularProgressIndicator()
        : const SizedBox.shrink();
  },
)

// 복합 상태 구독
Selector<TransactionViewModel, ({int count, double total})>(
  selector: (context, viewModel) => (
    count: viewModel.transactions.length,
    total: viewModel.totalAmount,
  ),
  builder: (context, data, child) {
    return Text('${data.count}건, 총 ₩${data.total}');
  },
)
```

---

# 🛠️ 네비게이션 처리

## ✅ NavigationMixin 활용

```dart
mixin NavigationMixin {
  void navigateTo(BuildContext context, String path) {
    context.push(path);
  }

  void navigateBack(BuildContext context) {
    context.pop();
  }

  Future<T?> navigateModal<T>(BuildContext context, String path) {
    return context.push<T>(path);
  }
}

class TransactionViewModel extends ChangeNotifier with NavigationMixin {
  // ... 다른 코드

  void navigateToDetail(BuildContext context, String transactionId) {
    navigateTo(context, '/transactions/$transactionId');
  }

  void navigateToAdd(BuildContext context) {
    navigateTo(context, '/transactions/add');
  }

  Future<void> addTransactionAndNavigateBack(
    BuildContext context, 
    Transaction transaction,
  ) async {
    final result = await _addTransactionUseCase(transaction);
    
    result.when(
      success: (_) {
        loadTransactions();
        navigateBack(context);
      },
      error: (failure) {
        _updateState(_state.copyWith(errorMessage: failure.message));
      },
    );
  }
}
```

---

# 🔥 고급 패턴

## ✅ 폼 상태 관리

```dart
class AddTransactionViewModel extends ChangeNotifier {
  final AddTransactionUseCase _addTransactionUseCase;

  AddTransactionViewModel({
    required AddTransactionUseCase addTransactionUseCase,
  }) : _addTransactionUseCase = addTransactionUseCase;

  // 폼 상태
  String _title = '';
  double _amount = 0.0;
  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get title => _title;
  double get amount => _amount;
  TransactionType get type => _type;
  String? get selectedCategoryId => _selectedCategoryId;
  DateTime get date => _date;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 폼 유효성 검증
  bool get isValid => 
      _title.trim().isNotEmpty &&
      _amount > 0 &&
      _selectedCategoryId != null;

  // 폼 업데이트 메서드들
  void updateTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void updateAmount(double amount) {
    _amount = amount;
    notifyListeners();
  }

  void updateType(TransactionType type) {
    _type = type;
    notifyListeners();
  }

  void updateCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void updateDate(DateTime date) {
    _date = date;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    if (!isValid) {
      _errorMessage = '모든 필드를 올바르게 입력해주세요.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final transaction = Transaction.create(
      title: _title,
      amount: _amount,
      type: _type,
      categoryId: _selectedCategoryId!,
      date: _date,
    );

    final result = await _addTransactionUseCase(transaction);

    result.when(
      success: (_) {
        _isLoading = false;
        notifyListeners();
        Navigator.pop(context, true); // 성공 결과와 함께 돌아가기
      },
      error: (failure) {
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
    );
  }

  void reset() {
    _title = '';
    _amount = 0.0;
    _type = TransactionType.expense;
    _selectedCategoryId = null;
    _date = DateTime.now();
    _errorMessage = null;
    notifyListeners();
  }
}
```

## ✅ 리스트 관리 (페이지네이션)

```dart
class TransactionListViewModel extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;

  TransactionListViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase;

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _transactions.clear();
    }

    _isLoading = refresh;
    _isLoadingMore = !refresh;
    _errorMessage = null;
    notifyListeners();

    final result = await _getTransactionsUseCase(page: _currentPage);

    result.when(
      success: (newTransactions) {
        if (refresh) {
          _transactions = newTransactions;
        } else {
          _transactions.addAll(newTransactions);
        }

        _hasMore = newTransactions.length >= 20; // 페이지 크기
        _currentPage++;
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      },
      error: (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    await loadTransactions();
  }

  Future<void> refresh() async {
    await loadTransactions(refresh: true);
  }
}
```

---

# 🧪 테스트 전략

```dart
group('TransactionViewModel 테스트', () {
  late TransactionViewModel viewModel;
  late MockGetTransactionsUseCase mockGetTransactionsUseCase;

  setUp(() {
    mockGetTransactionsUseCase = MockGetTransactionsUseCase();
    viewModel = TransactionViewModel(
      getTransactionsUseCase: mockGetTransactionsUseCase,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('초기 상태가 올바르게 설정됨', () {
    expect(viewModel.transactions, isEmpty);
    expect(viewModel.isLoading, false);
    expect(viewModel.hasError, false);
  });

  test('loadTransactions 성공 시 상태 업데이트', () async {
    // Given
    final transactions = [Transaction.create(...)];
    when(() => mockGetTransactionsUseCase())
        .thenAnswer((_) async => Success(transactions));

    // When
    await viewModel.loadTransactions();

    // Then
    expect(viewModel.transactions, equals(transactions));
    expect(viewModel.isLoading, false);
    expect(viewModel.hasError, false);
  });

  test('loadTransactions 실패 시 에러 상태 설정', () async {
    // Given
    final failure = NetworkFailure('네트워크 오류');
    when(() => mockGetTransactionsUseCase())
        .thenAnswer((_) async => Error(failure));

    // When
    await viewModel.loadTransactions();

    // Then
    expect(viewModel.hasError, true);
    expect(viewModel.errorMessage, '인터넷 연결을 확인해주세요.');
    expect(viewModel.isLoading, false);
  });
});
```

---

# 🧩 책임 구분

| 계층 | 역할 |
|:---|:---|
| **State** | UI에 필요한 최소한의 데이터 구조 (immutable, freezed 사용) |
| **ViewModel** | 상태를 보관하고, UseCase를 호출하여 상태를 변경 |
| **UseCase** | 비즈니스 로직 실행 (Repository 접근 포함) |
| **Screen** | ChangeNotifierProvider 설정, ViewModel 주입 |
| **View** | Consumer로 ViewModel 상태를 구독하고 UI를 렌더링 |

---

# ✅ 문서 요약

- ViewModel은 ChangeNotifier를 상속하여 상태를 관리합니다.
- 생성자에서 UseCase들을 주입받습니다.
- 모든 상태 변경 후 notifyListeners()를 호출합니다.
- Consumer/Selector로 UI에서 상태를 구독합니다.
- 네비게이션은 Mixin을 활용하여 처리합니다.
- 테스트는 상태 변화 중심으로 수행합니다.

---