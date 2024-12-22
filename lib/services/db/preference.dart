import 'package:pay_app/services/db/db.dart';
import 'package:sqflite_common/sqflite.dart';

class Preference {
  final String key;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String value;

  Preference({
    required this.key,
    required this.createdAt,
    required this.updatedAt,
    required this.value,
  });

  Preference.create({
    required this.key,
    required this.value,
  })  : createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'value': value,
    };
  }

  static Preference fromMap(Map<String, dynamic> map) {
    return Preference(
      key: map['key'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      value: map['value'],
    );
  }
}

class PreferenceTable extends DBTable {
  PreferenceTable(super.db);

  @override
  String get name => 'preference';

  @override
  String get createQuery => '''
    CREATE TABLE $name (
      key TEXT PRIMARY KEY,
      created_at TEXT,
      updated_at TEXT,
      value TEXT
    )
  ''';

  @override
  Future<void> create(Database db) async {
    await db.execute(createQuery);
  }

  @override
  Future<void> migrate(Database db, int oldVersion, int newVersion) async {}

  Future<void> clear() async {
    await db.delete(name);
  }

  Future<String?> get(String key) async {
    final List<Map<String, dynamic>> maps =
        await db.query(name, where: 'key = ?', whereArgs: [key]);
    return maps.isNotEmpty ? maps.first['value'] : null;
  }

  Future<void> set(String key, String value) async {
    await db.insert(
      name,
      Preference.create(key: key, value: value).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
