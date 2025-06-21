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
class History with _$History {
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

  // 헬퍼 메서드들
  String get formattedAmount => '₩${amount.toStringAsFixed(0)}';

  String get typeDisplayName => type.displayName;

  bool get isRecent => DateTime.now().difference(createdAt).inDays <= 7;
}