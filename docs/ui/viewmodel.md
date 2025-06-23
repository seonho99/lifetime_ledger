# 🧩 ViewModel 설계 가이드

---

## ✅ 목적

ViewModel은 앱의 상태를 보존하고, 사용자 액션을 처리하는  
**상태 관리 계층**입니다.

이 프로젝트에서는 **ChangeNotifier**를 기반으로  
모든 화면의 상태를 일관성 있게 관리하며,  
**Provider 패턴**을 통해 UI와 연결됩니다.

---

## 📚 MVVM 아키텍처에서의 역할

- **Model**: Entity, UseCase, Repository
- **View**: Screen, Widget
- **ViewModel**: 상태 관리, UseCase 호출, UI 로직 처리

ViewModel은 View와 Model 사이의 중재자 역할을 수행하며,  
UI 상태 관리와 비즈니스 로직 실행을 담당합니다.

---

# ⚙️ 기본 구조 예시

```dart
class HistoryViewModel extends ChangeNotifier {
  final GetHistoriesUseCase _getHistoriesUseCase;
  final AddHistoryUseCase _addHistoryUseCase;
  final UpdateHistoryUseCase _updateHistoryUseCase;
  final DeleteHistoryUseCase _deleteHistoryUseCase;

  HistoryViewModel({
    required GetHistoriesUseCase getHistoriesUseCase,
    required AddHistoryUseCase addHistoryUseCase,
    required UpdateHistoryUseCase updateHistoryUseCase,
    required DeleteHistoryUseCase deleteHistoryUseCase,
  }) : _getHistoriesUseCase = getHistoriesUseCase,
        _addHistoryUseCase = addHistoryUseCase,
        _updateHistoryUseCase = updateHistoryUseCase,
        _deleteHistoryUseCase = deleteHistoryUseCase;

  // 상태 관리
  HistoryState _state = HistoryState.initial();
  HistoryState get state => _state;

  // 편의 Getters
  List<History> get histories => _state.histories;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.errorMessage != null;
  String? get errorMessage => _state.errorMessage;

  // 상태 업데이트
  void _updateState(HistoryState newState) {
    _state = newState;
    notifyListeners();
  }

  // 비즈니스 메서드 - Result.when() 패턴 사용
  Future<void> loadHistories() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    final result = await _getHistoriesUseCase();

    result.when(
      success: (histories) {
        _updateState(_state.copyWith(
          histories: histories,
          isLoading: false,
          errorMessage: null,
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  Future<void> addHistory(History history) async {
    final result = await _addHistoryUseCase(history);

    result.when(
      success: (_) {
        // 성공 시 목록 새로고침
        loadHistories();
      },
      error: (failure) {
        _updateState(_state.copyWith(errorMessage: _getErrorMessage(failure)));
      },
    );
  }

  String _getErrorMessage(Failure failure) {
    // FailureMapper 타입 확인 메서드 활용
    if (FailureMapper.isNetworkError(failure)) {
      return '인터넷 연결을 확인해주세요.';
    } else if (FailureMapper.isServerError(failure)) {
      return '서버 오류가 발생했습니다.';
    } else if (FailureMapper.isValidationError(failure)) {
      return failure.message;
    } else {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }

  void retryLastAction() {
    clearError();
    loadHistories();
  }
}
```

✅ `ChangeNotifier`를 상속하여 상태 변경을 UI에 알립니다.  
✅ 생성자에서 UseCase들을 주입받습니다.  
✅ 데이터 호출은 반드시 UseCase를 통해 수행합니다.  
✅ **Result.when() 패턴**으로 성공/실패를 명확히 처리합니다.

---

# 🏗️ 파일 구조 및 명명 규칙

```text
lib/
└── features/
    └── history/
        └── ui/
            ├── viewmodel.dart
            └── state.dart
```

| 항목 | 규칙 |
|:---|:---|
| 파일 경로 | `lib/features/{기능}/ui/` |
| 파일명 | `viewmodel.dart` |
| 클래스명 | `{기능}ViewModel` |

---

# 🔥 ViewModel 초기화 패턴

## ✅ 기본 초기화

```dart
class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel({
    required GetHistoriesUseCase getHistoriesUseCase,
  }) : _getHistoriesUseCase = getHistoriesUseCase;

  HistoryState _state = HistoryState.initial();
  
  // 초기 데이터 로드는 Screen에서 호출
  Future<void> initialize() async {
    await loadHistories();
  }
}
```

## ✅ Screen에서 ViewModel 사용

