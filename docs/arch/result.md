# Result 패턴

## 개요
Result 패턴은 비동기 작업의 성공/실패를 명확하게 처리하기 위한 패턴입니다.
이 패턴을 통해 에러 처리를 더 명확하고 타입 안전하게 할 수 있습니다.

## Result 클래스 구조
```dart
sealed class Result<T> {
   const Result();
}

class Success<T> extends Result<T> {
   final T data;
   const Success(this.data);
}

class Error<T> extends Result<T> {
   final Failure failure;
   const Error(this.failure);
}
```

## Failure 클래스 구조
```dart
abstract class Failure {
   final String message;
   const Failure(this.message);
}

class ServerFailure extends Failure {
   const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
   const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
   const NetworkFailure(String message) : super(message);
}
```

## 사용 예시

### Repository 레벨
```dart
abstract class TransactionRepository {
   Future<Result<List<Transaction>>> getTransactions();
   Future<Result<void>> addTransaction(Transaction transaction);
}
```

### UseCase 레벨
```dart
class GetTransactionsUseCase {
   final TransactionRepository repository;

   GetTransactionsUseCase(this.repository);

   Future<Result<List<Transaction>>> call() async {
      return await repository.getTransactions();
   }
}
```

### ViewModel 레벨 (Provider 패턴)
```dart
class TransactionViewModel extends ChangeNotifier {
  final GetTransactionsUseCase getTransactionsUseCase;

  TransactionViewModel(this.getTransactionsUseCase);

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> loadTransactions() async {
    _setLoading(true);
    _clearError();
    
    final result = await getTransactionsUseCase();
    
    result.when(
      success: (transactions) {
        _transactions = transactions;
        _setLoading(false);
      },
      error: (failure) {
        _setError(failure.message);
        _setLoading(false);
      },
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
```

### UI 레벨에서 Result 처리
```dart
class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionViewModel(
        context.read<GetTransactionsUseCase>(),
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
                      onPressed: () {
                        viewModel.clearError();
                        viewModel.loadTransactions();
                      },
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

## Result 패턴 확장 메서드
```dart
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

## Repository 구현 예시
```dart
class TransactionRepositoryImpl implements TransactionRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<List<Transaction>>> getTransactions() async {
    try {
      final transactionDtos = await remoteDataSource.getTransactions();
      final transactions = transactionDtos
          .map((dto) => dto.toEntity())
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
      final dto = TransactionDto.fromEntity(transaction);
      await remoteDataSource.addTransaction(dto);
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

## Result 패턴의 장점
1. **타입 안전성**
   - 컴파일 타임에 에러 처리 확인
   - null 안전성 보장

2. **명확한 에러 처리**
   - 에러 타입별 구분
   - 에러 메시지 표준화

3. **코드 가독성**
   - 성공/실패 케이스 명확한 구분
   - 패턴 매칭을 통한 간결한 처리

4. **테스트 용이성**
   - 성공/실패 케이스 테스트 용이
   - 모킹이 간단

## Provider 패턴과의 연동

### ViewModel에서 Result 처리 패턴
```dart
Future<void> performAction() async {
  _setLoading(true);
  
  final result = await useCase();
  
  result.when(
    success: (data) {
      // 성공 처리
      _updateData(data);
      _setLoading(false);
    },
    error: (failure) {
      // 에러 처리
      _setError(failure.message);
      _setLoading(false);
    },
  );
}
```

### UI에서 상태별 처리
```dart
Consumer<ViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.hasError) {
      return ErrorWidget(message: viewModel.errorMessage!);
    }
    
    if (viewModel.isLoading) {
      return LoadingWidget();
    }
    
    return SuccessWidget(data: viewModel.data);
  },
)
```

## Best Practices
1. 모든 비동기 작업에 Result 패턴 적용
2. 구체적인 Failure 타입 정의
3. 에러 메시지의 일관성 유지
4. Result 처리 시 when 메서드 사용
5. ViewModel에서 적절한 상태 관리
6. UI에서 명확한 상태별 처리