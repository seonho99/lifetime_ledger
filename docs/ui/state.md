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
  **Freezed 3.0 방식**으로 작성한다. (일반 class + 일반 생성자)
- 상태는 직접 관리하지 않고,  
  **각 필드는 적절한 타입으로 관리**한다. (loading, error 상태 포함)
- 상태 객체 자체는 단순한 데이터 집합이며, 비즈니스 로직은 포함하지 않는다.

---

## ✅ 파일 구조 및 위치

```text
lib/
└── features/
    └── history/
        └── ui/
            └── state.dart
```

---

## ✅ 작성 규칙 및 구성

| 항목 | 규칙 |
|:---|:---|
| 어노테이션 | `@freezed` 사용 |
| 생성자 | Freezed 3.0 방식: 일반 class + 일반 생성자 |
| 상태 값 | 모든 필드는 nullable 또는 기본값 제공 |
| 로딩/에러 | boolean 필드와 errorMessage로 관리 |

---

## ✅ 기본 State 예시 (실제 구현)

### History State

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/model/history.dart';

part 'state.freezed.dart';

@freezed
class HistoryState with _$HistoryState {
  const HistoryState({
    required this.histories,
    required this.isLoading,
    this.errorMessage,
    this.selectedMonth,
    this.selectedYear,
    this.filterType,
  });

  final List<History> histories;
  final bool isLoading;
  final String? errorMessage;
  final int? selectedMonth;
  final int? selectedYear;
  final HistoryType? filterType;

  /// 초기 상태 생성
  factory HistoryState.initial() {
    final now = DateTime.now();
    return HistoryState(
      histories: [],
      isLoading: false,
      errorMessage: null,
      selectedMonth: now.month,
      selectedYear: now.year,
      filterType: null,
    );
  }

  /// 로딩 상태 생성
  factory HistoryState.loading() {
    final now = DateTime.now();
    return HistoryState(
      histories: [],
      isLoading: true,
      errorMessage: null,
      selectedMonth: now.month,
      selectedYear: now.year,
      filterType: null,
    );
  }

  /// 에러 상태 생성
  factory HistoryState.error(String message) {
    final now = DateTime.now();
    return HistoryState(
      histories: [],
      isLoading: false,
      errorMessage: message,
      selectedMonth: now.month,
      selectedYear: now.year,
      filterType: null,
    );
  }

  // 계산된 속성들
  bool get hasError => errorMessage != null;
  bool get isEmpty => histories.isEmpty && !isLoading;
  bool get hasData => histories.isNotEmpty;
  int get historyCount => histories.length;

  // 필터링된 내역들
  List<History> get filteredHistories {
    if (filterType == null) return histories;
    return histories.where((h) => h.type == filterType).toList();
  }

  // 총 수입
  double get totalIncome => histories
      .where((h) => h.isIncome)
      .map((h) => h.amount)
      .fold(0.0, (sum, amount) => sum + amount);

  // 총 지출
  double get totalExpense => histories
      .where((h) => h.isExpense)
      .map((h) => h.amount)
      .fold(0.0, (sum, amount) => sum + amount);

  // 잔액
  double get balance => totalIncome - totalExpense;

  // 선택된 월 문자열
  String get selectedMonthString {
    if (selectedMonth == null || selectedYear == null) return '';
    return '${selectedYear}년 ${selectedMonth}월';
  }
}
```

### Transaction State 예시

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/model/transaction.dart';

part 'transaction_state.freezed.dart';

@freezed
class TransactionState with _$TransactionState {
  const TransactionState({
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
class AddTransactionState with _$AddTransactionState {
  const AddTransactionState({
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
class TransactionListState with _$TransactionListState {
  const TransactionListState({
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
- Freezed 3.0 방식: 일반 class + 일반 생성자 사용
- boolean 필드로 로딩/에러 상태 관리
- 팩토리 생성자로 편의 상태 생성 메서드 제공
- Extension으로 계산된 속성 분리

---

## 📌 Freezed 3.0 주요 변경 사항

### 1. 기본 구조
```dart
// ❌ Freezed 2.x (구버전)
@freezed
sealed class HistoryState with _$HistoryState {
  const HistoryState._();

  const factory HistoryState({
    required List<History> histories,
    required bool isLoading,
    String? errorMessage,
  }) = _HistoryState;
}

// ✅ Freezed 3.0 (신버전)
@freezed
class HistoryState with _$HistoryState {
  const HistoryState({
    required this.histories,
    required this.isLoading,
    this.errorMessage,
  });

  final List<History> histories;
  final bool isLoading;
  final String? errorMessage;
}
```

### 2. 핵심 차이점

| 항목 | Freezed 2.x | Freezed 3.0 |
|------|-------------|-------------|
| 클래스 선언 | `sealed class` | `class` |
| 생성자 | `const factory` | 일반 생성자 |
| private 생성자 | `const ClassName._()` | 불필요 |
| 필드 선언 | 생성자 파라미터만 | `final` 필드 명시 |

---

## 📌 ViewModel에서 상태 관리 흐름

```dart
class HistoryViewModel extends ChangeNotifier {
  HistoryState _state = HistoryState.initial();
  HistoryState get state => _state;

  void _updateState(HistoryState newState) {
    _state = newState;
    notifyListeners(); // Provider에 상태 변경 알림
  }

