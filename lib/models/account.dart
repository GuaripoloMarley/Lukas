import '../data/database_helper.dart';

class Account {
  int? id;
  String name;
  double balance;
  String currency;
  int color;
  String icon;
  DateTime createdDate;

  Account({
    this.id,
    required this.name,
    required this.balance,
    required this.currency,
    required this.color,
    required this.icon,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) colAccountId: id,
      colAccountName: name,
      colAccountBalance: balance,
      colAccountCurrency: currency,
      colAccountColor: color,
      colAccountIcon: icon,
      colAccountCreatedDate: createdDate.toIso8601String(),
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map[colAccountId],
      name: map[colAccountName],
      balance: (map[colAccountBalance] as num).toDouble(),
      currency: map[colAccountCurrency],
      color: map[colAccountColor],
      icon: map[colAccountIcon],
      createdDate: DateTime.parse(map[colAccountCreatedDate]),
    );
  }

  Account copyWith({
    int? id,
    String? name,
    double? balance,
    String? currency,
    int? color,
    String? icon,
    DateTime? createdDate,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
