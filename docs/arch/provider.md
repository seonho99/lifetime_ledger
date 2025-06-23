# 🧩 Provider 의존성 주입 설계 가이드

---

## ✅ 목적

- **Provider 패턴**을 통해 앱의 의존성 주입을 체계적으로 관리
- Clean Architecture 계층별 의존성을 명확히 구분하여 관리
- **main.dart에서 전역 MultiProvider**와 **Screen에서 ChangeNotifierProvider**를 활용한 효율적인 상태 관리
- 테스트 가능성과 확장성을 고려한 의존성 구조 설계

---

## 🧱 설계 원칙

- **main.dart**에서 **MultiProvider**로 전역 의존성 설정 (DataSource, Repository, UseCase)
- **Screen**에서 **ChangeNotifierProvider**로 ViewModel 제공
- 계층별 의존성은 하향식으로만 주입 (UI → UseCase → Repository → DataSource)
- **context.read()**로 의존성 주입, **Consumer/Selector**로 상태 구독
- Provider 생명주기는 앱 생명주기와 연동 (전역) 또는 Screen 생명주기와 연동 (ViewModel)

---

## ✅ 파일 구조 및 위치

```
lib/
├── main.dart                           # MultiProvider 전역 설정
├── features/
│   └── {기능}/
│       ├── data/
│       │   ├── datasource/
│       │   └── repository_impl/
│       ├── domain/
│       │   ├── usecase/
│       │   └── repository/
│       └── ui/
│           ├── viewmodel.dart
│           └── screen.dart
└── core/
    └── di/
        └── injection_container.dart    # 의존성 컨테이너 (선택적)
```

---

## ✅ main.dart에서 전역 Provider 설정

```dart
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core Services
        Provider<FirebaseFirestore>(
          create: (context) => FirebaseFirestore.instance,
        ),

        // Data Layer - DataSources
        Provider<HistoryDataSource>(
          create: (context) => HistoryFirebaseDataSourceImpl(
            firestore: context.read<FirebaseFirestore>(),
          ),
        ),

        Provider<CategoryDataSource>(
          create: (context) => CategoryFirebaseDataSourceImpl(
            firestore: context.read<FirebaseFirestore>(),
          ),
        ),

        // Data Layer - Repositories
        Provider<HistoryRepository>(
          create: (context) => HistoryRepositoryImpl(
            dataSource: context.read<HistoryDataSource>(),
          ),
        ),

        Provider<CategoryRepository>(
          create: (context) => CategoryRepositoryImpl(
            dataSource: context.read<CategoryDataSource>(),
          ),
        ),

        // Domain Layer - UseCases (History)
        Provider<GetHistoriesUseCase>(
          create: (context) => GetHistoriesUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),

        Provider<GetHistoriesByMonthUseCase>(
          create: (context) => GetHistoriesByMonthUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),

        Provider<AddHistoryUseCase>(
          create: (context) => AddHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),

        Provider<UpdateHistoryUseCase>(
          create: (context) => UpdateHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),

        Provider<DeleteHistoryUseCase>(
          create: (context) => DeleteHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),

        // Domain Layer - UseCases (Category)
        Provider<GetCategoriesUseCase>(
          create: (context) => GetCategoriesUseCase(
            repository: context.read<CategoryRepository>(),
          ),
        ),

        Provider<AddCategoryUseCase>(
          create: (context) => AddCategoryUseCase(
            repository: context.read<CategoryRepository>(),
          ),
        ),

        // Domain Layer - UseCases (Statistics)
        Provider<GetExpensesByCategoryUseCase>(
          create: (context) => GetExpensesByCategoryUseCase(
            historyRepository: context.read<HistoryRepository>(),
            categoryRepository: context.read<CategoryRepository>(),
          ),
        ),

        Provider<GetMonthlyReportUseCase>(
          create: (context) => GetMonthlyReportUseCase(
            historyRepository: context.read<HistoryRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Lifetime Ledger',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        locale: const Locale('ko', 'KR'),
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ko', 'KR'),
        ],
        home: const HistoryScreen(),
      ),
    );
  }
}
```

---

## ✅ Screen에서 ViewModel Provider 설정

### 기본 Screen 패턴

