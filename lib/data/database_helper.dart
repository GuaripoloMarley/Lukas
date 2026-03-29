import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const String dbName = 'lukas.db';

// Tabla: cuentas (wallets)
const String accountsTable = 'accounts';
const String colAccountId = '_id';
const String colAccountName = 'name';
const String colAccountBalance = 'balance';
const String colAccountCurrency = 'currency';
const String colAccountColor = 'color';
const String colAccountIcon = 'icon';
const String colAccountCreatedDate = 'created_date';

// Tabla: categorías
const String categoriesTable = 'categories';
const String colCategoryId = '_id';
const String colCategoryName = 'name';
const String colCategoryIcon = 'icon';
const String colCategoryColor = 'color';
const String colCategoryType = 'type'; // 'expense' o 'income'

// Tabla: transacciones
const String transactionsTable = 'transactions';
const String colTransactionId = '_id';
const String colTransactionAccountId = 'account_id';
const String colTransactionCategoryId = 'category_id';
const String colTransactionAmount = 'amount';
const String colTransactionNote = 'note';
const String colTransactionType = 'type'; // 'expense' o 'income'
const String colTransactionDate = 'date';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, dbName);

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de cuentas
    await db.execute('''
      CREATE TABLE $accountsTable(
        $colAccountId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colAccountName TEXT NOT NULL,
        $colAccountBalance REAL NOT NULL DEFAULT 0.0,
        $colAccountCurrency TEXT NOT NULL DEFAULT 'CLP',
        $colAccountColor INTEGER NOT NULL,
        $colAccountIcon TEXT NOT NULL,
        $colAccountCreatedDate TEXT NOT NULL
      )
    ''');

    // Crear tabla de categorías
    await db.execute('''
      CREATE TABLE $categoriesTable(
        $colCategoryId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colCategoryName TEXT NOT NULL UNIQUE,
        $colCategoryIcon TEXT NOT NULL,
        $colCategoryColor INTEGER NOT NULL,
        $colCategoryType TEXT NOT NULL
      )
    ''');

    // Crear tabla de transacciones
    await db.execute('''
      CREATE TABLE $transactionsTable(
        $colTransactionId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colTransactionAccountId INTEGER NOT NULL,
        $colTransactionCategoryId INTEGER,
        $colTransactionAmount REAL NOT NULL,
        $colTransactionNote TEXT,
        $colTransactionType TEXT NOT NULL,
        $colTransactionDate TEXT NOT NULL,
        FOREIGN KEY($colTransactionAccountId) REFERENCES $accountsTable($colAccountId)
      )
    ''');

    // Insertar categorías por defecto
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {
        colCategoryName: 'Comida',
        colCategoryIcon: '🍔',
        colCategoryColor: 0xFFFF6B6B,
        colCategoryType: 'expense',
      },
      {
        colCategoryName: 'Transporte',
        colCategoryIcon: '🚗',
        colCategoryColor: 0xFF4ECDC4,
        colCategoryType: 'expense',
      },
      {
        colCategoryName: 'Compras',
        colCategoryIcon: '🛍️',
        colCategoryColor: 0xFFFFD93D,
        colCategoryType: 'expense',
      },
      {
        colCategoryName: 'Ocio',
        colCategoryIcon: '🎮',
        colCategoryColor: 0xFFA855F7,
        colCategoryType: 'expense',
      },
      {
        colCategoryName: 'Cuentas',
        colCategoryIcon: '📄',
        colCategoryColor: 0xFF6BCB77,
        colCategoryType: 'expense',
      },
      {
        colCategoryName: 'Viajes',
        colCategoryIcon: '✈️',
        colCategoryColor: 0xFF3B82F6,
        colCategoryType: 'expense',
      },
      {
        colCategoryName: 'Salud',
        colCategoryIcon: '⚕️',
        colCategoryColor: 0xFFEF4444,
        colCategoryType: 'expense',
      },
      {
        colCategoryName: 'Ingreso',
        colCategoryIcon: '💰',
        colCategoryColor: 0xFF10B981,
        colCategoryType: 'income',
      },
    ];

    for (final category in defaultCategories) {
      await db.insert(
        categoriesTable,
        category,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
