import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/place_with_menu.dart' as app_place_with_menu;
import 'package:pay_app/services/db/db.dart';
import 'package:sqflite/sqflite.dart';

class PlacesWithMenuTable extends DBTable {
  PlacesWithMenuTable(super.db);

  @override
  String get name => 't_places_with_menu';

  @override
  String get createQuery => '''
    CREATE TABLE $name (
      place_id INTEGER PRIMARY KEY,
      slug TEXT NOT NULL,
      place TEXT NOT NULL,
      profile TEXT,
      items TEXT NOT NULL
    )
  ''';

  @override
  Future<void> create(Database db) async {
    await db.execute(createQuery);

    // Create indexes for faster lookups
    await db.execute('''
      CREATE INDEX idx_${name}_slug ON $name (slug)
    ''');
  }

  @override
  Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    final migrations = {
      10: [
        createQuery,
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

  // Fetch all places with menu
  Future<List<app_place_with_menu.PlaceWithMenu>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query(name);
    return List.generate(
        maps.length, (i) => app_place_with_menu.PlaceWithMenu.fromMap(maps[i]));
  }

  // Fetch place with menu by placeId
  Future<app_place_with_menu.PlaceWithMenu?> getByPlaceId(int placeId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'place_id = ?',
      whereArgs: [placeId],
    );
    if (maps.isEmpty) return null;
    return app_place_with_menu.PlaceWithMenu.fromMap(maps.first);
  }

  // Fetch place with menu by slug
  Future<app_place_with_menu.PlaceWithMenu?> getBySlug(String slug) async {
    final List<Map<String, dynamic>> maps = await db.query(
      name,
      where: 'slug = ?',
      whereArgs: [slug],
    );
    if (maps.isEmpty) return null;
    return app_place_with_menu.PlaceWithMenu.fromMap(maps.first);
  }

  // Upsert place with menu
  Future<void> upsert(app_place_with_menu.PlaceWithMenu placeWithMenu) async {
    await db.insert(
      name,
      placeWithMenu.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Upsert multiple places with menu
  Future<void> upsertMany(
      List<app_place_with_menu.PlaceWithMenu> placesWithMenu) async {
    final batch = db.batch();
    for (final placeWithMenu in placesWithMenu) {
      batch.insert(
        name,
        placeWithMenu.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Delete place with menu by placeId
  Future<void> delete(int placeId) async {
    await db.delete(
      name,
      where: 'place_id = ?',
      whereArgs: [placeId],
    );
  }

  // Delete place with menu by slug
  Future<void> deleteBySlug(String slug) async {
    await db.delete(
      name,
      where: 'slug = ?',
      whereArgs: [slug],
    );
  }

  // Delete all places with menu
  Future<void> deleteAll() async {
    await db.delete(name);
  }
}
