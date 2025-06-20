# 🔄 Mapper 설계 가이드

## ✅ 목적

Mapper는 외부 DTO를 내부 Entity로 변환하고,  
반대로 Entity을 다시 DTO로 바꾸는 **데이터 구조 변환 계층**입니다.  
이 프로젝트에서는 **정적 메서드 기반 Mapper 클래스**를 활용해  
명확하고 일관된 방식으로 변환을 수행합니다.

---

## 🧱 설계 원칙

- 모든 변환은 **정적 메서드**로 정의
- 메서드 이름은 `toEntity()`, `toDto()` 고정
- 리스트 변환도 별도의 정적 메서드로 처리 (`toEntityList()`, `toDtoList()`)
- `null` 안전성 확보 필수
- **Provider 패턴**에서 Repository가 사용

---

## ✅ 파일 위치 및 네이밍

| 항목 | 규칙 |
|------|------|
| 파일 경로 | `lib/features/{기능}/data/mappers/` |
| 파일명 | `{entity_name}_mapper.dart` (예: `transaction_mapper.dart`) |
| 클래스명 | `{EntityName}Mapper` (예: `TransactionMapper`) |
| 메서드명 | `toEntity()`, `toDto()`, `toEntityList()`, `toDtoList()` |

---

## ✅ 기본 예시

### Transaction Mapper

```dart
import '../../domain/entities/transaction.dart';
import '../models/transaction_dto.dart';

/// Transaction DTO ↔ Entity 변환 Mapper
class TransactionMapper {
  TransactionMapper._(); // 인스턴스 생성 방지

  /// DTO → Entity 변환
  static Transaction toEntity(TransactionDto dto) {
    return Transaction(
      id: dto.id ?? '',
      title: dto.title ?? '',
      amount: dto.amount ?? 0.0,
      type: _mapTransactionType(dto.type),
      categoryId: dto.categoryId ?? '',
      date: dto.date ?? DateTime.now(),
      description: dto.description,
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
    );
  }

  /// Entity → DTO 변환
  static TransactionDto toDto(Transaction entity) {
    return TransactionDto(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      type: _mapTransactionTypeToString(entity.type),
      categoryId: entity.categoryId,
      date: entity.date,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// DTO List → Entity List 변환
  static List<Transaction> toEntityList(List<TransactionDto>? dtoList) {
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => toEntity(dto)).toList();
  }

  /// Entity List → DTO List 변환
  static List<TransactionDto> toDtoList(List<Transaction>? entityList) {
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => toDto(entity)).toList();
  }

  /// 문자열 → TransactionType 변환
  static TransactionType _mapTransactionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        return TransactionType.expense; // 기본값
    }
  }

  /// TransactionType → 문자열 변환
  static String _mapTransactionTypeToString(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
    }
  }

  /// Firebase Firestore Document → Entity 변환
  static Transaction fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Transaction(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: _mapTransactionType(data['type']),
      categoryId: data['categoryId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Entity → Firebase Firestore Map 변환
  static Map<String, dynamic> toFirestore(Transaction entity) {
    return {
      'title': entity.title,
      'amount': entity.amount,
      'type': _mapTransactionTypeToString(entity.type),
      'categoryId': entity.categoryId,
      'date': Timestamp.fromDate(entity.date),
      'description': entity.description,
      'createdAt': Timestamp.fromDate(entity.createdAt),
      'updatedAt': Timestamp.fromDate(entity.updatedAt),
    };
  }
}
```

### Category Mapper

```dart
import '../../domain/entities/category.dart';
import '../models/category_dto.dart';

/// Category DTO ↔ Entity 변환 Mapper
class CategoryMapper {
  CategoryMapper._();

  /// DTO → Entity 변환
  static Category toEntity(CategoryDto dto) {
    return Category(
      id: dto.id ?? '',
      name: dto.name ?? '',
      description: dto.description,
      type: _mapCategoryType(dto.type),
      parentId: dto.parentId,
      iconName: dto.iconName ?? '',
      colorCode: dto.colorCode ?? '#000000',
      budgetLimit: dto.budgetLimit ?? 0.0,
      isActive: dto.isActive ?? true,
      createdAt: dto.createdAt ?? DateTime.now(),
    );
  }

  /// Entity → DTO 변환
  static CategoryDto toDto(Category entity) {
    return CategoryDto(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      type: _mapCategoryTypeToString(entity.type),
      parentId: entity.parentId,
      iconName: entity.iconName,
      colorCode: entity.colorCode,
      budgetLimit: entity.budgetLimit,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  /// DTO List → Entity List 변환
  static List<Category> toEntityList(List<CategoryDto>? dtoList) {
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => toEntity(dto)).toList();
  }

  /// Entity List → DTO List 변환
  static List<CategoryDto> toDtoList(List<Category>? entityList) {
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => toDto(entity)).toList();
  }

  /// 문자열 → CategoryType 변환
  static CategoryType _mapCategoryType(String? type) {
    switch (type?.toLowerCase()) {
      case 'income':
        return CategoryType.income;
      case 'expense':
        return CategoryType.expense;
      default:
        return CategoryType.expense;
    }
  }

  /// CategoryType → 문자열 변환
  static String _mapCategoryTypeToString(CategoryType type) {
    switch (type) {
      case CategoryType.income:
        return 'income';
      case CategoryType.expense:
        return 'expense';
    }
  }
}
```

