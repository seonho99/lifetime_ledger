# 폴더 구조

## 프로젝트 루트 구조
```
lib/
├── core/                # 핵심 유틸리티 및 상수
├── features/            # 기능별 모듈 (Clean Architecture)
├── shared/              # 공통 위젯 및 유틸리티
└── main.dart            # 앱 진입점 (MultiProvider 설정)
```

## Core 구조
```
core/
├── constants/           # 상수 정의
│   ├── app_constants.dart
│   ├── api_constants.dart
│   └── ui_constants.dart
├── errors/              # 에러 및 예외 클래스
│   ├── exceptions.dart
│   ├── failures.dart
│   └── error_handler.dart
├── network/             # 네트워크 관련
│   ├── api_client.dart
│   ├── network_info.dart
│   └── interceptors/
├── utils/               # 유틸리티 함수
│   ├── formatters.dart
│   ├── validators.dart
│   └── extensions.dart
├── theme/               # 테마 설정
│   ├── app_theme.dart
│   ├── colors.dart
│   └── text_styles.dart
└── result/              # Result 패턴
    ├── result.dart
    └── result_extensions.dart
```

## Feature 구조 (Clean Architecture + MVVM)
```
features/
├── auth/                # 인증 기능
├── transaction/         # 거래 관리 기능
├── category/            # 카테고리 관리 기능
├── budget/              # 예산 관리 기능
└── statistics/          # 통계 및 리포트 기능
```

## Feature 내부 구조 (예: transaction)
```
transaction/
├── data/                # Data Layer
│   ├── datasources/     # 데이터 소스
│   │   ├── transaction_local_datasource.dart
│   │   ├── transaction_remote_datasource.dart
│   │   └── transaction_datasource.dart
│   ├── models/          # DTO 모델
│   │   ├── transaction_dto.dart
│   │   └── transaction_response_dto.dart
│   ├── repositories/    # Repository 구현
│   │   └── transaction_repository_impl.dart
│   └── mappers/         # DTO ↔ Entity 변환
│       └── transaction_mapper.dart
├── domain/              # Domain Layer
│   ├── entities/        # 도메인 엔티티
│   │   └── transaction.dart
│   ├── repositories/    # Repository 인터페이스
│   │   └── transaction_repository.dart
│   ├── usecases/        # 유스케이스
│   │   ├── get_transactions_usecase.dart
│   │   ├── add_transaction_usecase.dart
│   │   ├── update_transaction_usecase.dart
│   │   └── delete_transaction_usecase.dart
│   └── enums/           # 도메인 열거형
│       └── transaction_type.dart
└── presentation/        # Presentation Layer (MVVM)
    ├── states/          # State 객체 (freezed)
    │   ├── transaction_state.dart
    │   └── transaction_form_state.dart
    ├── viewmodels/      # ViewModel (ChangeNotifier)
    │   ├── transaction_viewmodel.dart
    │   ├── transaction_list_viewmodel.dart
    │   └── transaction_form_viewmodel.dart
    ├── screens/         # Screen (Provider 설정 + UI)
    │   ├── transaction_screen.dart
    │   ├── transaction_list_screen.dart
    │   ├── transaction_detail_screen.dart
    │   └── add_transaction_screen.dart
    └── widgets/         # UI 컴포넌트
        ├── transaction_card.dart
        ├── transaction_form.dart
        ├── transaction_summary.dart
        └── transaction_filter.dart
```

## Shared 구조
```
shared/
├── widgets/             # 공통 위젯
│   ├── common_button.dart
│   ├── common_text_field.dart
│   ├── loading_widget.dart
│   ├── error_widget.dart
│   └── empty_state_widget.dart
├── services/            # 공통 서비스
│   ├── storage_service.dart
│   ├── notification_service.dart
│   └── analytics_service.dart
├── extensions/          # 확장 메서드
│   ├── context_extensions.dart
│   ├── string_extensions.dart
│   └── datetime_extensions.dart
└── mixins/              # 공통 Mixin
    ├── error_handler_mixin.dart
    └── loading_state_mixin.dart
```

