# 🧱 상태 클래스 (State) 설계 가이드

---

## ✅ 목적

State 클래스는 화면에 필요한 모든 상태 값을 하나의 객체로 표현합니다.  
UI는 ViewModel을 통해 이 상태 객체를 구독하여 렌더링하며,  
ViewModel은 상태를 생성하고 변경합니다.

---

## 🧱 설계 원칙

- 상태는 화면에 필요한 데이터만 포함한 **최소 단위의 객체**로 설계한다.
- `@freezed`를 사용하여 불변 객체로 정의하고,  
  **Freezed 3.0 방식**으로 작성한다. (`sealed class` + 일반 생성자)
- 상태는 직접 관리하지 않고,  
  **각 필드는 적절한 타입으로 관리**한다. (loading, error 상태 포함)
- 상태 객체 자체는 단순한 데이터 집합이며, 비즈니스 로직은 포함하지 않는다.

---

## ✅ 파일 구조 및 위치

```text
lib/
└── features/
    └── transaction/
        └── presentation/
            └── states/
                └── transaction_state.dart
```

---

## ✅ 작성 규칙 및 구성

| 항목 | 규칙 |
|:---|:---|
| 어노테이션 | `@freezed` 사용 |
| 생성자 | Freezed 3.0 방식: `sealed class` + 일반 생성자 |
| 상태 값 | 모든 필드는 nullable 또는 기본값 제공 |
| 로딩/에러 | boolean 필드와 errorMessage로 관리 |

---

## ✅ 기본 State 예시

### Transaction State

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_state.freezed.dart';

@freezed
sealed class TransactionState with _$TransactionState {
  const TransactionState._();

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

  /// 초기 상태 생성
  factory TransactionState.initial() {
    return TransactionState(
      transactions: [],
      isLoading: false,
      errorMessage: null,
      selectedCategory: null,
      searchQuery: null,
    );
  }

  /// 로딩 상태 생성
  factory TransactionState.loading() {
    return TransactionState(
      transactions: [],
      isLoading: true,
      errorMessage: null,
    );
  }

  /// 에러 상태 생성
  factory TransactionState.error(String message) {
    return TransactionState(
      transactions: [],
      isLoading: false,
      errorMessage: message,
    );
  }

  /// 성공 상태 생성
  factory TransactionState.success(List<Transaction> transactions) {
    return TransactionState(
      transactions: transactions,
      isLoading: false,
      errorMessage: null,
    );
  }
}
```

### State Extension (계산된 속성)

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
}
```

### 폼 State 예시

```dart
@freezed
sealed class AddTransactionState with _$AddTransactionState {
  const AddTransactionState._();

  AddTransactionState({
    required this.title,
    required this.amount,
    required this.type,
    this.selectedCategoryId,
    required this.date,
    this.description,
    required this.isLoading,
    this.errorMessage,
  });

  final String title;
  final double amount;
  final TransactionType type;
  final String? selectedCategoryId;
  final DateTime date;
  final String? description;
  final bool isLoading;
  final String? errorMessage;

  /// 초기 상태
  factory AddTransactionState.initial() {
    return AddTransactionState(
      title: '',
      amount: 0.0,
      type: TransactionType.expense,
      selectedCategoryId: null,
      date: DateTime.now(),
      description: null,
      isLoading: false,
      errorMessage: null,
    );
  }

  /// 폼 유효성 검증
  bool get isValid =>
      title.trim().isNotEmpty &&
      amount > 0 &&
      selectedCategoryId != null;

  /// 에러 상태
  bool get hasError => errorMessage != null;
}
```

### 복잡한 State 예시 (페이지네이션)

```dart
@freezed
sealed class TransactionListState with _$TransactionListState {
  const TransactionListState._();

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

  /// 초기 상태
  factory TransactionListState.initial() {
    return TransactionListState(
      transactions: [],
      isLoading: false,
      isLoadingMore: false,
      hasMore: true,
      currentPage: 1,
      errorMessage: null,
      filter: null,
    );
  }

  /// 로딩 상태
  factory TransactionListState.loading() {
    return TransactionListState(
      transactions: [],
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      currentPage: 1,
    );
  }
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

✅ **주요 포인트**
- Freezed 3.0 방식: `sealed class` + 일반 생성자 사용
- boolean 필드로 로딩/에러 상태 관리
- 팩토리 생성자로 편의 상태 생성 메서드 제공
- Extension으로 계산된 속성 분리

---

## 📌 ViewModel에서 상태 관리 흐름

```dart
class TransactionViewModel extends ChangeNotifier {
  TransactionState _state = TransactionState.initial();
  TransactionState get state => _state;

