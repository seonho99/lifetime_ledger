# 🖥️ Screen 설계 가이드

---

## ✅ 목적

Screen은 **MultiProvider 설정**과 **UI 렌더링**을 담당하는 계층입니다.  
모든 의존성(DataSource, Repository, UseCase, ViewModel)을 Screen 레벨에서 주입하고,  
**Consumer**를 통해 상태를 구독하여 화면을 렌더링하는 역할을 수행합니다.

---

## ✅ 설계 원칙

- Screen은 **MultiProvider 설정**과 **View 분리**로 구성합니다.
- 모든 의존성을 Screen에서 주입합니다 (DataSource → Repository → UseCase → ViewModel).
- View는 항상 **StatelessWidget**으로 작성합니다.
- **Consumer/Selector**를 통해 ViewModel 상태를 구독합니다.
- **context.read<ViewModel>()**로 ViewModel 메서드를 호출합니다.
- 화면은 작은 빌드 함수로 세분화하여 유지보수성과 가독성을 높입니다.
- 모든 상태 분기는 ViewModel의 상태 기반으로 처리합니다.

---

## ✅ 파일 구조 및 위치

- 경로: `lib/features/{기능}/ui/`
- 파일명: `screen.dart`
- 클래스명: `{기능}Screen`, `{기능}View`

예시:  
`HistoryScreen`, `HistoryView`

---

## ✅ Screen 기본 구성 예시

### Screen 클래스 (MultiProvider 설정)

```dart
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
        Provider(
          create: (context) => GetHistoriesUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => AddHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => UpdateHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => DeleteHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => GetHistoriesByMonthUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),

        // ViewModel
        ChangeNotifierProvider(
          create: (context) => HistoryViewModel(
            getHistoriesUseCase: context.read<GetHistoriesUseCase>(),
            addHistoryUseCase: context.read<AddHistoryUseCase>(),
            updateHistoryUseCase: context.read<UpdateHistoryUseCase>(),
            deleteHistoryUseCase: context.read<DeleteHistoryUseCase>(),
            getHistoriesByMonthUseCase: context.read<GetHistoriesByMonthUseCase>(),
          )..loadHistoriesByMonth(DateTime.now().year, DateTime.now().month),
        ),
      ],
      child: const HistoryView(),
    );
  }
}
```

### View 클래스 (순수 UI)

```dart
class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildNavTabs(),
            const SizedBox(height: 16),
            _buildMonthlyTotal(),
            Expanded(
              child: _buildHistoryList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader() {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // 이전 달 버튼
              GestureDetector(
                onTap: () => viewModel.goToPreviousMonth(),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ),

              // 중앙 제목
              Expanded(
                child: Text(
                  viewModel.selectedMonthString,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),

              // 다음 달 버튼
              GestureDetector(
                onTap: () => viewModel.goToNextMonth(),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryList() {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, child) {
        // 에러 상태 처리
        if (viewModel.hasError) {
          return _buildErrorState(viewModel);
        }

        // 로딩 상태 처리
        if (viewModel.isLoading) {
          return _buildLoadingState();
        }

        // 빈 상태 처리
        if (viewModel.histories.isEmpty) {
          return _buildEmptyState();
        }

        // 내역 리스트
        return _buildHistoryItems(viewModel.histories);
      },
    );
  }

  Widget _buildErrorState(HistoryViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage ?? '오류가 발생했습니다',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.retryLastAction(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            '내역이 없습니다',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '새로운 내역을 추가해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: 내역 추가 화면으로 이동
        debugPrint('내역 추가 버튼 클릭');
      },
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add, size: 28),
    );
  }
}
```

---

## ✅ 상태 기반 렌더링

ViewModel의 상태를 기반으로 UI를 분기 처리합니다.

### Consumer 패턴

```dart
Consumer<HistoryViewModel>(
  builder: (context, viewModel, child) {
    // 상태별 UI 분기
    if (viewModel.hasError) {
      return ErrorWidget(message: viewModel.errorMessage!);
    }
    
    if (viewModel.isLoading) {
      return LoadingWidget();
    }
    
    return SuccessWidget(data: viewModel.histories);
  },
)
```

### Selector 패턴 (성능 최적화)

```dart
// 특정 상태만 구독
Selector<HistoryViewModel, bool>(
  selector: (context, viewModel) => viewModel.isLoading,
  builder: (context, isLoading, child) {
    return isLoading 
        ? const CircularProgressIndicator()
        : const SizedBox.shrink();
  },
)

// 리스트 길이만 구독
Selector<HistoryViewModel, int>(
  selector: (context, viewModel) => viewModel.histories.length,
  builder: (context, count, child) {
    return Text('총 ${count}개의 내역');
  },
)
```

---

## ✅ _buildXXX 함수 분리 원칙

Screen은 복잡해질 수 있는 화면 구조를 작은 빌드 함수로 세분화하여 유지보수성을 높입니다.

### 세분화 기준
- UI 구조가 2~3단계 이상 중첩될 때
- 반복적인 리스트나 카드 뷰를 그릴 때
- 조건 분기가 필요한 상태를 표시할 때
- Consumer가 필요한 위젯 그룹

### 작성 규칙
- `_buildHeader()`, `_buildList()`, `_buildBody()`처럼 목적에 맞게 명확히 함수명을 작성합니다.
- 하나의 _buildXXX 함수는 하나의 역할만 수행합니다.
- _buildXXX 함수에서는 Consumer로 ViewModel 상태에 접근합니다.
- ViewModel 메서드 호출은 `context.read<ViewModel>()`을 사용합니다.

### 예시

