import 'package:sqflite/sqflite.dart';

class MigrationScripts {
  static Future<void> migrate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _migrateToVersion(db, version);
    }
  }

  static Future<void> _migrateToVersion(Database db, int version) async {
    switch (version) {
      case 1:
        // Initial version - no migration needed
        break;
      case 2:
        await _migrateToVersion2(db);
        break;
      case 3:
        await _migrateToVersion3(db);
        break;
      // Add more migration cases as needed
      default:
        throw Exception('Unknown database version: $version');
    }
  }

  // Example migration to version 2
  static Future<void> _migrateToVersion2(Database db) async {
    // Example: Add a new column to customers table
    // await db.execute('ALTER TABLE customers ADD COLUMN email TEXT');
  }

  // Example migration to version 3
  static Future<void> _migrateToVersion3(Database db) async {
    // Example: Add a new table or modify existing structure
    // await db.execute('CREATE TABLE new_table (id INTEGER PRIMARY KEY, name TEXT)');
  }

  // Utility method to check if column exists
  static Future<bool> columnExists(
    Database db,
    String tableName,
    String columnName,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.any((column) => column['name'] == columnName);
  }

  // Utility method to check if table exists
  static Future<bool> tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  // Utility method to check if index exists
  static Future<bool> indexExists(Database db, String indexName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='index' AND name=?",
      [indexName],
    );
    return result.isNotEmpty;
  }

  // Safe column addition
  static Future<void> addColumnIfNotExists(
    Database db,
    String tableName,
    String columnName,
    String columnDefinition,
  ) async {
    if (!await columnExists(db, tableName, columnName)) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN $columnDefinition');
    }
  }

  // Safe index creation
  static Future<void> createIndexIfNotExists(
    Database db,
    String indexName,
    String indexDefinition,
  ) async {
    if (!await indexExists(db, indexName)) {
      await db.execute(indexDefinition);
    }
  }
}
