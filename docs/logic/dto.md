# DTO 설계 가이드

## 개요
DTO(Data Transfer Object)는 데이터 전송을 위한 객체로, API 응답, 로컬 저장소, Firebase 등 외부 데이터 소스와의 통신에 사용됩니다.
Domain Entity와 외부 데이터 형식 간의 변환을 담당합니다.

## 기본 원칙

### 1. 직렬화/역직렬화
- JSON 직렬화 지원 필수
- fromJson/toJson 메서드 제공
- 외부 API 스펙에 맞는 필드명 사용

### 2. 검증 없음
- 비즈니스 로직 포함하지 않음
- 단순한 데이터 컨테이너 역할
- 검증은 Entity에서 담당

### 3. Nullable 허용
- 외부 데이터의 불완전성 허용
- null 값 처리 가능
- 안전한 기본값 제공

## 기본 구조

### 1. freezed 3.0 기반 DTO
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_dto.freezed.dart';
part 'transaction_dto.g.dart';

@freezed
class TransactionDto with _$TransactionDto {
  const TransactionDto({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    @JsonKey(name: 'category_id') required this.categoryId,
    required this.date,
    this.description,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  final String id;
  final String title;
  final double amount;
  final String type; // enum이 아닌 String으로 받음
  final String categoryId;
  final String date; // DateTime이 아닌 String으로 받음
  final String? description;
  final String createdAt;
  final String updatedAt;

  // JSON 직렬화
  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);
}
```

### 2. Firebase DTO (Firestore용)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_firebase_dto.freezed.dart';
part 'transaction_firebase_dto.g.dart';

@freezed
class TransactionFirebaseDto with _$TransactionFirebaseDto {
  const TransactionFirebaseDto({
    this.id, // Firestore에서는 document ID가 별도
    required this.title,
    required this.amount,
    required this.type,
    @JsonKey(name: 'categoryId') required this.categoryId,
    required this.date, // Timestamp 처리
    this.description,
    @JsonKey(name: 'createdAt') required this.createdAt,
    @JsonKey(name: 'updatedAt') required this.updatedAt,
  });

  final String? id;
  final String title;
  final double amount;
  final String type;
  final String categoryId;
  final int date; // Firebase Timestamp (milliseconds)
  final String? description;
  final int createdAt;
  final int updatedAt;

  factory TransactionFirebaseDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionFirebaseDtoFromJson(json);
}
```

### 3. API 응답 DTO (중첩 구조)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_response_dto.freezed.dart';
part 'transaction_response_dto.g.dart';

@freezed
class TransactionResponseDto with _$TransactionResponseDto {
  const TransactionResponseDto({
    required this.success,
    this.message,
    this.data,
    this.pagination,
  });

  final bool success;
  final String? message;
  final TransactionDataDto? data;
  final PaginationDto? pagination;

  factory TransactionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionResponseDtoFromJson(json);
}

@freezed
class TransactionDataDto with _$TransactionDataDto {
  const TransactionDataDto({
    required this.transactions,
    required this.totalCount,
    this.summary,
  });

  final List<TransactionDto> transactions;
  @JsonKey(name: 'total_count') final int totalCount;
  final TransactionSummaryDto? summary;

  factory TransactionDataDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDataDtoFromJson(json);
}

@freezed
class PaginationDto with _$PaginationDto {
  const PaginationDto({
    @JsonKey(name: 'current_page') required this.currentPage,
    @JsonKey(name: 'per_page') required this.perPage,
    @JsonKey(name: 'total_pages') required this.totalPages,
    @JsonKey(name: 'has_next') required this.hasNext,
  });

  final int currentPage;
  final int perPage;
  final int totalPages;
  final bool hasNext;

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);
}
```

### 4. 생성/수정용 Request DTO
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_transaction_dto.freezed.dart';
part 'create_transaction_dto.g.dart';

@freezed
class CreateTransactionDto with _$CreateTransactionDto {
  const CreateTransactionDto({
    required this.title,
    required this.amount,
    required this.type,
    @JsonKey(name: 'category_id') required this.categoryId,
    required this.date,
    this.description,
  });

  final String title;
  final double amount;
  final String type;
  final String categoryId;
  final String date;
  final String? description;

  factory CreateTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTransactionDtoFromJson(json);
}

@freezed
class UpdateTransactionDto with _$UpdateTransactionDto {
  const UpdateTransactionDto({
    this.title,
    this.amount,
    this.type,
    @JsonKey(name: 'category_id') this.categoryId,
    this.date,
    this.description,
  });

  final String? title;
  final double? amount;
  final String? type;
  final String? categoryId;
  final String? date;
  final String? description;

  factory UpdateTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateTransactionDtoFromJson(json);
}
```

