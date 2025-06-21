import 'package:freezed_annotation/freezed_annotation.dart';

part 'history.freezed.dart';

/// 거래 타입 열거형
enum HistoryType {
  income('수입'),
  expense('지출');

  const HistoryType(this.displayName);

  final String displayName;

  bool get isIncome => this == HistoryType.income;
  bool get isExpense => this == HistoryType.expense;
}

/// 거래 도메인 모델
@freezed
sealed class History with _$History {
  const History._();

  const History({
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
  final HistoryType type;
  final String categoryId;
  final DateTime date;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 팩토리 생성자 (검증 포함)
  factory History.create({
    required String title,
    required double amount,
    required HistoryType type,
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

    return History(
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
  bool get isIncome => type == HistoryType.income;
  bool get isExpense => type == HistoryType.expense;
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
  History updateAmount(double newAmount) {
    if (newAmount <= 0) {
      throw ArgumentError('거래 금액은 0보다 커야 합니다');
    }
    return copyWith(
      amount: newAmount,
      updatedAt: DateTime.now(),
    );
  }

  History updateTitle(String newTitle) {
    if (newTitle.trim().isEmpty) {
      throw ArgumentError('거래 제목은 비어있을 수 없습니다');
    }
    return copyWith(
      title: newTitle.trim(),
      updatedAt: DateTime.now(),
    );
  }
}