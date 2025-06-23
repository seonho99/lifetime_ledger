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
- **Firebase 통합**: `fromFirestore`, `toFirestore` 메서드 제공
- **json_serializable 사용**: @JsonSerializable 어노테이션 활용

---

## ✅ 파일 위치 및 네이밍

| 항목 | 규칙 |
|------|------|
| 파일 경로 | `lib/features/{기능}/data/dto/` |
| 파일명 | `{entity_name}_dto.dart` (예: `history_dto.dart`) |
| 클래스명 | PascalCase + `Dto` 접미사 (예: `HistoryDto`) |
| codegen 파일 | `.g.dart` 자동 생성 (`json_serializable` 사용 시) |

---

## ✅ 기본 DTO 예시

### History DTO (실제 구현)

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'history_dto.g.dart';

@JsonSerializable()
class HistoryDto {
  const HistoryDto({
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

  factory HistoryDto.fromJson(Map<String, dynamic> json) => 
      _$HistoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryDtoToJson(this);

  /// Firebase Firestore Document에서 생성
  factory HistoryDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HistoryDto(
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
  HistoryDto copyWith({
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
    return HistoryDto(
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

### Transaction DTO (확장 예시)

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
import 'history_dto.dart';

part 'history_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class HistoryResponseDto {
  const HistoryResponseDto({
    this.success,
    this.message,
    this.data,
    this.pagination,
  });

  final bool? success;
  final String? message;
  final List<HistoryDto>? data;
  final PaginationDto? pagination;

  factory HistoryResponseDto.fromJson(Map<String, dynamic> json) => 
      _$HistoryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryResponseDtoToJson(this);
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
import 'package:cloud_firestore/cloud_firestore.dart';

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
class HistoryViewModel extends ChangeNotifier {
  List<HistoryDto> histories = []; // 잘못됨!
}

// ✅ 올바른 사용 - Repository에서 변환 후 Entity 사용
class HistoryRepositoryImpl implements HistoryRepository {
  @override
  Future<Result<List<History>>> getHistories() async {
    final dtos = await _dataSource.getHistories();
    final entities = dtos.toModelList(); // DTO → Entity 변환
    return Success(entities);
  }
}
```

> 참고: [mapper.md](mapper.md)

---

## ✅ Firebase 통합 특화

### 1. **Firestore 전용 메서드**
```dart
/// Firebase 전용 생성자
factory HistoryDto.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return HistoryDto(
    id: doc.id, // 문서 ID 자동 매핑
    // ... 필드 매핑
  );
}

/// Firebase 전용 저장 메서드
Map<String, dynamic> toFirestore() {
  return {
    // Timestamp 변환 포함
    'date': date != null ? Timestamp.fromDate(date!) : null,
    // ... 다른 필드들
  };
}
```

### 2. **Timestamp 처리**
```dart
// Firestore Timestamp ↔ DateTime 변환
date: (data['date'] as Timestamp?)?.toDate(),
createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
```

### 3. **필드명 매핑**
```dart
// JSON API용 (snake_case)
@JsonKey(name: 'category_id')
final String? categoryId;

// Firestore용 (camelCase) - toFirestore에서 처리
'categoryId': categoryId,
```

---

## ✅ 기타 고려사항

| 항목 | 설명 |
|:---|:---|
| **불완전한 응답 대비** | 모든 필드를 `nullable`로 선언 |
| **Firebase 우선** | `fromFirestore`, `toFirestore` 메서드 우선 제공 |
| **JSON API 호환** | `fromJson`, `toJson` 메서드로 REST API 대응 |
| **숫자 타입 안전성** | API에서 int/double이 혼재할 수 있으므로 `num` 사용 |
| **copyWith 지원** | 업데이트 작업을 위한 copyWith 메서드 제공 |
| **Timestamp 변환** | Firebase Timestamp와 DateTime 간 자동 변환 |

---

## ✅ 중첩 및 리스트 구조 예시

### 복잡한 중첩 구조 DTO

```dart
@JsonSerializable(explicitToJson: true)
class HistoryWithCategoryDto {
  const HistoryWithCategoryDto({
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

  factory HistoryWithCategoryDto.fromJson(Map<String, dynamic> json) => 
      _$HistoryWithCategoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryWithCategoryDtoToJson(this);
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
group('HistoryDto 테스트', () {
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
    final dto = HistoryDto.fromJson(json);

    // Then
    expect(dto.id, '1');
    expect(dto.title, '커피');
    expect(dto.amount, 4500);
    expect(dto.type, 'expense');
    expect(dto.categoryId, 'food');
  });

  test('toJson으로 DTO를 JSON으로 변환', () {
    // Given
    final dto = HistoryDto(
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

  test('Firebase Firestore 변환 테스트', () {
    // Given
    final dto = HistoryDto(
      title: '커피',
      amount: 4500,
      type: 'expense',
      categoryId: 'food',
      date: DateTime(2024, 1, 15),
    );

    // When
    final firestoreMap = dto.toFirestore();

    // Then
    expect(firestoreMap['title'], '커피');
    expect(firestoreMap['amount'], 4500);
    expect(firestoreMap['type'], 'expense');
    expect(firestoreMap['categoryId'], 'food');
    expect(firestoreMap['date'], isA<Timestamp>());
  });

  test('null 값이 포함된 JSON도 안전하게 처리', () {
    // Given
    final json = <String, dynamic>{
      'id': null,
      'title': null,
      'amount': null,
    };

    // When
    final dto = HistoryDto.fromJson(json);

    // Then
    expect(dto.id, null);
    expect(dto.title, null);
    expect(dto.amount, null);
  });
});
```

---

## 📋 실제 구현과의 차이점

### 1. **파일명 변경**
- `transaction_dto.dart` → `history_dto.dart` (실제 구현에 맞춤)

### 2. **Firebase 우선**
- `fromFirestore`, `toFirestore` 메서드를 기본 제공
- Timestamp 변환 로직 포함

### 3. **copyWith 메서드**
- 실제 구현에서 사용하는 업데이트 패턴 반영

### 4. **필드명 일관성**
- 실제 Firebase 필드명과 일치 (camelCase)
- JSON API용 snake_case 매핑 유지

---