```dart
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HistoryViewModel(
        getHistoriesUseCase: context.read<GetHistoriesUseCase>(),
        getHistoriesByMonthUseCase: context.read<GetHistoriesByMonthUseCase>(),
        addHistoryUseCase: context.read<AddHistoryUseCase>(),
        updateHistoryUseCase: context.read<UpdateHistoryUseCase>(),
        deleteHistoryUseCase: context.read<DeleteHistoryUseCase>(),
      )..loadHistoriesByMonth(DateTime.now().year, DateTime.now().month), // 초기 데이터 로드
      child: const HistoryView(),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('거래 내역'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.read<HistoryViewModel>().navigateToAdd(context),
          ),
        ],
      ),
      body: Consumer<HistoryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage!),
                  ElevatedButton(
                    onPressed: () => viewModel.retryLastAction(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: viewModel.histories.length,
            itemBuilder: (context, index) {
              return HistoryCard(
                history: viewModel.histories[index],
                onTap: () => viewModel.navigateToDetail(
                  context,
                  viewModel.histories[index].id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

### Parameter가 있는 Screen

```dart
class HistoryDetailScreen extends StatelessWidget {
  final String historyId;
  
  const HistoryDetailScreen({
    super.key,
    required this.historyId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HistoryDetailViewModel(
        historyId: historyId,
        getHistoryByIdUseCase: context.read<GetHistoryByIdUseCase>(),
        updateHistoryUseCase: context.read<UpdateHistoryUseCase>(),
        deleteHistoryUseCase: context.read<DeleteHistoryUseCase>(),
      )..loadHistory(),
      child: const HistoryDetailView(),
    );
  }
}
```

---

## ✅ ViewModel 의존성 주입 패턴

```dart
class HistoryViewModel extends ChangeNotifier {
  final GetHistoriesUseCase _getHistoriesUseCase;
  final GetHistoriesByMonthUseCase _getHistoriesByMonthUseCase;
  final AddHistoryUseCase _addHistoryUseCase;
  final UpdateHistoryUseCase _updateHistoryUseCase;
  final DeleteHistoryUseCase _deleteHistoryUseCase;

  HistoryViewModel({
    required GetHistoriesUseCase getHistoriesUseCase,
    required GetHistoriesByMonthUseCase getHistoriesByMonthUseCase,
    required AddHistoryUseCase addHistoryUseCase,
    required UpdateHistoryUseCase updateHistoryUseCase,
    required DeleteHistoryUseCase deleteHistoryUseCase,
  }) : _getHistoriesUseCase = getHistoriesUseCase,
       _getHistoriesByMonthUseCase = getHistoriesByMonthUseCase,
       _addHistoryUseCase = addHistoryUseCase,
       _updateHistoryUseCase = updateHistoryUseCase,
       _deleteHistoryUseCase = deleteHistoryUseCase;

  // 상태 관리 로직...
  
  Future<void> loadHistories() async {
    final result = await _getHistoriesUseCase();
    // Result 처리...
  }

  Future<void> addHistory(History history) async {
    final result = await _addHistoryUseCase(history);
    // Result 처리...
  }
}
```

---

## ✅ UseCase 의존성 주입 패턴

```dart
class GetHistoriesUseCase {
  final HistoryRepository _repository;

  GetHistoriesUseCase({
    required HistoryRepository repository,
  }) : _repository = repository;

  Future<Result<List<History>>> call() async {
    return await _repository.getHistories();
  }
}
```

---

## ✅ Repository 의존성 주입 패턴

```dart
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDataSource _dataSource;

  HistoryRepositoryImpl({
    required HistoryDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<List<History>>> getHistories() async {
    try {
      final historyDtos = await _dataSource.getHistories();
      final histories = historyDtos.toModelList();
      return Success(histories);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }
}
```

---

## 🔄 Provider 생명주기 관리

### Provider 타입별 생명주기

| Provider 타입 | 생명주기 | 사용 사례 |
|--------------|---------|-----------|
| **Provider** (전역) | 앱 생명주기 동안 유지 | Repository, UseCase, Service |
| **ChangeNotifierProvider** (Screen) | 화면 생명주기와 연동 | ViewModel |
| **Consumer** | 위젯 리빌드 시 호출 | 상태 구독 |
| **Selector** | 선택된 상태 변경 시만 호출 | 성능 최적화 |

### 메모리 관리 고려사항

```dart
// ✅ 좋은 예: 전역에서 Repository, UseCase 관리
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 전역 의존성들
        Provider<HistoryRepository>(...),
        Provider<GetHistoriesUseCase>(...),
      ],
      child: MaterialApp(...),
    );
  }
}

