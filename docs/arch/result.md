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

---

## ✅ 흐름 구조 요약

```text
DataSource      → throws Exception
Repository      → try-catch → Result<T> (Failure 포함)
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
}

/// 실패 결과
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

/// Result 패턴 확장 메서드
extension ResultExtension<T> on Result<T> {
  void when({
    required Function(T data) success,
    required Function(Failure failure) error,
  }) {
    switch (this) {
      case Success<T> success:
        return success(success.data);
      case Error<T> error:
        return error(error.failure);
    }
  }

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    switch (this) {
      case Success<T> success:
        return onSuccess(success.data);
      case Error<T> error:
        return onError(error.failure);
    }
  }

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;

  T? get dataOrNull {
    switch (this) {
      case Success<T> success:
        return success.data;
      case Error<T>():
        return null;
    }
  }

  Failure? get failureOrNull {
    switch (this) {
      case Success<T>():
        return null;
      case Error<T> error:
        return error.failure;
    }
  }
}
```

---

## ✅ Failure 정의

```dart
/// Failure 추상 클래스
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// 서버 에러
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

/// 네트워크 에러
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// 캐시 에러
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// 검증 에러
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
```

---

## ✅ 예외 → Result 변환 예시 (Repository)

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
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('알 수 없는 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Result<void>> addTransaction(Transaction transaction) async {
    try {
      final dto = TransactionMapper.toDto(transaction);
      await _remoteDataSource.addTransaction(dto);
      return Success(null);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('거래 추가 중 오류가 발생했습니다.'));
    }
  }
}
```

---

## ✅ Exception → Failure 매핑 유틸

```dart
/// 커스텀 예외 클래스들
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

/// Exception을 Failure로 매핑하는 유틸리티
class FailureMapper {
  static Failure mapExceptionToFailure(Object error) {
    if (error is NetworkException) {
      return NetworkFailure(error.message);
    } else if (error is ServerException) {
      return ServerFailure(error.message);
    } else if (error is CacheException) {
      return CacheFailure(error.message);
    } else if (error is FormatException) {
      return ServerFailure('데이터 형식 오류입니다');
    } else if (error.toString().contains('SocketException')) {
      return NetworkFailure('인터넷 연결을 확인해주세요');
    } else {
      return ServerFailure('알 수 없는 오류가 발생했습니다');
    }
  }
}
```

---

## ✅ UseCase에서 Result 처리

```dart
class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase({required TransactionRepository repository})
      : _repository = repository;

  Future<Result<List<Transaction>>> call() async {
    return await _repository.getTransactions();
  }
}
```

---

## ✅ ViewModel에서 Result 처리

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
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return '인터넷 연결을 확인해주세요.';
      case ServerFailure:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case ValidationFailure:
        return failure.message;
      default:
        return '알 수 없는 오류가 발생했습니다.';
    }
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

## ✅ UI (Provider + Consumer)

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
                    Text(viewModel.errorMessage!),
                    ElevatedButton(
                      onPressed: () => viewModel.retryLastAction(),
                      child: Text('다시 시도'),
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

## ✅ 흐름 요약

| 단계       | 처리 방식                          |
|------------|-----------------------------------|
| DataSource | Exception throw                   |
| Repository | try-catch → `Result<T>`           |
| UseCase    | `Result<T>` 그대로 반환           |
| ViewModel  | `Result.when()` 처리 → State 업데이트 → notifyListeners() |
| UI         | Consumer로 상태 구독 → 상태별 UI 렌더링 |

---
