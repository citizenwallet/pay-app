import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/transaction.dart' as app_transaction;
import 'package:pay_app/services/db/db.dart';
import 'package:sqflite/sqflite.dart';

class TransactionsTable extends DBTable {
  TransactionsTable(super.db);

  @override
  String get name => 't_transactions';

  @override
  String get createQuery => '''
    CREATE TABLE $name (
      id TEXT PRIMARY KEY,
      tx_hash TEXT NOT NULL,
      contract TEXT NOT NULL,
      from_account TEXT NOT NULL,
      to_account TEXT NOT NULL,
      amount TEXT NOT NULL,
      description TEXT,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  ''';

  @override
  Future<void> create(Database db) async {
    await db.execute(createQuery);

    // Create indexes for faster lookups
    await db.execute('''
      CREATE INDEX idx_${name}_tx_hash ON $name (tx_hash)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_contract ON $name (contract)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_from_account ON $name (from_account)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_to_account ON $name (to_account)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_created_at ON $name (created_at)
    ''');
    // Composite index for efficient querying of transactions between users
    await db.execute('''
      CREATE INDEX idx_${name}_user_transactions ON $name (from_account, to_account, created_at)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_user_transactions_reverse ON $name (to_account, from_account, created_at)
    ''');
  }

  @override
  Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    final migrations = {
      4: [
        createQuery,
        'CREATE INDEX idx_${name}_tx_hash ON $name (tx_hash)',
        'CREATE INDEX idx_${name}_from_account ON $name (from_account)',
        'CREATE INDEX idx_${name}_to_account ON $name (to_account)',
        'CREATE INDEX idx_${name}_created_at ON $name (created_at)',
        'CREATE INDEX idx_${name}_user_transactions ON $name (from_account, to_account, created_at)',
        'CREATE INDEX idx_${name}_user_transactions_reverse ON $name (to_account, from_account, created_at)',
      ],
      5: [
        'ALTER TABLE $name DROP COLUMN exchange_direction',
      ],
      13: [
        'CREATE INDEX idx_${name}_contract ON $name (contract)',
      ]
    };

    for (var i = oldVersion + 1; i <= newVersion; i++) {
      final queries = migrations[i];

      if (queries != null) {
        for (final query in queries) {
          try {
            await db.execute(query);
          } catch (e, s) {
            debugPrint('Migration error: $e');
            debugPrintStack(stackTrace: s);
          }
        }
      }
    }
  }

  // Fetch all transactions
  Future<List<app_transaction.Transaction>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query(name);
    return List.generate(
        maps.length, (i) => app_transaction.Transaction.fromMap(maps[i]));
  }

  // Fetch transaction by id
  Future<app_transaction.Transaction?> getById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return app_transaction.Transaction.fromMap(maps.first);
  }

  // Fetch transaction by txHash
  Future<app_transaction.Transaction?> getByTxHash(String txHash) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'tx_hash = ?',
      whereArgs: [txHash],
    );
    if (maps.isEmpty) return null;
    return app_transaction.Transaction.fromMap(maps.first);
  }

  // Fetch transactions between two accounts (efficient query using indexes)
  Future<List<app_transaction.Transaction>> getTransactionsBetweenUsers(
    String accountA,
    String accountB, {
    int? limit,
    int? offset,
  }) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where:
          '(from_account = ? AND to_account = ?) OR (from_account = ? AND to_account = ?)',
      whereArgs: [accountA, accountB, accountB, accountA],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(
        maps.length, (i) => app_transaction.Transaction.fromMap(maps[i]));
  }

  // Fetch transactions for a specific account
  Future<List<app_transaction.Transaction>> getTransactionsForAccount(
    String account, {
    int? limit,
    int? offset,
    String? token,
  }) async {
    String whereClause = 'from_account = ? OR to_account = ?';
    List<dynamic> whereArgs = [account, account];
    if (token != null) {
      whereClause += ' AND contract = ?';
      whereArgs.add(token);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(
        maps.length, (i) => app_transaction.Transaction.fromMap(maps[i]));
  }

  // Upsert transaction
  Future<void> upsert(app_transaction.Transaction transaction) async {
    await db.insert(
      name,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Upsert multiple transactions
  Future<void> upsertMany(
      List<app_transaction.Transaction> transactions) async {
    final batch = db.batch();
    for (final transaction in transactions) {
      batch.insert(
        name,
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Delete transaction by id
  Future<void> delete(String id) async {
    await db.delete(
      name,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all transactions
  Future<void> deleteAll() async {
    await db.delete(name);
  }
}
