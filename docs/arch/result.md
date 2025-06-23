# 🎯 Result 패턴 설계 가이드

---

## ✅ 목적

Repository 계층에서 발생하는 성공/실패 응답을 예외 없이 흐름으로 처리하기 위해  
Result 패턴을 사용한다. 이를 통해 도메인 계층에서 예외를 래핑하고,  
ViewModel은 흐름만 받아 상태를 구성한다. 테스트성과 추적성이 향상되고  
상태 기반 UI 연동이 자연스럽게 이어진다.

---

## ✅ 설계 원칙

- Repository는 항상 `Result<T>`를 반환한다.
- Result는 `Success<T>`와 `Error(Failure)` 두 가지 형태를 갖는 sealed class이다.
- 예외를 직접 throw하지 않고, `Failure`로 포장한 후 `Result.error()`로 감싼다.
- ViewModel은 Result를 직접 처리하여 State 객체를 업데이트하고 notifyListeners()를 호출한다.
- DataSource는 외부 호출 중 발생하는 Exception을 throw하고,  
  Repository는 이를 catch하여 Result로 변환한다.
- **FailureMapper**를 통해 일관된 예외 처리 및 타입 확인을 수행한다.

---

## ✅ 흐름 구조 요약

```text
DataSource      → throws Exception
Repository      → try-catch → FailureMapper → Result<T> (Failure 포함)
UseCase         → Result<T> 그대로 반환
ViewModel       → Result.when() 처리 → State 업데이트 → notifyListeners()
UI              → Consumer로 상태 구독 → 상태별 UI 렌더링
```

---

## ✅ Result 클래스 정의

```dart
/// 비동기 작업의 성공/실패를 타입 안전하게 처리하기 위한 Result 패턴
sealed class Result<T> {
  const Result();
}

/// 성공 결과
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

/// 실패 결과
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Error<T> && other.failure == failure;
  }

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Error(failure: $failure)';
}
```

---

## ✅ Result 확장 메서드

```dart
/// Result 패턴 확장 메서드
extension ResultExtension<T> on Result<T> {
  /// when 패턴 - 성공/실패에 따른 처리
  void when({
    required Function(T data) success,
    required Function(Failure failure) error,
  }) {
    switch (this) {
      case Success<T> successResult:
        success(successResult.data);
      case Error<T> errorResult:
        error(errorResult.failure);
    }
  }

  /// fold 패턴 - 성공/실패를 다른 타입으로 변환
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    switch (this) {
      case Success<T> successResult:
        return onSuccess(successResult.data);
      case Error<T> errorResult:
        return onError(errorResult.failure);
    }
  }

  /// 성공 여부 확인
  bool get isSuccess => this is Success<T>;

  /// 실패 여부 확인
  bool get isError => this is Error<T>;

  /// 성공 시 데이터 반환, 실패 시 null
  T? get dataOrNull {
    switch (this) {
      case Success<T> successResult:
        return successResult.data;
      case Error<T>():
        return null;
    }
  }

  /// 실패 시 Failure 반환, 성공 시 null
  Failure? get failureOrNull {
    switch (this) {
      case Success<T>():
        return null;
      case Error<T> errorResult:
        return errorResult.failure;
    }
  }

  /// 데이터 변환 (성공인 경우에만)
  Result<R> map<R>(R Function(T data) transform) {
    switch (this) {
      case Success<T> successResult:
        try {
          return Success(transform(successResult.data));
        } catch (e) {
          return Error(UnknownFailure('Transformation failed: $e'));
        }
      case Error<T> errorResult:
        return Error(errorResult.failure);
    }
  }

  /// 성공인 경우에만 추가 작업 수행
  Result<T> onSuccess(void Function(T data) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }

  /// 실패인 경우에만 추가 작업 수행
  Result<T> onError(void Function(Failure failure) action) {
    if (this is Error<T>) {
      action((this as Error<T>).failure);
    }
    return this;
  }
}
```

---

## ✅ Failure 클래스 정의

```dart
/// Failure 추상 클래스
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'Failure(message: $message)';
}

/// 서버 에러
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);

  @override
  String toString() => 'ServerFailure(message: $message)';
}

/// 네트워크 에러
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);

  @override
  String toString() => 'NetworkFailure(message: $message)';
}

/// 캐시 에러
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);

  @override
  String toString() => 'CacheFailure(message: $message)';
}

/// 검증 에러
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);

  @override
  String toString() => 'ValidationFailure(message: $message)';
}

/// 권한 에러
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(String message) : super(message);

  @override
  String toString() => 'UnauthorizedFailure(message: $message)';
}

/// Firebase 에러
class FirebaseFailure extends Failure {
  const FirebaseFailure(String message) : super(message);

  @override
  String toString() => 'FirebaseFailure(message: $message)';
}

/// 알 수 없는 오류
class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);

  @override
  String toString() => 'UnknownFailure(message: $message)';
}
```

