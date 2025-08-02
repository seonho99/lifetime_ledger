# 📁 폴더 구조 설계 가이드 (업데이트)

---

## ✅ 목적

이 프로젝트는 기능 단위(Feature-first) 기반으로 폴더를 구성하며,  
**Provider + MVVM + Clean Architecture** 패턴을 적용하여 유지보수성과 가독성, 확장성, 팀 단위 협업의 효율을 높입니다.

현재는 단일 기능(History)으로 시작하여 점진적으로 기능을 확장할 예정입니다.

---

## ✅ 설계 원칙

- 현재는 **단일 기능 구조**로 시작하여 점진적으로 **기능 단위**로 확장
- Clean Architecture의 3개 레이어를 명확히 구분: `data/`, `domain/`, `ui/`
- 공통 요소는 `lib/core/`에 위치
- 레이어 간 의존성은 항상 하향식만 허용 (UI → Domain → Data)

---

## ✅ 현재 폴더 구조 (v1.0 - History 기능 중심)

```
lib/
├── core/                            # 핵심 유틸리티 및 상수
│   ├── result/
│   │   └── result.dart              # Result 패턴
│   └── errors/
│       ├── failure.dart             # Failure 클래스들
│       ├── exceptions.dart          # Exception 클래스들
│       └── failure_mapper.dart      # Exception → Failure 매핑
├── data/                            # Data Layer (Clean Architecture)
│   ├── datasource/                  # DataSource 구현체들
│   │   ├── history_datasource.dart
│   │   └── history_firebase_datasource_impl.dart (Firebase 구현체)
│   ├── dto/                         # DTO 모델들
│   │   ├── history_dto.dart
│   │   └── history_dto.g.dart       # json_serializable 생성 파일
│   ├── mapper/                      # DTO ↔ Model 변환
│   │   └── history_mapper.dart
│   └── repository_impl/             # Repository 구현체
│       └── history_repository_impl.dart
├── domain/                          # Domain Layer (Clean Architecture)
│   ├── model/                       # 도메인 모델
│   │   ├── history.dart
│   │   └── history.freezed.dart     # Freezed 생성 파일
│   ├── repository/                  # Repository 인터페이스
│   │   └── history_repository.dart
│   └── usecase/                     # UseCase들
│       ├── get_histories_usecase.dart
│       ├── add_history_usecase.dart
│       ├── update_history_usecase.dart
│       ├── delete_history_usecase.dart
│       └── get_histories_by_month_usecase.dart
├── ui/                              # Presentation Layer (MVVM)
│   └── history/                     # 기능별 UI 폴더
│       ├── history_state.dart       # State 객체 (freezed)
│       ├── history_state.freezed.dart # Freezed 생성 파일
│       ├── history_viewmodel.dart   # ViewModel (ChangeNotifier)
│       └── history_screen.dart      # Screen (Provider 설정 + UI)
├── firebase_options.dart            # Firebase 설정
└── main.dart                        # 앱 진입점
```

---

## ✅ 향후 확장 계획 (v2.0 - Feature 기반 구조)

새로운 기능 추가 시 다음과 같이 확장할 예정입니다:

```
lib/
├── core/                            # 핵심 유틸리티 및 상수
│   ├── result/
│   ├── errors/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── features/                        # 기능별 폴더
│   ├── history/                     # 거래 내역 기능
│   │   ├── data/
│   │   │   ├── datasource/
│   │   │   ├── dto/
│   │   │   ├── mapper/
│   │   │   └── repository_impl/
│   │   ├── domain/
│   │   │   ├── model/
│   │   │   ├── repository/
│   │   │   └── usecase/
│   │   └── ui/
│   │       ├── state.dart
│   │       ├── viewmodel.dart
│   │       ├── screen.dart
│   │       └── components.dart
│   ├── category/                    # 카테고리 기능 (향후 추가)
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   ├── statistics/                  # 통계 기능 (향후 추가)
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   └── settings/                    # 설정 기능 (향후 추가)
│       ├── data/
│       ├── domain/
│       └── ui/
├── shared/                          # 여러 기능이 공유하는 요소들
│   ├── widgets/                     # 공통 위젯
│   ├── services/                    # 공통 서비스
│   └── models/                      # 공통 모델
├── firebase_options.dart
└── main.dart
```

---

## ✅ 폴더별 책임 요약

