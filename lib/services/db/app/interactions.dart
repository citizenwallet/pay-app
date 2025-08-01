import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/interaction.dart' as app_interaction;
import 'package:pay_app/services/db/db.dart';
import 'package:sqflite/sqflite.dart';

class InteractionsTable extends DBTable {
  InteractionsTable(super.db);

  @override
  String get name => 't_interactions';

  @override
  String get createQuery => '''
    CREATE TABLE $name (
      id TEXT PRIMARY KEY,
      direction TEXT NOT NULL,
      with_account TEXT NOT NULL,
      name TEXT NOT NULL,
      image_url TEXT,
      contract TEXT NOT NULL,
      amount TEXT NOT NULL,
      description TEXT,
      is_place INTEGER NOT NULL,
      is_treasury INTEGER NOT NULL,
      place_id INTEGER,
      has_unread_messages INTEGER NOT NULL,
      last_message_at TEXT NOT NULL,
      has_menu_item INTEGER NOT NULL,
      place TEXT,
      profile TEXT NOT NULL
    )
  ''';

  @override
  Future<void> create(Database db) async {
    await db.execute(createQuery);

    // Create indexes for faster lookups
    await db.execute('''
      CREATE INDEX idx_${name}_with_account ON $name (with_account)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_last_message_at ON $name (last_message_at)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_is_place ON $name (is_place)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_has_unread_messages ON $name (has_unread_messages)
    ''');
    // Composite index for efficient querying of interactions sorted by lastMessageAt
    await db.execute('''
      CREATE INDEX idx_${name}_last_message_at_desc ON $name (last_message_at DESC)
    ''');
  }

  @override
  Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    final migrations = {
      11: [
        createQuery,
        'CREATE INDEX idx_${name}_with_account ON $name (with_account)',
        'CREATE INDEX idx_${name}_last_message_at ON $name (last_message_at)',
        'CREATE INDEX idx_${name}_is_place ON $name (is_place)',
        'CREATE INDEX idx_${name}_has_unread_messages ON $name (has_unread_messages)',
        'CREATE INDEX idx_${name}_last_message_at_desc ON $name (last_message_at DESC)',
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

  // Fetch all interactions sorted by lastMessageAt (most recent first)
  Future<List<app_interaction.Interaction>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      orderBy: 'last_message_at DESC',
    );
    return List.generate(
        maps.length, (i) => app_interaction.Interaction.fromMap(maps[i]));
  }

  // Fetch interactions with pagination, sorted by lastMessageAt
  Future<List<app_interaction.Interaction>> getAllPaginated({
    int? limit,
    int? offset,
  }) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      orderBy: 'last_message_at DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(
        maps.length, (i) => app_interaction.Interaction.fromMap(maps[i]));
  }

  // Fetch interaction by id
  Future<app_interaction.Interaction?> getById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return app_interaction.Interaction.fromMap(maps.first);
  }

  // Fetch interactions for a specific account
  Future<List<app_interaction.Interaction>> getInteractionsForAccount(
    String account, {
    int? limit,
    int? offset,
  }) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'with_account = ?',
      whereArgs: [account],
      orderBy: 'last_message_at DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(
        maps.length, (i) => app_interaction.Interaction.fromMap(maps[i]));
  }

  // Fetch place interactions only
  Future<List<app_interaction.Interaction>> getPlaceInteractions({
    int? limit,
    int? offset,
  }) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'is_place = 1',
      orderBy: 'last_message_at DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(
        maps.length, (i) => app_interaction.Interaction.fromMap(maps[i]));
  }

  // Fetch interactions with unread messages
  Future<List<app_interaction.Interaction>> getUnreadInteractions({
    int? limit,
    int? offset,
  }) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'has_unread_messages = 1',
      orderBy: 'last_message_at DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(
        maps.length, (i) => app_interaction.Interaction.fromMap(maps[i]));
  }

  // Upsert interaction
  Future<void> upsert(app_interaction.Interaction interaction) async {
    await db.insert(
      name,
      interaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Upsert multiple interactions
  Future<void> upsertMany(
      List<app_interaction.Interaction> interactions) async {
    final batch = db.batch();
    for (final interaction in interactions) {
      batch.insert(
        name,
        interaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Delete interaction by id
  Future<void> delete(String id) async {
    await db.delete(
      name,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all interactions
  Future<void> deleteAll() async {
    await db.delete(name);
  }

  // Mark interaction as read/unread
  Future<void> updateUnreadStatus(String id, bool hasUnreadMessages) async {
    await db.update(
      name,
      {'has_unread_messages': hasUnreadMessages ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update last message timestamp
  Future<void> updateLastMessageAt(String id, DateTime lastMessageAt) async {
    await db.update(
      name,
      {'last_message_at': lastMessageAt.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