// ✅ 좋은 예: Screen에서 ViewModel만 관리
class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HistoryViewModel(
        getHistoriesUseCase: context.read<GetHistoriesUseCase>(),
      ),
      child: HistoryView(),
    );
  }
}

// ❌ 나쁜 예: Screen에서 Repository까지 생성
class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => HistoryRepositoryImpl(...)), // 중복 생성
        ChangeNotifierProvider(create: (context) => HistoryViewModel(...)),
      ],
      child: HistoryView(),
    );
  }
}
```

---

## 🧪 테스트 전략

### Provider Override를 이용한 테스트

```dart
testWidgets('HistoryScreen 위젯 테스트', (WidgetTester tester) async {
  // Mock 객체들
  final mockRepository = MockHistoryRepository();
  final mockUseCase = MockGetHistoriesUseCase();
  
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<HistoryRepository>.value(value: mockRepository),
        Provider<GetHistoriesUseCase>.value(value: mockUseCase),
      ],
      child: MaterialApp(
        home: HistoryScreen(),
      ),
    ),
  );

  // 테스트 로직...
});
```

### ViewModel 단위 테스트

```dart
group('HistoryViewModel 테스트', () {
  late HistoryViewModel viewModel;
  late MockGetHistoriesUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetHistoriesUseCase();
    viewModel = HistoryViewModel(
      getHistoriesUseCase: mockUseCase,
      // 다른 UseCase들...
    );
  });

  test('loadHistories 성공 시 상태 업데이트', () async {
    // Given
    final histories = [History(...)];
    when(() => mockUseCase()).thenAnswer((_) async => Success(histories));

    // When
    await viewModel.loadHistories();

    // Then
    expect(viewModel.histories, equals(histories));
    expect(viewModel.isLoading, false);
    expect(viewModel.hasError, false);
  });
});
```

---

## 📋 의존성 주입 흐름

```
main.dart (MultiProvider)
    ↓
전역 Provider 등록 (DataSource, Repository, UseCase)
    ↓
Screen (ChangeNotifierProvider)
    ↓
ViewModel 생성 및 의존성 주입 (context.read<UseCase>())
    ↓
UI (Consumer/Selector)
    ↓
상태 구독 및 UI 업데이트
```

---

## ✅ Best Practices

### 1. Provider 설정
- **전역**: DataSource, Repository, UseCase (main.dart)
- **지역**: ViewModel (Screen별 ChangeNotifierProvider)
- **접근**: read() vs watch() vs Consumer 적절히 선택

### 2. 의존성 관리
- **단방향 의존성**: 상위 → 하위로만 의존
- **인터페이스 활용**: 구현체가 아닌 인터페이스에 의존
- **생명주기 고려**: Provider가 객체 생명주기 자동 관리

### 3. 성능 고려사항
- **Selector 활용**: 필요한 상태만 구독
- **적절한 범위**: Provider를 필요한 곳에만 배치
- **메모리 관리**: 전역 Provider는 신중하게 선택

---

## ✅ 복합 의존성 예시

### 통계 기능 (여러 Repository 의존)

```dart
// main.dart
Provider<GetExpensesByCategoryUseCase>(
  create: (context) => GetExpensesByCategoryUseCase(
    historyRepository: context.read<HistoryRepository>(),
    categoryRepository: context.read<CategoryRepository>(),
  ),
),

// UseCase 구현
class GetExpensesByCategoryUseCase {
  final HistoryRepository _historyRepository;
  final CategoryRepository _categoryRepository;

  GetExpensesByCategoryUseCase({
    required HistoryRepository historyRepository,
    required CategoryRepository categoryRepository,
  }) : _historyRepository = historyRepository,
       _categoryRepository = categoryRepository;

  Future<Result<Map<String, double>>> call() async {
    // 복합 비즈니스 로직
    final historiesResult = await _historyRepository.getHistories();
    final categoriesResult = await _categoryRepository.getCategories();
    
    // 결과 조합 및 처리...
  }
}
```

---

## 📌 최종 요약

- **main.dart**에서 전역 MultiProvider로 DataSource, Repository, UseCase 설정
- **Screen**에서 ChangeNotifierProvider로 ViewModel만 설정
- 의존성 흐름: DataSource → Repository → UseCase → ViewModel
- 전역 Provider는 앱 생명주기, ViewModel Provider는 Screen 생명주기
- 테스트 시 Provider Override 활용
- 성능 최적화를 위해 Selector 패턴 적극 활용

---