---

## ✅ Exception 클래스 정의

```dart
/// 앱에서 사용하는 커스텀 예외들
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => 'AppException(message: $message)';
}

/// 네트워크 예외
class NetworkException extends AppException {
  const NetworkException(String message) : super(message);

  @override
  String toString() => 'NetworkException(message: $message)';
}

/// 서버 예외
class ServerException extends AppException {
  const ServerException(String message) : super(message);

  @override
  String toString() => 'ServerException(message: $message)';
}

/// 캐시 예외
class CacheException extends AppException {
  const CacheException(String message) : super(message);

  @override
  String toString() => 'CacheException(message: $message)';
}

/// 검증 예외
class ValidationException extends AppException {
  const ValidationException(String message) : super(message);

  @override
  String toString() => 'ValidationException(message: $message)';
}

/// 권한 예외
class UnauthorizedException extends AppException {
  const UnauthorizedException(String message) : super(message);

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}
```

---

## ✅ FailureMapper 활용

```dart
/// Exception을 Failure로 매핑하는 유틸리티
class FailureMapper {
  FailureMapper._(); // 인스턴스 생성 방지

  /// Exception을 Failure로 변환
  static Failure mapExceptionToFailure(Object error, [StackTrace? stackTrace]) {
    // 디버그 모드에서만 상세 로깅
    if (kDebugMode) {
      debugPrint('❌ Exception occurred: $error');
      if (stackTrace != null) {
        debugPrintStack(label: 'Exception StackTrace', stackTrace: stackTrace);
      }
    }

    // 커스텀 예외들
    if (error is NetworkException) {
      return NetworkFailure(error.message);
    } else if (error is ServerException) {
      return ServerFailure(error.message);
    } else if (error is CacheException) {
      return CacheFailure(error.message);
    } else if (error is ValidationException) {
      return ValidationFailure(error.message);
    } else if (error is UnauthorizedException) {
      return UnauthorizedFailure(error.message);
    }

    // Firebase 예외들
    else if (error is FirebaseException) {
      return _mapFirestoreException(error);
    }

    // 시스템 예외들
    else if (error is TimeoutException) {
      return NetworkFailure('요청 시간이 초과되었습니다');
    } else if (error is SocketException) {
      return NetworkFailure('인터넷 연결을 확인해주세요');
    } else if (error is HttpException) {
      return ServerFailure('서버와의 통신 중 오류가 발생했습니다');
    } else if (error is FormatException) {
      return ServerFailure('데이터 형식 오류입니다');
    } else if (error is ArgumentError) {
      return ValidationFailure(error.message?.toString() ?? '잘못된 입력입니다');
    }

    // 기타 예외
    else {
      return UnknownFailure('알 수 없는 오류가 발생했습니다: ${error.toString()}');
    }
  }

  /// Firestore 예외를 Failure로 매핑
  static Failure _mapFirestoreException(FirebaseException error) {
    final errorCode = error.code;
    final errorMessage = error.message ?? '알 수 없는 Firebase 오류';

    switch (errorCode) {
      case 'permission-denied':
        return UnauthorizedFailure('접근 권한이 없습니다');
      case 'unavailable':
        return NetworkFailure('서비스를 일시적으로 사용할 수 없습니다');
      case 'deadline-exceeded':
        return NetworkFailure('요청 시간이 초과되었습니다');
      case 'not-found':
        return ServerFailure('요청한 데이터를 찾을 수 없습니다');
      case 'already-exists':
        return ValidationFailure('이미 존재하는 데이터입니다');
      case 'unauthenticated':
        return UnauthorizedFailure('인증이 필요합니다');
      default:
        return FirebaseFailure('Firebase 오류: $errorMessage');
    }
  }

  /// 네트워크 관련 오류인지 확인
  static bool isNetworkError(Failure failure) {
    return failure is NetworkFailure;
  }

  /// 권한 관련 오류인지 확인
  static bool isAuthError(Failure failure) {
    return failure is UnauthorizedFailure;
  }

  /// 서버 관련 오류인지 확인
  static bool isServerError(Failure failure) {
    return failure is ServerFailure || failure is FirebaseFailure;
  }

  /// 검증 관련 오류인지 확인
  static bool isValidationError(Failure failure) {
    return failure is ValidationFailure;
  }

  /// 재시도 가능한 오류인지 확인
  static bool isRetryable(Failure failure) {
    return failure is NetworkFailure ||
        failure is ServerFailure ||
        (failure is FirebaseFailure &&
            (failure.message.contains('unavailable') ||
                failure.message.contains('deadline-exceeded')));
  }
}
```

---

