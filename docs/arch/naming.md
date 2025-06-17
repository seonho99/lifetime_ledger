# 🏷️ 네이밍 규칙 가이드

---

## ✅ 목적

이 문서는 **Provider + MVVM + Clean Architecture** 구조에서 사용하는 클래스, 파일, 폴더, 컴포넌트, 프로바이더, 생성자 정의에 대한 명명 규칙을 정의한다.  
일관된 네이밍은 팀 협업, 구조 파악, 검색 가능성, 유지보수성을 높이며  
기능 단위 기반 폴더 구조와도 명확하게 연결되어야 한다.

---

## ✅ 설계 원칙

- 모든 네이밍은 **기능 중심**으로 작성한다.
- 축약, 약어 등을 지양하고 도메인 또는 용도나 의미가 드러나도록 명명한다.
- Snake case (`lower_snake_case`)와 Pascal case (`UpperCamelCase`)를 구분하여 사용한다.
- 파일명은 모두 소문자 + 언더스코어(`_`) 기반으로 작성한다.
- 각 계층별로 고정된 접미사 규칙을 따라야 한다. (아키텍처별 차별 및 추정 원칙)
- Firebase 구현체 외에 API 기반 구현체는 `Impl` 접미사만 사용하며, `Api`, `Rest` 등 기술명 접두사는 금지한다.

---

# ✅ 1. Repository & DataSource 네이밍 및 메서드 규칙

### 📁 Repository

- 도메인 중심 명명: `TransactionRepository`, `CategoryRepository` 등
- 인터페이스와 구현 클래스는 구분: `TransactionRepository`, `TransactionRepositoryImpl`
- 파일명: `transaction_repository.dart`, `transaction_repository_impl.dart`

#### 📌 Repository 메서드 네이밍 규칙

| 동작 유형   | 접두사 예시              | 설명                         |
|-------------|--------------------------|------------------------------|
| 데이터 조회 | `get`, `fetch`           | 도메인 객체를 가져오는 경우 |
| 상태 변경   | `update`, `toggle`       | 데이터 수정, 상태 전환 |
| 생성/등록   | `add`, `create`, `save`  | 새로운 데이터 등록           |
| 삭제        | `delete`, `remove`       | 데이터 제거                  |
| 검증/확인   | `check`, `verify`        | 조건 확인, 유효성 검사 등    |

---

### 📁 DataSource

| 구분        | 클래스명 예시                    | 파일명 예시                                |
|-------------|----------------------------------|--------------------------------------------|
| 인터페이스  | `TransactionDataSource`          | `transaction_datasource.dart`              |
| Remote 구현체| `TransactionRemoteDataSource`   | `transaction_remote_datasource.dart`       |
| Local 구현체 | `TransactionLocalDataSource`    | `transaction_local_datasource.dart`        |
| Firebase 구현체 | `TransactionFirebaseDataSource` | `transaction_firebase_datasource.dart`   |

- Remote/Local로 구분하여 명명
- Firebase만 `Firebase` 접두사를 붙인다.
- Mock 클래스는 테스트에서 교체 가능하도록 동일한 인터페이스를 구현한다.

```dart
abstract class TransactionDataSource {
  Future<List<TransactionDto>> getTransactions();
  Future<void> addTransaction(TransactionDto transaction);
}

class TransactionRemoteDataSource implements TransactionDataSource {
  // API 호출 구현
}

class TransactionLocalDataSource implements TransactionDataSource {
  // Local Storage 구현
}
```

#### 📌 DataSource 메서드 네이밍 규칙

| 동작 유형     | 접두사 예시         | 설명                                      |
|----------------|----------------------|-------------------------------------------|
| 네트워크 호출  | `fetch`, `post`, `put`, `delete` | HTTP or Firebase 호출               |
| 로컬 저장소    | `get`, `save`, `remove`    | SharedPreferences, SQLite 등   |

---

# ✅ 2. UseCase 네이밍 및 사용 규칙

- 클래스명: `{동작명}UseCase`  
  예: `GetTransactionsUseCase`, `AddTransactionUseCase`
- 파일명: `{동작명}_usecase.dart`  
  예: `get_transactions_usecase.dart`, `add_transaction_usecase.dart`
- 메서드는 기본적으로 `call()` 사용 (함수 객체 패턴)

```dart
class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase({required TransactionRepository repository}) 
      : _repository = repository;

  Future<Result<List<Transaction>>> call() async {
    return await _repository.getTransactions();
  }
}
```

