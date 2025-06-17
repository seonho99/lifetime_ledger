# Mapper 설계 가이드

## 개요
Mapper는 DTO와 Entity 간의 변환을 담당하는 클래스입니다.
외부 데이터 형식과 도메인 모델 간의 안전한 변환과 타입 변환, 검증을 수행합니다.

## 기본 원칙

### 1. 단방향 변환
- **DTO → Entity**: fromDto 메서드 (외부 → 도메인)
- **Entity → DTO**: toDto 메서드 (도메인 → 외부)
- **양방향 지원**: 필요시 둘 다 구현

### 2. 타입 안전성
- **타입 변환**: String → DateTime, String → Enum 등
- **null 안전성**: null 값 적절히 처리
- **검증 통합**: Entity 생성 시 검증 로직 호출

### 3. 에러 처리
- **변환 실패**: 명확한 에러 메시지
- **부분 실패**: 일부 필드 변환 실패 시 처리
- **기본값 제공**: 필수 데이터 누락 시 기본값

## 기본 구조

### 1. 간단한 Mapper
```dart
class TransactionMapper {
  // DTO → Entity 변환
  static Transaction fromDto(TransactionDto dto) {
    return Transaction(
      id: dto.id,
      title: dto.title,
      amount: dto.amount,
      type: _parseTransactionType(dto.type),
      categoryId: dto.categoryId,
      date: DateTime.parse(dto.date),
      description: dto.description,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  // Entity → DTO 변환
  static TransactionDto toDto(Transaction entity) {
    return TransactionDto(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      type: entity.type.name,
      categoryId: entity.categoryId,
      date: entity.date.toIso8601String(),
      description: entity.description,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  // Enum 변환 헬퍼
  static TransactionType _parseTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        throw ArgumentError('알 수 없는 거래 타입: $type');
    }
  }
}
```

### 2. 복잡한 Mapper (중첩 객체 처리)
```dart
class CategoryMapper {
  // DTO → Entity 변환 (중첩 구조 처리)
  static Category fromDto(CategoryDto dto) {
    return Category(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      type: _parseCategoryType(dto.type),
      parentId: dto.parentId,
      iconName: dto.iconName,
      colorCode: dto.colorCode,
      budgetLimit: dto.budgetLimit,
      createdAt: DateTime.parse(dto.createdAt),
    );
  }

  // Entity → DTO 변환
  static CategoryDto toDto(Category entity) {
    return CategoryDto(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      type: entity.type.name,
      parentId: entity.parentId,
      iconName: entity.iconName,
      colorCode: entity.colorCode,
      budgetLimit: entity.budgetLimit,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  // 리스트 변환 (계층 구조 처리)
  static List<Category> fromDtoList(List<CategoryDto> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }

  // 계층 구조 변환 (부모-자식 관계)
  static List<Category> fromDtoListWithHierarchy(List<CategoryDto> dtos) {
    // 부모 카테고리부터 처리
    final parentCategories = dtos
        .where((dto) => dto.parentId == null)
        .map((dto) => fromDto(dto))
        .toList();

    // 자식 카테고리 매핑은 필요시 별도 로직으로 처리
    return parentCategories;
  }

  static CategoryType _parseCategoryType(String type) {
    return CategoryType.values.firstWhere(
      (e) => e.name.toLowerCase() == type.toLowerCase(),
      orElse: () => throw ArgumentError('알 수 없는 카테고리 타입: $type'),
    );
  }
}
```

### 3. Firebase 전용 Mapper
```dart
class TransactionFirebaseMapper {
  // Firebase DTO → Entity
  static Transaction fromFirebaseDto(
    TransactionFirebaseDto dto,
    String documentId,
  ) {
    return Transaction(
      id: documentId, // Firebase document ID 사용
      title: dto.title,
      amount: dto.amount,
      type: _parseTransactionType(dto.type),
      categoryId: dto.categoryId,
      date: DateTime.fromMillisecondsSinceEpoch(dto.date),
      description: dto.description,
      createdAt: DateTime.fromMillisecondsSinceEpoch(dto.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(dto.updatedAt),
    );
  }

  // Entity → Firebase DTO
  static TransactionFirebaseDto toFirebaseDto(Transaction entity) {
    return TransactionFirebaseDto(
      // id는 제외 (Firebase document ID로 별도 관리)
      title: entity.title,
      amount: entity.amount,
      type: entity.type.name,
      categoryId: entity.categoryId,
      date: entity.date.millisecondsSinceEpoch,
      description: entity.description,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    );
  }

  // Firestore 데이터 변환 (Map<String, dynamic>)
  static Map<String, dynamic> toFirestoreData(Transaction entity) {
    return toFirebaseDto(entity).toJson()..remove('id');
  }

  static TransactionType _parseTransactionType(String type) {
    return TransactionType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => TransactionType.expense, // 기본값
    );
  }
}
```

