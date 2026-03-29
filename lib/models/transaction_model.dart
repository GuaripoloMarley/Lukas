import '../data/database_helper.dart';

class Transaction {
  int? id;
  int accountId;
  int? categoryId;
  double amount;
  String? note;
  String type; // 'expense' o 'income'
  DateTime date;

  Transaction({
    this.id,
    required this.accountId,
    this.categoryId,
    required this.amount,
    this.note,
    required this.type,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) colTransactionId: id,
      colTransactionAccountId: accountId,
      if (categoryId != null) colTransactionCategoryId: categoryId,
      colTransactionAmount: amount,
      if (note != null) colTransactionNote: note,
      colTransactionType: type,
      colTransactionDate: date.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map[colTransactionId],
      accountId: map[colTransactionAccountId],
      categoryId: map[colTransactionCategoryId],
      amount: (map[colTransactionAmount] as num).toDouble(),
      note: map[colTransactionNote],
      type: map[colTransactionType],
      date: DateTime.parse(map[colTransactionDate]),
    );
  }

  Transaction copyWith({
    int? id,
    int? accountId,
    int? categoryId,
    double? amount,
    String? note,
    String? type,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }
}
