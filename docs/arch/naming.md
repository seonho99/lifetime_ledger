# 네이밍 컨벤션

## 파일 네이밍

### 1. Dart 파일 (스네이크 케이스)
- 소문자와 언더스코어 사용
- 기능을 명확히 표현
- 접미사로 역할 표시

```
✅ 올바른 예시:
- transaction_repository.dart
- transaction_viewmodel.dart
- transaction_state.dart
- transaction_screen.dart
- transaction_card.dart

❌ 잘못된 예시:
- TransactionRepository.dart
- transactionViewModel.dart
- Transaction.dart
- transactionscreen.dart
```

### 2. 레이어별 파일 네이밍

#### Data Layer
```
# Repository 구현
transaction_repository_impl.dart
category_repository_impl.dart

# DataSource
transaction_remote_datasource.dart
transaction_local_datasource.dart

# DTO 모델
transaction_dto.dart
transaction_response_dto.dart
category_dto.dart

# Mapper
transaction_mapper.dart
category_mapper.dart
```

#### Domain Layer
```
# Entity
transaction.dart
category.dart
user.dart

# Repository 인터페이스
transaction_repository.dart
category_repository.dart

# UseCase
get_transactions_usecase.dart
add_transaction_usecase.dart
update_transaction_usecase.dart
delete_transaction_usecase.dart

# Enum
transaction_type.dart
category_type.dart
```

#### Presentation Layer (MVVM)
```
# State 객체
transaction_state.dart
transaction_list_state.dart
transaction_form_state.dart

# ViewModel
transaction_viewmodel.dart
transaction_list_viewmodel.dart
transaction_form_viewmodel.dart

# Screen
transaction_screen.dart
transaction_list_screen.dart
transaction_detail_screen.dart
add_transaction_screen.dart

# Widget
transaction_card.dart
transaction_form.dart
transaction_summary.dart
```

### 3. 테스트 파일
- 테스트 대상 파일명 + _test 접미사

```
✅ 올바른 예시:
- transaction_repository_impl_test.dart
- transaction_viewmodel_test.dart
- transaction_screen_test.dart
- get_transactions_usecase_test.dart

❌ 잘못된 예시:
- test_transaction_repository.dart
- transaction_repository.spec.dart
- transaction_test.dart
```

## 클래스 네이밍

### 1. 일반 클래스 (파스칼 케이스)
- 파스칼 케이스 사용
- 명사로 시작
- 역할을 명확히 표현

```dart
✅ 올바른 예시:
class Transaction { }
class TransactionRepository { }
class TransactionViewModel extends ChangeNotifier { }
class TransactionScreen extends StatelessWidget { }
class TransactionCard extends StatelessWidget { }

❌ 잘못된 예시:
class transactionRepository { }
class transaction_viewmodel { }
class TRANSACTION { }
class transactionscreen { }
```

### 2. 레이어별 클래스 네이밍

#### Data Layer
```dart
// Repository 구현
class TransactionRepositoryImpl implements TransactionRepository { }
class CategoryRepositoryImpl implements CategoryRepository { }

// DataSource
abstract class TransactionDataSource { }
class TransactionRemoteDataSource implements TransactionDataSource { }
class TransactionLocalDataSource implements TransactionDataSource { }

// DTO
class TransactionDto { }
class TransactionResponseDto { }
class CategoryDto { }

// Mapper
class TransactionMapper { }
class CategoryMapper { }
```

#### Domain Layer
```dart
// Entity
class Transaction { }
class Category { }
class User { }

// Repository 인터페이스
abstract class TransactionRepository { }
abstract class CategoryRepository { }

// UseCase
class GetTransactionsUseCase { }
class AddTransactionUseCase { }
class UpdateTransactionUseCase { }
class DeleteTransactionUseCase { }

// Enum
enum TransactionType { income, expense }
enum CategoryType { fixed, variable }
```

