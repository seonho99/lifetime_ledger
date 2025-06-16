# State 객체 설계 가이드

## freezed 3.0 기반 상태 관리

### 1. 기본 State 구조 (freezed 3.0 문법)

```dart
@freezed
sealed class TransactionState with _$TransactionState {
  TransactionState({
    required this.transactions,
    required this.isLoading,
    this.errorMessage,
    this.selectedCategory,
    this.searchQuery,
  });

  final List<Transaction> transactions;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedCategory;
  final String? searchQuery;
}
```

### 2. State Extension 메서드 패턴

#### 기본 상태 확인 Extension
```dart
extension TransactionStateX on TransactionState {
  // 에러 상태
  bool get hasError => errorMessage != null;
  
  // 빈 상태
  bool get isEmpty => transactions.isEmpty && !isLoading;
  
  // 데이터 상태
  bool get hasData => transactions.isNotEmpty;
  
  // 필터링 상태
  bool get isFiltered => selectedCategory != null || 
                        (searchQuery != null && searchQuery!.isNotEmpty);
  
  // 거래 개수
  int get transactionCount => transactions.length;
}
```

#### 계산된 속성 Extension
```dart
extension TransactionStateCalculations on TransactionState {
  // 총 수입
  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .map((t) => t.amount)
      .fold(0.0, (sum, amount) => sum + amount);
      
  // 총 지출  
  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .map((t) => t.amount)
      .fold(0.0, (sum, amount) => sum + amount);
      
  // 잔액
  double get balance => totalIncome - totalExpense;
  
  // 카테고리별 지출
  Map<String, double> get expensesByCategory {
    final Map<String, double> result = {};
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        result[transaction.category] = 
            (result[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return result;
  }
  
  // 월별 거래
  List<Transaction> get currentMonthTransactions {
    final now = DateTime.now();
    return transactions.where((t) => 
      t.date.year == now.year && t.date.month == now.month
    ).toList();
  }
}
```

### 3. State 헬퍼 메서드

```dart
extension TransactionStateHelpers on TransactionState {
  // 초기 상태
  static TransactionState initial() {
    return TransactionState(
      transactions: [],
      isLoading: false,
      errorMessage: null,
      selectedCategory: null,
      searchQuery: null,
    );
  }
  
  // 로딩 상태
  static TransactionState loading({
    List<Transaction>? currentTransactions,
  }) {
    return TransactionState(
      transactions: currentTransactions ?? [],
      isLoading: true,
      errorMessage: null,
    );
  }
  
  // 에러 상태
  static TransactionState error(
    String message, {
    List<Transaction>? currentTransactions,
  }) {
    return TransactionState(
      transactions: currentTransactions ?? [],
      isLoading: false,
      errorMessage: message,
    );
  }
  
  // 성공 상태
  static TransactionState success(List<Transaction> transactions) {
    return TransactionState(
      transactions: transactions,
      isLoading: false,
      errorMessage: null,
    );
  }
}
```

### 4. 복잡한 State 구조 예시

#### 페이지네이션이 있는 State
```dart
@freezed
sealed class TransactionListState with _$TransactionListState {
  TransactionListState({
    required this.transactions,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.currentPage,
    this.errorMessage,
    this.filter,
  });

  final List<Transaction> transactions;
  final bool isLoading;           // 초기 로딩
  final bool isLoadingMore;       // 추가 로딩  
  final bool hasMore;             // 더 가져올 데이터 있는지
  final int currentPage;          // 현재 페이지
  final String? errorMessage;
  final TransactionFilter? filter; // 필터 객체
}

extension TransactionListStateX on TransactionListState {
  bool get hasError => errorMessage != null;
  bool get isEmpty => transactions.isEmpty && !isLoading;
  bool get canLoadMore => hasMore && !isLoadingMore && !hasError;
  
  // 필터링된 거래 목록
  List<Transaction> get filteredTransactions {
    if (filter == null) return transactions;
    return transactions.where((t) => filter!.matches(t)).toList();
  }
}
```

#### 필터 객체
```dart
@freezed
sealed class TransactionFilter with _$TransactionFilter {
  TransactionFilter({
    this.categoryId,
    this.type,
    this.dateRange,
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
  });

  final String? categoryId;
  final TransactionType? type;
  final DateRange? dateRange;
  final double? minAmount;
  final double? maxAmount;
  final String? searchQuery;
}

extension TransactionFilterX on TransactionFilter {
  bool get hasActiveFilter => 
      categoryId != null ||
      type != null ||
      dateRange != null ||
      minAmount != null ||
      maxAmount != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);

  bool matches(Transaction transaction) {
    // 카테고리 필터
    if (categoryId != null && transaction.categoryId != categoryId) {
      return false;
    }
    
    // 타입 필터
    if (type != null && transaction.type != type) {
      return false;
    }
    
    // 금액 필터
    if (minAmount != null && transaction.amount < minAmount!) {
      return false;
    }
    if (maxAmount != null && transaction.amount > maxAmount!) {
      return false;
    }
    
    // 검색어 필터
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      return transaction.title.toLowerCase().contains(query) ||
             transaction.description?.toLowerCase().contains(query) == true;
    }
    
    return true;
  }
}
```

