# 📁 폴더 구조 설계 가이드 (업데이트)

---

## ✅ 목적

이 프로젝트는 기능 단위(Feature-first) 기반으로 폴더를 구성하며,  
각 기능 폴더는 일관된 구조(data, domain, ui)를 따릅니다.  
**Provider + MVVM + Clean Architecture** 패턴을 적용하여 유지보수성과 가독성, 확장성, 팀 단위 협업의 효율을 높입니다.

---

## ✅ 설계 원칙

- 모든 화면/기능은 `lib/{기능}/` 하위에 구성하며, 도메인 기준으로 개별 폴더를 생성합니다.
- 각 기능 폴더는 아래 3개의 레이어 폴더를 포함합니다:
  - `data/` : DataSource, DTO, Mapper, Repository 구현체
  - `domain/` : Model, Repository Interface, UseCase
  - `ui/` : State, ViewModel, Screen, Component
- 공통 요소는 `lib/core/`에 위치시킵니다.
- 레이어 간 의존성은 항상 하향식만 허용됩니다 (UI → UseCase → Repository Interface)

---

## ✅ 폴더 구조 예시

```
lib/
├── core/                            # 핵심 유틸리티 및 상수
│   ├── result/
│   │   └── result.dart              # Result 패턴
│   ├── errors/
│   │   ├── failure.dart             # Failure 클래스들
│   │   ├── exceptions.dart          # Exception 클래스들
│   │   └── failure_mapper.dart      # Exception → Failure 매핑
│   ├── constants/
│   ├── theme/
│   └── utils/
├── history/                         # 거래 내역 기능
│   ├── data/
│   │   ├── data_source/            # DataSource 구현체들
│   │   │   ├── transaction_remote_datasource.dart
│   │   │   ├── transaction_local_datasource.dart
│   │   │   └── transaction_firebase_datasource.dart
│   │   ├── dto/                    # DTO 모델들
│   │   │   ├── transaction_dto.dart
│   │   │   └── transaction_response_dto.dart
│   │   ├── mapper/                 # DTO ↔ Model 변환
│   │   │   └── transaction_mapper.dart
│   │   └── repository_impl/        # Repository 구현체
│   │       └── transaction_repository_impl.dart
│   ├── domain/
│   │   ├── model/                  # 도메인 모델
│   │   │   └── transaction.dart
│   │   ├── repository/             # Repository 인터페이스
│   │   │   └── transaction_repository.dart
│   │   └── usecase/                # UseCase들
│   │       ├── get_transactions_usecase.dart
│   │       ├── add_transaction_usecase.dart
│   │       ├── update_transaction_usecase.dart
│   │       └── delete_transaction_usecase.dart
│   └── ui/
│       ├── state.dart              # State 객체 (freezed)
│       ├── viewmodel.dart          # ViewModel (ChangeNotifier)
│       ├── screen.dart             # Screen (Provider 설정 + UI)
│       └── components.dart         # UI 컴포넌트들
├── category/                        # 카테고리 기능 (동일한 구조)
│   ├── data/
│   ├── domain/
│   └── ui/
├── statistics/                      # 통계 기능 (동일한 구조)
│   ├── data/
│   ├── domain/
│   └── ui/
└── main.dart                       # MultiProvider 설정
```

---

## ✅ 폴더별 책임 요약

| 폴더                     | 설명                                         |
|------------------------|------------------------------------------|
| `core/`                | 앱 전체에서 사용하는 핵심 유틸리티, 상수, 테마 등           |
| `data/data_source/`    | 외부 API, Firebase, SharedPreferences 등 연결   |
| `data/repository_impl/`| Repository 인터페이스의 실제 구현                   |
| `data/dto/`            | 서버와 통신하는 DTO (Data Transfer Object)       |
| `data/mapper/`         | DTO ↔ Model 변환 로직                        |
| `domain/model/`        | 앱 내부에서 사용하는 도메인 모델 정의                    |
| `domain/repository/`   | UseCase에서 참조하는 Repository 인터페이스           |
| `domain/usecase/`      | 하나의 도메인 기능을 수행하는 유스케이스                   |
| `ui/state.dart`        | freezed 기반 불변 상태 객체                       |
| `ui/viewmodel.dart`    | ChangeNotifier 기반 ViewModel             |
| `ui/screen.dart`       | ChangeNotifierProvider 설정 + UI           |
| `ui/components.dart`   | 재사용 가능한 UI 컴포넌트                          |

