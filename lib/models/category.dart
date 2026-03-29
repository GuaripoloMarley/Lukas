import '../data/database_helper.dart';

class Category {
  int? id;
  String name;
  String icon;
  int color;
  String type; // 'expense' o 'income'

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) colCategoryId: id,
      colCategoryName: name,
      colCategoryIcon: icon,
      colCategoryColor: color,
      colCategoryType: type,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map[colCategoryId],
      name: map[colCategoryName],
      icon: map[colCategoryIcon],
      color: map[colCategoryColor],
      type: map[colCategoryType],
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    int? color,
    String? type,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }
}
