# 🧩 Repository 설계 가이드

## ✅ 목적

Repository는 DataSource를 통해 외부 데이터를 가져오고,  
앱 내부에서 사용할 수 있도록 도메인 모델로 가공하는 **중간 추상화 계층**입니다.  
UseCase는 Repository를 통해 간접적으로 데이터를 접근하며,  
ViewModel은 UseCase를 통해 비즈니스 로직을 실행합니다.

---

## 🧱 설계 원칙

- 항상 `interface` + `impl` 구조로 분리합니다.
- 내부에서 DataSource를 호출하며, 외부 예외는 `Failure`로 변환합니다.
- 반환 타입은 `Result<T>`로 통일합니다.
- 외부로 노출되는 데이터는 DTO가 아닌 **Entity(Domain Model)** 을 기준으로 처리합니다.
- **Provider 패턴**으로 의존성 주입을 관리합니다.

---

## ✅ 파일 구조 및 위치

```
lib/
└── features/
    └── transaction/
        ├── domain/
        │   └── repositories/
        │       └── transaction_repository.dart           # 인터페이스
        └── data/
            └── repositories/
                └── transaction_repository_impl.dart     # 구현체
```

> 📎 전체 폴더 구조는 [../arch/folder.md](../arch/folder.md)

---

## ✅ 네이밍 및 클래스 구성

### Repository 인터페이스 예시

```dart
/// Transaction Repository 인터페이스
abstract class TransactionRepository {
  Future<Result<List<Transaction>>> getTransactions();
  Future<Result<Transaction>> getTransactionById(String id);
  Future<Result<void>> addTransaction(Transaction transaction);
  Future<Result<void>> updateTransaction(Transaction transaction);
  Future<Result<void>> deleteTransaction(String id);
  
  // 검색 및 필터링
  Future<Result<List<Transaction>>> searchTransactions(String query);
  Future<Result<List<Transaction>>> getTransactionsByCategory(String categoryId);
  Future<Result<List<Transaction>>> getTransactionsByDateRange(
    DateTime startDate, 
    DateTime endDate,
  );
  
  // 통계 관련
  Future<Result<double>> getTotalIncome();
  Future<Result<double>> getTotalExpense();
  Future<Result<Map<String, double>>> getExpensesByCategory();
}
```

### Repository 구현체 예시