## 복잡한 DTO 구조

### 1. 카테고리 DTO (계층 구조)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_dto.freezed.dart';
part 'category_dto.g.dart';

@freezed
class CategoryDto with _$CategoryDto {
  const CategoryDto({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    @JsonKey(name: 'parent_id') this.parentId,
    @JsonKey(name: 'icon_name') required this.iconName,
    @JsonKey(name: 'color_code') required this.colorCode,
    @JsonKey(name: 'budget_limit') required this.budgetLimit,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'sub_categories') this.subCategories,
  });

  final String id;
  final String name;
  final String? description;
  final String type;
  final String? parentId;
  final String iconName;
  final String colorCode;
  final double budgetLimit;
  final String createdAt;
  final List<CategoryDto>? subCategories; // 중첩 구조

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);
}
```

### 2. 통계 DTO (복합 데이터)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_dto.freezed.dart';
part 'statistics_dto.g.dart';

@freezed
class MonthlyStatisticsDto with _$MonthlyStatisticsDto {
  const MonthlyStatisticsDto({
    required this.year,
    required this.month,
    @JsonKey(name: 'total_income') required this.totalIncome,
    @JsonKey(name: 'total_expense') required this.totalExpense,
    required this.balance,
    @JsonKey(name: 'category_breakdown') required this.categoryBreakdown,
    @JsonKey(name: 'daily_data') required this.dailyData,
  });

  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<CategoryBreakdownDto> categoryBreakdown;
  final List<DailyDataDto> dailyData;

  factory MonthlyStatisticsDto.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStatisticsDtoFromJson(json);
}

@freezed
class CategoryBreakdownDto with _$CategoryBreakdownDto {
  const CategoryBreakdownDto({
    @JsonKey(name: 'category_id') required this.categoryId,
    @JsonKey(name: 'category_name') required this.categoryName,
    required this.amount,
    required this.percentage,
    @JsonKey(name: 'transaction_count') required this.transactionCount,
  });

  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;
  final int transactionCount;

  factory CategoryBreakdownDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryBreakdownDtoFromJson(json);
}

@freezed
class DailyDataDto with _$DailyDataDto {
  const DailyDataDto({
    required this.date,
    required this.income,
    required this.expense,
    @JsonKey(name: 'transaction_count') required this.transactionCount,
  });

  final String date;
  final double income;
  final double expense;
  final int transactionCount;

  factory DailyDataDto.fromJson(Map<String, dynamic> json) =>
      _$DailyDataDtoFromJson(json);
}
```

## 데이터 소스별 DTO 구분

### 1. REST API DTO
```dart
// 스네이크 케이스 필드명 사용
@freezed
class TransactionApiDto with _$TransactionApiDto {
  const TransactionApiDto({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    @JsonKey(name: 'category_id') required this.categoryId,
    required this.date,
    this.description,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  // ... 필드 정의

  factory TransactionApiDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionApiDtoFromJson(json);
}
```

### 2. Firebase Firestore DTO
```dart
// 카멜 케이스 필드명 사용 (Firebase 컨벤션)
@freezed
class TransactionFirestoreDto with _$TransactionFirestoreDto {
  const TransactionFirestoreDto({
    this.id, // Document ID는 별도 관리
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId, // 카멜 케이스
    required this.date,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String title;
  final double amount;
  final String type;
  final String categoryId;
  final int date; // Timestamp (milliseconds)
  final String? description;
  final int createdAt;
  final int updatedAt;

  factory TransactionFirestoreDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionFirestoreDtoFromJson(json);
}
```

### 3. SQLite 로컬 DTO
```dart
@freezed
class TransactionLocalDto with _$TransactionLocalDto {
  const TransactionLocalDto({
    this.id, // AUTO INCREMENT
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus, // 동기화 상태
  });

  final int? id; // 로컬 DB의 INTEGER PRIMARY KEY
  final String title;
  final double amount;
  final String type;
  final String categoryId;
  final String date;
  final String? description;
  final String createdAt;
  final String updatedAt;
  final String? syncStatus; // 'synced', 'pending', 'failed'

  factory TransactionLocalDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionLocalDtoFromJson(json);
}
```

