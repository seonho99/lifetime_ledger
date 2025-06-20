# 📥 DTO (Data Transfer Object) 설계 가이드

## ✅ 목적

DTO는 외부 시스템(API, Firebase 등)과의 통신을 위한  
**입출력 전용 데이터 구조**입니다.
앱 내부에서 직접 사용하는 도메인 모델(Entity)와는 분리되어야 하며,  
Mapper를 통해 변환해서 사용합니다.

---

## 🧱 설계 원칙

- **nullable 허용**: 외부 응답은 항상 불완전할 수 있으므로 모든 필드는 nullable로 정의
- **숫자형은 `num` 기본 사용**: API에서 `int`/`double` 구분이 불명확한 경우 대비
- `fromJson`, `toJson` 메서드 포함
- `@JsonKey`로 snake_case → camelCase 매핑 대응
- **중첩/리스트 구조 포함 시 `explicitToJson: true`를 설정하여 명시적으로 JSON 변환**
- **json_serializable 사용**: @JsonSerializable 어노테이션 활용

---

## ✅ 파일 위치 및 네이밍

| 항목 | 규칙 |
|------|------|
| 파일 경로 | `lib/features/{기능}/data/models/` |
| 파일명 | `{entity_name}_dto.dart` (예: `transaction_dto.dart`) |
| 클래스명 | PascalCase + `Dto` 접미사 (예: `TransactionDto`) |
| codegen 파일 | `.g.dart` 자동 생성 (`json_serializable` 사용 시) |

---

## ✅ 기본 DTO 예시

### Transaction DTO

```dart
import 'package:json_annotation/json_annotation.dart';

part 'transaction_dto.g.dart';

@JsonSerializable()
class TransactionDto {
  const TransactionDto({
    this.id,
    this.title,
    this.amount,
    this.type,
    this.categoryId,
    this.date,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? title;
  final num? amount;
  final String? type;
  
  @JsonKey(name: 'category_id')
  final String? categoryId;
  
  final DateTime? date;
  final String? description;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  factory TransactionDto.fromJson(Map<String, dynamic> json) => 
      _$TransactionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionDtoToJson(this);

  /// Firebase Firestore Document에서 생성
  factory TransactionDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionDto(
      id: doc.id,
      title: data['title'],
      amount: data['amount'],
      type: data['type'],
      categoryId: data['categoryId'],
      date: (data['date'] as Timestamp?)?.toDate(),
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Firebase Firestore에 저장할 Map 생성
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'description': description,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// copyWith 메서드 (업데이트용)
  TransactionDto copyWith({
    String? id,
    String? title,
    num? amount,
    String? type,
    String? categoryId,
    DateTime? date,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionDto(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

### API 응답 래퍼 DTO

```dart
import 'package:json_annotation/json_annotation.dart';
import 'transaction_dto.dart';

part 'transaction_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class TransactionResponseDto {
  const TransactionResponseDto({
    this.success,
    this.message,
    this.data,
    this.pagination,
  });

  final bool? success;
  final String? message;
  final List<TransactionDto>? data;
  final PaginationDto? pagination;

  factory TransactionResponseDto.fromJson(Map<String, dynamic> json) => 
      _$TransactionResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionResponseDtoToJson(this);
}

@JsonSerializable()
class PaginationDto {
  const PaginationDto({
    this.currentPage,
    this.totalPages,
    this.totalItems,
    this.itemsPerPage,
  });

  @JsonKey(name: 'current_page')
  final int? currentPage;
  
  @JsonKey(name: 'total_pages')
  final int? totalPages;
  
  @JsonKey(name: 'total_items')
  final int? totalItems;
  
  @JsonKey(name: 'items_per_page')
  final int? itemsPerPage;

  factory PaginationDto.fromJson(Map<String, dynamic> json) => 
      _$PaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationDtoToJson(this);
}
```

### Category DTO

```dart
import 'package:json_annotation/json_annotation.dart';

part 'category_dto.g.dart';

@JsonSerializable()
class CategoryDto {
  const CategoryDto({
    this.id,
    this.name,
    this.description,
    this.type,
    this.parentId,
    this.iconName,
    this.colorCode,
    this.budgetLimit,
    this.isActive,
    this.createdAt,
  });

  final String? id;
  final String? name;
  final String? description;
  final String? type;
  
  @JsonKey(name: 'parent_id')
  final String? parentId;
  
  @JsonKey(name: 'icon_name')
  final String? iconName;
  
  @JsonKey(name: 'color_code')
  final String? colorCode;
  
  @JsonKey(name: 'budget_limit')
  final num? budgetLimit;
  
  @JsonKey(name: 'is_active')
  final bool? isActive;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  factory CategoryDto.fromJson(Map<String, dynamic> json) => 
      _$CategoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryDtoToJson(this);