## Provider 기반 main.dart 구조
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
        
        Provider<CategoryRepository>(
          create: (context) => CategoryRepositoryImpl(
            remoteDataSource: CategoryRemoteDataSourceImpl(),
            localDataSource: CategoryLocalDataSourceImpl(),
          ),
        ),
        
        // UseCases
        Provider<GetTransactionsUseCase>(
          create: (context) => GetTransactionsUseCase(
            repository: context.read<TransactionRepository>(),
          ),
        ),
        
        Provider<AddTransactionUseCase>(
          create: (context) => AddTransactionUseCase(
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

## 파일 네이밍 규칙

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

### 클래스 네이밍 규칙
```dart
// Entity
class Transaction { }

// DTO
class TransactionDto { }

// Repository
abstract class TransactionRepository { }
class TransactionRepositoryImpl implements TransactionRepository { }

// UseCase
class GetTransactionsUseCase { }

// State
class TransactionState { }

// ViewModel
class TransactionViewModel extends ChangeNotifier { }

// Screen
class TransactionScreen extends StatelessWidget { }

// Widget
class TransactionCard extends StatelessWidget { }
```

## 테스트 구조
```
test/
├── unit/                # 단위 테스트
│   ├── features/
│   │   └── transaction/
│   │       ├── data/
│   │       │   ├── repositories/
│   │       │   │   └── transaction_repository_impl_test.dart
│   │       │   └── datasources/
│   │       │       └── transaction_remote_datasource_test.dart
│   │       ├── domain/
│   │       │   └── usecases/
│   │       │       └── get_transactions_usecase_test.dart
│   │       └── presentation/
│   │           └── viewmodels/
│   │               └── transaction_viewmodel_test.dart
│   └── core/
├── widget/              # 위젯 테스트
│   └── features/
│       └── transaction/
│           └── presentation/
│               ├── screens/
│               │   └── transaction_screen_test.dart
│               └── widgets/
│                   └── transaction_card_test.dart
└── integration/         # 통합 테스트
    └── app_test.dart
```

## 리소스 구조
```
assets/
├── images/              # 이미지 리소스
│   ├── icons/
│   │   ├── app_icon.png
│   │   └── transaction_icon.png
│   └── illustrations/
│       ├── empty_state.png
│       └── error_state.png
├── fonts/               # 폰트 리소스
│   ├── Pretendard-Regular.ttf
│   └── Pretendard-Bold.ttf
└── data/                # 로컬 데이터
    └── categories.json
```

## 설정 파일들
```
root/
├── pubspec.yaml         # 의존성 관리
├── analysis_options.yaml # 린트 설정
├── build.yaml           # 빌드 설정 (freezed, json_serializable)
└── firebase_options.dart # Firebase 설정 (생성됨)
```

## 실제 프로젝트 예시 구조
```
lifetime_ledger/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── network/
│   │   ├── theme/
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── transaction/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   ├── repositories/
│   │   │   │   └── mappers/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── states/
│   │   │       ├── viewmodels/
│   │   │       ├── screens/
│   │   │       └── widgets/
│   │   ├── category/
│   │   ├── budget/
│   │   └── statistics/
│   ├── shared/
│   │   ├── widgets/
│   │   ├── services/
│   │   ├── extensions/
│   │   └── mixins/
│   └── main.dart
├── test/
├── assets/
├── pubspec.yaml
└── analysis_options.yaml
```

## Best Practices

### 1. 폴더 구조 원칙
- **기능별 분리**: 각 feature는 독립적
- **레이어별 분리**: data, domain, presentation 명확히 구분
- **관심사 분리**: state, viewmodel, screen, widget 각각 분리

### 2. 파일 네이밍
- **일관성**: 모든 파일에 일관된 네이밍 적용
- **명확성**: 파일 역할을 이름으로 명확히 표현
- **접미사**: _impl, _dto, _state, _viewmodel 등 역할 표시

### 3. 의존성 관리
- **계층 순서**: core → shared → features
- **순환 참조 방지**: feature 간 직접 참조 금지
- **공통 코드**: shared 폴더에 배치

### 4. 확장성
- **새 기능 추가**: feature 폴더 추가로 간단히 확장
- **테스트 구조**: 실제 코드 구조와 동일하게 유지
- **리소스 관리**: 타입별로 체계적 분류

## 체크리스트

### 폴더 구조
- [ ] Clean Architecture 3레이어 분리
- [ ] MVVM 패턴 적용 (states, viewmodels, screens)
- [ ] 기능별 feature 폴더 생성
- [ ] core, shared 폴더 적절히 활용

### 파일 네이밍
- [ ] 일관된 네이밍 규칙 적용
- [ ] 역할별 접미사 사용
- [ ] 클래스명과 파일명 일치

### 의존성
- [ ] 계층 간 의존성 규칙 준수
- [ ] 순환 참조 방지
- [ ] Provider 설정 순서 확인

### 확장성
- [ ] 새 기능 추가 용이성
- [ ] 테스트 구조 일관성
- [ ] 리소스 체계적 관리