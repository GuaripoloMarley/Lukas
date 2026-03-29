import 'package:sqflite/sqflite.dart';
import 'package:lukas/data/database_helper.dart';
import '../../models/category.dart';

class CategoryProvider {
  late final Database _db;

  CategoryProvider(this._db);

  Future<int> insert(Category category) async {
    return await _db.insert(
      categoriesTable,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Category category) async {
    return await _db.update(
      categoriesTable,
      category.toMap(),
      where: '$colCategoryId = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(int id) async {
    return await _db.delete(
      categoriesTable,
      where: '$colCategoryId = ?',
      whereArgs: [id],
    );
  }

  Future<Category?> getById(int id) async {
    final maps = await _db.query(
      categoriesTable,
      where: '$colCategoryId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Category>> getAll() async {
    final maps = await _db.query(categoriesTable);
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<Category>> getAllByType(String type) async {
    final maps = await _db.query(
      categoriesTable,
      where: '$colCategoryType = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }
}