| 폴더                     | 설명                                         |
|------------------------|------------------------------------------|
| `core/`                | 앱 전체에서 사용하는 핵심 유틸리티, 상수, 테마 등           |
| `data/datasource/`    | 외부 API, Firebase, SharedPreferences 등 연결   |
| `data/repository_impl/`| Repository 인터페이스의 실제 구현                   |
| `data/dto/`            | 서버와 통신하는 DTO (Data Transfer Object)       |
| `data/mapper/`         | DTO ↔ Model 변환 로직 (Extension 방식)           |
| `domain/model/`        | 앱 내부에서 사용하는 도메인 모델 정의                    |
| `domain/repository/`   | UseCase에서 참조하는 Repository 인터페이스           |
| `domain/usecase/`      | 하나의 도메인 기능을 수행하는 유스케이스                   |
| `ui/`                  | Presentation Layer (State, ViewModel, Screen)  |

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
DataSource (data/datasource/)
```

---

## ✅ 파일 네이밍 규칙

### Data Layer
```
# DataSource
history_datasource.dart                  # DataSource 인터페이스
history_firebase_datasource_impl.dart    # Firebase DataSource 구현체

# DTO
history_dto.dart                         # DTO 모델

# Mapper
history_mapper.dart                      # Extension 방식 매퍼

# Repository Implementation
history_repository_impl.dart            # Repository 구현
```

### Domain Layer
```
# Model
history.dart                            # Entity

# Repository Interface
history_repository.dart                 # Repository 인터페이스

# UseCase
get_histories_usecase.dart              # UseCase
add_history_usecase.dart                # UseCase
```

### UI Layer
```
history_state.dart                      # State 객체
history_viewmodel.dart                  # ViewModel
history_screen.dart                     # Screen
```

---

## ✅ Provider 기반 main.dart 구조

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 한국어 로케일 초기화
  await initializeDateFormatting('ko_KR', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lifetime Ledger',
      home: const HistoryScreen(),
    );
  }
}
```

---

## ✅ Screen별 Provider 구조

```dart
// ui/history/history_screen.dart
class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // DataSource
        Provider(
          create: (context) => HistoryFirebaseDataSourceImpl(
            firestore: FirebaseFirestore.instance,
          ),
        ),
        
        // Repository
        Provider<HistoryRepository>(
          create: (context) => HistoryRepositoryImpl(
            dataSource: context.read<HistoryFirebaseDataSourceImpl>(),
          ),
        ),
        
        // UseCases
        Provider(create: (context) => GetHistoriesUseCase(...)),
        Provider(create: (context) => AddHistoryUseCase(...)),
        
        // ViewModel
        ChangeNotifierProvider(
          create: (context) => HistoryViewModel(...)..loadHistoriesByMonth(...),
        ),
      ],
      child: const HistoryView(),
    );
  }
}
```

---

## ✅ 기능 확장 전략

### 새로운 기능 추가 시
1. **v1.0에서는**: `lib/` 하위에 직접 해당 기능 폴더 추가
2. **v2.0에서는**: `lib/features/{기능명}/` 폴더로 이동 및 리팩토링
3. **공통 요소**: `lib/core/` 또는 `lib/shared/`로 이동

### 예시: Category 기능 추가 (v1.0)
```
lib/
├── data/
│   ├── datasource/
│   │   ├── history_datasource.dart
│   │   ├── history_firebase_datasource_impl.dart
│   │   ├── category_datasource.dart          # 새로 추가
│   │   └── category_firebase_datasource_impl.dart     # 새로 추가
│   └── ...
├── domain/
│   ├── model/
│   │   ├── history.dart
│   │   └── category.dart                     # 새로 추가
│   └── ...
├── ui/
│   ├── history/
│   └── category/                             # 새로 추가
└── ...
```

---

## ✅ 장점

### 1. **점진적 확장**
- 단일 기능으로 시작하여 자연스러운 확장
- 초기 개발 속도 향상

### 2. **명확한 책임 분리**
- Clean Architecture 레이어가 물리적으로 분리됨
- 각 폴더의 역할이 명확히 구분됨

### 3. **높은 확장성**
- v2.0에서 feature 기반으로 자연스러운 리팩토링
- 새 기능 추가 시 동일한 구조 적용

### 4. **효율적인 협업**
- 기능별로 작업 분담 가능
- 파일 충돌 최소화

### 5. **Firebase 통합**
- Firebase Authentication과 Firestore 자연스럽게 통합
- 보안 규칙과 연동 가능

---

## ✅ 마이그레이션 계획

### v1.0 → v2.0 마이그레이션
1. `lib/features/` 폴더 생성
2. 기존 기능들을 `lib/features/{기능명}/` 하위로 이동
3. 공통 요소는 `lib/core/` 또는 `lib/shared/`로 분리
4. import 경로 업데이트
5. Provider 설정 조정

이러한 구조를 통해 초기 개발의 단순함을 유지하면서도 향후 확장에 대비한 견고한 기반을 마련했습니다.