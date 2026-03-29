import 'package:sqflite/sqflite.dart';
import 'package:lukas/data/database_helper.dart';
import '../../models/account.dart';

class AccountProvider {
  late final Database _db;

  AccountProvider(this._db);

  Future<int> insert(Account account) async {
    return await _db.insert(
      accountsTable,
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Account account) async {
    return await _db.update(
      accountsTable,
      account.toMap(),
      where: '$colAccountId = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> delete(int id) async {
    return await _db.delete(
      accountsTable,
      where: '$colAccountId = ?',
      whereArgs: [id],
    );
  }

  Future<Account?> getById(int id) async {
    final maps = await _db.query(
      accountsTable,
      where: '$colAccountId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Account>> getAll() async {
    final maps = await _db.query(accountsTable);
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  Future<double> getBalance(int accountId) async {
    final result = await _db.rawQuery(
      'SELECT SUM(CASE WHEN type = "income" THEN amount ELSE -amount END) as balance '
      'FROM $transactionsTable WHERE $colTransactionAccountId = ?',
      [accountId],
    );

    if (result.isNotEmpty && result.first['balance'] != null) {
      return (result.first['balance'] as num).toDouble();
    }
    return 0.0;
  }
}
