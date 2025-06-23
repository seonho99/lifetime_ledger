# 🔄 Mapper 설계 가이드 (Extension 방식)

## ✅ 목적

Mapper는 외부 DTO를 내부 Entity로 변환하고,  
반대로 Entity을 다시 DTO로 바꾸는 **데이터 구조 변환 계층**입니다.  
이 프로젝트에서는 **Extension 기반 Mapper 패턴**을 활용해  
자연스럽고 직관적인 방식으로 변환을 수행합니다.

---

## 🧱 설계 원칙

- 모든 변환은 **Extension 메서드**로 정의
- 메서드 이름은 `toModel()`, `toDto()`, `toFirestore()` 등 명확한 의미
- 리스트 변환도 별도의 Extension 메서드로 처리 (`toModelList()`, `toDtoList()`)
- `null` 안전성 확보 필수
- **Provider 패턴**에서 Repository가 사용
- Firebase Firestore 통합 우선 고려

---

## ✅ 파일 위치 및 네이밍

| 항목 | 규칙 |
|------|------|
| 파일 경로 | `lib/features/{기능}/data/mapper/` |
| 파일명 | `{entity_name}_mapper.dart` (예: `history_mapper.dart`) |
| Extension명 | `{EntityName}DtoMapper`, `{EntityName}Mapper` 등 |
| 메서드명 | `toModel()`, `toDto()`, `toFirestore()`, `toModelList()` 등 |

---

## ✅ 기본 예시 (실제 구현)

### History Mapper

```dart
import '../../domain/model/history.dart';
import '../dto/history_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// HistoryDto -> History 변환
extension HistoryDtoMapper on HistoryDto? {
  History? toModel() {
    final dto = this;
    if (dto == null) return null;

    return History(
      id: dto.id ?? '',
      title: dto.title ?? '',
      amount: (dto.amount ?? 0.0).toDouble(),
      type: _stringToHistoryType(dto.type),
      categoryId: dto.categoryId ?? '',
      date: dto.date ?? DateTime.now(),
      description: dto.description,
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
    );
  }

  /// 문자열을 HistoryType으로 변환하는 내부 헬퍼 메서드
  HistoryType _stringToHistoryType(String? type) {
    switch (type?.toLowerCase()) {
      case 'income':
        return HistoryType.income;
      case 'expense':
        return HistoryType.expense;
      default:
        return HistoryType.expense; // 기본값
    }
  }
}

/// History -> HistoryDto 변환
extension HistoryMapper on History {
  HistoryDto toDto() {
    return HistoryDto(
      id: id,
      title: title,
      amount: amount,
      type: type.toStringValue(),
      categoryId: categoryId,
      date: date,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Firebase Firestore에 저장할 Map 생성
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'type': type.toStringValue(),
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// HistoryType을 문자열로 변환하는 extension
extension HistoryTypeExtension on HistoryType {
  String toStringValue() {
    switch (this) {
      case HistoryType.income:
        return 'income';
      case HistoryType.expense:
        return 'expense';
    }
  }
}

/// List<HistoryDto> -> List<History> 변환
extension HistoryDtoListMapper on List<HistoryDto>? {
  List<History> toModelList() {
    final dtoList = this;
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => dto.toModel()).whereType<History>().toList();
  }
}

/// List<History> -> List<HistoryDto> 변환
extension HistoryListMapper on List<History>? {
  List<HistoryDto> toDtoList() {
    final entityList = this;
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => entity.toDto()).toList();
  }
}

/// Firebase Firestore Document -> History 변환
extension FirestoreDocumentMapper on DocumentSnapshot {
  History? toHistoryModel() {
    if (!exists) return null;

    final data = this.data() as Map<String, dynamic>;

    return History(
      id: id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: _stringToHistoryType(data['type']),
      categoryId: data['categoryId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 문자열을 HistoryType으로 변환하는 내부 헬퍼 메서드
  HistoryType _stringToHistoryType(String? type) {
    switch (type?.toLowerCase()) {
      case 'income':
        return HistoryType.income;
      case 'expense':
        return HistoryType.expense;
      default:
        return HistoryType.expense; // 기본값
    }
  }
}
```

### Transaction Mapper (확장 예시)

```dart
import '../../domain/model/transaction.dart';
import '../dto/transaction_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// TransactionDto -> Transaction 변환
extension TransactionDtoMapper on TransactionDto? {
  Transaction? toModel() {
    final dto = this;
    if (dto == null) return null;

    return Transaction(
      id: dto.id ?? '',
      title: dto.title ?? '',
      amount: (dto.amount ?? 0.0).toDouble(),
      type: _stringToTransactionType(dto.type),
      categoryId: dto.categoryId ?? '',
      date: dto.date ?? DateTime.now(),
      description: dto.description,
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
    );
  }

  /// 문자열을 TransactionType으로 변환
  TransactionType _stringToTransactionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        return TransactionType.expense;
    }
  }
}

/// Transaction -> TransactionDto 변환
extension TransactionMapper on Transaction {
  TransactionDto toDto() {
    return TransactionDto(
      id: id,
      title: title,
      amount: amount,
      type: type.toStringValue(),
      categoryId: categoryId,
      date: date,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Firebase Firestore에 저장할 Map 생성
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'type': type.toStringValue(),
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// TransactionType Extension
extension TransactionTypeExtension on TransactionType {
  String toStringValue() {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
    }
  }
}

/// List 변환 Extensions
extension TransactionDtoListMapper on List<TransactionDto>? {
  List<Transaction> toModelList() {
    final dtoList = this;
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => dto.toModel()).whereType<Transaction>().toList();
  }
}

extension TransactionListMapper on List<Transaction>? {
  List<TransactionDto> toDtoList() {
    final entityList = this;
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => entity.toDto()).toList();
  }
}
```