```dart
Widget _buildMonthlyTotal() {
  return Consumer<HistoryViewModel>(
    builder: (context, viewModel, child) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Text(
          '${viewModel.selectedMonthString} 총 지출: ₩${viewModel.totalExpense.toStringAsFixed(0)}',
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      );
    },
  );
}

Widget _buildNavTabs() {
  final tabNames = ['내역', '소비', '달력', '설정', '통계'];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        for (int i = 0; i < tabNames.length; i++)
          _buildNavTab(tabNames[i], i == 0), // 현재는 '내역' 탭만 활성화
      ],
    ),
  );
}
```

---

## ✅ 파라미터가 있는 Screen

### URL 파라미터 처리

```dart
class HistoryDetailScreen extends StatelessWidget {
  final String historyId;
  
  const HistoryDetailScreen({
    super.key,
    required this.historyId,
  });

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
        Provider(
          create: (context) => GetHistoryByIdUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => UpdateHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),
        Provider(
          create: (context) => DeleteHistoryUseCase(
            repository: context.read<HistoryRepository>(),
          ),
        ),

        // ViewModel
        ChangeNotifierProvider(
          create: (context) => HistoryDetailViewModel(
            historyId: historyId,
            getHistoryByIdUseCase: context.read<GetHistoryByIdUseCase>(),
            updateHistoryUseCase: context.read<UpdateHistoryUseCase>(),
            deleteHistoryUseCase: context.read<DeleteHistoryUseCase>(),
          )..loadHistory(),
        ),
      ],
      child: const HistoryDetailView(),
    );
  }
}
```

---

## ✅ 의존성 주입 패턴

### DataSource → Repository → UseCase → ViewModel 순서

```dart
MultiProvider(
  providers: [
    // 1. DataSource (가장 하위 레벨)
    Provider(
      create: (context) => HistoryFirebaseDataSourceImpl(
        firestore: FirebaseFirestore.instance,
      ),
    ),

    // 2. Repository (DataSource 의존)
    Provider<HistoryRepository>(
      create: (context) => HistoryRepositoryImpl(
        dataSource: context.read<HistoryFirebaseDataSourceImpl>(),
      ),
    ),

    // 3. UseCases (Repository 의존)
    Provider(
      create: (context) => GetHistoriesUseCase(
        repository: context.read<HistoryRepository>(),
      ),
    ),
    Provider(
      create: (context) => AddHistoryUseCase(
        repository: context.read<HistoryRepository>(),
      ),
    ),

    // 4. ViewModel (UseCase 의존 + 초기 데이터 로드)
    ChangeNotifierProvider(
      create: (context) => HistoryViewModel(
        getHistoriesUseCase: context.read<GetHistoriesUseCase>(),
        addHistoryUseCase: context.read<AddHistoryUseCase>(),
      )..loadHistoriesByMonth(DateTime.now().year, DateTime.now().month),
    ),
  ],
  child: const HistoryView(),
)
```

---

## ✅ 책임 분리 요약

| 계층 | 책임 |
|:---|:---|
| **Screen** | MultiProvider 설정, 모든 의존성 주입 |
| **View** | Consumer로 상태 구독, UI 렌더링, ViewModel 메서드 호출 |
| **ViewModel** | 상태 관리, UseCase 호출, 비즈니스 로직 실행 |

---

## ✅ 장점

### 1. **명확한 의존성 관리**
- 모든 의존성이 Screen에서 한눈에 보임
- 의존성 흐름이 명확함 (DataSource → Repository → UseCase → ViewModel)

### 2. **테스트 용이성**
- Screen 단위로 모든 의존성을 Mock으로 교체 가능
- 각 레이어별 독립적 테스트 가능

### 3. **재사용성**
- Screen별로 필요한 의존성만 주입
- 다른 Screen에서 동일한 패턴 재사용

### 4. **확장성**
- 새로운 UseCase나 Repository 추가 시 Screen에서만 수정
- 기능별로 독립적인 의존성 관리

---

## ✅ 테스트 전략

### Widget 테스트

```dart
group('HistoryScreen 위젯 테스트', () {
  testWidgets('로딩 상태에서 CircularProgressIndicator 표시', (tester) async {
    // Given
    final mockViewModel = MockHistoryViewModel();
    when(() => mockViewModel.isLoading).thenReturn(true);
    when(() => mockViewModel.hasError).thenReturn(false);

    // When
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<HistoryViewModel>.value(
          value: mockViewModel,
          child: const HistoryView(),
        ),
      ),
    );

    // Then
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('에러 상태에서 에러 메시지 표시', (tester) async {
    // Given
    final mockViewModel = MockHistoryViewModel();
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.hasError).thenReturn(true);
    when(() => mockViewModel.errorMessage).thenReturn('네트워크 오류');

    // When
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<HistoryViewModel>.value(
          value: mockViewModel,
          child: const HistoryView(),
        ),
      ),
    );

    // Then
    expect(find.text('네트워크 오류'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
});
```

---

## 📌 최종 요약

- Screen은 MultiProvider 설정을 담당하여 모든 의존성을 주입합니다.
- View는 StatelessWidget으로 작성하고 Consumer로 상태를 구독합니다.
- ViewModel 메서드 호출은 `context.read<ViewModel>()`을 사용합니다.
- 화면 요소는 _buildXXX() 함수로 작은 단위로 나눕니다.
- Selector를 활용하여 성능을 최적화합니다.
- 상태별 UI 분기는 ViewModel의 상태 속성을 기반으로 합니다.
- 의존성 흐름은 DataSource → Repository → UseCase → ViewModel 순서로 진행됩니다.

---