## 고급 매핑 패턴

### 1. 에러 처리가 포함된 Mapper
```dart
class SafeTransactionMapper {
  // Result 패턴 적용한 안전한 변환
  static Result<Transaction> safeFromDto(TransactionDto dto) {
    try {
      // 필수 필드 검증
      if (dto.id.isEmpty) {
        return Error(ValidationFailure('거래 ID는 필수입니다'));
      }

      if (dto.title.trim().isEmpty) {
        return Error(ValidationFailure('거래 제목은 필수입니다'));
      }

      if (dto.amount <= 0) {
        return Error(ValidationFailure('거래 금액은 0보다 커야 합니다'));
      }

      // 타입 변환 시도
      final transactionType = _safeParseTransactionType(dto.type);
      if (transactionType == null) {
        return Error(ValidationFailure('잘못된 거래 타입: ${dto.type}'));
      }

      // 날짜 변환 시도
      final date = _safeParseDate(dto.date);
      if (date == null) {
        return Error(ValidationFailure('잘못된 날짜 형식: ${dto.date}'));
      }

      final createdAt = _safeParseDate(dto.createdAt);
      if (createdAt == null) {
        return Error(ValidationFailure('잘못된 생성일 형식: ${dto.createdAt}'));
      }

      final updatedAt = _safeParseDate(dto.updatedAt);
      if (updatedAt == null) {
        return Error(ValidationFailure('잘못된 수정일 형식: ${dto.updatedAt}'));
      }

      // Entity 생성
      final transaction = Transaction(
        id: dto.id,
        title: dto.title.trim(),
        amount: dto.amount,
        type: transactionType,
        categoryId: dto.categoryId,
        date: date,
        description: dto.description?.trim(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      return Success(transaction);
    } catch (e) {
      return Error(ValidationFailure('거래 변환 중 오류 발생: ${e.toString()}'));
    }
  }

  // 안전한 타입 변환
  static TransactionType? _safeParseTransactionType(String? type) {
    if (type == null) return null;
    
    try {
      return TransactionType.values.firstWhere(
        (e) => e.name.toLowerCase() == type.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // 안전한 날짜 변환
  static DateTime? _safeParseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // 리스트 변환 (부분 실패 허용)
  static Result<List<Transaction>> safeFromDtoList(List<TransactionDto> dtos) {
    final List<Transaction> transactions = [];
    final List<String> errors = [];

    for (int i = 0; i < dtos.length; i++) {
      final result = safeFromDto(dtos[i]);
      switch (result) {
        case Success(data: final transaction):
          transactions.add(transaction);
        case Error(failure: final failure):
          errors.add('인덱스 $i: ${failure.message}');
      }
    }

    if (errors.isNotEmpty && transactions.isEmpty) {
      return Error(ValidationFailure('모든 거래 변환 실패: ${errors.join(', ')}'));
    }

    if (errors.isNotEmpty) {
      // 부분 성공 로그 (실제로는 로깅 시스템 사용)
      print('일부 거래 변환 실패: ${errors.join(', ')}');
    }

    return Success(transactions);
  }
}
```

### 2. 통계 데이터 Mapper (복합 변환)
```dart
class StatisticsMapper {
  // 복잡한 통계 DTO → Entity 변환
  static MonthlyStatistics fromDto(MonthlyStatisticsDto dto) {
    return MonthlyStatistics(
      year: dto.year,
      month: dto.month,
      totalIncome: dto.totalIncome,
      totalExpense: dto.totalExpense,
      balance: dto.balance,
      categoryBreakdown: _mapCategoryBreakdown(dto.categoryBreakdown),
      dailyData: _mapDailyData(dto.dailyData),
    );
  }

  // 카테고리 분석 데이터 변환
  static List<CategoryBreakdown> _mapCategoryBreakdown(
    List<CategoryBreakdownDto> dtos,
  ) {
    return dtos.map((dto) => CategoryBreakdown(
      categoryId: dto.categoryId,
      categoryName: dto.categoryName,
      amount: dto.amount,
      percentage: dto.percentage,
      transactionCount: dto.transactionCount,
    )).toList();
  }

  // 일별 데이터 변환
  static List<DailyData> _mapDailyData(List<DailyDataDto> dtos) {
    return dtos.map((dto) => DailyData(
      date: DateTime.parse(dto.date),
      income: dto.income,
      expense: dto.expense,
      transactionCount: dto.transactionCount,
    )).toList();
  }

  // Entity → DTO 변환 (리포트 생성용)
  static MonthlyStatisticsDto toDto(MonthlyStatistics entity) {
    return MonthlyStatisticsDto(
      year: entity.year,
      month: entity.month,
      totalIncome: entity.totalIncome,
      totalExpense: entity.totalExpense,
      balance: entity.balance,
      categoryBreakdown: entity.categoryBreakdown.map((breakdown) =>
        CategoryBreakdownDto(
          categoryId: breakdown.categoryId,
          categoryName: breakdown.categoryName,
          amount: breakdown.amount,
          percentage: breakdown.percentage,
          transactionCount: breakdown.transactionCount,
        ),
      ).toList(),
      dailyData: entity.dailyData.map((daily) =>
        DailyDataDto(
          date: daily.date.toIso8601String().split('T')[0], // YYYY-MM-DD
          income: daily.income,
          expense: daily.expense,
          transactionCount: daily.transactionCount,
        ),
      ).toList(),
    );
  }
}
```

