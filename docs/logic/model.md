# 도메인 모델 설계 가이드

## 개요
도메인 모델(Entity)은 비즈니스 로직의 핵심을 담당하는 순수한 Dart 객체입니다.
외부 의존성 없이 비즈니스 규칙과 데이터 구조만을 표현합니다.

## 기본 원칙

### 1. 순수성
- 외부 패키지 의존성 없음 (Flutter, Firebase 등)
- 비즈니스 로직만 포함
- 불변 객체로 설계

### 2. 불변성
- 모든 필드는 final
- 데이터 변경 시 새 인스턴스 생성
- copyWith 메서드로 부분 업데이트

### 3. 검증 로직
- 생성자에서 유효성 검사
- 비즈니스 규칙 강제
- 잘못된 상태 방지

## 기본 구조

### 1. freezed 3.0 기반 Entity
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

@freezed
class Transaction with _$Transaction {
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

  // 비즈니스 로직 메서드
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isToday => DateTime.now().difference(date).inDays == 0;
  
  // 검증 메서드
  bool get isValid => amount > 0 && title.trim().isNotEmpty;
}
```

### 2. Enum 정의
```dart
enum TransactionType {
  income('수입'),
  expense('지출');

  const TransactionType(this.displayName);
  
  final String displayName;

  bool get isIncome => this == TransactionType.income;
  bool get isExpense => this == TransactionType.expense;
}
```

### 3. 복잡한 Entity (중첩 객체)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
class Category with _$Category {
  Category({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.parentId,
    required this.iconName,
    required this.colorCode,
    required this.budgetLimit,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final CategoryType type;
  final String? parentId;
  final String iconName;
  final String colorCode;
  final double budgetLimit;
  final DateTime createdAt;

  // 비즈니스 로직
  bool get isParentCategory => parentId == null;
  bool get isSubCategory => parentId != null;
  bool get hasValidBudget => budgetLimit > 0;
  bool get isIncomeCategory => type == CategoryType.income;
  bool get isExpenseCategory => type == CategoryType.expense;
}

enum CategoryType {
  income('수입'),
  expense('지출');

  const CategoryType(this.displayName);
  final String displayName;
}
```

## 비즈니스 로직 포함

### 1. 계산 로직이 있는 Entity
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';

@freezed
class Budget with _$Budget {
  Budget({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.spentAmount,
    required this.startDate,
    required this.endDate,
    required this.period,
  });

  final String id;
  final String categoryId;
  final double limitAmount;
  final double spentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPeriod period;

  // 계산된 속성들
  double get remainingAmount => limitAmount - spentAmount;
  double get usagePercentage => (spentAmount / limitAmount * 100).clamp(0, 100);
  bool get isOverBudget => spentAmount > limitAmount;
  bool get isWarningLevel => usagePercentage >= 80;
  bool get isActive => DateTime.now().isBefore(endDate);

  // 예산 상태
  BudgetStatus get status {
    if (!isActive) return BudgetStatus.expired;
    if (isOverBudget) return BudgetStatus.exceeded;
    if (isWarningLevel) return BudgetStatus.warning;
    return BudgetStatus.normal;
  }

  // 비즈니스 메서드
  Budget addExpense(double amount) {
    return copyWith(spentAmount: spentAmount + amount);
  }

  Budget updateLimit(double newLimit) {
    return copyWith(limitAmount: newLimit);
  }
}

enum BudgetPeriod {
  weekly('주간'),
  monthly('월간'),
  yearly('연간');

  const BudgetPeriod(this.displayName);
  final String displayName;
}

enum BudgetStatus {
  normal('정상'),
  warning('경고'),
  exceeded('초과'),
  expired('만료');

  const BudgetStatus(this.displayName);
  final String displayName;
}
```

### 2. 검증 로직이 있는 Entity
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String email,
    required String displayName,
    String? photoUrl,
    required UserSettings settings,
    required DateTime createdAt,
    required DateTime lastLoginAt,
  }) = _User;

  // 팩토리 생성자 (검증 포함)
  factory User.create({
    required String id,
    required String email,
    required String displayName,
    String? photoUrl,
    UserSettings? settings,
  }) {
    // 이메일 검증
    if (!_isValidEmail(email)) {
      throw ArgumentError('유효하지 않은 이메일 형식입니다: $email');
    }

    // 이름 검증
    if (displayName.trim().isEmpty) {
      throw ArgumentError('사용자 이름은 비어있을 수 없습니다');
    }

    final now = DateTime.now();
    return User(
      id: id,
      email: email.toLowerCase().trim(),
      displayName: displayName.trim(),
      photoUrl: photoUrl,
      settings: settings ?? UserSettings.defaultSettings(),
      createdAt: now,
      lastLoginAt: now,
    );
  }

  // 이메일 검증 헬퍼
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}
    );
  }
}
```

