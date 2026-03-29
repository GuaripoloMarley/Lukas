import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';
import '../data/providers/account_provider.dart';
import '../data/providers/category_provider.dart';
import '../data/providers/transaction_provider.dart';
import '../models/account.dart';
import '../models/categoria.dart';
import '../models/category.dart';
import '../models/gasto.dart';
import '../models/transaction_model.dart';
import '../services/currency_service.dart';

class AppState extends ChangeNotifier {
  // Configuración (SharedPreferences)
  bool esPremium = false, modoOscuro = false, bloqueoActivado = false;
  String moneda = 'CLP', idioma = 'Español';
  String? pinCode, geminiApiKey;
  int topeGastosMensual = 0;

  // Datos de SQLite
  final List<Account> _accounts = [];
  final List<Category> _categories = [];
  final List<Transaction> _transactions = [];
  int? _activeAccountId;

  List<Account> get accounts => _accounts;
  List<Category> get categories => _categories;
  List<Transaction> get transactions => _transactions;
  int? get activeAccountId => _activeAccountId;

  Account? get activeAccount {
    if (_activeAccountId == null) return null;
    try {
      return _accounts.firstWhere((a) => a.id == _activeAccountId);
    } catch (e) {
      return null;
    }
  }

  // Compatibilidad con código antiguo
  late List<Categoria> categorias;
  final List<Gasto> _gastos = [];
  List<Gasto> get gastos => _gastos;

  AppState() {
    categorias = [
      Categoria(
        nombre: 'Comida',
        icono: Icons.restaurant_rounded,
        color: const Color(0xFFFF6B6B),
      ),
      Categoria(
        nombre: 'Transporte',
        icono: Icons.directions_bus_rounded,
        color: const Color(0xFF4ECDC4),
      ),
      Categoria(
        nombre: 'Compras',
        icono: Icons.shopping_bag_rounded,
        color: const Color(0xFFFFD93D),
      ),
      Categoria(
        nombre: 'Ocio',
        icono: Icons.sports_esports_rounded,
        color: const Color(0xFFA855F7),
      ),
      Categoria(
        nombre: 'Cuentas',
        icono: Icons.receipt_long_rounded,
        color: const Color(0xFF6BCB77),
      ),
      Categoria(
        nombre: 'Viajes',
        icono: Icons.flight_takeoff_rounded,
        color: const Color(0xFF3B82F6),
      ),
      Categoria(
        nombre: 'Salud',
        icono: Icons.local_hospital_rounded,
        color: const Color(0xFFEF4444),
      ),
      Categoria(
        nombre: 'Otro',
        icono: Icons.category_rounded,
        color: const Color(0xFF94A3B8),
      ),
    ];
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    modoOscuro = prefs.getBool('modoOscuro') ?? false;
    esPremium = prefs.getBool('esPremium') ?? false;
    moneda = prefs.getString('moneda') ?? 'CLP';
    pinCode = prefs.getString('pinCode');
    geminiApiKey = prefs.getString('geminiApiKey');
    bloqueoActivado = pinCode != null;
    _activeAccountId = prefs.getInt('activeAccountId');

    // Cargar datos del legacy (si existen)
    final gastosJson = prefs.getString('gastos');
    if (gastosJson != null) {
      final List decode = jsonDecode(gastosJson);
      _gastos.clear();
      _gastos.addAll(decode.map((m) => Gasto.fromMap(m)).toList());
    }

    // Cargar datos de SQLite
    try {
      final database = await DatabaseHelper().database;
      final accountProvider = AccountProvider(database);
      final categoryProvider = CategoryProvider(database);
      final transactionProvider = TransactionProvider(database);

      _accounts.clear();
      _accounts.addAll(await accountProvider.getAll());

      _categories.clear();
      _categories.addAll(await categoryProvider.getAll());

      _transactions.clear();
      _transactions.addAll(await transactionProvider.getAll());

      // Si no hay cuenta activa, usar la primera
      if (_activeAccountId == null && _accounts.isNotEmpty) {
        _activeAccountId = _accounts.first.id;
        await prefs.setInt('activeAccountId', _activeAccountId!);
      }
    } catch (e) {
      // Base de datos aún no inicializada
      debugPrint('Error loading database: $e');
    }
    // Precargar tasas al inicio
    await CurrencyService.getRates();
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modoOscuro', modoOscuro);
    await prefs.setBool('esPremium', esPremium);
    await prefs.setString('moneda', moneda);
    if (pinCode != null) {
      await prefs.setString('pinCode', pinCode!);
    } else {
      await prefs.remove('pinCode');
    }
    if (geminiApiKey != null) {
      await prefs.setString('geminiApiKey', geminiApiKey!);
    } else {
      await prefs.remove('geminiApiKey');
    }
    if (_activeAccountId != null) {
      await prefs.setInt('activeAccountId', _activeAccountId!);
    }

    // Guardar datos legacy
    final gastosJson = jsonEncode(_gastos.map((g) => g.toMap()).toList());
    await prefs.setString('gastos', gastosJson);
  }

