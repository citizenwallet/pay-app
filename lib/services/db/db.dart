import 'dart:io';

import 'package:pay_app/services/db/preference.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class DBTable {
  final Database _db;

  DBTable(this._db);

  Database get db => _db;

  String get name => 'table';
  String get createQuery => '''
    CREATE TABLE $name (
      id INTEGER PRIMARY KEY
    )
  ''';

  Future<void> create(Database db);

  Future<void> migrate(Database db, int oldVersion, int newVersion);
}

abstract class DBService {
  Database? _db;
  late String name;

  String get path => _db!.path;

  // open a database, create tables and migrate data
  Future<Database> openDB(String path);

  Future<void> init(String name) async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
    }

    databaseFactory = databaseFactoryFfi;

    this.name = '$name.db';
    final dbPath = join(await getDatabasesPath(), this.name);
    _db = await openDB(dbPath);
  }

  // reset db
  Future<void> resetDB() async {
    if (_db == null) return;

    final dbPath = _db!.path;
    await _db!.close();
    await deleteDatabase(dbPath);
    _db = await openDB(dbPath);
  }

  // delete db
  Future<void> deleteDB() async {
    if (_db == null) return;

    final dbPath = _db!.path;
    await _db!.close();
    await deleteDatabase(dbPath);
  }

  // get db size in bytes
  Future<int> getDBSize() async {
    if (_db == null) return 0;

    final dbPath = _db!.path;
    final file = File(dbPath);
    return file.length();
  }
}

Future<String> getDBPath(String name) async {
  return join(await getDatabasesPath(), '$name.db');
}

class MainDB extends DBService {
  static final MainDB _instance = MainDB._internal();

  factory MainDB() {
    return _instance;
  }

  MainDB._internal();

  late PreferenceTable preference;

  // open a database, create tables and migrate data
  @override
  Future<Database> openDB(String path) async {
    final options = OpenDatabaseOptions(
      onConfigure: (db) async {
        // instantiate tables
        preference = PreferenceTable(db);
      },
      onCreate: (db, version) async {
        // create tables
        await preference.create(db);

        return;
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // migrate data
        await preference.migrate(db, oldVersion, newVersion);

        return;
      },
      version: 3,
    );

    final db = await databaseFactory.openDatabase(
      path,
      options: options,
    );

    return db;
  }
}