### 5. State Union 패턴 (선택적)

복잡한 상태가 필요한 경우 Union 패턴 사용:

```dart
@freezed
sealed class TransactionPageState with _$TransactionPageState {
  const factory TransactionPageState.initial() = TransactionInitial;
  const factory TransactionPageState.loading() = TransactionLoading;
  const factory TransactionPageState.loaded(
    List<Transaction> transactions,
    {TransactionFilter? filter}
  ) = TransactionLoaded;
  const factory TransactionPageState.error(String message) = TransactionError;
  const factory TransactionPageState.empty() = TransactionEmpty;
}

// Pattern Matching 사용 (Dart 3.0)
Widget buildUI(TransactionPageState state) {
  return switch (state) {
    TransactionInitial() => const SizedBox(),
    TransactionLoading() => const CircularProgressIndicator(),
    TransactionLoaded(:final transactions) => TransactionList(transactions: transactions),
    TransactionError(:final message) => ErrorWidget(message: message),
    TransactionEmpty() => const EmptyStateWidget(),
  };
}
```

### 6. ViewModel에서 State 사용 패턴

```dart
class TransactionViewModel extends ChangeNotifier {
  TransactionState _state = TransactionState.initial();
  
  TransactionState get state => _state;
  
  // 편의 Getters (선택적)
  List<Transaction> get transactions => _state.transactions;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  double get totalBalance => _state.balance;

  // 상태 업데이트 헬퍼
  void _updateState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }
  
  // 부분 상태 업데이트
  void _updateLoading(bool loading) {
    _updateState(_state.copyWith(isLoading: loading));
  }
  
  void _updateError(String? error) {
    _updateState(_state.copyWith(errorMessage: error));
  }
  
  void _updateTransactions(List<Transaction> transactions) {
    _updateState(_state.copyWith(
      transactions: transactions,
      isLoading: false,
      errorMessage: null,
    ));
  }
}
```

### 7. State 최적화 패턴

#### 불변성 보장
```dart
// ❌ 잘못된 방식 - 상태 직접 변경
void addTransaction(Transaction transaction) {
  _state.transactions.add(transaction); // 에러!
  notifyListeners();
}

// ✅ 올바른 방식 - 새 상태 생성
void addTransaction(Transaction transaction) {
  final updatedTransactions = [..._state.transactions, transaction];
  _updateState(_state.copyWith(transactions: updatedTransactions));
}
```

#### 메모이제이션 (선택적)
```dart
extension TransactionStateMemo on TransactionState {
  // 계산 비용이 높은 경우 캐싱
  static final Map<String, Map<String, double>> _categoryCache = {};
  
  Map<String, double> get expensesByCategoryCached {
    final key = transactions.map((t) => '${t.id}-${t.amount}').join(',');
    
    if (_categoryCache.containsKey(key)) {
      return _categoryCache[key]!;
    }
    
    final result = expensesByCategory; // 실제 계산
    _categoryCache[key] = result;
    return result;
  }
}
```

## Best Practices

### 1. State 설계 원칙
- **불변성**: 모든 속성을 final로 선언
- **단순성**: 복잡한 로직은 Extension으로 분리
- **일관성**: 모든 State에서 동일한 패턴 사용
- **확장성**: Extension으로 기능 확장

### 2. Extension 활용
- **기본 상태**: hasError, isEmpty 등
- **계산된 속성**: 복잡한 계산 로직
- **헬퍼 메서드**: 상태 생성 도우미
- **필터링**: 조건별 데이터 추출

### 3. 성능 최적화
- **적절한 분리**: 자주 변경되는 상태와 안정적인 상태 구분
- **메모이제이션**: 계산 비용이 높은 경우만 적용
- **Selector 활용**: UI에서 필요한 부분만 구독

### 4. 테스트 용이성
- **순수 함수**: Extension 메서드는 순수 함수로 작성
- **예측 가능성**: 동일한 입력에 동일한 출력
- **격리성**: 각 State는 독립적으로 테스트 가능

## 체크리스트

### State 정의
- [ ] freezed sealed class 사용
- [ ] 모든 속성 final 선언
- [ ] 필요한 속성만 포함
- [ ] null 안전성 고려

### Extension 메서드
- [ ] 기본 상태 확인 메서드
- [ ] 계산된 속성 분리
- [ ] 헬퍼 메서드 제공
- [ ] 성능 고려사항 체크

### ViewModel 연동
- [ ] State 객체로 상태 관리
- [ ] copyWith로 불변성 유지
- [ ] 적절한 notifyListeners 호출
- [ ] 편의 Getters 제공