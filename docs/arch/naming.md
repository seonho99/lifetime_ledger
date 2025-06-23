# 🏷️ 네이밍 규칙 가이드 (수정됨)

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
- Firebase 구현체는 `FirebaseDataSourceImpl` 접미사를 사용한다.

---

# ✅ 1. Repository & DataSource 네이밍 및 메서드 규칙

### 📁 Repository

- 도메인 중심 명명: `HistoryRepository`, `CategoryRepository` 등
- 인터페이스와 구현 클래스는 구분: `HistoryRepository`, `HistoryRepositoryImpl`
- 파일명: `history_repository.dart`, `history_repository_impl.dart`

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
| 인터페이스  | `HistoryDataSource`              | `history_datasource.dart`                 |
| Firebase 구현체 | `HistoryFirebaseDataSourceImpl` | `history_firebase_datasource_impl.dart`   |

- Firebase 구현체만 `FirebaseDataSourceImpl` 접미사를 사용한다.
- Mock 클래스는 테스트에서 교체 가능하도록 동일한 인터페이스를 구현한다.

```dart
abstract class HistoryDataSource {
  Future<List<HistoryDto>> getHistories();
  Future<void> addHistory(HistoryDto history);
}

class HistoryFirebaseDataSourceImpl implements HistoryDataSource {
  // Firebase 호출 구현
}
```

#### 📌 DataSource 메서드 네이밍 규칙

| 동작 유형     | 접두사 예시         | 설명                                      |
|----------------|----------------------|-------------------------------------------|
| Firebase 호출  | `get`, `add`, `update`, `delete` | Firebase Firestore 호출           |
| 로컬 저장소    | `get`, `save`, `remove`    | SharedPreferences, SQLite 등   |

---

# ✅ 2. UseCase 네이밍 및 사용 규칙

- 클래스명: `{동작명}UseCase`  
  예: `GetHistoriesUseCase`, `AddHistoryUseCase`
- 파일명: `{동작명}_usecase.dart`  
  예: `get_histories_usecase.dart`, `add_history_usecase.dart`
- 메서드는 기본적으로 `call()` 사용 (함수 객체 패턴)

```dart
class GetHistoriesUseCase {
  final HistoryRepository _repository;

  GetHistoriesUseCase({required HistoryRepository repository}) 
      : _repository = repository;

  Future<Result<List<History>>> call() async {
    return await _repository.getHistories();
  }
}

class GetHistoriesByMonthUseCase {
  final HistoryRepository _repository;

  GetHistoriesByMonthUseCase({required HistoryRepository repository}) 
      : _repository = repository;

  Future<Result<List<History>>> call({
    required int year,
    required int month,
  }) async {
    return await _repository.getHistoriesByMonth(year, month);
  }
}
```

---

# ✅ 3. Presentation 계층 네이밍 (MVVM)

### 📁 구성 예시

```
ui/
├── state.dart                     # HistoryState
├── viewmodel.dart                 # HistoryViewModel  
├── screen.dart                    # HistoryScreen, HistoryView
└── components.dart                # UI 컴포넌트들
```

### 📌 ViewModel 네이밍

- 클래스명: `{기능명}ViewModel`  
  예: `HistoryViewModel`, `CategoryViewModel`
- 파일명: `{기능명}_viewmodel.dart` → **실제로는 `viewmodel.dart`**
- ChangeNotifier를 상속하여 구현

```dart
class HistoryViewModel extends ChangeNotifier {
  final GetHistoriesUseCase _getHistoriesUseCase;

  HistoryViewModel({
    required GetHistoriesUseCase getHistoriesUseCase,
  }) : _getHistoriesUseCase = getHistoriesUseCase;

  // 상태 관리 로직
}
```

### 📌 State 네이밍

- 클래스명: `{기능명}State`  
  예: `HistoryState`, `CategoryState`
- 파일명: `{기능명}_state.dart` → **실제로는 `state.dart`**
- freezed를 사용하여 불변 객체로 구현

```dart
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
}
```

### 📌 Screen 네이밍

- 클래스명: `{기능명}Screen`, `{기능명}View`  
  예: `HistoryScreen`, `HistoryView`
- 파일명: `{기능명}_screen.dart` → **실제로는 `screen.dart`**
- MultiProvider 설정과 UI를 분리

```dart
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
        
        // ViewModel
        ChangeNotifierProvider(
          create: (context) => HistoryViewModel(...),
        ),
      ],
      child: const HistoryView(),
    );
  }
}

class HistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, child) {
        // UI 구현
      },
    );
  }
}
```

### 📌 Widget 네이밍

- **기능명 접두사 필수**
  - `history_card.dart`, `history_summary.dart`
- 단순 역할명 (`card.dart`, `summary.dart`) 지양
- 공통 요소가 되지 않은 위젯은 각 기능 폴더 내에 위치

---

# ✅ 4. 생성자 정의 및 주입 규칙

- 모든 주입 필드는 `final` + `_` 접두사로 선언
- 생성자에서는 `required`로 명시적으로 받음
- 외부 노출을 막기 위해 `_` 접두사로 캡슐화
- 변경 불가능한 구조로 불변성 유지