#### Presentation Layer (MVVM)
```dart
// State 객체 (freezed)
@freezed
class TransactionState with _$TransactionState { }

@freezed
class TransactionListState with _$TransactionListState { }

@freezed
class TransactionFormState with _$TransactionFormState { }

// ViewModel (ChangeNotifier)
class TransactionViewModel extends ChangeNotifier { }
class TransactionListViewModel extends ChangeNotifier { }
class TransactionFormViewModel extends ChangeNotifier { }

// Screen (StatelessWidget)
class TransactionScreen extends StatelessWidget { }
class TransactionListScreen extends StatelessWidget { }
class TransactionDetailScreen extends StatelessWidget { }

// Widget
class TransactionCard extends StatelessWidget { }
class TransactionForm extends StatelessWidget { }
class TransactionSummary extends StatelessWidget { }
```

### 3. 인터페이스/추상 클래스
- abstract 키워드 사용
- 구현체와 구분되도록 명명

```dart
✅ 올바른 예시:
abstract class TransactionRepository { }
abstract class TransactionDataSource { }
abstract class BaseViewModel { }

// 구현체
class TransactionRepositoryImpl implements TransactionRepository { }
class TransactionRemoteDataSource implements TransactionDataSource { }
```

## 변수/함수 네이밍

### 1. 변수 (카멜 케이스)
- 카멜 케이스 사용
- 명사로 시작
- 의미를 명확히 표현

```dart
✅ 올바른 예시:
List<Transaction> transactions;
TransactionState currentState;
bool isLoading;
String? errorMessage;
int transactionCount;

❌ 잘못된 예시:
List<Transaction> transaction_list;
TransactionState CurrentState;
bool is_loading;
String error_message;
int count;
```

### 2. 함수/메서드 (카멜 케이스)
- 카멜 케이스 사용
- 동사로 시작
- 동작을 명확히 표현

```dart
✅ 올바른 예시:
Future<void> loadTransactions();
void updateTransaction(Transaction transaction);
void clearError();
bool hasError();
int calculateTotalAmount();

❌ 잘못된 예시:
Future<void> load_transactions();
void transaction_update();
void clear();
bool error();
int total();
```

### 3. ViewModel 메서드 네이밍 패턴

#### 데이터 로딩
```dart
Future<void> loadTransactions();
Future<void> refreshTransactions();
Future<void> loadMoreTransactions();
```

#### 데이터 조작
```dart
Future<void> addTransaction(Transaction transaction);
Future<void> updateTransaction(Transaction transaction);
Future<void> deleteTransaction(String id);
```

#### 상태 관리
```dart
void clearError();
void resetState();
void setLoading(bool loading);
void updateState(TransactionState newState);
```

#### 검증 및 계산
```dart
bool validateTransaction(Transaction transaction);
double calculateTotalIncome();
double calculateTotalExpense();
double calculateBalance();
```

### 4. 상수 (대문자 스네이크 케이스)
- 대문자 스네이크 케이스 사용
- 의미를 명확히 표현

```dart
✅ 올바른 예시:
static const int MAX_TRANSACTION_AMOUNT = 10000000;
static const String DEFAULT_CURRENCY = 'KRW';
static const Duration API_TIMEOUT = Duration(seconds: 30);
static const String STORAGE_KEY_TRANSACTIONS = 'transactions';

❌ 잘못된 예시:
static const int maxTransactionAmount = 10000000;
static const String defaultCurrency = 'KRW';
static const Duration apiTimeout = Duration(seconds: 30);
```

## Provider 관련 네이밍

### 1. Provider 변수명
```dart
// ChangeNotifierProvider
ChangeNotifierProvider<TransactionViewModel>(...)
ChangeNotifierProvider<CategoryViewModel>(...)

// Provider
Provider<TransactionRepository>(...)
Provider<GetTransactionsUseCase>(...)

// MultiProvider
MultiProvider(providers: [...])
```

### 2. context 사용
```dart
// read (메서드 호출용)
context.read<TransactionViewModel>().loadTransactions();
context.read<GetTransactionsUseCase>();

// watch (상태 구독용)
final isLoading = context.watch<TransactionViewModel>().isLoading;
final transactions = context.watch<TransactionViewModel>().transactions;
```