  // Métodos para cuentas
  Future<void> addAccount(Account account) async {
    final database = await DatabaseHelper().database;
    final accountProvider = AccountProvider(database);
    final id = await accountProvider.insert(account);
    account.id = id;
    _accounts.add(account);
    if (_activeAccountId == null) {
      _activeAccountId = id;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('activeAccountId', id);
    }
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    final database = await DatabaseHelper().database;
    final accountProvider = AccountProvider(database);
    await accountProvider.update(account);
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
    }
    notifyListeners();
  }

  Future<void> deleteAccount(int accountId) async {
    final database = await DatabaseHelper().database;
    final accountProvider = AccountProvider(database);
    await accountProvider.delete(accountId);
    _accounts.removeWhere((a) => a.id == accountId);
    if (_activeAccountId == accountId && _accounts.isNotEmpty) {
      _activeAccountId = _accounts.first.id;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('activeAccountId', _activeAccountId!);
    }
    notifyListeners();
  }

  Future<void> setActiveAccount(int accountId) async {
    _activeAccountId = accountId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('activeAccountId', accountId);
    notifyListeners();
  }

  // Métodos para transacciones
  Future<void> addTransaction(Transaction transaction) async {
    final database = await DatabaseHelper().database;
    final transactionProvider = TransactionProvider(database);
    final accountProvider = AccountProvider(database);
    final id = await transactionProvider.insert(transaction);
    transaction.id = id;
    _transactions.insert(0, transaction);
    // Actualizar saldo de la cuenta
    if (_activeAccountId != null) {
      final balance = await accountProvider.getBalance(_activeAccountId!);
      final account = activeAccount;
      if (account != null) {
        account.balance = balance;
        await accountProvider.update(account);
      }
    }
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final database = await DatabaseHelper().database;
    final transactionProvider = TransactionProvider(database);
    await transactionProvider.update(transaction);
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
    notifyListeners();
  }

  Future<void> deleteTransaction(int transactionId) async {
    final database = await DatabaseHelper().database;
    final transactionProvider = TransactionProvider(database);
    await transactionProvider.delete(transactionId);
    _transactions.removeWhere((t) => t.id == transactionId);
    notifyListeners();
  }

  // Métodos para categorías
  Future<List<Category>> getCategoriesByType(String type) async {
    final database = await DatabaseHelper().database;
    final categoryProvider = CategoryProvider(database);
    return await categoryProvider.getAllByType(type);
  }

  // Método antiguo para compatibilidad
  void agregarGasto(Gasto g) {
    _gastos.insert(0, g);
    saveData();
    notifyListeners();
  }

  void eliminarGasto(String id) {
    _gastos.removeWhere((g) => g.id == id);
    saveData();
    notifyListeners();
  }

  void toggleModoOscuro() {
    modoOscuro = !modoOscuro;
    saveData();
    notifyListeners();
  }

  void establecerPin(String pin) {
    pinCode = pin;
    bloqueoActivado = true;
    saveData();
    notifyListeners();
  }

  void desactivarBloqueo() {
    bloqueoActivado = false;
    pinCode = null;
    saveData();
    notifyListeners();
  }

  void activarPremium() {
    esPremium = true;
    saveData();
    notifyListeners();
  }

  void establecerGeminiKey(String key) {
    geminiApiKey = key.isEmpty ? null : key;
    saveData();
    notifyListeners();
  }

  Categoria obtenerCategoria(String nombre) => categorias.firstWhere(
    (c) => c.nombre == nombre,
    orElse: () => categorias.last,
  );

  List<Gasto> get gastosMesActual {
    final now = DateTime.now();
    return _gastos
        .where((g) => g.fecha.month == now.month && g.fecha.year == now.year)
        .toList();
  }

  List<Gasto> get gastosSemanaActual {
    final hace7 = DateTime.now().subtract(const Duration(days: 7));
    return _gastos.where((g) => g.fecha.isAfter(hace7)).toList();
  }

  double get totalMes => gastosMesActual.fold(0.0, (s, g) => s + g.monto);
  bool get puedeAgregar => esPremium || _gastos.length < 50;

  Future<double> convertirMoneda(double monto, String de, String a) async {
    return await CurrencyService.convert(monto, de, a);
  }
}

final appState = AppState();
