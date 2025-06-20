# 🌐 DataSource 설계 가이드

## ✅ 목적

DataSource는 외부 데이터와의 연결 지점을 담당하며,  
API 호출, Firebase 작업, LocalStorage 접근 등을 수행하는 **실제 입출력 계층**입니다.  
Repository는 이 계층을 통해 데이터를 요청하고, 예외 상황을 처리합니다.

---

## 🧱 설계 원칙

- 항상 **interface 정의 → 구현체 분리**
- Remote/Local 구분으로 데이터 소스 분리
- Firebase 구현체는 별도 클래스로 관리
- **Exception은 그대로 throw**, 가공은 Repository에서 처리
- **Provider 패턴**으로 의존성 주입 관리

---

## ✅ 파일 구조 및 위치

```text
lib/
└── features/
    └── transaction/
        └── data/
            └── datasources/
                ├── transaction_datasource.dart                 # 인터페이스
                ├── transaction_remote_datasource.dart         # Remote 구현체
                ├── transaction_local_datasource.dart          # Local 구현체
                ├── transaction_firebase_datasource.dart       # Firebase 구현체
                └── mock_transaction_datasource.dart           # 테스트용
```

> 📎 전체 폴더 구조 가이드는 [../arch/folder.md](../arch/folder.md)

---

## ✅ 네이밍 및 클래스 구성

### DataSource 인터페이스

```dart
/// Transaction DataSource 인터페이스
abstract class TransactionDataSource {
  Future<List<TransactionDto>> getTransactions();
  Future<TransactionDto> getTransactionById(String id);
  Future<void> addTransaction(TransactionDto transaction);
  Future<void> updateTransaction(TransactionDto transaction);
  Future<void> deleteTransaction(String id);
}
```

### Remote DataSource 구현체

```dart
/// API 기반 Remote DataSource
class TransactionRemoteDataSource implements TransactionDataSource {
  final ApiService _apiService;

  TransactionRemoteDataSource({
    required ApiService apiService,
  }) : _apiService = apiService;

  @override
  Future<List<TransactionDto>> getTransactions() async {
    try {
      final response = await _apiService.get('/transactions');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['transactions'];
        return data.map((json) => TransactionDto.fromJson(json)).toList();
      } else {
        throw ServerException('서버에서 데이터를 가져올 수 없습니다');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException('연결 시간이 초과되었습니다');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('응답 시간이 초과되었습니다');
      } else {
        throw NetworkException('네트워크 오류가 발생했습니다');
      }
    } catch (e) {
      throw ServerException('알 수 없는 오류가 발생했습니다');
    }
  }

  @override
  Future<TransactionDto> getTransactionById(String id) async {
    try {
      final response = await _apiService.get('/transactions/$id');
      
      if (response.statusCode == 200) {
        return TransactionDto.fromJson(response.data);
      } else {
        throw ServerException('거래 정보를 찾을 수 없습니다');
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw ServerException('거래 정보를 가져오는 중 오류가 발생했습니다');
    }
  }

  @override
  Future<void> addTransaction(TransactionDto transaction) async {
    try {
      final response = await _apiService.post(
        '/transactions',
        data: transaction.toJson(),
      );
      
      if (response.statusCode != 201) {
        throw ServerException('거래를 추가할 수 없습니다');
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw ServerException('거래 추가 중 오류가 발생했습니다');
    }
  }

  @override
  Future<void> updateTransaction(TransactionDto transaction) async {
    try {
      final response = await _apiService.put(
        '/transactions/${transaction.id}',
        data: transaction.toJson(),
      );
      
      if (response.statusCode != 200) {
        throw ServerException('거래를 수정할 수 없습니다');
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw ServerException('거래 수정 중 오류가 발생했습니다');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      final response = await _apiService.delete('/transactions/$id');
      
      if (response.statusCode != 200) {
        throw ServerException('거래를 삭제할 수 없습니다');
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw ServerException('거래 삭제 중 오류가 발생했습니다');
    }
  }
}
```

### Local DataSource 구현체