```dart
class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HistoryViewModel(
        getHistoriesUseCase: context.read<GetHistoriesUseCase>(),
        addHistoryUseCase: context.read<AddHistoryUseCase>(),
      )..loadHistories(), // 초기 데이터 로드
      child: const HistoryView(),
    );
  }
}
```

---

# 🧠 State 관리 패턴

## ✅ State 객체 기반 관리

```dart
class HistoryViewModel extends ChangeNotifier {
  HistoryState _state = HistoryState.initial();
  HistoryState get state => _state;

  // 편의 Getters (선택적)
  List<History> get histories => _state.histories;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.errorMessage != null;

  void _updateState(HistoryState newState) {
    _state = newState;
    notifyListeners();
  }
}
```

---

# 👁️ UI에서 ViewModel 사용

## ✅ Consumer 패턴

```dart
class HistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.hasError) {
          return ErrorWidget(message: viewModel.errorMessage!);
        }
        
        if (viewModel.isLoading) {
          return const LoadingWidget();
        }
        
        return HistoryList(histories: viewModel.histories);
      },
    );
  }
}
```

## ✅ Selector 패턴 (성능 최적화)

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

// 복합 상태 구독
Selector<HistoryViewModel, ({int count, double total})>(
  selector: (context, viewModel) => (
    count: viewModel.histories.length,
    total: viewModel.totalAmount,
  ),
  builder: (context, data, child) {
    return Text('${data.count}건, 총 ₩${data.total}');
  },
)
```

---

# 🛠️ 네비게이션 처리

## ✅ NavigationMixin 활용

```dart
mixin NavigationMixin {
  void navigateTo(BuildContext context, String path) {
    context.push(path);
  }

  void navigateBack(BuildContext context) {
    context.pop();
  }

  Future<T?> navigateModal<T>(BuildContext context, String path) {
    return context.push<T>(path);
  }
}

class HistoryViewModel extends ChangeNotifier with NavigationMixin {
  // ... 다른 코드

  void navigateToDetail(BuildContext context, String historyId) {
    navigateTo(context, '/histories/$historyId');
  }

  void navigateToAdd(BuildContext context) {
    navigateTo(context, '/histories/add');
  }

  Future<void> addHistoryAndNavigateBack(
    BuildContext context, 
    History history,
  ) async {
    final result = await _addHistoryUseCase(history);
    
    result.when(
      success: (_) {
        loadHistories();
        navigateBack(context);
      },
      error: (failure) {
        _updateState(_state.copyWith(errorMessage: _getErrorMessage(failure)));
      },
    );
  }
}
```

---

# 🔥 고급 패턴

## ✅ 폼 상태 관리

```dart
class AddHistoryViewModel extends ChangeNotifier {
  final AddHistoryUseCase _addHistoryUseCase;

  AddHistoryViewModel({
    required AddHistoryUseCase addHistoryUseCase,
  }) : _addHistoryUseCase = addHistoryUseCase;

  // 폼 상태
  String _title = '';
  double _amount = 0.0;
  HistoryType _type = HistoryType.expense;
  String? _selectedCategoryId;
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get title => _title;
  double get amount => _amount;
  HistoryType get type => _type;
  String? get selectedCategoryId => _selectedCategoryId;
  DateTime get date => _date;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 폼 유효성 검증
  bool get isValid => 
      _title.trim().isNotEmpty &&
      _amount > 0 &&
      _selectedCategoryId != null;

  // 폼 업데이트 메서드들
  void updateTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void updateAmount(double amount) {
    _amount = amount;
    notifyListeners();
  }

  void updateType(HistoryType type) {
    _type = type;
    notifyListeners();
  }

  void updateCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void updateDate(DateTime date) {
    _date = date;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    if (!isValid) {
      _errorMessage = '모든 필드를 올바르게 입력해주세요.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final history = History(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title,
      amount: _amount,
      type: _type,
      categoryId: _selectedCategoryId!,
      date: _date,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _addHistoryUseCase(history);

    result.when(
      success: (_) {
        _isLoading = false;
        notifyListeners();
        Navigator.pop(context, true); // 성공 결과와 함께 돌아가기
      },
      error: (failure) {
        _isLoading = false;
        _errorMessage = _getErrorMessage(failure);
        notifyListeners();
      },
    );
  }

  String _getErrorMessage(Failure failure) {
    if (FailureMapper.isValidationError(failure)) {
      return failure.message;
    } else if (FailureMapper.isNetworkError(failure)) {
      return '인터넷 연결을 확인해주세요.';
    } else {
      return '저장 중 오류가 발생했습니다.';
    }
  }

  void reset() {
    _title = '';
    _amount = 0.0;
    _type = HistoryType.expense;
    _selectedCategoryId = null;
    _date = DateTime.now();
    _errorMessage = null;
    notifyListeners();
  }
}
```

## ✅ 리스트 관리 (페이지네이션)

```dart
class HistoryListViewModel extends ChangeNotifier {
  final GetHistoriesUseCase _getHistoriesUseCase;