  /// Firebase Firestore Document에서 생성
  factory CategoryDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryDto(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      type: data['type'],
      parentId: data['parentId'],
      iconName: data['iconName'],
      colorCode: data['colorCode'],
      budgetLimit: data['budgetLimit'],
      isActive: data['isActive'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Firebase Firestore에 저장할 Map 생성
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'parentId': parentId,
      'iconName': iconName,
      'colorCode': colorCode,
      'budgetLimit': budgetLimit,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
```

---

## 🔁 DTO ↔ Entity 변환

- DTO는 직접 앱에 사용하지 않고 반드시 **Mapper**를 통해 Entity로 변환합니다.
- DTO는 ViewModel 또는 UI에서 직접 접근하지 않습니다.
- Repository에서 DataSource로부터 DTO를 받아 Mapper로 Entity 변환 후 반환합니다.

```dart
// ❌ 잘못된 사용 - ViewModel에서 DTO 직접 사용
class TransactionViewModel extends ChangeNotifier {
  List<TransactionDto> transactions = []; // 잘못됨!
}

// ✅ 올바른 사용 - Repository에서 변환 후 Entity 사용
class TransactionRepositoryImpl implements TransactionRepository {
  @override
  Future<Result<List<Transaction>>> getTransactions() async {
    final dtos = await _remoteDataSource.getTransactions();
    final entities = TransactionMapper.toEntityList(dtos); // DTO → Entity 변환
    return Success(entities);
  }
}
```

> 참고: [mapper.md](mapper.md)

---

## ✅ 기타 고려사항

| 항목 | 설명 |
|:---|:---|
| **불완전한 응답 대비** | 모든 필드를 `nullable`로 선언 |
| **서버 응답 필드명 다름** | `@JsonKey(name: "snake_case")` 활용 |
| **리스트/중첩 구조** | `List<SubDto>?`, `SubDto.fromJson()`을 통해 변환. `toJson` 시 `@JsonSerializable(explicitToJson: true)` 설정 필요 |
| **숫자 타입 안전성** | API에서 int/double이 혼재할 수 있으므로 `num` 사용 |
| **Firebase 대응** | `fromFirestore()`, `toFirestore()` 메서드 별도 제공 |
| **copyWith 지원** | 업데이트 작업을 위한 copyWith 메서드 제공 |

---

## ✅ 중첩 및 리스트 구조 예시

### 복잡한 중첩 구조 DTO

```dart
@JsonSerializable(explicitToJson: true)
class TransactionWithCategoryDto {
  const TransactionWithCategoryDto({
    this.id,
    this.title,
    this.amount,
    this.category,
    this.tags,
  });

  final String? id;
  final String? title;
  final num? amount;
  final CategoryDto? category;
  final List<TagDto>? tags;

  factory TransactionWithCategoryDto.fromJson(Map<String, dynamic> json) => 
      _$TransactionWithCategoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionWithCategoryDtoToJson(this);
}

@JsonSerializable()
class TagDto {
  const TagDto({
    this.id,
    this.name,
    this.color,
  });

  final String? id;
  final String? name;
  final String? color;

  factory TagDto.fromJson(Map<String, dynamic> json) => 
      _$TagDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TagDtoToJson(this);
}
```

> 중요: 내부 DTO들의 `toJson()` 호출을 명시적으로 처리할 때 `explicitToJson: true`를 포함해야 안전함.

---

## 🧪 테스트 전략

### DTO 직렬화/역직렬화 테스트

```dart
group('TransactionDto 테스트', () {
  test('fromJson으로 JSON에서 DTO 생성', () {
    // Given
    final json = {
      'id': '1',
      'title': '커피',
      'amount': 4500,
      'type': 'expense',
      'category_id': 'food',
      'created_at': '2024-01-15T10:30:00Z',
    };

    // When
    final dto = TransactionDto.fromJson(json);

    // Then
    expect(dto.id, '1');
    expect(dto.title, '커피');
    expect(dto.amount, 4500);
    expect(dto.type, 'expense');
    expect(dto.categoryId, 'food');
  });

  test('toJson으로 DTO를 JSON으로 변환', () {
    // Given
    final dto = TransactionDto(
      id: '1',
      title: '커피',
      amount: 4500,
      type: 'expense',
      categoryId: 'food',
    );

    // When
    final json = dto.toJson();

    // Then
    expect(json['id'], '1');
    expect(json['title'], '커피');
    expect(json['amount'], 4500);
    expect(json['type'], 'expense');
    expect(json['category_id'], 'food');
  });

  test('null 값이 포함된 JSON도 안전하게 처리', () {
    // Given
    final json = <String, dynamic>{
      'id': null,
      'title': null,
      'amount': null,
    };

    // When
    final dto = TransactionDto.fromJson(json);

    // Then
    expect(dto.id, null);
    expect(dto.title, null);
    expect(dto.amount, null);
  });
});
```

---