### 3. Batch 변환 Mapper
```dart
class BatchTransactionMapper {
  // 대량 데이터 변환 (메모리 효율적)
  static Stream<Transaction> fromDtoStream(Stream<TransactionDto> dtoStream) {
    return dtoStream.map((dto) => TransactionMapper.fromDto(dto));
  }

  // 청크 단위 변환 (메모리 제한 환경)
  static List<List<Transaction>> fromDtoChunks(
    List<TransactionDto> dtos, {
    int chunkSize = 100,
  }) {
    final List<List<Transaction>> chunks = [];
    
    for (int i = 0; i < dtos.length; i += chunkSize) {
      final end = (i + chunkSize < dtos.length) ? i + chunkSize : dtos.length;
      final chunk = dtos.sublist(i, end);
      final entities = chunk.map((dto) => TransactionMapper.fromDto(dto)).toList();
      chunks.add(entities);
    }
    
    return chunks;
  }

  // 병렬 변환 (CPU 집약적 작업)
  static Future<List<Transaction>> fromDtoListParallel(
    List<TransactionDto> dtos,
  ) async {
    const int numberOfCores = 4; // 또는 Platform.numberOfProcessors
    final int chunkSize = (dtos.length / numberOfCores).ceil();
    
    final List<Future<List<Transaction>>> futures = [];
    
    for (int i = 0; i < dtos.length; i += chunkSize) {
      final end = (i + chunkSize < dtos.length) ? i + chunkSize : dtos.length;
      final chunk = dtos.sublist(i, end);
      
      futures.add(Future(() => 
        chunk.map((dto) => TransactionMapper.fromDto(dto)).toList()
      ));
    }
    
    final List<List<Transaction>> results = await Future.wait(futures);
    return results.expand((list) => list).toList();
  }
}
```

## Extension 활용 패턴

### 1. DTO Extension
```dart
extension TransactionDtoMapper on TransactionDto {
  // DTO에서 직접 Entity 변환
  Transaction toEntity() {
    return TransactionMapper.fromDto(this);
  }

  // 안전한 변환
  Result<Transaction> toEntitySafe() {
    return SafeTransactionMapper.safeFromDto(this);
  }
}

extension TransactionDtoListMapper on List<TransactionDto> {
  // 리스트 변환
  List<Transaction> toEntityList() {
    return map((dto) => dto.toEntity()).toList();
  }

  // 안전한 리스트 변환
  Result<List<Transaction>> toEntityListSafe() {
    return SafeTransactionMapper.safeFromDtoList(this);
  }
}
```

### 2. Entity Extension
```dart
extension TransactionEntityMapper on Transaction {
  // Entity에서 직접 DTO 변환
  TransactionDto toDto() {
    return TransactionMapper.toDto(this);
  }

  // Firebase DTO 변환
  TransactionFirebaseDto toFirebaseDto() {
    return TransactionFirebaseMapper.toFirebaseDto(this);
  }

  // 생성용 DTO 변환
  CreateTransactionDto toCreateDto() {
    return CreateTransactionDto(
      title: title,
      amount: amount,
      type: type.name,
      categoryId: categoryId,
      date: date.toIso8601String(),
      description: description,
    );
  }
}

extension TransactionEntityListMapper on List<Transaction> {
  // 리스트 DTO 변환
  List<TransactionDto> toDtoList() {
    return map((entity) => entity.toDto()).toList();
  }
}
```

## 특수 케이스 처리

