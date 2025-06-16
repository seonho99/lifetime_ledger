# 에러 처리

## 에러 처리 전략

### 1. 도메인 레이어 에러
```dart
abstract class DomainException implements Exception {
  final String message;
  const DomainException(this.message);
}

class ValidationException extends DomainException {
  const ValidationException(String message) : super(message);
}

class BusinessRuleException extends DomainException {
  const BusinessRuleException(String message) : super(message);
}
```

### 2. 데이터 레이어 에러
```dart
abstract class DataException implements Exception {
  final String message;
  const DataException(this.message);
}

class NetworkException extends DataException {
  const NetworkException(String message) : super(message);
}

class CacheException extends DataException {
  const CacheException(String message) : super(message);
}

class ServerException extends DataException {
  const ServerException(String message) : super(message);
}
```

### 3. Failure 클래스 (Result 패턴용)
```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
```

## 에러 처리 흐름

### 1. 데이터 소스 레벨
```dart
class RemoteDataSource {
  Future<Result<List<TransactionDto>>> getTransactions() async {
    try {
      final response = await apiClient.get('/transactions');
      final transactions = response.data
          .map<TransactionDto>((json) => TransactionDto.fromJson(json))
          .toList();
      
      return Success(transactions);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return Error(NetworkFailure('연결 시간이 초과되었습니다.'));
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return Error(NetworkFailure('응답 시간이 초과되었습니다.'));
      } else {
        return Error(NetworkFailure('네트워크 오류가 발생했습니다.'));
      }
    } catch (e) {
      return Error(ServerFailure('알 수 없는 오류가 발생했습니다.'));
    }
  }
}
```

### 2. 리포지토리 레벨
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
      final result = await remoteDataSource.getTransactions();
      
      return result.fold(
        onSuccess: (dtos) {
          final transactions = dtos.map((dto) => dto.toEntity()).toList();
          return Success(transactions);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('데이터 처리 중 오류가 발생했습니다.'));
    }
  }
}
```

### 3. 유스케이스 레벨
```dart
class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Result<List<Transaction>>> call() async {
    try {
      return await repository.getTransactions();
    } catch (e) {
      return Error(ServerFailure('거래 내역을 가져오는 중 오류가 발생했습니다.'));
    }
  }
}
```

### 4. ViewModel 레벨 (Provider 패턴)
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
        _handleError(failure);
        _setLoading(false);
      },
    );
  }

  void _handleError(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        _setError('인터넷 연결을 확인해주세요.');
        break;
      case ServerFailure:
        _setError('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
        break;
      case ValidationFailure:
        _setError(failure.message);
        break;
      default:
        _setError('알 수 없는 오류가 발생했습니다.');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void retryLastAction() {
    clearError();
    loadTransactions();
  }
}
```

### 5. UI 레벨에서 에러 처리
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
            return Stack(
              children: [
                // 메인 컨텐츠
                _buildMainContent(viewModel),
                
                // 에러 오버레이
                if (viewModel.hasError)
                  _buildErrorOverlay(context, viewModel),
                
                // 로딩 오버레이
                if (viewModel.isLoading)
                  _buildLoadingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(TransactionViewModel viewModel) {
    if (viewModel.transactions.isEmpty && !viewModel.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('거래 내역이 없습니다.'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.transactions.length,
      itemBuilder: (context, index) {
        return TransactionCard(
          transaction: viewModel.transactions[index],
        );
      },
    );
  }

  Widget _buildErrorOverlay(BuildContext context, TransactionViewModel viewModel) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
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
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('로딩 중...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## 에러 처리 유틸리티

### 공통 에러 처리 Mixin
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
    final result = await getTransactionsUseCase();
    
    result.when(
      success: (transactions) => _transactions = transactions,
      error: (failure) => handleError(failure), // Mixin 사용
    );
  }
}
```

### 글로벌 에러 핸들러
```dart
class GlobalErrorHandler {
  static void handle(Failure failure) {
    // 로깅
    print('Error: ${failure.message}');
    
    // 에러 리포팅 (Crashlytics 등)
    // FirebaseCrashlytics.instance.recordError(failure, null);
    
    // 사용자에게 알림 (필요시)
    if (failure is NetworkFailure) {
      // 네트워크 에러 특별 처리
    }
  }
}
```

## 에러 처리 Best Practices

### 1. 에러 계층화
- **Exception**: 기술적 에러 (네트워크, 파싱 등)
- **Failure**: 비즈니스 에러 (Result 패턴용)
- **UI Error**: 사용자에게 보여줄 에러 메시지

### 2. ViewModel에서 에러 관리
- **상태로 관리**: `_errorMessage`, `hasError`
- **타입별 처리**: NetworkFailure, ServerFailure 등
- **사용자 친화적 메시지**: 기술적 용어 지양

### 3. UI에서 에러 표시
- **오버레이 방식**: 현재 화면 위에 표시
- **인라인 방식**: 해당 위치에 직접 표시
- **스낵바 방식**: 간단한 에러 메시지

### 4. 에러 복구
- **다시 시도**: `retryLastAction()` 메서드
- **에러 해제**: `clearError()` 메서드
- **대안 제시**: 오프라인 모드, 캐시 데이터 등

## 체크리스트

### 에러 정의
- [ ] 각 레이어별 Exception 정의
- [ ] Failure 클래스 구조화
- [ ] 사용자 친화적 메시지 준비

### ViewModel 에러 처리
- [ ] 에러 상태 관리 (errorMessage, hasError)
- [ ] 타입별 에러 처리 로직
- [ ] 에러 해제 및 재시도 메서드

### UI 에러 표시
- [ ] Consumer로 에러 상태 구독
- [ ] 적절한 에러 UI 구성
- [ ] 사용자 액션 제공 (다시 시도, 닫기)

### 성능 및 UX
- [ ] 에러 발생 시 리소스 정리
- [ ] 적절한 로딩 상태 관리
- [ ] 에러 로깅 및 모니터링