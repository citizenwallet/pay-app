import 'package:pay_app/services/db/app/cards.dart';
import 'package:pay_app/services/db/app/contacts.dart';
import 'package:pay_app/services/db/db.dart';
import 'package:sqflite/sqflite.dart';

class AppDBService extends DBService {
  static final AppDBService _instance = AppDBService._internal();

  factory AppDBService() {
    return _instance;
  }

  AppDBService._internal();

  late ContactsTable contacts;
  late CardsTable cards;

  @override
  Future<Database> openDB(String path) async {
    final options = OpenDatabaseOptions(
      onConfigure: (db) async {
        contacts = ContactsTable(db);
        cards = CardsTable(db);
      },
      onCreate: (db, version) async {
        await contacts.create(db);
        await cards.create(db);
        return;
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await contacts.migrate(db, oldVersion, newVersion);
        await cards.migrate(db, oldVersion, newVersion);
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