  void _updateState(TransactionState newState) {
    _state = newState;
    notifyListeners(); // Provider에 상태 변경 알림
  }

  Future<void> loadTransactions() async {
    // 로딩 상태로 변경
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await _getTransactionsUseCase();
    
    result.when(
      success: (transactions) {
        // 성공 상태로 변경
        _updateState(_state.copyWith(
          transactions: transactions,
          isLoading: false,
          errorMessage: null,
        ));
      },
      error: (failure) {
        // 에러 상태로 변경
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
    );
  }

  void updateFilter(String? category) {
    _updateState(_state.copyWith(selectedCategory: category));
  }

  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }
}
```

- 항상 **copyWith로 안전하게 새로운 상태 생성**
- **notifyListeners()로 Provider에 변경 알림**
- 상태 변경은 ViewModel에서만 수행

---

## 🧠 UI에서 상태 사용

```dart
// Consumer로 전체 상태 구독
Consumer<TransactionViewModel>(
  builder: (context, viewModel, child) {
    final state = viewModel.state;
    
    if (state.hasError) {
      return ErrorWidget(message: state.errorMessage!);
    }
    
    if (state.isLoading) {
      return LoadingWidget();
    }
    
    return TransactionList(transactions: state.transactions);
  },
)

// Selector로 특정 상태만 구독 (성능 최적화)
Selector<TransactionViewModel, bool>(
  selector: (context, viewModel) => viewModel.state.isLoading,
  builder: (context, isLoading, child) {
    return isLoading 
        ? const CircularProgressIndicator()
        : const SizedBox.shrink();
  },
)

// Extension 활용
Selector<TransactionViewModel, double>(
  selector: (context, viewModel) => viewModel.state.balance,
  builder: (context, balance, child) {
    return Text('잔액: ₩${balance.toStringAsFixed(0)}');
  },
)
```

---

## 📋 책임 구분

| 구성 요소 | 역할 |
|:---|:---|
| **State** | UI에 필요한 최소한의 데이터 보관 (불변 객체) |
| **ViewModel** | 상태를 생성하고 변경하는 책임 (ChangeNotifier) |
| **View** | 상태를 구독하고 UI를 렌더링하는 책임 (Consumer) |

---

## 🧪 테스트 전략

```dart
group('TransactionState 테스트', () {
  test('초기 상태가 올바르게 생성됨', () {
    // Given & When
    final state = TransactionState.initial();

    // Then
    expect(state.transactions, isEmpty);
    expect(state.isLoading, false);
    expect(state.hasError, false);
    expect(state.errorMessage, null);
  });

  test('copyWith로 상태 업데이트가 올바르게 됨', () {
    // Given
    final initialState = TransactionState.initial();
    final transactions = [Transaction.create(...)];

    // When
    final updatedState = initialState.copyWith(
      transactions: transactions,
      isLoading: false,
    );

    // Then
    expect(updatedState.transactions, equals(transactions));
    expect(updatedState.isLoading, false);
    expect(updatedState.hasError, false);
  });

  test('Extension 메서드가 올바르게 동작함', () {
    // Given
    final transactions = [
      Transaction.create(
        title: '수입',
        amount: 1000,
        type: TransactionType.income,
        categoryId: 'salary',
        date: DateTime.now(),
      ),
      Transaction.create(
        title: '지출',
        amount: 500,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime.now(),
      ),
    ];

    final state = TransactionState.success(transactions);

    // When & Then
    expect(state.totalIncome, 1000);
    expect(state.totalExpense, 500);
    expect(state.balance, 500);
    expect(state.transactionCount, 2);
    expect(state.hasData, true);
    expect(state.isEmpty, false);
  });
});
```

---

## ✅ 문서 요약

- State는 Freezed 3.0 방식으로 불변 객체로 정의합니다.
- 로딩/에러 상태는 boolean 필드로 관리합니다.
- Extension으로 계산된 속성을 분리합니다.
- ViewModel에서 copyWith로 상태를 업데이트합니다.
- UI에서는 Consumer/Selector로 상태를 구독합니다.
- 팩토리 생성자로 편의 상태 생성 메서드를 제공합니다.

---