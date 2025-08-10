import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/order.dart' as app_order;
import 'package:pay_app/services/db/db.dart';
import 'package:sqflite/sqflite.dart';

class OrdersTable extends DBTable {
  OrdersTable(super.db);

  @override
  String get name => 't_orders';

  @override
  String get createQuery => '''
    CREATE TABLE $name (
      id INTEGER PRIMARY KEY,
      created_at TEXT NOT NULL,
      completed_at TEXT,
      total INTEGER NOT NULL,
      due INTEGER NOT NULL,
      place_id INTEGER NOT NULL,
      slug TEXT NOT NULL,
      items TEXT NOT NULL,
      status TEXT NOT NULL,
      description TEXT,
      tx_hash TEXT,
      type TEXT,
      account TEXT,
      fees INTEGER NOT NULL DEFAULT 0,
      place TEXT NOT NULL
    )
  ''';

  @override
  Future<void> create(Database db) async {
    await db.execute(createQuery);

    // Create indexes for faster lookups
    await db.execute('''
      CREATE INDEX idx_${name}_place_id ON $name (place_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_slug ON $name (slug)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_account ON $name (account)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_created_at ON $name (created_at)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_status ON $name (status)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_tx_hash ON $name (tx_hash)
    ''');
    // Composite indexes for efficient querying
    await db.execute('''
      CREATE INDEX idx_${name}_place_created ON $name (place_id, created_at)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_account_created ON $name (account, created_at)
    ''');
  }

  @override
  Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    final migrations = {
      6: [
        createQuery,
        'CREATE INDEX idx_${name}_place_id ON $name (place_id)',
        'CREATE INDEX idx_${name}_account ON $name (account)',
        'CREATE INDEX idx_${name}_created_at ON $name (created_at)',
        'CREATE INDEX idx_${name}_status ON $name (status)',
        'CREATE INDEX idx_${name}_tx_hash ON $name (tx_hash)',
        'CREATE INDEX idx_${name}_place_created ON $name (place_id, created_at)',
        'CREATE INDEX idx_${name}_account_created ON $name (account, created_at)',
      ],
      7: [
        'DROP TABLE $name',
        createQuery,
        'CREATE INDEX idx_${name}_place_id ON $name (place_id)',
        'CREATE INDEX idx_${name}_account ON $name (account)',
        'CREATE INDEX idx_${name}_created_at ON $name (created_at)',
        'CREATE INDEX idx_${name}_status ON $name (status)',
        'CREATE INDEX idx_${name}_tx_hash ON $name (tx_hash)',
        'CREATE INDEX idx_${name}_place_created ON $name (place_id, created_at)',
        'CREATE INDEX idx_${name}_account_created ON $name (account, created_at)',
        'ALTER TABLE $name ADD COLUMN slug TEXT NOT NULL',
        'CREATE INDEX idx_${name}_slug ON $name (slug)',
      ],
      8: [
        'DROP TABLE $name',
        createQuery,
        'CREATE INDEX idx_${name}_place_id ON $name (place_id)',
        'CREATE INDEX idx_${name}_account ON $name (account)',
        'CREATE INDEX idx_${name}_created_at ON $name (created_at)',
        'CREATE INDEX idx_${name}_status ON $name (status)',
        'CREATE INDEX idx_${name}_tx_hash ON $name (tx_hash)',
        'CREATE INDEX idx_${name}_place_created ON $name (place_id, created_at)',
        'CREATE INDEX idx_${name}_account_created ON $name (account, created_at)',
        'CREATE INDEX idx_${name}_slug ON $name (slug)',
      ],
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

  // Fetch all orders
  Future<List<app_order.Order>> getAll(String account) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'account = ?',
      whereArgs: [account],
    );
    return List.generate(maps.length, (i) => app_order.Order.fromMap(maps[i]));
  }

  // Fetch order by id
  Future<app_order.Order?> getById(int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return app_order.Order.fromMap(maps.first);
  }

  // Fetch order by txHash
  Future<app_order.Order?> getByTxHash(String txHash) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'tx_hash = ?',
      whereArgs: [txHash],
    );
    if (maps.isEmpty) return null;
    return app_order.Order.fromMap(maps.first);
  }

  // Fetch orders by place_id, sorted by created_at date
  Future<List<app_order.Order>> getOrdersBySlug(
    String account,
    String slug, {
    int? limit,
    int? offset,
  }) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'account = ? AND slug = ?',
      whereArgs: [account, slug],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) => app_order.Order.fromMap(maps[i]));
  }

  // Fetch orders by account, sorted by created_at date
  Future<List<app_order.Order>> getOrdersByAccount(
    String account, {
    int? limit,
    int? offset,
  }) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'account = ?',
      whereArgs: [account],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) => app_order.Order.fromMap(maps[i]));
  }

  // Fetch orders by status
  Future<List<app_order.Order>> getOrdersByStatus(
    String account,
    app_order.OrderStatus status, {
    int? limit,
    int? offset,
  }) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'account = ? AND status = ?',
      whereArgs: [account, status.name],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) => app_order.Order.fromMap(maps[i]));
  }

  // Upsert order
  Future<void> upsert(app_order.Order order) async {
    await db.insert(
      name,
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Upsert multiple orders
  Future<void> upsertMany(List<app_order.Order> orders) async {
    final batch = db.batch();
    for (final order in orders) {
      batch.insert(
        name,
        order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Delete order by id
  Future<void> delete(int id) async {
    await db.delete(
      name,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all orders
  Future<void> deleteAll() async {
    await db.delete(name);
  }
}