  HistoryListViewModel({
    required GetHistoriesUseCase getHistoriesUseCase,
  }) : _getHistoriesUseCase = getHistoriesUseCase;

  List<History> _histories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;

  // Getters
  List<History> get histories => _histories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistories({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _histories.clear();
    }

    _isLoading = refresh;
    _isLoadingMore = !refresh;
    _errorMessage = null;
    notifyListeners();

    final result = await _getHistoriesUseCase(page: _currentPage);

    result.when(
      success: (newHistories) {
        if (refresh) {
          _histories = newHistories;
        } else {
          _histories.addAll(newHistories);
        }

        _hasMore = newHistories.length >= 20; // 페이지 크기
        _currentPage++;
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      },
      error: (failure) {
        _errorMessage = _getErrorMessage(failure);
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    await loadHistories();
  }

  Future<void> refresh() async {
    await loadHistories(refresh: true);
  }

  String _getErrorMessage(Failure failure) {
    if (FailureMapper.isNetworkError(failure)) {
      return '인터넷 연결을 확인해주세요.';
    } else if (FailureMapper.isServerError(failure)) {
      return '서버 오류가 발생했습니다.';
    } else {
      return '데이터를 불러오는 중 오류가 발생했습니다.';
    }
  }
}
```

---

# 🧪 테스트 전략

```dart
group('HistoryViewModel 테스트', () {
  late HistoryViewModel viewModel;
  late MockGetHistoriesUseCase mockGetHistoriesUseCase;

  setUp(() {
    mockGetHistoriesUseCase = MockGetHistoriesUseCase();
    viewModel = HistoryViewModel(
      getHistoriesUseCase: mockGetHistoriesUseCase,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('초기 상태가 올바르게 설정됨', () {
    expect(viewModel.histories, isEmpty);
    expect(viewModel.isLoading, false);
    expect(viewModel.hasError, false);
  });

  test('loadHistories 성공 시 상태 업데이트', () async {
    // Given
    final histories = [History(...)];
    when(() => mockGetHistoriesUseCase())
        .thenAnswer((_) async => Success(histories));

    // When
    await viewModel.loadHistories();

    // Then
    expect(viewModel.histories, equals(histories));
    expect(viewModel.isLoading, false);
    expect(viewModel.hasError, false);
  });

  test('loadHistories 실패 시 에러 상태 설정', () async {
    // Given
    final failure = NetworkFailure('네트워크 오류');
    when(() => mockGetHistoriesUseCase())
        .thenAnswer((_) async => Error(failure));

    // When
    await viewModel.loadHistories();

    // Then
    expect(viewModel.hasError, true);
    expect(viewModel.errorMessage, '인터넷 연결을 확인해주세요.');
    expect(viewModel.isLoading, false);
  });
});
```

---

# 🧩 책임 구분

| 계층 | 역할 |
|:---|:---|
| **State** | UI에 필요한 최소한의 데이터 구조 (immutable, freezed 사용) |
| **ViewModel** | 상태를 보관하고, UseCase를 호출하여 상태를 변경 |
| **UseCase** | 비즈니스 로직 실행 (Repository 접근 포함) |
| **Screen** | ChangeNotifierProvider 설정, ViewModel 주입 |
| **View** | Consumer로 ViewModel 상태를 구독하고 UI를 렌더링 |

---

# ✅ 문서 요약

- ViewModel은 ChangeNotifier를 상속하여 상태를 관리합니다.
- 생성자에서 UseCase들을 주입받습니다.
- 모든 상태 변경 후 notifyListeners()를 호출합니다.
- **Result.when() 패턴**으로 성공/실패를 명확히 처리합니다.
- Consumer/Selector로 UI에서 상태를 구독합니다.
- 네비게이션은 Mixin을 활용하여 처리합니다.
- 테스트는 상태 변화 중심으로 수행합니다.
- **FailureMapper의 타입 확인 메서드**를 활용하여 에러 메시지를 분류합니다.

---