  Future<void> loadHistories() async {
    // 로딩 상태로 변경
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await _getHistoriesUseCase();
    
    result.when(
      success: (histories) {
        // 성공 상태로 변경
        _updateState(_state.copyWith(
          histories: histories,
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

  void updateFilter(HistoryType? filterType) {
    _updateState(_state.copyWith(filterType: filterType));
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
Consumer<HistoryViewModel>(
  builder: (context, viewModel, child) {
    final state = viewModel.state;
    
    if (state.hasError) {
      return ErrorWidget(message: state.errorMessage!);
    }
    
    if (state.isLoading) {
      return LoadingWidget();
    }
    
    return HistoryList(histories: state.histories);
  },
)

// Selector로 특정 상태만 구독 (성능 최적화)
Selector<HistoryViewModel, bool>(
  selector: (context, viewModel) => viewModel.state.isLoading,
  builder: (context, isLoading, child) {
    return isLoading 
        ? const CircularProgressIndicator()
        : const SizedBox.shrink();
  },
)

// Extension 활용
Selector<HistoryViewModel, double>(
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
group('HistoryState 테스트', () {
  test('초기 상태가 올바르게 생성됨', () {
    // Given & When
    final state = HistoryState.initial();

    // Then
    expect(state.histories, isEmpty);
    expect(state.isLoading, false);
    expect(state.hasError, false);
    expect(state.errorMessage, null);
    expect(state.selectedMonth, DateTime.now().month);
    expect(state.selectedYear, DateTime.now().year);
  });

  test('copyWith로 상태 업데이트가 올바르게 됨', () {
    // Given
    final initialState = HistoryState.initial();
    final histories = [
      History(
        id: '1',
        title: '커피',
        amount: 4500,
        type: HistoryType.expense,
        categoryId: 'food',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // When
    final updatedState = initialState.copyWith(
      histories: histories,
      isLoading: false,
    );

    // Then
    expect(updatedState.histories, equals(histories));
    expect(updatedState.isLoading, false);
    expect(updatedState.hasError, false);
  });

  test('계산된 속성이 올바르게 동작함', () {
    // Given
    final histories = [
      History(
        id: '1',
        title: '수입',
        amount: 1000,
        type: HistoryType.income,
        categoryId: 'salary',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      History(
        id: '2',
        title: '지출',
        amount: 500,
        type: HistoryType.expense,
        categoryId: 'food',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final state = HistoryState.initial().copyWith(histories: histories);

    // When & Then
    expect(state.totalIncome, 1000);
    expect(state.totalExpense, 500);
    expect(state.balance, 500);
    expect(state.historyCount, 2);
    expect(state.hasData, true);
    expect(state.isEmpty, false);
  });

  test('팩토리 생성자들이 올바르게 동작함', () {
    // When & Then
    final loadingState = HistoryState.loading();
    expect(loadingState.isLoading, true);
    expect(loadingState.hasError, false);

    final errorState = HistoryState.error('네트워크 오류');
    expect(errorState.isLoading, false);
    expect(errorState.hasError, true);
    expect(errorState.errorMessage, '네트워크 오류');
  });
});
```

---

## 🆚 Migration 가이드

### 기존 코드를 Freezed 3.0으로 마이그레이션

```dart
// Before (Freezed 2.x)
@freezed
sealed class HistoryState with _$HistoryState {
  const HistoryState._();

  const factory HistoryState({
    required List<History> histories,
    required bool isLoading,
    String? errorMessage,
  }) = _HistoryState;

  bool get hasError => errorMessage != null;
}

// After (Freezed 3.0)
@freezed
class HistoryState with _$HistoryState {
  const HistoryState({
    required this.histories,
    required this.isLoading,
    this.errorMessage,
  });

  final List<History> histories;
  final bool isLoading;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
}
```

---

## ✅ 상태 설계 Best Practices

### 1. **최소한의 상태**
```dart
// ✅ 좋은 예: 필요한 최소한의 상태만
@freezed
class HistoryState with _$HistoryState {
  const HistoryState({
    required this.histories,
    required this.isLoading,
    this.errorMessage,
  });
  // 계산된 속성은 getter로
  bool get hasError => errorMessage != null;
}

// ❌ 나쁜 예: 중복된 상태
@freezed
class HistoryState with _$HistoryState {
  const HistoryState({
    required this.histories,
    required this.isLoading,
    required this.hasError,    // errorMessage로 충분
    required this.hasData,     // histories.isNotEmpty로 계산 가능
  });
}
```

### 2. **명확한 상태 구분**
```dart
// ✅ 좋은 예: 명확한 상태 구분
factory HistoryState.initial() => HistoryState(...);
factory HistoryState.loading() => HistoryState(...);
factory HistoryState.error(String message) => HistoryState(...);
```

### 3. **Extension으로 로직 분리**
```dart
// ✅ 복잡한 계산은 Extension으로 분리
extension HistoryStateX on HistoryState {
  List<History> get expenseHistories => 
      histories.where((h) => h.isExpense).toList();
      
  Map<String, double> get categorySummary => /* ... */;
}
```

---

## ✅ 문서 요약

- State는 Freezed 3.0 문법으로 불변 객체로 정의합니다.
- 일반 class + 일반 생성자 방식을 사용합니다.
- 로딩/에러 상태는 boolean 필드로 관리합니다.
- Extension으로 계산된 속성을 분리합니다.
- ViewModel에서 copyWith로 상태를 업데이트합니다.
- UI에서는 Consumer/Selector로 상태를 구독합니다.
- 팩토리 생성자로 편의 상태 생성 메서드를 제공합니다.

---