## Best Practices

### 1. 네이밍
- **명사 사용**: Transaction, Category, Budget
- **비즈니스 용어**: 도메인 전문가가 사용하는 용어
- **약어 지양**: 의미가 명확한 전체 단어 사용

### 2. 구조
- **순수성 유지**: 외부 의존성 없음
- **불변성 보장**: final 필드, copyWith 패턴
- **검증 로직**: 팩토리 생성자 또는 생성자에서

### 3. 비즈니스 로직
- **계산된 속성**: get 메서드로 표현
- **상태 확인**: boolean 반환 메서드
- **비즈니스 메서드**: 새 인스턴스 반환

### 4. 테스트 용이성
- **순수 함수**: 동일 입력 → 동일 출력
- **불변성**: 부작용 없음
- **검증 가능**: 명확한 비즈니스 규칙


## 체크리스트

### Entity 정의
- [ ] @freezed 어노테이션 사용
- [ ] const 생성자와 private constructor 정의
- [ ] part 파일 import 추가
- [ ] 비즈니스 로직 메서드 구현

### 비즈니스 로직
- [ ] 계산된 속성 정의 (get 메서드)
- [ ] 검증 로직 포함 (팩토리 생성자)
- [ ] 상태 확인 메서드 (boolean 반환)
- [ ] 비즈니스 메서드 구현 (새 인스턴스 반환)

### 코드 품질
- [ ] 외부 의존성 없음 (순수 Dart)
- [ ] 명확한 네이밍
- [ ] 적절한 주석
- [ ] freezed 코드 생성 설정 (`dart run build_runner build`)).hasMatch(email);
  }

  // 로그인 시간 업데이트
  User updateLastLogin() {
  return copyWith(lastLoginAt: DateTime.now());
  }

  // 비즈니스 로직
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
  bool get isActive => DateTime.now().difference(lastLoginAt).inDays < 30;
  }

@freezed
class UserSettings with _$UserSettings {
const UserSettings._();

const factory UserSettings({
required String currency,
required String locale,
required bool darkMode,
required bool notificationEnabled,
required double monthlyBudgetLimit,
}) = _UserSettings;

factory UserSettings.defaultSettings() {
return const UserSettings(
currency: 'KRW',
locale: 'ko_KR',
darkMode: false,
notificationEnabled: true,
monthlyBudgetLimit: 1000000,
);
}

bool get hasValidBudgetLimit => monthlyBudgetLimit > 0;
}

## Best Practices

### 1. 네이밍
- **명사 사용**: Transaction, Category, Budget
- **비즈니스 용어**: 도메인 전문가가 사용하는 용어
- **약어 지양**: 의미가 명확한 전체 단어 사용

### 2. 구조
- **순수성 유지**: 외부 의존성 없음
- **불변성 보장**: final 필드, copyWith 패턴
- **검증 로직**: 팩토리 생성자 또는 생성자에서

### 3. 비즈니스 로직
- **계산된 속성**: get 메서드로 표현
- **상태 확인**: boolean 반환 메서드
- **비즈니스 메서드**: 새 인스턴스 반환

### 4. 테스트 용이성
- **순수 함수**: 동일 입력 → 동일 출력
- **불변성**: 부작용 없음
- **검증 가능**: 명확한 비즈니스 규칙


## 체크리스트

### Entity 정의
- [ ] 모든 필드 final 선언
- [ ] copyWith 메서드 구현
- [ ] 동등성 비교 구현 (== 및 hashCode)
- [ ] toString 메서드 구현

### 비즈니스 로직
- [ ] 계산된 속성 정의
- [ ] 검증 로직 포함
- [ ] 상태 확인 메서드
- [ ] 비즈니스 메서드 구현

### 코드 품질
- [ ] 외부 의존성 없음
- [ ] 명확한 네이밍
- [ ] 적절한 주석
- [ ] 테스트 가능한 구조