---

# ✅ 3. Presentation 계층 네이밍 (MVVM)

### 📁 구성 예시

```
presentation/
├── states/
│   ├── transaction_state.dart
│   └── transaction_form_state.dart
├── viewmodels/
│   ├── transaction_viewmodel.dart
│   └── transaction_form_viewmodel.dart
├── screens/
│   ├── transaction_screen.dart
│   └── add_transaction_screen.dart
└── widgets/
    ├── transaction_card.dart
    └── transaction_form.dart
```

### 📌 ViewModel 네이밍

- 클래스명: `{기능명}ViewModel`  
  예: `TransactionViewModel`, `TransactionListViewModel`
- 파일명: `{기능명}_viewmodel.dart`
- ChangeNotifier를 상속하여 구현

```dart
class TransactionViewModel extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;

  TransactionViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase;

  // 상태 관리 로직
}
```

### 📌 State 네이밍

- 클래스명: `{기능명}State`  
  예: `TransactionState`, `TransactionFormState`
- 파일명: `{기능명}_state.dart`
- freezed를 사용하여 불변 객체로 구현

```dart
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

### 📌 Screen 네이밍

- 클래스명: `{기능명}Screen`  
  예: `TransactionScreen`, `AddTransactionScreen`
- 파일명: `{기능명}_screen.dart`
- ChangeNotifierProvider 설정과 UI를 분리

```dart
class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(
        getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
      ),
      child: const TransactionView(),
    );
  }
}

class TransactionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        // UI 구현
      },
    );
  }
}
```

### 📌 Widget 네이밍

- **기능명 접두사 필수**
    - `transaction_card.dart`, `transaction_summary.dart`
- 단순 역할명 (`card.dart`, `summary.dart`) 지양
- 공통 요소가 되지 않은 위젯은 각 기능 폴더 내에 위치

---

# ✅ 4. 생성자 정의 및 주입 규칙

- 모든 주입 필드는 `final` + `_` 접두사로 선언
- 생성자에서는 `required`로 명시적으로 받음
- 외부 노출을 막기 위해 `_` 접두사로 캡슐화
- 변경 불가능한 구조로 불변성 유지

```dart
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;
  final TransactionLocalDataSource _localDataSource;

  TransactionRepositoryImpl({
    required TransactionRemoteDataSource remoteDataSource,
    required TransactionLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;
}
```

---

# ✅ 5. Provider 설정 및 상태 객체 명명

- Provider 설정은 main.dart의 MultiProvider에서 관리
- ChangeNotifierProvider는 각 Screen에서 설정
- Consumer/Selector로 상태 구독

```dart
// main.dart - 전역 Provider 설정
MultiProvider(
  providers: [
    Provider<TransactionRepository>(
      create: (context) => TransactionRepositoryImpl(...),
    ),
    Provider<GetTransactionsUseCase>(
      create: (context) => GetTransactionsUseCase(
        repository: context.read<TransactionRepository>(),
      ),
    ),
  ],
  child: MyApp(),
)

// Screen - ViewModel Provider 설정
ChangeNotifierProvider<TransactionViewModel>(
  create: (context) => TransactionViewModel(
    getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
  ),
  child: TransactionView(),
)
```

---

# ✅ 네이밍 요약표

| 항목           | 예시                              | 설명                                    |
|----------------|---------------------------------|-----------------------------------------|
| Entity         | `Transaction`                   | 도메인 모델                              |
| Repository (Interface) | `TransactionRepository`    | Repository 인터페이스                    |
| Repository (Impl) | `TransactionRepositoryImpl` | Repository 구현체                        |
| DataSource     | `TransactionRemoteDataSource`   | Remote/Local/Firebase 구분              |
| UseCase        | `GetTransactionsUseCase`        | 비즈니스 단위 로직                      |
| ViewModel      | `TransactionViewModel`          | ChangeNotifier 기반 상태 관리           |
| State          | `TransactionState`              | freezed 기반 상태 클래스                |
| Screen         | `TransactionScreen`             | ChangeNotifierProvider 설정 + UI       |
| Widget         | `transaction_card.dart`         | 기능 접두사 필수                         |
| DTO            | `TransactionDto`                | 데이터 전송 객체                         |
| Mapper         | `TransactionMapper`             | DTO ↔ Entity 변환                       |
| 생성자 필드    | `_repository`                   | final + 프라이빗 + required 주입        |

---
