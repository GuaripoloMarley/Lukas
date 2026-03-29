import 'package:sqflite/sqflite.dart';
import 'package:lukas/data/database_helper.dart';
import '../../models/transaction_model.dart' as tm;

class TransactionProvider {
  late final Database _db;

  TransactionProvider(this._db);

  Future<int> insert(tm.Transaction transaction) async {
    return await _db.insert(
      transactionsTable,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(tm.Transaction transaction) async {
    return await _db.update(
      transactionsTable,
      transaction.toMap(),
      where: '$colTransactionId = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> delete(int id) async {
    return await _db.delete(
      transactionsTable,
      where: '$colTransactionId = ?',
      whereArgs: [id],
    );
  }

  Future<tm.Transaction?> getById(int id) async {
    final maps = await _db.query(
      transactionsTable,
      where: '$colTransactionId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return tm.Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<List<tm.Transaction>> getAll() async {
    final maps = await _db.query(
      transactionsTable,
      orderBy: '$colTransactionDate DESC',
    );
    return List.generate(maps.length, (i) => tm.Transaction.fromMap(maps[i]));
  }

  Future<List<tm.Transaction>> getByAccountId(int accountId) async {
    final maps = await _db.query(
      transactionsTable,
      where: '$colTransactionAccountId = ?',
      whereArgs: [accountId],
      orderBy: '$colTransactionDate DESC',
    );
    return List.generate(maps.length, (i) => tm.Transaction.fromMap(maps[i]));
  }

  Future<List<tm.Transaction>> getByDateRange(
    DateTime start,
    DateTime end, {
    int? accountId,
  }) async {
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    String where = '$colTransactionDate >= ? AND $colTransactionDate <= ?';
    List<dynamic> whereArgs = [startStr, endStr];

    if (accountId != null) {
      where += ' AND $colTransactionAccountId = ?';
      whereArgs.add(accountId);
    }

    final maps = await _db.query(
      transactionsTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: '$colTransactionDate DESC',
    );
    return List.generate(maps.length, (i) => tm.Transaction.fromMap(maps[i]));
  }

  Future<List<tm.Transaction>> getByCategory(int categoryId) async {
    final maps = await _db.query(
      transactionsTable,
      where: '$colTransactionCategoryId = ?',
      whereArgs: [categoryId],
      orderBy: '$colTransactionDate DESC',
    );
    return List.generate(maps.length, (i) => tm.Transaction.fromMap(maps[i]));
  }

  Future<Map<int, double>> getMonthlyTotals(int accountId, String type) async {
    final result = await _db.rawQuery(
      '''
      SELECT 
        strftime('%Y-%m', $colTransactionDate) as month,
        SUM($colTransactionAmount) as total
      FROM $transactionsTable
      WHERE $colTransactionAccountId = ? AND $colTransactionType = ?
      GROUP BY strftime('%Y-%m', $colTransactionDate)
      ORDER BY month DESC
      ''',
      [accountId, type],
    );

    final map = <int, double>{};
    for (final row in result) {
      // Convertir mes en timestamp o índice si es necesario
      map[row['month'].toString().hashCode] = (row['total'] as num).toDouble();
    }
    return map;
  }
}