### 1. 버전 호환성 Mapper
```dart
class VersionedTransactionMapper {
  // API 버전별 변환
  static Transaction fromDtoV1(TransactionDtoV1 dto) {
    return Transaction(
      id: dto.id,
      title: dto.title,
      amount: dto.amount,
      type: _parseTransactionType(dto.type),
      categoryId: dto.categoryId ?? 'default', // V1에는 categoryId가 없을 수 있음
      date: DateTime.parse(dto.date),
      description: dto.description,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  static Transaction fromDtoV2(TransactionDtoV2 dto) {
    return Transaction(
      id: dto.id,
      title: dto.title,
      amount: dto.amount,
      type: _parseTransactionType(dto.type),
      categoryId: dto.categoryId,
      date: DateTime.parse(dto.date),
      description: dto.description,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  // 버전 자동 감지 변환
  static Transaction fromDtoAnyVersion(Map<String, dynamic> json) {
    final version = json['version'] as String? ?? 'v1';
    
    switch (version) {
      case 'v1':
        return fromDtoV1(TransactionDtoV1.fromJson(json));
      case 'v2':
        return fromDtoV2(TransactionDtoV2.fromJson(json));
      default:
        throw UnsupportedError('지원하지 않는 API 버전: $version');
    }
  }

  static TransactionType _parseTransactionType(String type) {
    // 기존 로직과 동일
    return TransactionType.values.firstWhere(
      (e) => e.name.toLowerCase() == type.toLowerCase(),
      orElse: () => TransactionType.expense,
    );
  }
}
```

### 2. 부분 업데이트 Mapper
```dart
class UpdateTransactionMapper {
  // 부분 업데이트 DTO → Entity 병합
  static Transaction mergeUpdate(
    Transaction existing,
    UpdateTransactionDto updateDto,
  ) {
    return existing.copyWith(
      title: updateDto.title ?? existing.title,
      amount: updateDto.amount ?? existing.amount,
      type: updateDto.type != null 
          ? _parseTransactionType(updateDto.type!)
          : existing.type,
      categoryId: updateDto.categoryId ?? existing.categoryId,
      date: updateDto.date != null 
          ? DateTime.parse(updateDto.date!)
          : existing.date,
      description: updateDto.description ?? existing.description,
      updatedAt: DateTime.now(), // 수정 시간은 항상 현재 시간
    );
  }

  // Entity → 부분 업데이트 DTO
  static UpdateTransactionDto toUpdateDto(
    Transaction entity, {
    Set<String>? onlyFields,
  }) {
    if (onlyFields == null) {
      return UpdateTransactionDto(
        title: entity.title,
        amount: entity.amount,
        type: entity.type.name,
        categoryId: entity.categoryId,
        date: entity.date.toIso8601String(),
        description: entity.description,
      );
    }

    return UpdateTransactionDto(
      title: onlyFields.contains('title') ? entity.title : null,
      amount: onlyFields.contains('amount') ? entity.amount : null,
      type: onlyFields.contains('type') ? entity.type.name : null,
      categoryId: onlyFields.contains('categoryId') ? entity.categoryId : null,
      date: onlyFields.contains('date') ? entity.date.toIso8601String() : null,
      description: onlyFields.contains('description') ? entity.description : null,
    );
  }

  static TransactionType _parseTransactionType(String type) {
    return TransactionType.values.firstWhere(
      (e) => e.name.toLowerCase() == type.toLowerCase(),
      orElse: () => TransactionType.expense,
    );
  }
}
```

## Best Practices

### 1. 에러 처리
- **안전한 변환**: null 체크, 타입 검증
- **의미있는 에러**: 구체적인 에러 메시지
- **부분 실패 허용**: 일부 데이터만 실패해도 처리

### 2. 성능 최적화
- **Lazy 변환**: 필요할 때만 변환
- **Batch 처리**: 대량 데이터 청크 단위 처리
- **메모리 관리**: Stream, Iterator 활용

### 3. 타입 안전성
- **명시적 변환**: 암시적 변환 지양
- **기본값 제공**: 필수 데이터 누락 시 기본값
- **Enum 처리**: 안전한 Enum 변환

### 4. 확장성
- **Extension 활용**: 편의 메서드 제공
- **버전 호환성**: API 버전 변경 대응
- **재사용성**: 공통 변환 로직 분리

## 체크리스트

### Mapper 정의
- [ ] static 메서드로 구현
- [ ] fromDto/toDto 메서드 제공
- [ ] 타입 변환 로직 포함
- [ ] 에러 처리 로직 구현

### 변환 로직
- [ ] null 안전성 확보
- [ ] 기본값 처리
- [ ] 타입 검증 로직
- [ ] 의미있는 에러 메시지

### 성능 최적화
- [ ] 대량 데이터 처리 고려
- [ ] 메모리 효율성 확보
- [ ] 불필요한 변환 최소화
- [ ] 캐싱 전략 (필요시)

### 코드 품질
- [ ] Extension 활용
- [ ] 테스트 가능한 구조
- [ ] 문서화 및 예제
- [ ] 버전 호환성 고려