## ✅ Repository에서 Result 사용 예시

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

  @override
  Future<Result<History>> getHistoryById(String id) async {
    try {
      // 입력 값 검증
      if (id.trim().isEmpty) {
        return Error(ValidationFailure('내역 ID는 필수입니다'));
      }

      final historyDto = await _dataSource.getHistoryById(id);
      final history = historyDto.toModel();

      if (history == null) {
        return Error(ServerFailure('내역 데이터를 변환할 수 없습니다'));
      }

      return Success(history);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> addHistory(History history) async {
    try {
      // 비즈니스 규칙 검증
      if (!history.isValid) {
        return Error(ValidationFailure('유효하지 않은 내역 정보입니다'));
      }

      final historyDto = history.toDto();
      await _dataSource.addHistory(historyDto);

      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }
}
```

---

## ✅ UseCase에서 Result 처리

```dart
class GetHistoriesUseCase {
  final HistoryRepository _repository;

  GetHistoriesUseCase({required HistoryRepository repository})
      : _repository = repository;

  Future<Result<List<History>>> call() async {
    return await _repository.getHistories();
  }
}

class AddHistoryUseCase {
  final HistoryRepository _repository;

  AddHistoryUseCase({required HistoryRepository repository})
      : _repository = repository;

  Future<Result<void>> call(History history) async {
    // 비즈니스 규칙 검증
    if (!history.isValid) {
      return Error(ValidationFailure('유효하지 않은 내역 정보입니다'));
    }

    return await _repository.addHistory(history);
  }
}
```

---

## ✅ ViewModel에서 Result 처리 (실제 패턴)

```dart
class HistoryViewModel extends ChangeNotifier {
  final GetHistoriesUseCase _getHistoriesUseCase;
  final AddHistoryUseCase _addHistoryUseCase;

  HistoryViewModel({
    required GetHistoriesUseCase getHistoriesUseCase,
    required AddHistoryUseCase addHistoryUseCase,
  }) : _getHistoriesUseCase = getHistoriesUseCase,
       _addHistoryUseCase = addHistoryUseCase;

  HistoryState _state = HistoryState.initial();
  HistoryState get state => _state;

  List<History> get histories => _state.histories;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  String? get errorMessage => _state.errorMessage;

  void _updateState(HistoryState newState) {
    _state = newState;
    notifyListeners();
  }

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

  /// FailureMapper를 활용한 에러 메시지 생성
  String _getErrorMessage(Failure failure) {
    if (FailureMapper.isNetworkError(failure)) {
      return '인터넷 연결을 확인해주세요.';
    } else if (FailureMapper.isServerError(failure)) {
      return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    } else if (FailureMapper.isValidationError(failure)) {
      return failure.message;
    } else if (FailureMapper.isAuthError(failure)) {
      return '로그인이 필요합니다.';
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

---

## ✅ UI에서 Result 기반 상태 처리

```dart
class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내역')),
      body: Consumer<HistoryViewModel>(
        builder: (context, viewModel, child) {
          // 에러 상태 처리
          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => viewModel.clearError(),
                        child: const Text('닫기'),
                      ),
                      ElevatedButton(
                        onPressed: () => viewModel.retryLastAction(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          // 로딩 상태 처리
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 성공 상태 처리
          return ListView.builder(
            itemCount: viewModel.histories.length,
            itemBuilder: (context, index) {
              return HistoryCard(
                history: viewModel.histories[index],
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## ✅ 테스트에서 Result 패턴 활용

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

  test('loadHistories 네트워크 에러 시 적절한 메시지 표시', () async {
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

  test('FailureMapper를 통한 에러 타입 분류 테스트', () {
    // Given
    final networkFailure = NetworkFailure('네트워크 오류');
    final serverFailure = ServerFailure('서버 오류');
    final validationFailure = ValidationFailure('검증 오류');

    // When & Then
    expect(FailureMapper.isNetworkError(networkFailure), true);
    expect(FailureMapper.isServerError(serverFailure), true);
    expect(FailureMapper.isValidationError(validationFailure), true);
    expect(FailureMapper.isRetryable(networkFailure), true);
  });
});
```

---

## ✅ 흐름 요약

| 단계       | 처리 방식                          |
|------------|-----------------------------------|
| DataSource | Exception throw                   |
| Repository | try-catch → FailureMapper → `Result<T>` |
| UseCase    | `Result<T>` 그대로 반환           |
| ViewModel  | `Result.when()` 처리 → FailureMapper 활용 → State 업데이트 → notifyListeners() |
| UI         | Consumer로 상태 구독 → 상태별 UI 렌더링 |

---

## ✅ FailureMapper 활용의 장점

1. **일관된 예외 처리**: 모든 Exception을 표준화된 Failure로 변환
2. **타입 안전성**: Failure 타입별 처리 로직 분리
3. **사용자 친화적 메시지**: 기술적 오류를 사용자가 이해할 수 있는 메시지로 변환
4. **재시도 로직**: 재시도 가능한 오류 자동 판별
5. **디버깅 효율성**: 개발 모드에서 상세한 로그 제공

---