import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/database_constants.dart';
import '../constants/app_constants.dart';
import 'migrations/migration_scripts.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // Create all tables
    batch.execute(DatabaseConstants.createSettingsTable);
    batch.execute(DatabaseConstants.createCustomersTable);
    batch.execute(DatabaseConstants.createProductsTable);
    batch.execute(DatabaseConstants.createPaymentsTable);

    // Create indexes
    final indexes = DatabaseConstants.createIndexes.split(';');
    for (final index in indexes) {
      if (index.trim().isNotEmpty) {
        batch.execute(index.trim());
      }
    }

    await batch.commit();

    // Insert default settings
    await _insertDefaultSettings(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations
    await MigrationScripts.migrate(db, oldVersion, newVersion);
  }

  Future<void> _insertDefaultSettings(Database db) async {
    // Check if settings already exist
    final result = await db.query(DatabaseConstants.settingsTable);
    if (result.isEmpty) {
      await db.insert(DatabaseConstants.settingsTable, {
        DatabaseConstants.settingsId: 1,
        DatabaseConstants.settingsAppPassword: AppConstants.defaultPassword,
        DatabaseConstants.settingsBusinessName: null,
        DatabaseConstants.settingsOwnerName: null,
        DatabaseConstants.settingsPhone: null,
        DatabaseConstants.settingsCreatedDate: DateTime.now().toIso8601String(),
        DatabaseConstants.settingsUpdatedDate: DateTime.now().toIso8601String(),
      });
    }
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>?> queryFirst(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final results = await query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> count(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return result.first['count'] as int;
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<void> rawInsert(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.rawInsert(sql, arguments);
  }

  Future<void> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.rawUpdate(sql, arguments);
  }

  Future<void> rawDelete(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.rawDelete(sql, arguments);
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Batch operations
  Future<List<Object?>> batch(Function(Batch batch) operations) async {
    final db = await database;
    final batch = db.batch();
    operations(batch);
    return await batch.commit();
  }

  // Search functionality
  Future<List<Map<String, dynamic>>> search(
    String table,
    List<String> searchColumns,
    String searchTerm, {
    List<String>? columns,
    String? additionalWhere,
    List<dynamic>? additionalWhereArgs,
    String? orderBy,
    int? limit,
  }) async {
    if (searchTerm.isEmpty) {
      return query(
        table,
        columns: columns,
        where: additionalWhere,
        whereArgs: additionalWhereArgs,
        orderBy: orderBy,
        limit: limit,
      );
    }

    final searchConditions = searchColumns
        .map((column) => '$column LIKE ?')
        .join(' OR ');

    final searchArgs = searchColumns.map((column) => '%$searchTerm%').toList();

    String finalWhere = '($searchConditions)';
    List<dynamic> finalWhereArgs = searchArgs;

    if (additionalWhere != null) {
      finalWhere = '$finalWhere AND $additionalWhere';
      finalWhereArgs.addAll(additionalWhereArgs ?? []);
    }

    return query(
      table,
      columns: columns,
      where: finalWhere,
      whereArgs: finalWhereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  // Database utility methods
  Future<bool> isTableEmpty(String table) async {
    final count = await this.count(table);
    return count == 0;
  }

  Future<void> clearTable(String table) async {
    await delete(table);
  }

  Future<void> clearAllTables() async {
    await transaction((txn) async {
      await txn.delete(DatabaseConstants.paymentsTable);
      await txn.delete(DatabaseConstants.productsTable);
      await txn.delete(DatabaseConstants.customersTable);
      // Don't clear settings table
    });
  }

  Future<String> getDatabasePath() async {
    final databasePath = await getDatabasesPath();
    return join(databasePath, AppConstants.databaseName);
  }

  Future<int> getDatabaseVersion() async {
    final db = await database;
    return await db.getVersion();
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    await closeDatabase();
    final path = await getDatabasePath();
    await databaseFactory.deleteDatabase(path);
  }

  // Backup and restore
  Future<Map<String, List<Map<String, dynamic>>>> exportAllData() async {
    final data = <String, List<Map<String, dynamic>>>{};

    data['settings'] = await query(DatabaseConstants.settingsTable);
    data['customers'] = await query(DatabaseConstants.customersTable);
    data['products'] = await query(DatabaseConstants.productsTable);
    data['payments'] = await query(DatabaseConstants.paymentsTable);

    return data;
  }

  Future<void> importAllData(
    Map<String, List<Map<String, dynamic>>> data,
  ) async {
    await transaction((txn) async {
      // Clear existing data (except settings)
      await txn.delete(DatabaseConstants.paymentsTable);
      await txn.delete(DatabaseConstants.productsTable);
      await txn.delete(DatabaseConstants.customersTable);

      // Import customers
      if (data['customers'] != null) {
        for (final customer in data['customers']!) {
          await txn.insert(DatabaseConstants.customersTable, customer);
        }
      }

      // Import products
      if (data['products'] != null) {
        for (final product in data['products']!) {
          await txn.insert(DatabaseConstants.productsTable, product);
        }
      }

      // Import payments
      if (data['payments'] != null) {
        for (final payment in data['payments']!) {
          await txn.insert(DatabaseConstants.paymentsTable, payment);
        }
      }

      // Update settings if provided
      if (data['settings'] != null && data['settings']!.isNotEmpty) {
        final settings = data['settings']!.first;
        await txn.update(
          DatabaseConstants.settingsTable,
          settings,
          where: '${DatabaseConstants.settingsId} = ?',
          whereArgs: [1],
        );
      }
    });
  }
}