```dart
/// SharedPreferences 기반 Local DataSource
class TransactionLocalDataSource implements TransactionDataSource {
  final StorageService _storageService;
  static const String _transactionsKey = 'transactions';

  TransactionLocalDataSource({
    required StorageService storageService,
  }) : _storageService = storageService;

  @override
  Future<List<TransactionDto>> getTransactions() async {
    try {
      final jsonString = await _storageService.getString(_transactionsKey);
      
      if (jsonString == null) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => TransactionDto.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('로컬 데이터를 읽는 중 오류가 발생했습니다');
    }
  }

  @override
  Future<TransactionDto> getTransactionById(String id) async {
    try {
      final transactions = await getTransactions();
      final transaction = transactions.firstWhere(
        (t) => t.id == id,
        orElse: () => throw CacheException('거래를 찾을 수 없습니다'),
      );
      return transaction;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('거래 정보를 가져오는 중 오류가 발생했습니다');
    }
  }

  @override
  Future<void> addTransaction(TransactionDto transaction) async {
    try {
      final transactions = await getTransactions();
      transactions.add(transaction);
      await _saveTransactions(transactions);
    } catch (e) {
      throw CacheException('거래를 저장하는 중 오류가 발생했습니다');
    }
  }

  @override
  Future<void> updateTransaction(TransactionDto transaction) async {
    try {
      final transactions = await getTransactions();
      final index = transactions.indexWhere((t) => t.id == transaction.id);
      
      if (index == -1) {
        throw CacheException('수정할 거래를 찾을 수 없습니다');
      }
      
      transactions[index] = transaction;
      await _saveTransactions(transactions);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('거래를 수정하는 중 오류가 발생했습니다');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      final transactions = await getTransactions();
      transactions.removeWhere((t) => t.id == id);
      await _saveTransactions(transactions);
    } catch (e) {
      throw CacheException('거래를 삭제하는 중 오류가 발생했습니다');
    }
  }

  Future<void> _saveTransactions(List<TransactionDto> transactions) async {
    final jsonString = json.encode(
      transactions.map((t) => t.toJson()).toList(),
    );
    await _storageService.setString(_transactionsKey, jsonString);
  }
}
```

### Firebase DataSource 구현체

```dart
/// Firebase Firestore 기반 DataSource
class TransactionFirebaseDataSource implements TransactionDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'transactions';

  TransactionFirebaseDataSource({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<List<TransactionDto>> getTransactions() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionDto.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('데이터를 가져오는 중 오류가 발생했습니다');
    }
  }

  @override
  Future<TransactionDto> getTransactionById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) {
        throw ServerException('거래를 찾을 수 없습니다');
      }
      
      return TransactionDto.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('거래 정보를 가져오는 중 오류가 발생했습니다');
    }
  }

  @override
  Future<void> addTransaction(TransactionDto transaction) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(transaction.id)
          .set(transaction.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('거래를 추가하는 중 오류가 발생했습니다');
    }
  }

  @override
  Future<void> updateTransaction(TransactionDto transaction) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(transaction.id)
          .update(transaction.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('거래를 수정하는 중 오류가 발생했습니다');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    } catch (e) {
      throw ServerException('거래를 삭제하는 중 오류가 발생했습니다');
    }
  }
}
```

### Mock DataSource 구현체

```dart
/// 테스트용 Mock DataSource
class MockTransactionDataSource implements TransactionDataSource {
  // 메모리 내 데이터 저장
  final List<TransactionDto> _transactions = [];
  bool _initialized = false;

  // 초기화는 한 번만 수행
  Future<void> _initializeIfNeeded() async {
    if (_initialized) return;
    
    // 초기 Mock 데이터 설정
    _transactions.addAll(_generateMockData());
    _initialized = true;
  }

  List<TransactionDto> _generateMockData() {
    return [
      TransactionDto(
        id: '1',
        title: '커피',
        amount: 4500,
        type: 'expense',
        categoryId: 'food',
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: '스타벅스 아메리카노',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TransactionDto(
        id: '2',
        title: '월급',
        amount: 3000000,
        type: 'income',
        categoryId: 'salary',
        date: DateTime.now().subtract(const Duration(days: 5)),
        description: '12월 월급',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<List<TransactionDto>> getTransactions() async {
    await _initializeIfNeeded();
    // 복사본 반환으로 원본 데이터 보호
    return List.from(_transactions);
  }

  @override
  Future<TransactionDto> getTransactionById(String id) async {
    await _initializeIfNeeded();
    
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      throw ServerException('거래를 찾을 수 없습니다');
    }
  }

  @override
  Future<void> addTransaction(TransactionDto transaction) async {
    await _initializeIfNeeded();
    
    // 새로운 ID 생성
    final newTransaction = transaction.copyWith(
      id: _generateNewId(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _transactions.add(newTransaction);
  }

  @override
  Future<void> updateTransaction(TransactionDto transaction) async {
    await _initializeIfNeeded();
    
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index == -1) {
      throw ServerException('수정할 거래를 찾을 수 없습니다');
    }
    
    _transactions[index] = transaction.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _initializeIfNeeded();
    
    final removed = _transactions.removeWhere((t) => t.id == id);
    if (removed == 0) {
      throw ServerException('삭제할 거래를 찾을 수 없습니다');
    }
  }

  String _generateNewId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
```