---

## 📌 Repository에서 Mapper 사용

### TransactionRepository에서 활용

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
      // DataSource에서 DTO 리스트 가져오기
      final transactionDtos = await _remoteDataSource.getTransactions();
      
      // Mapper를 통해 DTO → Entity 변환
      final transactions = TransactionMapper.toEntityList(transactionDtos);
      
      return Success(transactions);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> addTransaction(Transaction transaction) async {
    try {
      // Mapper를 통해 Entity → DTO 변환
      final transactionDto = TransactionMapper.toDto(transaction);
      
      // DataSource에 DTO 전달
      await _remoteDataSource.addTransaction(transactionDto);
      
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }
}
```

---

## 🧪 테스트 전략

### Mapper 단위 테스트

```dart
group('TransactionMapper 테스트', () {
  group('toEntity', () {
    test('유효한 DTO를 Entity로 변환', () {
      // Given
      final dto = TransactionDto(
        id: '1',
        title: '커피',
        amount: 4500.0,
        type: 'expense',
        categoryId: 'food',
        date: DateTime(2024, 1, 15),
        description: '스타벅스 아메리카노',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // When
      final entity = TransactionMapper.toEntity(dto);

      // Then
      expect(entity.id, '1');
      expect(entity.title, '커피');
      expect(entity.amount, 4500.0);
      expect(entity.type, TransactionType.expense);
      expect(entity.categoryId, 'food');
      expect(entity.description, '스타벅스 아메리카노');
      expect(entity.isExpense, true);
    });

    test('null 값이 포함된 DTO도 안전하게 변환', () {
      // Given
      final dto = TransactionDto(
        id: null,
        title: null,
        amount: null,
        type: null,
        categoryId: null,
        date: null,
        description: null,
        createdAt: null,
        updatedAt: null,
      );

      // When
      final entity = TransactionMapper.toEntity(dto);

      // Then
      expect(entity.id, '');
      expect(entity.title, '');
      expect(entity.amount, 0.0);
      expect(entity.type, TransactionType.expense); // 기본값
      expect(entity.categoryId, '');
      expect(entity.description, null);
    });
  });

  group('toDto', () {
    test('Entity를 DTO로 변환', () {
      // Given
      final entity = Transaction.create(
        title: '커피',
        amount: 4500.0,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime(2024, 1, 15),
        description: '스타벅스 아메리카노',
      );

      // When
      final dto = TransactionMapper.toDto(entity);

      // Then
      expect(dto.title, '커피');
      expect(dto.amount, 4500.0);
      expect(dto.type, 'expense');
      expect(dto.categoryId, 'food');
      expect(dto.description, '스타벅스 아메리카노');
    });
  });

  group('toEntityList', () {
    test('DTO 리스트를 Entity 리스트로 변환', () {
      // Given
      final dtoList = [
        TransactionDto(id: '1', title: '커피', amount: 4500.0, type: 'expense'),
        TransactionDto(id: '2', title: '월급', amount: 3000000.0, type: 'income'),
      ];

      // When
      final entityList = TransactionMapper.toEntityList(dtoList);

      // Then
      expect(entityList.length, 2);
      expect(entityList[0].title, '커피');
      expect(entityList[0].type, TransactionType.expense);
      expect(entityList[1].title, '월급');
      expect(entityList[1].type, TransactionType.income);
    });

    test('null 또는 빈 리스트는 빈 리스트 반환', () {
      // When & Then
      expect(TransactionMapper.toEntityList(null), []);
      expect(TransactionMapper.toEntityList([]), []);
    });
  });
});
```

---

## ✨ 장점 요약

| 항목 | 설명 |
|------|------|
| **명확성** | `TransactionMapper.toEntity(dto)` 처럼 의도가 명확 |
| **일관성** | 모든 Mapper가 동일한 패턴을 따름 |
| **테스트성** | 정적 메서드로 독립 테스트 용이 |
| **null 안전성** | null 값 처리를 Mapper에서 일괄 담당 |
| **확장성** | Firebase, API 등 다양한 데이터 소스 지원 |

---