---

## ✅ 의존성 흐름

```
UI Layer (screen.dart)
    ↓
ViewModel (viewmodel.dart)
    ↓
UseCase (domain/usecase/)
    ↓
Repository Interface (domain/repository/)
    ↓
Repository Implementation (data/repository_impl/)
    ↓
DataSource (data/data_source/)
```

---

## ✅ 파일 네이밍 규칙

### Data Layer
```
# DataSource
transaction_remote_datasource.dart     # Remote DataSource
transaction_local_datasource.dart      # Local DataSource
transaction_firebase_datasource.dart   # Firebase DataSource

# DTO
transaction_dto.dart                    # DTO 모델
transaction_response_dto.dart          # API 응답 DTO

# Mapper
transaction_mapper.dart                 # 매퍼

# Repository Implementation
transaction_repository_impl.dart       # Repository 구현
```

### Domain Layer
```
# Model
transaction.dart                        # Entity

# Repository Interface
transaction_repository.dart            # Repository 인터페이스

# UseCase
get_transactions_usecase.dart          # UseCase
add_transaction_usecase.dart           # UseCase
```

### UI Layer
```
state.dart                             # State 객체
viewmodel.dart                         # ViewModel
screen.dart                           # Screen
components.dart                       # UI 컴포넌트들
```

---

## ✅ Provider 기반 main.dart 구조

```dart
// main.dart
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
        
        // DataSources
        Provider<TransactionRemoteDataSource>(
          create: (context) => TransactionFirebaseDataSource(),
        ),
        
        // Repositories
        Provider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(
            remoteDataSource: context.read<TransactionRemoteDataSource>(),
          ),
        ),
        
        // UseCases
        Provider<GetTransactionsUseCase>(
          create: (context) => GetTransactionsUseCase(
            repository: context.read<TransactionRepository>(),
          ),
        ),
        
        // ... 다른 UseCase들
      ],
      child: MaterialApp(
        title: 'Lifetime Ledger',
        home: const HistoryScreen(),
      ),
    );
  }
}
```

---

## ✅ 기능 확장 전략

### 새로운 기능 추가 시
1. **새 기능 폴더 생성**: `lib/{기능명}/`
2. **3개 레이어 폴더 생성**: `data/`, `domain/`, `ui/`
3. **각 레이어에 필요한 하위 폴더 생성**
4. **기존 구조를 템플릿으로 활용**

### 예시: Budget 기능 추가
```
lib/
├── budget/
│   ├── data/
│   │   ├── data_source/
│   │   │   └── budget_firebase_datasource.dart
│   │   ├── dto/
│   │   │   └── budget_dto.dart
│   │   ├── mapper/
│   │   │   └── budget_mapper.dart
│   │   └── repository_impl/
│   │       └── budget_repository_impl.dart
│   ├── domain/
│   │   ├── model/
│   │   │   └── budget.dart
│   │   ├── repository/
│   │   │   └── budget_repository.dart
│   │   └── usecase/
│   │       ├── get_budgets_usecase.dart
│   │       └── add_budget_usecase.dart
│   └── ui/
│       ├── state.dart
│       ├── viewmodel.dart
│       ├── screen.dart
│       └── components.dart
```

---

## ✅ 장점

### 1. **명확한 책임 분리**
- 각 폴더의 역할이 명확히 구분됨
- Clean Architecture 레이어가 물리적으로 분리됨

### 2. **높은 확장성**
- 새 기능 추가 시 동일한 구조 적용
- 팀원들이 쉽게 이해하고 적응 가능

### 3. **효율적인 협업**
- 기능별로 작업 분담 가능
- 파일 충돌 최소화

### 4. **유지보수성**
- 특정 기능 수정 시 해당 폴더만 집중
- 의존성 흐름이 명확함

---