```dart
/// Transaction Repository 구현체
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;
  final TransactionLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  TransactionRepositoryImpl({
    required TransactionRemoteDataSource remoteDataSource,
    required TransactionLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Result<List<Transaction>>> getTransactions() async {
    try {
      List<TransactionDto> transactionDtos;
      
      // 네트워크 연결 상태에 따라 데이터 소스 선택
      if (await _networkInfo.isConnected) {
        try {
          transactionDtos = await _remoteDataSource.getTransactions();
          // 성공 시 로컬에 캐싱
          await _localDataSource.cacheTransactions(transactionDtos);
        } catch (e) {
          // Remote 실패 시 Local 데이터 사용
          transactionDtos = await _localDataSource.getTransactions();
        }
      } else {
        // 오프라인 시 Local 데이터만 사용
        transactionDtos = await _localDataSource.getTransactions();
      }
      
      // DTO → Entity 변환
      final transactions = transactionDtos
          .map((dto) => TransactionMapper.toEntity(dto))
          .toList();
      
      return Success(transactions);
    } catch (e, stackTrace) {
      // 예외를 Failure로 변환
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<Transaction>> getTransactionById(String id) async {
    try {
      TransactionDto transactionDto;
      
      if (await _networkInfo.isConnected) {
        try {
          transactionDto = await _remoteDataSource.getTransactionById(id);
        } catch (e) {
          transactionDto = await _localDataSource.getTransactionById(id);
        }
      } else {
        transactionDto = await _localDataSource.getTransactionById(id);
      }
      
      final transaction = TransactionMapper.toEntity(transactionDto);
      return Success(transaction);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> addTransaction(Transaction transaction) async {
    try {
      // Entity → DTO 변환
      final transactionDto = TransactionMapper.toDto(transaction);
      
      // 로컬에 먼저 저장 (오프라인 지원)
      await _localDataSource.addTransaction(transactionDto);
      
      // 네트워크 연결 시 원격 서버에도 저장
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.addTransaction(transactionDto);
        } catch (e) {
          // 원격 저장 실패 시 로그만 남기고 계속 진행
          debugPrint('Remote add failed: $e');
          // TODO: 동기화 큐에 추가하여 나중에 재시도
        }
      }
      
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> updateTransaction(Transaction transaction) async {
    try {
      final transactionDto = TransactionMapper.toDto(transaction);
      
      // 로컬 업데이트
      await _localDataSource.updateTransaction(transactionDto);
      
      // 원격 업데이트
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.updateTransaction(transactionDto);
        } catch (e) {
          debugPrint('Remote update failed: $e');
        }
      }
      
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String id) async {
    try {
      // 로컬 삭제
      await _localDataSource.deleteTransaction(id);
      
      // 원격 삭제
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.deleteTransaction(id);
        } catch (e) {
          debugPrint('Remote delete failed: $e');
        }
      }
      
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<List<Transaction>>> searchTransactions(String query) async {
    try {
      final transactionDtos = await _localDataSource.searchTransactions(query);
      final transactions = transactionDtos
          .map((dto) => TransactionMapper.toEntity(dto))
          .toList();
      
      return Success(transactions);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<List<Transaction>>> getTransactionsByCategory(String categoryId) async {
    try {
      final transactionDtos = await _localDataSource.getTransactionsByCategory(categoryId);
      final transactions = transactionDtos
          .map((dto) => TransactionMapper.toEntity(dto))
          .toList();
      
      return Success(transactions);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<List<Transaction>>> getTransactionsByDateRange(
    DateTime startDate, 
    DateTime endDate,
  ) async {
    try {
      final transactionDtos = await _localDataSource.getTransactionsByDateRange(
        startDate, 
        endDate,
      );
      final transactions = transactionDtos
          .map((dto) => TransactionMapper.toEntity(dto))
          .toList();
      
      return Success(transactions);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<double>> getTotalIncome() async {
    try {
      final total = await _localDataSource.getTotalIncome();
      return Success(total);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<double>> getTotalExpense() async {
    try {
      final total = await _localDataSource.getTotalExpense();
      return Success(total);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<Map<String, double>>> getExpensesByCategory() async {
    try {
      final expenses = await _localDataSource.getExpensesByCategory();
      return Success(expenses);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }
}
```

> 📎 DataSource 구성은 [datasource.md](datasource.md)  
> 📎 Mapper 확장 방식은 [mapper.md](mapper.md)  
> 📎 Entity 정의는 [model.md](model.md)  
> 📎 네이밍 규칙은 [../arch/naming.md](../arch/naming.md)

---

## 📌 책임 구분

| 계층 | 역할 |
|------|------|
| **DataSource** | 외부 호출 + DTO 반환 + 예외 throw |
| **Repository** | 예외 → Failure 변환, DTO → Entity 변환, Result<T> 반환, 오프라인 지원 |
| **UseCase** | Repository 호출 + 비즈니스 로직 실행 |
| **ViewModel** | UseCase 호출 + Result<T> 처리 + State 업데이트 + notifyListeners() |

> 📎 UseCase 흐름은 [usecase.md](usecase.md)

---

## ✅ 예외 처리 전략

### 기본 예외 처리 패턴

```dart
@override
Future<Result<List<Transaction>>> getTransactions() async {
  try {
    // DataSource 호출
    final transactionDtos = await _remoteDataSource.getTransactions();
    
    // DTO → Entity 변환
    final transactions = transactionDtos
        .map((dto) => TransactionMapper.toEntity(dto))
        .toList();
    
    return Success(transactions);
  } catch (e, stackTrace) {
    // 예외를 Failure로 변환
    final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
    return Error(failure);
  }
}
```

### 커스텀 예외 처리

