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

  // Developer Tools Methods
  
  /// Resets the database by deleting all transactions and resetting categories to defaults
  Future<void> resetDatabase() async {
    final db = await database;
    
    // Delete all transactions
    await db.delete('transactions');
    
    // Delete all categories
    await db.delete('categories');
    
    // Re-initialize default categories
    await _initializeDefaultCategories(db);
  }

  /// Loads dummy data for testing and demo purposes
  Future<int> loadDummyData() async {
    final db = await database;
    final now = DateTime.now();
    int transactionsAdded = 0;
    
    // Get all categories to use in transactions
    final incomeCategories = await getCategoriesByType(AppConstants.typeIncome);
    final expenseCategories = await getCategoriesByType(AppConstants.typeExpense);
    
    if (incomeCategories.isEmpty || expenseCategories.isEmpty) {
      throw Exception('Categories must be initialized before loading dummy data');
    }
    
    // Generate transactions for the last 6 months
    for (int monthOffset = 0; monthOffset < 6; monthOffset++) {
      final monthDate = DateTime(now.year, now.month - monthOffset, 1);
      
      // Income Transactions
      // Salary - monthly on 1st
      final salaryAmount = 4500.0 + (monthOffset * 200.0); // Vary between 4500-5500
      await _createDummyTransaction(
        db,
        AppConstants.typeIncome,
        salaryAmount,
        'Monthly Salary Payment',
        'Salary',
        DateTime(monthDate.year, monthDate.month, 1),
      );
      transactionsAdded++;
      
      // Rental Income - monthly on 5th
      if (monthOffset % 2 == 0) { // Every other month
        final rentalAmount = 1200.0 + (monthOffset * 100.0);
        await _createDummyTransaction(
          db,
          AppConstants.typeIncome,
          rentalAmount,
          'Property Rental Income',
          'Rental Income',
          DateTime(monthDate.year, monthDate.month, 5),
        );
        transactionsAdded++;
      }
      
      // Freelance - occasional
      if (monthOffset % 3 == 0) {
        final freelanceAmount = 200.0 + (monthOffset * 250.0);
        await _createDummyTransaction(
          db,
          AppConstants.typeIncome,
          freelanceAmount,
          'Freelance Project',
          'Freelance',
          DateTime(monthDate.year, monthDate.month, 15),
        );
        transactionsAdded++;
      }
      
      // Investments - occasional dividends
      if (monthOffset % 4 == 0) {
        final investmentAmount = 50.0 + (monthOffset * 80.0);
        await _createDummyTransaction(
          db,
          AppConstants.typeIncome,
          investmentAmount,
          'Investment Dividends',
          'Investments',
          DateTime(monthDate.year, monthDate.month, 20),
        );
        transactionsAdded++;
      }
      
      // Expense Transactions
      // Mortgage - monthly
      final mortgageAmount = 1800.0 + (monthOffset * 80.0);
      await _createDummyTransaction(
        db,
        AppConstants.typeExpense,
        mortgageAmount,
        'Monthly Mortgage Payment',
        'Mortgage',
        DateTime(monthDate.year, monthDate.month, 1),
      );
      transactionsAdded++;
      
      // Utilities - monthly
      final utilitiesAmount = 150.0 + (monthOffset * 25.0);
      await _createDummyTransaction(
        db,
        AppConstants.typeExpense,
        utilitiesAmount,
        'Utilities Bill',
        'Bills & Utilities',
        DateTime(monthDate.year, monthDate.month, 10),
      );
      transactionsAdded++;
      
      // Management Fees - monthly
      final managementAmount = 150.0 + (monthOffset * 30.0);
      await _createDummyTransaction(
        db,
        AppConstants.typeExpense,
        managementAmount,
        'Property Management Fees',
        'Management Fees',
        DateTime(monthDate.year, monthDate.month, 15),
      );
      transactionsAdded++;
      
      // Food & Dining - multiple per month
      final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
      for (int i = 0; i < 8; i++) {
        final foodAmount = 50.0 + (i * 15.0);
        int day = 3 + (i * 3);
        if (day > daysInMonth) day = daysInMonth;
        await _createDummyTransaction(
          db,
          AppConstants.typeExpense,
          foodAmount,
          i % 2 == 0 ? 'Grocery Shopping' : 'Restaurant Dining',
          'Food & Dining',
          DateTime(monthDate.year, monthDate.month, day),
        );
        transactionsAdded++;
      }
      
      // Transportation - multiple per month
      for (int i = 0; i < 5; i++) {
        final transportAmount = 40.0 + (i * 20.0);
        int day = 2 + (i * 5);
        if (day > daysInMonth) day = daysInMonth;
        await _createDummyTransaction(
          db,
          AppConstants.typeExpense,
          transportAmount,
          i % 2 == 0 ? 'Gas/Fuel' : 'Public Transport',
          'Transportation',
          DateTime(monthDate.year, monthDate.month, day),
        );
        transactionsAdded++;
      }
      
      // Shopping - occasional
      if (monthOffset % 2 == 0) {
        final shoppingAmount = 100.0 + (monthOffset * 40.0);
        await _createDummyTransaction(
          db,
          AppConstants.typeExpense,
          shoppingAmount,
          'Shopping',
          'Shopping',
          DateTime(monthDate.year, monthDate.month, 18),
        );
        transactionsAdded++;
      }
      
      // Entertainment - occasional
      if (monthOffset % 2 == 1) {
        final entertainmentAmount = 50.0 + (monthOffset * 10.0);
        await _createDummyTransaction(
          db,
          AppConstants.typeExpense,
          entertainmentAmount,
          'Entertainment',
          'Entertainment',
          DateTime(monthDate.year, monthDate.month, 22),
        );
        transactionsAdded++;
      }
      
      // Healthcare - occasional
      if (monthOffset % 3 == 0) {
        final healthcareAmount = 100.0 + (monthOffset * 20.0);
        await _createDummyTransaction(
          db,
          AppConstants.typeExpense,
          healthcareAmount,
          'Medical Visit',
          'Healthcare',
          DateTime(monthDate.year, monthDate.month, 12),
        );
        transactionsAdded++;
      }
      
      // Maintenance - occasional
      if (monthOffset % 3 == 1) {
        final maintenanceAmount = 200.0 + (monthOffset * 50.0);
        await _createDummyTransaction(
          db,
          AppConstants.typeExpense,
          maintenanceAmount,
          'Property Maintenance',
          'Maintenance',
          DateTime(monthDate.year, monthDate.month, 25),
        );
        transactionsAdded++;
      }
      
      // Accountant - quarterly (every 3 months, but offset from healthcare)
      if (monthOffset % 3 == 2) {
        final accountantAmount = 300.0 + (monthOffset * 40.0);
        await _createDummyTransaction(
          db,
          AppConstants.typeExpense,
          accountantAmount,
          'Accounting Services',
          'Accountant',
          DateTime(monthDate.year, monthDate.month, 28),
        );
        transactionsAdded++;
      }
    }
    
    return transactionsAdded;
  }

  /// Helper method to create a dummy transaction
  Future<void> _createDummyTransaction(
    Database db,
    String type,
    double amount,
    String description,
    String category,
    DateTime date,
  ) async {
    final now = DateTime.now();
    await db.insert('transactions', {
      'type': type,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }
}