## 에러 처리 DTO

### 1. API 에러 응답 DTO
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_response_dto.freezed.dart';
part 'error_response_dto.g.dart';

@freezed
class ErrorResponseDto with _$ErrorResponseDto {
  const ErrorResponseDto({
    required this.success,
    required this.message,
    @JsonKey(name: 'error_code') this.errorCode,
    @JsonKey(name: 'error_details') this.errorDetails,
    this.timestamp,
  });

  final bool success;
  final String message;
  final String? errorCode;
  final List<ErrorDetailDto>? errorDetails;
  final String? timestamp;

  factory ErrorResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseDtoFromJson(json);
}

@freezed
class ErrorDetailDto with _$ErrorDetailDto {
  const ErrorDetailDto({
    required this.field,
    required this.message,
    this.code,
  });

  final String field;
  final String message;
  final String? code;

  factory ErrorDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ErrorDetailDtoFromJson(json);
}
```

## JSON 어노테이션 활용

### 1. 필드명 매핑
```dart
@freezed
class TransactionDto with _$TransactionDto {
  const TransactionDto({
    required this.id,
    @JsonKey(name: 'transaction_title') required this.title,
    @JsonKey(name: 'amount_value') required this.amount,
    @JsonKey(name: 'transaction_type') required this.type,
  });

  final String id;
  final String title;
  final double amount;
  final String type;

  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);
}
```

### 2. 기본값 처리
```dart
@freezed
class ConfigDto with _$ConfigDto {
  const ConfigDto({
    @JsonKey(defaultValue: 'KRW') required this.currency,
    @JsonKey(defaultValue: true) required this.notificationEnabled,
    @JsonKey(defaultValue: 1000000.0) required this.defaultBudget,
  });

  final String currency;
  final bool notificationEnabled;
  final double defaultBudget;

  factory ConfigDto.fromJson(Map<String, dynamic> json) =>
      _$ConfigDtoFromJson(json);
}
```

### 3. 커스텀 변환
```dart
@freezed
class DateTransactionDto with _$DateTransactionDto {
  const DateTransactionDto({
    required this.id,
    @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
    required this.date,
  });

  final String id;
  final DateTime date;

  // 커스텀 변환 함수
  static DateTime _dateFromJson(String dateStr) {
    return DateTime.parse(dateStr);
  }

  static String _dateToJson(DateTime date) {
    return date.toIso8601String();
  }

  factory DateTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$DateTransactionDtoFromJson(json);
}
```

## Best Practices

### 1. 네이밍
- **DTO 접미사**: 모든 DTO 클래스에 Dto 접미사 사용
- **소스 구분**: ApiDto, FirestoreDto, LocalDto 등으로 구분
- **용도 구분**: CreateDto, UpdateDto, ResponseDto 등

### 2. 구조
- **단순성 유지**: 비즈니스 로직 포함하지 않음
- **Nullable 허용**: 외부 데이터의 불완전성 허용
- **JSON 지원**: fromJson/toJson 필수 구현

### 3. 타입 안전성
- **String 우선**: 외부에서 받는 데이터는 String으로
- **변환은 Mapper에서**: DTO → Entity 변환 시 타입 변환
- **null 처리**: null 값에 대한 안전한 처리

### 4. 성능
- **필요한 필드만**: 불필요한 필드 제거
- **중첩 최소화**: 깊은 중첩 구조 지양
- **List 처리**: 대량 데이터 처리 시 성능 고려

## 체크리스트

### DTO 정의
- [ ] @freezed 어노테이션 사용
- [ ] fromJson/toJson 구현
- [ ] part 파일 import 추가
- [ ] 적절한 @JsonKey 사용

### 필드 설계
- [ ] 외부 API 스펙에 맞는 필드명
- [ ] 적절한 nullable 처리
- [ ] 기본값 설정 (필요시)
- [ ] 커스텀 변환 로직 (필요시)

### 코드 생성
- [ ] part 파일 선언
- [ ] build_runner 실행 설정
- [ ] JSON 직렬화 테스트
- [ ] 스키마 변경 대응

### 문서화
- [ ] DTO 역할 명시
- [ ] 외부 스키마 참조
- [ ] 변환 규칙 문서화
- [ ] 예제 데이터 제공