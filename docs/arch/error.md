# 🚨 예외 처리 및 Failure 설계 가이드

---

## ✅ 목적

데이터 계층에서 발생하는 다양한 예외를 일관된 방식으로 다루기 위해,  
`Failure` 클래스 기반의 예외 포장 전략을 사용한다.  
이 방식은 앱 전체에 통일된 에러 핸들링 구조를 제공하며,  
테스트 가능성, 디버깅 효율, 사용자 경험 모두를 향상시킨다.

---

## ✅ 설계 원칙

- **DataSource**는 외부 호출 중 발생한 예외를 그대로 throw 한다.
- **Repository**는 모든 예외를 `Failure`로 변환한 뒤, `Result.error(Failure)`로 감싼다.
- **UseCase**는 `Result`를 그대로 반환한다.
- **ViewModel**은 `Result`를 받아 상태를 업데이트하고 `notifyListeners()`를 호출한다.
- 모든 예외는 **하나의 Failure 객체로 통합**되며, 타입, 메시지, 원인(cause)을 포함한다.

---

## ✅ 예외 → Failure 흐름 구조

```
DataSource        → throw Exception
Repository        → try-catch → Result.error(Failure)
UseCase           → Result 그대로 반환
ViewModel         → Result.when() → State 업데이트 → notifyListeners()
UI                → Consumer → 에러 메시지 표시
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
```

---

## ✅ 커스텀 예외 클래스들

```dart
/// 앱에서 사용하는 커스텀 예외들
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}

class ServerException extends AppException {
  const ServerException(String message) : super(message);
}

class CacheException extends AppException {
  const CacheException(String message) : super(message);
}

class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(String message) : super(message);
}
```

---

## ✅ 예외 매핑 유틸 (`FailureMapper`)

```dart
/// Exception을 Failure로 매핑하는 유틸리티
class FailureMapper {
  static Failure mapExceptionToFailure(Object error, [StackTrace? stackTrace]) {
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
    
    // 시스템 예외들
    else if (error is TimeoutException) {
      return NetworkFailure('요청 시간이 초과되었습니다');
    } else if (error is FormatException) {
      return ServerFailure('데이터 형식 오류입니다');
    } else if (error.toString().contains('SocketException')) {
      return NetworkFailure('인터넷 연결을 확인해주세요');
    } else if (error.toString().contains('HttpException')) {
      return ServerFailure('서버와의 통신 중 오류가 발생했습니다');
    }
    
    // 기타 예외
    else {
      return ServerFailure('알 수 없는 오류가 발생했습니다: ${error.toString()}');
    }
  }
}
```

---

## ✅ Repository 내 사용 예시

```dart
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;
  final TransactionLocalDataSource _localDataSource;

  TransactionRepositoryImpl({
    required TransactionRemoteDataSource remoteDataSource,
    required TransactionLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Result<List<Transaction>>> getTransactions() async {
    try {
      final transactionDtos = await _remoteDataSource.getTransactions();
      final transactions = transactionDtos
          .map((dto) => TransactionMapper.toEntity(dto))
          .toList();
      
      return Success(transactions);
    } catch (e, stackTrace) {
      // 디버그 로깅
      _logError('getTransactions', e, stackTrace);
      
      // Failure로 변환
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> addTransaction(Transaction transaction) async {
    try {
      final dto = TransactionMapper.toDto(transaction);
      await _remoteDataSource.addTransaction(dto);
      
      return Success(null);
    } catch (e, stackTrace) {
      _logError('addTransaction', e, stackTrace);
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    debugPrint('❌ TransactionRepository.$method Error: $error');
    debugPrintStack(label: 'TransactionRepository Error', stackTrace: stackTrace);
    
    // 개발 모드에서만 assert
    assert(false, '처리되지 않은 예외 in $method: $error');
  }
}
```

---

## ✅ ViewModel에서 에러 처리

