import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budget.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String dbPath;
    
    // Use path_provider for desktop, getDatabasesPath for mobile
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      final directory = await getApplicationDocumentsDirectory();
      dbPath = directory.path;
    } else {
      dbPath = await getDatabasesPath();
    }
    
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        category TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        is_default INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Initialize default categories
    await _initializeDefaultCategories(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add categories table
      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          is_default INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');

      // Initialize default categories
      await _initializeDefaultCategories(db);
    }
  }

  Future<void> _initializeDefaultCategories(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Insert default income categories
    for (final name in AppConstants.incomeCategories) {
      await db.insert('categories', {
        'name': name,
        'type': AppConstants.typeIncome,
        'is_default': 1,
        'created_at': now,
      });
    }

    // Insert default expense categories
    for (final name in AppConstants.expenseCategories) {
      await db.insert('categories', {
        'name': name,
        'type': AppConstants.typeExpense,
        'is_default': 1,
        'created_at': now,
      });
    }
  }

  Future<int> createTransaction(BudgetTransaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<BudgetTransaction?> readTransaction(int id) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BudgetTransaction.fromMap(maps.first);
    }
    return null;
  }

  Future<List<BudgetTransaction>> readAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((map) => BudgetTransaction.fromMap(map)).toList();
  }

  Future<List<BudgetTransaction>> readTransactionsByMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 1).toIso8601String();

    final maps = await db.query(
      'transactions',
      where: 'date >= ? AND date < ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );

    return maps.map((map) => BudgetTransaction.fromMap(map)).toList();
  }

  Future<int> updateTransaction(BudgetTransaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, double>> getMonthlyStats(int year, int month) async {
    final transactions = await readTransactionsByMonth(year, month);
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in transactions) {
      if (transaction.type == AppConstants.typeIncome) {
        totalIncome += transaction.amount;
      } else if (transaction.type == AppConstants.typeExpense) {
        totalExpenses += transaction.amount;
      }
    }

    return {
      'income': totalIncome,
      'expenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
    };
  }

  // Category CRUD operations
  Future<List<BudgetCategory>> getCategoriesByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return maps.map((map) => BudgetCategory.fromMap(map)).toList();
  }

  Future<int> createCategory(BudgetCategory category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<BudgetCategory?> readCategory(int id) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BudgetCategory.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCategory(BudgetCategory category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> categoryNameExists(String name, String type, {int? excludeId}) async {
    final db = await database;
    final whereClause = excludeId != null
        ? 'name = ? AND type = ? AND id != ?'
        : 'name = ? AND type = ?';
    final whereArgs = excludeId != null
        ? [name, type, excludeId]
        : [name, type];

    final maps = await db.query(
      'categories',
      where: whereClause,
      whereArgs: whereArgs,
    );
    return maps.isNotEmpty;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null; // Reset the database instance
  }
}
