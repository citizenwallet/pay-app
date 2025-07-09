import 'package:flutter/cupertino.dart';
import 'package:pay_app/services/db/db.dart';
import 'package:pay_app/theme/card_colors.dart';
import 'package:sqflite/sqflite.dart';

class DBCard {
  final String uid;
  final String project;
  final String account;

  DBCard({
    required this.uid,
    required this.project,
    required this.account,
  });

  factory DBCard.fromMap(Map<String, dynamic> map) {
    return DBCard(
      uid: map['uid'],
      project: map['project'],
      account: map['account'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'project': project,
      'account': account,
    };
  }

  Color getColor() {
    return projectCardColor(project);
  }
}

class CardsTable extends DBTable {
  CardsTable(super.db);

  @override
  String get name => 't_cards';

  @override
  String get createQuery => '''
    CREATE TABLE $name (
      uid TEXT PRIMARY KEY,
      project TEXT NOT NULL,
      account TEXT NOT NULL
    )
  ''';

  @override
  Future<void> create(Database db) async {
    await db.execute(createQuery);

    // Create indexes for faster lookups
    await db.execute('''
      CREATE INDEX idx_${name}_account ON $name (account)
    ''');
    await db.execute('''
      CREATE INDEX idx_${name}_project ON $name (project)
    ''');
  }

  @override
  Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    final migrations = {
      2: [
        createQuery,
        'CREATE INDEX idx_${name}_account ON $name (account)',
        'CREATE INDEX idx_${name}_project ON $name (project)',
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

  // Fetch all cards
  Future<List<DBCard>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query(name);
    return List.generate(maps.length, (i) => DBCard.fromMap(maps[i]));
  }

  // Fetch card by uid
  Future<DBCard?> getByUid(String uid) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'uid = ?',
      whereArgs: [uid],
    );
    if (maps.isEmpty) return null;
    return DBCard.fromMap(maps.first);
  }

  // Fetch card by account
  Future<DBCard?> getByAccount(String account) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'account = ?',
      whereArgs: [account],
    );
    if (maps.isEmpty) return null;
    return DBCard.fromMap(maps.first);
  }

  // Upsert card by account
  Future<void> upsert(DBCard card) async {
    await db.insert(
      name,
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
