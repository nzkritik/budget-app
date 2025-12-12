import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'database_service.dart';

class BackupInfo {
  final String filename;
  final String path;
  final DateTime date;
  final int size;

  BackupInfo({
    required this.filename,
    required this.path,
    required this.date,
    required this.size,
  });
}

class BackupService {
  static final BackupService instance = BackupService._init();

  BackupService._init();

  /// Get the backups directory path (e.g., ~/Documents/BudgetApp/backups/)
  Future<Directory> getBackupsDirectory() async {
    final Directory baseDir;
    
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      baseDir = await getApplicationDocumentsDirectory();
    } else {
      // For mobile, use app documents directory
      baseDir = await getApplicationDocumentsDirectory();
    }
    
    final backupsDir = Directory(join(baseDir.path, 'BudgetApp', 'backups'));
    
    // Create the directory if it doesn't exist
    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }
    
    return backupsDir;
  }

  /// Create a backup with timestamp in filename (e.g., budget_backup_2025-12-12_143022.db)
  Future<File> createBackup() async {
    // Get the current database path
    final db = await DatabaseService.instance.database;
    final dbPath = db.path;
    
    // Get backups directory
    final backupsDir = await getBackupsDirectory();
    
    // Create timestamp for filename
    final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    final backupFilename = 'budget_backup_$timestamp.db';
    final backupPath = join(backupsDir.path, backupFilename);
    
    // Copy the database file
    final sourceFile = File(dbPath);
    final backupFile = await sourceFile.copy(backupPath);
    
    return backupFile;
  }

  /// Restore database from a backup file
  Future<void> restoreFromBackup(String backupPath) async {
    // Verify backup file exists
    final backupFile = File(backupPath);
    if (!await backupFile.exists()) {
      throw Exception('Backup file does not exist: $backupPath');
    }
    
    // Close the current database connection
    await DatabaseService.instance.close();
    
    // Get the current database path
    String dbPath;
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      final directory = await getApplicationDocumentsDirectory();
      dbPath = join(directory.path, 'budget.db');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      dbPath = join(directory.path, 'budget.db');
    }
    
    // Copy backup file over the current database
    await backupFile.copy(dbPath);
    
    // Re-initialize the database service
    // The next call to database getter will re-open the database
  }

  /// List all existing backups
  Future<List<BackupInfo>> listBackups() async {
    final backupsDir = await getBackupsDirectory();
    
    // List all .db files in the backups directory
    final files = await backupsDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.db'))
        .cast<File>()
        .toList();
    
    // Create BackupInfo objects
    final backups = <BackupInfo>[];
    for (final file in files) {
      final stat = await file.stat();
      backups.add(BackupInfo(
        filename: basename(file.path),
        path: file.path,
        date: stat.modified,
        size: stat.size,
      ));
    }
    
    // Sort by date (newest first)
    backups.sort((a, b) => b.date.compareTo(a.date));
    
    return backups;
  }

  /// Delete a specific backup file
  Future<void> deleteBackup(String backupPath) async {
    final file = File(backupPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get backup file information
  Future<BackupInfo?> getBackupInfo(String backupPath) async {
    final file = File(backupPath);
    if (!await file.exists()) {
      return null;
    }
    
    final stat = await file.stat();
    return BackupInfo(
      filename: basename(file.path),
      path: file.path,
      date: stat.modified,
      size: stat.size,
    );
  }
}