### Category Mapper

```dart
import '../../domain/model/category.dart';
import '../dto/category_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// CategoryDto -> Category 변환
extension CategoryDtoMapper on CategoryDto? {
  Category? toModel() {
    final dto = this;
    if (dto == null) return null;

    return Category(
      id: dto.id ?? '',
      name: dto.name ?? '',
      description: dto.description,
      type: _stringToCategoryType(dto.type),
      parentId: dto.parentId,
      iconName: dto.iconName ?? '',
      colorCode: dto.colorCode ?? '#000000',
      budgetLimit: (dto.budgetLimit ?? 0.0).toDouble(),
      isActive: dto.isActive ?? true,
      createdAt: dto.createdAt ?? DateTime.now(),
    );
  }

  /// 문자열을 CategoryType으로 변환
  CategoryType _stringToCategoryType(String? type) {
    switch (type?.toLowerCase()) {
      case 'income':
        return CategoryType.income;
      case 'expense':
        return CategoryType.expense;
      default:
        return CategoryType.expense;
    }
  }
}

/// Category -> CategoryDto 변환
extension CategoryMapper on Category {
  CategoryDto toDto() {
    return CategoryDto(
      id: id,
      name: name,
      description: description,
      type: type.toStringValue(),
      parentId: parentId,
      iconName: iconName,
      colorCode: colorCode,
      budgetLimit: budgetLimit,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  /// Firebase Firestore에 저장할 Map 생성
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type.toStringValue(),
      'parentId': parentId,
      'iconName': iconName,
      'colorCode': colorCode,
      'budgetLimit': budgetLimit,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// CategoryType Extension
extension CategoryTypeExtension on CategoryType {
  String toStringValue() {
    switch (this) {
      case CategoryType.income:
        return 'income';
      case CategoryType.expense:
        return 'expense';
    }
  }
}

/// List 변환 Extensions
extension CategoryDtoListMapper on List<CategoryDto>? {
  List<Category> toModelList() {
    final dtoList = this;
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => dto.toModel()).whereType<Category>().toList();
  }
}

extension CategoryListMapper on List<Category>? {
  List<CategoryDto> toDtoList() {
    final entityList = this;
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => entity.toDto()).toList();
  }
}
```

---

## 📌 Repository에서 Extension Mapper 사용

### HistoryRepository에서 활용

```dart
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDataSource _dataSource;

  HistoryRepositoryImpl({
    required HistoryDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<List<History>>> getHistories() async {
    try {
      // DataSource에서 DTO 리스트 가져오기
      final historyDtos = await _dataSource.getHistories();
      
      // Extension을 통해 DTO → Entity 변환
      final histories = historyDtos.toModelList();
      
      return Success(histories);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> addHistory(History history) async {
    try {
      // Extension을 통해 Entity → DTO 변환
      final historyDto = history.toDto();
      
      // DataSource에 DTO 전달
      await _dataSource.addHistory(historyDto);
      
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<History>> getHistoryById(String id) async {
    try {
      final historyDto = await _dataSource.getHistoryById(id);
      
      // Extension으로 단일 객체 변환 (null 안전성 포함)
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
}
```

---

## 🧪 테스트 전략

### Extension Mapper 단위 테스트