### 3. Consumer/Selector
```dart
// Consumer
Consumer<TransactionViewModel>(
  builder: (context, viewModel, child) => ...,
)

// Selector
Selector<TransactionViewModel, bool>(
  selector: (context, viewModel) => viewModel.isLoading,
  builder: (context, isLoading, child) => ...,
)
```

## State 관련 네이밍

### 1. State 클래스
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
```

### 2. State Extension
```dart
extension TransactionStateX on TransactionState {
  bool get hasError => errorMessage != null;
  bool get isEmpty => transactions.isEmpty;
  int get transactionCount => transactions.length;
  
  // 계산된 속성
  double get totalIncome => ...;
  double get totalExpense => ...;
  double get balance => ...;
}

// 헬퍼 메서드
extension TransactionStateHelpers on TransactionState {
  static TransactionState initial() => ...;
  static TransactionState loading() => ...;
  static TransactionState error(String message) => ...;
}
```

## Result 패턴 네이밍

### 1. Result 클래스
```dart
sealed class Result<T> { }
class Success<T> extends Result<T> { }
class Error<T> extends Result<T> { }
```

### 2. Failure 클래스
```dart
abstract class Failure { }
class NetworkFailure extends Failure { }
class ServerFailure extends Failure { }
class CacheFailure extends Failure { }
class ValidationFailure extends Failure { }
```

## 폴더/패키지 네이밍

### 1. 폴더명 (소문자)
```
✅ 올바른 예시:
features/
  transaction/
  category/
  budget/
  statistics/
shared/
  widgets/
  services/
  extensions/

❌ 잘못된 예시:
Features/
  Transaction/
  Category/
shared/
  Widgets/
  Services/
```

### 2. 패키지명 (snake_case)
```
✅ 올바른 예시:
lifetime_ledger
transaction_service
category_management
budget_tracker

❌ 잘못된 예시:
LifetimeLedger
transactionService
categoryManagement
```

## 네이밍 Best Practices

### 1. 일관성
- 프로젝트 전체에서 일관된 네이밍 사용
- 팀 내 네이밍 규칙 준수
- 기존 코드 스타일 유지

### 2. 명확성
- 의미를 명확히 전달
- 축약어 사용 지양 (단, 널리 알려진 것은 허용)
- 역할과 책임을 명확히 표현

```dart
✅ 명확한 네이밍:
class TransactionViewModel extends ChangeNotifier { }
Future<void> loadTransactions();
bool get hasError;

❌ 불명확한 네이밍:
class TxVM extends ChangeNotifier { }
Future<void> load();
bool get err;
```

### 3. 간결성
- 불필요한 접두사/접미사 제거
- 적절한 길이 유지
- 중복되는 단어 제거

```dart
✅ 간결한 네이밍:
class TransactionCard extends StatelessWidget { }
void clearError();

❌ 너무 긴 네이밍:
class TransactionCardWidgetComponent extends StatelessWidget { }
void clearErrorMessageFromState();
```

### 4. 검색 용이성
- 검색하기 쉬운 이름 사용
- 일관된 접두사/접미사 사용
- 관련 코드 그룹화 용이

## 체크리스트

### 파일 네이밍
- [ ] 소문자와 언더스코어 사용
- [ ] 역할을 명확히 표현하는 접미사
- [ ] 테스트 파일 규칙 준수
- [ ] 레이어별 일관된 네이밍

### 클래스 네이밍
- [ ] 파스칼 케이스 사용
- [ ] 역할을 명확히 표현
- [ ] 인터페이스/구현체 구분
- [ ] MVVM 패턴에 맞는 네이밍

### 변수/함수 네이밍
- [ ] 카멜 케이스 사용
- [ ] 의미를 명확히 표현
- [ ] 상수는 대문자 스네이크 케이스
- [ ] Provider 패턴에 맞는 네이밍

### 일관성 및 명확성
- [ ] 프로젝트 전체 일관성
- [ ] 팀 규칙 준수
- [ ] 명확하고 간결한 네이밍
- [ ] 검색 용이성 고려