```dart
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDataSource _dataSource;

  HistoryRepositoryImpl({
    required HistoryDataSource dataSource,
  }) : _dataSource = dataSource;
}

class HistoryViewModel extends ChangeNotifier {
  final GetHistoriesUseCase _getHistoriesUseCase;
  final AddHistoryUseCase _addHistoryUseCase;

  HistoryViewModel({
    required GetHistoriesUseCase getHistoriesUseCase,
    required AddHistoryUseCase addHistoryUseCase,
  }) : _getHistoriesUseCase = getHistoriesUseCase,
       _addHistoryUseCase = addHistoryUseCase;
}
```

---

# ✅ 5. Provider 설정 및 상태 객체 명명

- Provider 설정은 각 Screen의 MultiProvider에서 관리
- ChangeNotifierProvider는 각 Screen에서 설정
- Consumer/Selector로 상태 구독

```dart
// history/ui/screen.dart - Provider 설정
MultiProvider(
  providers: [
    Provider<HistoryRepository>(
      create: (context) => HistoryRepositoryImpl(...),
    ),
    Provider<GetHistoriesUseCase>(
      create: (context) => GetHistoriesUseCase(
        repository: context.read<HistoryRepository>(),
      ),
    ),
    ChangeNotifierProvider<HistoryViewModel>(
      create: (context) => HistoryViewModel(
        getHistoriesUseCase: context.read<GetHistoriesUseCase>(),
      ),
    ),
  ],
  child: HistoryView(),
)
```

---

# ✅ 6. Mapper 네이밍 (Extension 방식)

- 파일명: `{entity_name}_mapper.dart`
- Extension 방식으로 구현

```dart
/// HistoryDto -> History 변환
extension HistoryDtoMapper on HistoryDto? {
  History? toModel() {
    // DTO → Entity 변환 로직
  }
}

/// History -> HistoryDto 변환
extension HistoryMapper on History {
  HistoryDto toDto() {
    // Entity → DTO 변환 로직
  }
}

/// List 변환
extension HistoryDtoListMapper on List<HistoryDto>? {
  List<History> toModelList() {
    // List 변환 로직
  }
}
```

---

# ✅ 7. DTO 네이밍

- 클래스명: `{EntityName}Dto`
- 파일명: `{entity_name}_dto.dart`
- json_serializable 사용

```dart
@JsonSerializable()
class HistoryDto {
  const HistoryDto({
    this.id,
    this.title,
    this.amount,
    this.type,
    this.categoryId,
    this.date,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? title;
  final num? amount;
  final String? type;
  final String? categoryId;
  final DateTime? date;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

---

# ✅ 네이밍 요약표

| 항목           | 예시                              | 파일명                              |
|----------------|---------------------------------|------------------------------------|
| Entity         | `History`                       | `history.dart`                     |
| Repository (Interface) | `HistoryRepository`    | `history_repository.dart`          |
| Repository (Impl) | `HistoryRepositoryImpl`     | `history_repository_impl.dart`     |
| DataSource (Interface) | `HistoryDataSource`     | `history_datasource.dart`          |
| DataSource (Impl) | `HistoryFirebaseDataSourceImpl` | `history_firebase_datasource_impl.dart` |
| UseCase        | `GetHistoriesUseCase`           | `get_histories_usecase.dart`        |
| ViewModel      | `HistoryViewModel`              | `viewmodel.dart`                    |
| State          | `HistoryState`                  | `state.dart`                        |
| Screen         | `HistoryScreen`, `HistoryView`  | `screen.dart`                       |
| DTO            | `HistoryDto`                    | `history_dto.dart`                  |
| Mapper         | `HistoryMapper` (Extension)     | `history_mapper.dart`               |
| 생성자 필드    | `_repository`                   | final + 프라이빗 + required 주입    |

---

# ✅ 실제 사용 예시

## 기능 추가 시 파일 생성 순서

1. **Domain Layer**
   ```
   history/domain/model/history.dart              → History
   history/domain/repository/history_repository.dart → HistoryRepository
   history/domain/usecase/get_histories_usecase.dart → GetHistoriesUseCase
   ```

2. **Data Layer**
   ```
   history/data/dto/history_dto.dart              → HistoryDto
   history/data/mapper/history_mapper.dart        → Extension Mappers
   history/data/datasource/history_datasource.dart → HistoryDataSource
   history/data/datasource/history_firebase_datasource_impl.dart → HistoryFirebaseDataSourceImpl
   history/data/repository_impl/history_repository_impl.dart → HistoryRepositoryImpl
   ```

3. **UI Layer**
   ```
   history/ui/state.dart                          → HistoryState
   history/ui/viewmodel.dart                      → HistoryViewModel
   history/ui/screen.dart                         → HistoryScreen, HistoryView
   ```

## Import 예시

```dart
// ViewModel에서의 import
import '../domain/model/history.dart';
import '../domain/usecase/get_histories_usecase.dart';
import '../domain/usecase/add_history_usecase.dart';
import 'state.dart';

// Repository에서의 import  
import '../../domain/model/history.dart';
import '../../domain/repository/history_repository.dart';
import '../datasource/history_datasource.dart';
import '../mapper/history_mapper.dart';
```

---