```dart
group('HistoryDtoMapper Extension 테스트', () {
  group('toModel', () {
    test('유효한 DTO를 Entity로 변환', () {
      // Given
      final dto = HistoryDto(
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
      final entity = dto.toModel();

      // Then
      expect(entity?.id, '1');
      expect(entity?.title, '커피');
      expect(entity?.amount, 4500.0);
      expect(entity?.type, HistoryType.expense);
      expect(entity?.categoryId, 'food');
      expect(entity?.description, '스타벅스 아메리카노');
      expect(entity?.isExpense, true);
    });

    test('null DTO는 null 반환', () {
      // Given
      HistoryDto? dto;

      // When
      final entity = dto.toModel();

      // Then
      expect(entity, null);
    });

    test('null 값이 포함된 DTO도 안전하게 변환', () {
      // Given
      final dto = HistoryDto(
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
      final entity = dto.toModel();

      // Then
      expect(entity?.id, '');
      expect(entity?.title, '');
      expect(entity?.amount, 0.0);
      expect(entity?.type, HistoryType.expense); // 기본값
      expect(entity?.categoryId, '');
      expect(entity?.description, null);
    });
  });

  group('toDto', () {
    test('Entity를 DTO로 변환', () {
      // Given
      final entity = History(
        id: '1',
        title: '커피',
        amount: 4500.0,
        type: HistoryType.expense,
        categoryId: 'food',
        date: DateTime(2024, 1, 15),
        description: '스타벅스 아메리카노',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // When
      final dto = entity.toDto();

      // Then
      expect(dto.id, '1');
      expect(dto.title, '커피');
      expect(dto.amount, 4500.0);
      expect(dto.type, 'expense');
      expect(dto.categoryId, 'food');
      expect(dto.description, '스타벅스 아메리카노');
    });
  });

  group('toModelList', () {
    test('DTO 리스트를 Entity 리스트로 변환', () {
      // Given
      final dtoList = [
        HistoryDto(id: '1', title: '커피', amount: 4500.0, type: 'expense'),
        HistoryDto(id: '2', title: '월급', amount: 3000000.0, type: 'income'),
      ];

      // When
      final entityList = dtoList.toModelList();

      // Then
      expect(entityList.length, 2);
      expect(entityList[0].title, '커피');
      expect(entityList[0].type, HistoryType.expense);
      expect(entityList[1].title, '월급');
      expect(entityList[1].type, HistoryType.income);
    });

    test('null 또는 빈 리스트는 빈 리스트 반환', () {
      // When & Then
      expect((<HistoryDto>?null).toModelList(), []);
      expect((<HistoryDto>[]).toModelList(), []);
    });
  });

  group('Firebase Extensions', () {
    test('toFirestore Map 생성', () {
      // Given
      final entity = History(
        id: '1',
        title: '커피',
        amount: 4500.0,
        type: HistoryType.expense,
        categoryId: 'food',
        date: DateTime(2024, 1, 15),
        description: '스타벅스 아메리카노',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // When
      final firestoreMap = entity.toFirestore();

      // Then
      expect(firestoreMap['title'], '커피');
      expect(firestoreMap['amount'], 4500.0);
      expect(firestoreMap['type'], 'expense');
      expect(firestoreMap['categoryId'], 'food');
      expect(firestoreMap['date'], isA<Timestamp>());
      expect(firestoreMap['createdAt'], isA<Timestamp>());
      expect(firestoreMap['updatedAt'], isA<Timestamp>());
    });
  });
});
```

---

## ✨ Extension 방식의 장점

| 항목 | 설명 |
|------|------|
| **자연스러운 사용법** | `dto.toModel()`, `entity.toDto()` 직관적 |
| **null 안전성** | Extension에서 null 체크 처리 |
| **타입 안전성** | 컴파일 타임에 타입 체크 |
| **확장성** | 새로운 변환 메서드 쉽게 추가 |
| **가독성** | 메서드 체이닝으로 명확한 의도 표현 |
| **분산 정의** | 각 타입별로 Extension 분리 가능 |

---

## 🆚 기존 정적 메서드 방식과 비교

### ❌ 기존 정적 메서드 방식
```dart
// 사용이 번거롭고 null 체크가 복잡함
final entities = TransactionMapper.toEntityList(dtoList);
final dto = TransactionMapper.toDto(entity);
```

### ✅ Extension 방식
```dart
// 자연스럽고 null 안전한 사용법
final entities = dtoList.toModelList();
final dto = entity.toDto();
final history = historyDto?.toModel(); // null 안전
```

---

## 🔄 다양한 변환 패턴

### 1. **기본 변환**
```dart
final history = historyDto.toModel();
final dto = history.toDto();
```

### 2. **리스트 변환**
```dart
final histories = historyDtos.toModelList();
final dtos = histories.toDtoList();
```

### 3. **Firebase 변환**
```dart
final firestoreMap = history.toFirestore();
final history = document.toHistoryModel();
```

### 4. **체이닝**
```dart
final processedHistories = rawDtos
    .toModelList()
    .where((h) => h.isValid)
    .toList();
```

### 5. **Null 안전성**
```dart
final history = nullableDto?.toModel(); // null이면 null 반환
final histories = nullableList?.toModelList() ?? []; // null이면 빈 리스트
```

---

## 📋 Extension 네이밍 규칙

| Extension 타입 | 네이밍 규칙 | 예시 |
|----------------|-------------|------|
| DTO → Entity | `{Entity}DtoMapper` | `HistoryDtoMapper` |
| Entity → DTO | `{Entity}Mapper` | `HistoryMapper` |
| Enum 변환 | `{Enum}Extension` | `HistoryTypeExtension` |
| List 변환 | `{Entity}DtoListMapper` | `HistoryDtoListMapper` |
| Firebase | `FirestoreDocumentMapper` | `FirestoreDocumentMapper` |

---

## ✅ 문서 요약

- Extension 방식으로 자연스럽고 직관적인 변환 API 제공
- null 안전성과 타입 안전성을 Extension에서 처리
- Firebase Firestore 통합을 우선 고려한 변환 메서드
- 리스트 변환과 단일 객체 변환 모두 지원
- 실제 구현 코드와 완전 일치하는 패턴 사용
- 테스트 가능하고 확장 가능한 구조

---