> 📎 메소드명 등의 네이밍 규칙은 [../arch/naming.md](../arch/naming.md)  
> 📎 DTO 구조는 [dto.md](dto.md)  
> 📎 Mapper 예시는 [mapper.md](mapper.md)

---

## ✅ 예외 처리 전략

- DataSource에서는 오류가 발생해도 직접 처리하지 않고, 그대로 예외를 던집니다  
  (예: `throw NetworkException(...)`, `throw ServerException(...)`, `throw CacheException(...)` 등).
- 예외를 try-catch로 잡아서 Failure로 바꾸는 일은 Repository에서 담당합니다.
- 즉, 예외 처리 코드는 Repository에만 작성하고, DataSource에는 작성하지 않습니다.

```dart
// ✅ DataSource에서 올바른 예외 처리
@override
Future<List<TransactionDto>> getTransactions() async {
  final response = await _apiService.get('/transactions');
  
  if (response.statusCode != 200) {
    throw ServerException('서버에서 데이터를 가져올 수 없습니다'); // 예외 던지기
  }
  
  return response.data.map((json) => TransactionDto.fromJson(json)).toList();
}

// ❌ DataSource에서 잘못된 예외 처리
@override
Future<Result<List<TransactionDto>>> getTransactions() async {
  try {
    final response = await _apiService.get('/transactions');
    return Success(response.data); // Result 패턴은 Repository에서만!
  } catch (e) {
    return Error(ServerFailure(e.toString())); // Repository 책임!
  }
}
```

> 📎 예외 매핑 유틸은 [../arch/error.md](../arch/error.md)

---

## ✅ Provider 설정

### main.dart에서 DataSource Provider 등록

```dart
MultiProvider(
  providers: [
    // Core Services
    Provider<ApiService>(
      create: (context) => ApiServiceImpl(),
    ),
    Provider<StorageService>(
      create: (context) => StorageServiceImpl(),
    ),
    Provider<FirebaseFirestore>(
      create: (context) => FirebaseFirestore.instance,
    ),

    // DataSources
    Provider<TransactionRemoteDataSource>(
      create: (context) => TransactionRemoteDataSource(
        apiService: context.read<ApiService>(),
      ),
    ),
    Provider<TransactionLocalDataSource>(
      create: (context) => TransactionLocalDataSource(
        storageService: context.read<StorageService>(),
      ),
    ),
    
    // 개발/테스트 환경에서는 Mock DataSource 사용
    // Provider<TransactionRemoteDataSource>(
    //   create: (context) => MockTransactionDataSource(),
    // ),

    // Firebase DataSource (선택적)
    // Provider<TransactionFirebaseDataSource>(
    //   create: (context) => TransactionFirebaseDataSource(
    //     firestore: context.read<FirebaseFirestore>(),
    //   ),
    // ),
  ],
  child: MyApp(),
)
```

---

## 🧪 테스트 가이드

### DataSource 단위 테스트

```dart
group('TransactionRemoteDataSource 테스트', () {
  late TransactionRemoteDataSource dataSource;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    dataSource = TransactionRemoteDataSource(apiService: mockApiService);
  });

  test('getTransactions 성공 시 TransactionDto 리스트 반환', () async {
    // Given
    final mockResponse = MockResponse(
      statusCode: 200,
      data: {
        'transactions': [
          {'id': '1', 'title': '커피', 'amount': 4500},
        ]
      },
    );
    when(() => mockApiService.get('/transactions'))
        .thenAnswer((_) async => mockResponse);

    // When
    final result = await dataSource.getTransactions();

    // Then
    expect(result, isA<List<TransactionDto>>());
    expect(result.length, 1);
    expect(result.first.title, '커피');
  });

  test('getTransactions 실패 시 ServerException 발생', () async {
    // Given
    when(() => mockApiService.get('/transactions'))
        .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

    // When & Then
    expect(
      () => dataSource.getTransactions(),
      throwsA(isA<NetworkException>()),
    );
  });
});
```

### Repository 테스트에서 Mock DataSource 사용

```dart
group('TransactionRepository 테스트', () {
  late TransactionRepositoryImpl repository;
  late MockTransactionDataSource mockRemoteDataSource;
  late MockTransactionDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockTransactionDataSource();
    mockLocalDataSource = MockTransactionDataSource();
    repository = TransactionRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  // 테스트 케이스들...
});
```

> 📎 Repository 테스트 및 흐름 구조는 [repository.md](repository.md)

---