```dart
@override
Future<Result<Transaction>> getTransactionById(String id) async {
  try {
    // 입력 값 검증
    if (id.trim().isEmpty) {
      return Error(ValidationFailure('거래 ID는 필수입니다'));
    }
    
    final transactionDto = await _remoteDataSource.getTransactionById(id);
    final transaction = TransactionMapper.toEntity(transactionDto);
    
    return Success(transaction);
  } on NetworkException catch (e) {
    return Error(NetworkFailure(e.message));
  } on ServerException catch (e) {
    return Error(ServerFailure(e.message));
  } catch (e, stackTrace) {
    final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
    return Error(failure);
  }
}
```

### 복합 데이터 소스 처리

```dart
@override
Future<Result<List<Transaction>>> getTransactions() async {
  try {
    if (await _networkInfo.isConnected) {
      // 온라인: Remote → Local 캐싱
      try {
        final remoteData = await _remoteDataSource.getTransactions();
        await _localDataSource.cacheTransactions(remoteData);
        
        final transactions = remoteData
            .map((dto) => TransactionMapper.toEntity(dto))
            .toList();
        
        return Success(transactions);
      } catch (e) {
        // Remote 실패 시 Local 데이터로 fallback
        debugPrint('Remote failed, using local data: $e');
        final localData = await _localDataSource.getTransactions();
        
        final transactions = localData
            .map((dto) => TransactionMapper.toEntity(dto))
            .toList();
        
        return Success(transactions);
      }
    } else {
      // 오프라인: Local 데이터만 사용
      final localData = await _localDataSource.getTransactions();
      
      final transactions = localData
          .map((dto) => TransactionMapper.toEntity(dto))
          .toList();
      
      return Success(transactions);
    }
  } catch (e, stackTrace) {
    final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
    return Error(failure);
  }
}
```

> 📎 예외 → Failure 변환 로직은 [../arch/error.md](../arch/error.md)

---

## ✅ Provider 설정

### main.dart에서 Repository Provider 등록

```dart
MultiProvider(
  providers: [
    // DataSources
    Provider<TransactionRemoteDataSource>(
      create: (context) => TransactionRemoteDataSourceImpl(
        apiService: context.read<ApiService>(),
      ),
    ),
    Provider<TransactionLocalDataSource>(
      create: (context) => TransactionLocalDataSourceImpl(
        storageService: context.read<StorageService>(),
      ),
    ),
    
    // Core Services
    Provider<NetworkInfo>(
      create: (context) => NetworkInfoImpl(),
    ),

    // Repository
    Provider<TransactionRepository>(
      create: (context) => TransactionRepositoryImpl(
        remoteDataSource: context.read<TransactionRemoteDataSource>(),
        localDataSource: context.read<TransactionLocalDataSource>(),
        networkInfo: context.read<NetworkInfo>(),
      ),
    ),
  ],
  child: MyApp(),
)
```

---

## 🧪 테스트 가이드

### Repository 단위 테스트

