# 🧬 Model (Entity) 설계 가이드

## ✅ 목적

Model(Entity)은 앱 내부에서 사용하는 **도메인 중심의 데이터 구조**입니다.  
ViewModel, UseCase, Repository 등에서 공통적으로 사용되며,  
외부 의존성이 없는 **순수 비즈니스 객체**로 유지하는 것이 원칙입니다.

---

## 🧱 설계 원칙

- 모든 모델은 **Freezed 3.0** 기반으로 정의
- 불변성(Immutable) 유지
- **필수값은 `required`**, 선택값은 `nullable` 처리
- API 기반 DTO와는 분리하며, 필요 시 Mapper를 통해 변환
- **freezed 3.0 최신 방식**으로 직접 constructor를 작성 (sealed class + 일반 생성자)
- **비즈니스 로직** 포함 (계산된 속성, 검증 메서드, 상태 확인 등)

---

## ✅ 파일 위치 및 네이밍

| 항목 | 규칙 |
|------|------|
| 파일 경로 | `lib/features/{기능}/domain/entities/` |
| 파일명 | `snake_case.dart` (예: `transaction.dart`) |
| 클래스명 | `PascalCase` (예: `Transaction`) |
| 관련 파일 | `.freezed.dart` 는 codegen 자동 생성 |

---

## ✅ 예시

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

/// 거래 타입 열거형
enum TransactionType {
  income('수입'),
  expense('지출');

  const TransactionType(this.displayName);
  
  final String displayName;

  bool get isIncome => this == TransactionType.income;
  bool get isExpense => this == TransactionType.expense;
}

/// 거래 도메인 모델
@freezed
sealed class Transaction with _$Transaction {
  const Transaction._();

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 팩토리 생성자 (검증 포함)
  factory Transaction.create({
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? description,
  }) {
    // 제목 검증
    if (title.trim().isEmpty) {
      throw ArgumentError('거래 제목은 비어있을 수 없습니다');
    }

    // 금액 검증
    if (amount <= 0) {
      throw ArgumentError('거래 금액은 0보다 커야 합니다');
    }

    // 카테고리 검증
    if (categoryId.trim().isEmpty) {
      throw ArgumentError('카테고리는 필수입니다');
    }

    final now = DateTime.now();
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    return Transaction(
      id: id,
      title: title.trim(),
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      description: description?.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }

  // 비즈니스 로직 메서드들
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isToday => DateTime.now().difference(date).inDays == 0;
  bool get isThisMonth => 
      DateTime.now().year == date.year && 
      DateTime.now().month == date.month;
  
  // 검증 메서드
  bool get isValid => 
      amount > 0 && 
      title.trim().isNotEmpty && 
      categoryId.trim().isNotEmpty;

  // 거래 업데이트 (새 인스턴스 반환)
  Transaction updateAmount(double newAmount) {
    if (newAmount <= 0) {
      throw ArgumentError('거래 금액은 0보다 커야 합니다');
    }
    return copyWith(
      amount: newAmount,
      updatedAt: DateTime.now(),
    );
  }

  Transaction updateTitle(String newTitle) {
    if (newTitle.trim().isEmpty) {
      throw ArgumentError('거래 제목은 비어있을 수 없습니다');
    }
    return copyWith(
      title: newTitle.trim(),
      updatedAt: DateTime.now(),
    );
  }
}
```

---

## 📌 설계 팁

### 1. 비즈니스 로직 포함
- **계산된 속성**: `get` 메서드로 표현
- **상태 확인**: boolean 반환 메서드
- **비즈니스 메서드**: 새 인스턴스 반환
- **검증 로직**: 팩토리 생성자에서

### 2. 불변성 유지
- 모든 필드는 `final`
- 데이터 변경 시 `copyWith`로 새 인스턴스 생성
- 비즈니스 메서드도 새 인스턴스 반환

### 3. 타입 안전성
- **강타입 사용**: `DateTime`, `double`, `int` 등
- **Enum 활용**: 상태나 타입을 명확히 표현
- **null 안전성**: 선택적 필드만 nullable

---

## 🧪 테스트 전략

### Entity 단위 테스트

```dart
group('Transaction Entity 테스트', () {
  test('create 팩토리 생성자로 유효한 Transaction 생성', () {
    // Given
    const title = '커피';
    const amount = 4500.0;
    const type = TransactionType.expense;
    const categoryId = 'food';
    final date = DateTime.now();

    // When
    final transaction = Transaction.create(
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
    );

    // Then
    expect(transaction.title, title);
    expect(transaction.amount, amount);
    expect(transaction.type, type);
    expect(transaction.categoryId, categoryId);
    expect(transaction.isValid, true);
    expect(transaction.isExpense, true);
    expect(transaction.isIncome, false);
  });

  test('유효하지 않은 제목으로 생성 시 ArgumentError 발생', () {
    // When & Then
    expect(
      () => Transaction.create(
        title: '',
        amount: 4500.0,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime.now(),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
});
```

---