```dart
class TransactionViewModel extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;

  TransactionViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase;

  TransactionState _state = TransactionState.initial();
  TransactionState get state => _state;

  List<Transaction> get transactions => _state.transactions;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.errorMessage != null;
  String? get errorMessage => _state.errorMessage;

  void _updateState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await _getTransactionsUseCase();
    
    result.when(
      success: (transactions) {
        _updateState(_state.copyWith(
          transactions: transactions,
          isLoading: false,
          errorMessage: null,
        ));
      },
      error: (failure) {
        _handleError(failure);
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  /// 에러 타입별 상세 처리
  void _handleError(Failure failure) {
    // 에러 로깅
    debugPrint('❌ TransactionViewModel Error: $failure');
    
    // 에러 타입별 추가 처리
    switch (failure.runtimeType) {
      case NetworkFailure:
        // 네트워크 에러 시 특별한 처리 (예: 오프라인 모드 활성화)
        break;
      case UnauthorizedFailure:
        // 인증 에러 시 로그아웃 처리
        _handleUnauthorized();
        break;
      case ServerFailure:
        // 서버 에러 시 에러 리포팅
        _reportServerError(failure);
        break;
    }
  }

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return '인터넷 연결을 확인해주세요.';
      case ServerFailure:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case ValidationFailure:
        return failure.message;
      case UnauthorizedFailure:
        return '로그인이 필요합니다.';
      case CacheFailure:
        return '로컬 데이터 접근에 실패했습니다.';
      default:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }

  void _handleUnauthorized() {
    // 로그아웃 처리 로직
    debugPrint('🔒 Unauthorized - 로그아웃 처리');
  }

  void _reportServerError(Failure failure) {
    // 에러 리포팅 (Crashlytics 등)
    debugPrint('📊 Server Error Report: $failure');
  }

  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }

  void retryLastAction() {
    clearError();
    loadTransactions();
  }
}
```

---

## ✅ 에러 처리 Mixin (공통 로직)

```dart
mixin ErrorHandlerMixin on ChangeNotifier {
  String? _errorMessage;

  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  void handleError(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        _setError('인터넷 연결을 확인해주세요.');
        break;
      case ServerFailure:
        _setError('서버 오류가 발생했습니다.');
        break;
      case ValidationFailure:
        _setError(failure.message);
        break;
      case UnauthorizedFailure:
        _setError('로그인이 필요합니다.');
        break;
      default:
        _setError('알 수 없는 오류가 발생했습니다.');
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// 사용 예시
class TransactionViewModel extends ChangeNotifier with ErrorHandlerMixin {
  // ... 다른 코드

  Future<void> loadTransactions() async {
    final result = await _getTransactionsUseCase();

    result.when(
      success: (transactions) => _transactions = transactions,
      error: (failure) => handleError(failure), // Mixin 사용
    );
  }
}
```

---

## ✅ UI 처리 예시 (Consumer 기반)

```dart
class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(
        getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
      )..loadTransactions(),
      child: Scaffold(
        appBar: AppBar(title: Text('거래 내역')),
        body: Consumer<TransactionViewModel>(
          builder: (context, viewModel, child) {
            // 에러 상태 처리
            if (viewModel.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => viewModel.clearError(),
                          child: Text('닫기'),
                        ),
                        ElevatedButton(
                          onPressed: () => viewModel.retryLastAction(),
                          child: Text('다시 시도'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            // 로딩 상태 처리
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            // 성공 상태 처리
            return ListView.builder(
              itemCount: viewModel.transactions.length,
              itemBuilder: (context, index) {
                return TransactionCard(
                  transaction: viewModel.transactions[index],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
```

---

## ✅ 글로벌 에러 핸들러

```dart
class GlobalErrorHandler {
  static void handleError(Failure failure) {
    // 에러 로깅
    debugPrint('🌍 Global Error: $failure');

    // 에러 리포팅 (Crashlytics 등)
    // FirebaseCrashlytics.instance.recordError(failure, null);

    // 특정 에러 타입별 전역 처리
    switch (failure.runtimeType) {
      case NetworkFailure:
        _handleNetworkError();
        break;
      case UnauthorizedFailure:
        _handleUnauthorizedError();
        break;
    }
  }

  static void _handleNetworkError() {
    // 네트워크 에러 전역 처리
    debugPrint('🌐 Global Network Error Handler');
  }

  static void _handleUnauthorizedError() {
    // 인증 에러 전역 처리
    debugPrint('🔐 Global Auth Error Handler');
  }
}
```

---

## ✅ 디버깅을 위한 assert 및 로그 전략

```dart
// Repository에서 사용
try {
  // ... 비즈니스 로직
} catch (e, stackTrace) {
  // 디버그 모드에서만 상세 로깅
  if (kDebugMode) {
    debugPrint('❌ Repository Error: $e');
    debugPrintStack(label: 'Repository Error', stackTrace: stackTrace);
    
    // 개발 중에만 assert로 오류 강제 확인
    assert(false, '처리되지 않은 예외: $e');
  }
  
  final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
  return Error(failure);
}
```

---