```dart
group('TransactionRepositoryImpl 테스트', () {
  late TransactionRepositoryImpl repository;
  late MockTransactionRemoteDataSource mockRemoteDataSource;
  late MockTransactionLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockTransactionRemoteDataSource();
    mockLocalDataSource = MockTransactionLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    
    repository = TransactionRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getTransactions', () {
    final testTransactionDtos = [
      TransactionDto(
        id: '1',
        title: '커피',
        amount: 4500,
        type: 'expense',
        categoryId: 'food',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    test('온라인 상태에서 성공 시 Success<List<Transaction>> 반환', () async {
      // Given
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getTransactions())
          .thenAnswer((_) async => testTransactionDtos);
      when(() => mockLocalDataSource.cacheTransactions(any()))
          .thenAnswer((_) async {});

      // When
      final result = await repository.getTransactions();

      // Then
      expect(result, isA<Success<List<Transaction>>>());
      final transactions = result.dataOrNull!;
      expect(transactions.length, 1);
      expect(transactions.first.title, '커피');
      
      // 캐싱 호출 검증
      verify(() => mockLocalDataSource.cacheTransactions(testTransactionDtos))
          .called(1);
    });

    test('온라인 상태에서 Remote 실패 시 Local 데이터로 fallback', () async {
      // Given
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getTransactions())
          .thenThrow(NetworkException('네트워크 오류'));
      when(() => mockLocalDataSource.getTransactions())
          .thenAnswer((_) async => testTransactionDtos);

      // When
      final result = await repository.getTransactions();

      // Then
      expect(result, isA<Success<List<Transaction>>>());
      final transactions = result.dataOrNull!;
      expect(transactions.length, 1);
      
      // Local 데이터 소스 호출 검증
      verify(() => mockLocalDataSource.getTransactions()).called(1);
    });

    test('오프라인 상태에서 Local 데이터만 사용', () async {
      // Given
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.getTransactions())
          .thenAnswer((_) async => testTransactionDtos);

      // When
      final result = await repository.getTransactions();

      // Then
      expect(result, isA<Success<List<Transaction>>>());
      
      // Remote 호출되지 않음 검증
      verifyNever(() => mockRemoteDataSource.getTransactions());
    });

    test('예외 발생 시 Error<Failure> 반환', () async {
      // Given
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.getTransactions())
          .thenThrow(CacheException('로컬 데이터 오류'));

      // When
      final result = await repository.getTransactions();

      // Then
      expect(result, isA<Error<List<Transaction>>>());
      final failure = result.failureOrNull!;
      expect(failure, isA<CacheFailure>());
    });
  });

  group('addTransaction', () {
    final testTransaction = Transaction.create(
      title: '커피',
      amount: 4500,
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime.now(),
    );

    test('성공 시 Success<void> 반환', () async {
      // Given
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.addTransaction(any()))
          .thenAnswer((_) async {});
      when(() => mockRemoteDataSource.addTransaction(any()))
          .thenAnswer((_) async {});

      // When
      final result = await repository.addTransaction(testTransaction);

      // Then
      expect(result, isA<Success<void>>());
      
      // 로컬과 원격 모두 호출 검증
      verify(() => mockLocalDataSource.addTransaction(any())).called(1);
      verify(() => mockRemoteDataSource.addTransaction(any())).called(1);
    });

    test('Local 실패 시 Error<Failure> 반환', () async {
      // Given
      when(() => mockLocalDataSource.addTransaction(any()))
          .thenThrow(CacheException('로컬 저장 실패'));

      // When
      final result = await repository.addTransaction(testTransaction);

      // Then
      expect(result, isA<Error<void>>());
      final failure = result.failureOrNull!;
      expect(failure, isA<CacheFailure>());
    });
  });
});
```

### Integration 테스트

```dart
group('TransactionRepository Integration 테스트', () {
  late TransactionRepository repository;

  setUp(() {
    repository = TransactionRepositoryImpl(
      remoteDataSource: MockTransactionRemoteDataSource(),
      localDataSource: MockTransactionLocalDataSource(),
      networkInfo: MockNetworkInfo(),
    );
  });

  test('전체 CRUD 플로우 테스트', () async {
    // Given
    final transaction = Transaction.create(
      title: '테스트 거래',
      amount: 10000,
      type: TransactionType.expense,
      categoryId: 'test',
      date: DateTime.now(),
    );

    // When & Then
    // 1. 추가
    final addResult = await repository.addTransaction(transaction);
    expect(addResult.isSuccess, true);

    // 2. 조회
    final getResult = await repository.getTransactions();
    expect(getResult.isSuccess, true);
    expect(getResult.dataOrNull!.isNotEmpty, true);

    // 3. 수정
    final updatedTransaction = transaction.updateTitle('수정된 거래');
    final updateResult = await repository.updateTransaction(updatedTransaction);
    expect(updateResult.isSuccess, true);

    // 4. 삭제
    final deleteResult = await repository.deleteTransaction(transaction.id);
    expect(deleteResult.isSuccess, true);
  });
});
```

> 📎 DTO 구조는 [dto.md](dto.md)  
> 📎 Entity 정의는 [model.md](model.md)

---

