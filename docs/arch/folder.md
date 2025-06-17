# 📁 폴더 구조 설계 가이드

---

## ✅ 목적

이 프로젝트는 기능 단위(Feature-first) 기반으로 폴더를 구성하며,  
각 기능 폴더는 일관된 구조(presentation, domain, data)를 따릅니다.  
**Provider + MVVM + Clean Architecture** 패턴을 적용하여 유지보수성과 가독성, 확장성, 팀 단위 협업의 효율을 높입니다.

---

## ✅ 설계 원칙

- 모든 화면/기능은 `lib/features/{기능}/` 하위에 구성하며, 도메인 기준으로 개별 폴더를 생성합니다.
- 각 기능 폴더는 아래 3개의 레이어 폴더를 포함합니다:
    - `presentation/` : Screen, ViewModel, State, Widget
    - `domain/` : Entity, Repository Interface, UseCase
    - `data/` : Repository 구현체, DataSource, DTO, Mapper
- 공통 요소는 `lib/core/`와 `lib/shared/`에 위치시킵니다.  
  단, 공용화가 확정된 요소만 이동하며, 성급한 추출은 금지합니다.
- Repository 구현체는 반드시 `data/repositories/` 폴더에 위치합니다.
- `presentation/` 폴더 내 구성은 다음 항목을 원칙으로 합니다:
    - `screens/`, `viewmodels/`, `states/`, `widgets/`
- 레이어 간 의존성은 항상 하향식만 허용됩니다 (UI → UseCase → Repository Interface)

---

## ✅ 폴더 구조 예시

```
lib/
├── core/                            # 핵심 유틸리티 및 상수
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   ├── utils/
│   └── result/
├── shared/                          # 공통 위젯 및 서비스
│   ├── widgets/
│   ├── services/
│   ├── extensions/
│   └── mixins/
├── features/
│   ├── transaction/
│   │   ├── data/
│   │   │   ├── datasources/        # Remote/Local DataSource
│   │   │   │   ├── transaction_remote_datasource.dart
│   │   │   │   └── transaction_local_datasource.dart
│   │   │   ├── models/             # DTO 모델
│   │   │   │   ├── transaction_dto.dart
│   │   │   │   └── transaction_response_dto.dart
│   │   │   ├── repositories/       # Repository 구현체
│   │   │   │   └── transaction_repository_impl.dart
│   │   │   └── mappers/            # DTO ↔ Entity 변환
│   │   │       └── transaction_mapper.dart
│   │   ├── domain/
│   │   │   ├── entities/           # 도메인 엔티티
│   │   │   │   └── transaction.dart
│   │   │   ├── repositories/       # Repository 인터페이스
│   │   │   │   └── transaction_repository.dart
│   │   │   ├── usecases/           # 유스케이스
│   │   │   │   ├── get_transactions_usecase.dart
│   │   │   │   ├── add_transaction_usecase.dart
│   │   │   │   ├── update_transaction_usecase.dart
│   │   │   │   └── delete_transaction_usecase.dart
│   │   │   └── enums/              # 도메인 열거형
│   │   │       └── transaction_type.dart
│   │   └── presentation/
│   │       ├── states/             # State 객체 (freezed)
│   │       │   ├── transaction_state.dart
│   │       │   └── transaction_form_state.dart
│   │       ├── viewmodels/         # ViewModel (ChangeNotifier)
│   │       │   ├── transaction_viewmodel.dart
│   │       │   ├── transaction_list_viewmodel.dart
│   │       │   └── transaction_form_viewmodel.dart
│   │       ├── screens/            # Screen (Provider 설정 + UI)
│   │       │   ├── transaction_screen.dart
│   │       │   ├── transaction_list_screen.dart
│   │       │   ├── transaction_detail_screen.dart
│   │       │   └── add_transaction_screen.dart
│   │       └── widgets/            # UI 컴포넌트
│   │           ├── transaction_card.dart
│   │           ├── transaction_form.dart
│   │           └── transaction_summary.dart
│   ├── category/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── budget/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── statistics/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart                       # MultiProvider 설정
```

---

## ✅ 폴더별 책임 요약

| 폴더                     | 설명                                         |
|------------------------|------------------------------------------|
| `core/`                | 앱 전체에서 사용하는 핵심 유틸리티, 상수, 테마 등           |
| `shared/`              | 여러 feature에서 공통으로 사용하는 위젯, 서비스 등         |
| `data/datasources/`    | 외부 API, Firebase, SharedPreferences 등 연결   |
| `data/repositories/`   | Repository 인터페이스의 실제 구현                   |
| `data/models/`         | 서버와 통신하는 DTO (Data Transfer Object)       |
| `data/mappers/`        | DTO ↔ Entity 변환 로직                        |
| `domain/entities/`     | 앱 내부에서 사용하는 도메인 모델 정의                    |
| `domain/repositories/` | UseCase에서 참조하는 Repository 인터페이스           |
| `domain/usecases/`     | 하나의 도메인 기능을 수행하는 유스케이스                   |
| `presentation/states/` | freezed 기반 불변 상태 객체                       |
| `presentation/viewmodels/` | ChangeNotifier 기반 ViewModel             |
| `presentation/screens/` | ChangeNotifierProvider 설정 + UI           |
| `presentation/widgets/` | 재사용 가능한 UI 컴포넌트                          |

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
        
        // Repositories
        Provider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(
            remoteDataSource: TransactionRemoteDataSourceImpl(),
            localDataSource: TransactionLocalDataSourceImpl(),
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
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const TransactionScreen(),
      ),
    );
  }
}
```

---

## ✅ 기능 템플릿 확산 전략

- 기능 추가 시 기존 기능 구조(transaction 등)를 복제하여 시작합니다.
- 구조만 복제하여 클래스명, 경로, Provider 설정 모두 해당 기능에 맞게 수정해야 합니다.
- shell 또는 Dart CLI 기반 템플릿 자동 생성 스크립트를 사용하면 빠르게 구조 확산이 가능합니다.

---

## ✅ 파일 네이밍 규칙

### Feature 파일들
```
# Data Layer
transaction_repository_impl.dart     # Repository 구현
transaction_remote_datasource.dart   # Remote DataSource
transaction_local_datasource.dart    # Local DataSource
transaction_dto.dart                 # DTO 모델
transaction_mapper.dart              # 매퍼

# Domain Layer
transaction.dart                     # Entity
transaction_repository.dart         # Repository 인터페이스
get_transactions_usecase.dart       # UseCase
transaction_type.dart               # Enum

# Presentation Layer
transaction_state.dart              # State 객체
transaction_viewmodel.dart          # ViewModel
transaction_screen.dart             # Screen
transaction_card.dart               # Widget
```

---

