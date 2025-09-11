import 'package:pay_app/services/db/app/cards.dart';
import 'package:pay_app/services/db/app/contacts.dart';
import 'package:pay_app/services/db/app/interactions.dart';
import 'package:pay_app/services/db/app/orders.dart';
import 'package:pay_app/services/db/app/places_with_menu.dart';
import 'package:pay_app/services/db/app/transactions.dart';
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
  late InteractionsTable interactions;
  late TransactionsTable transactions;
  late OrdersTable orders;
  late PlacesWithMenuTable placesWithMenu;

  @override
  Future<Database> openDB(String path) async {
    final options = OpenDatabaseOptions(
      onConfigure: (db) async {
        contacts = ContactsTable(db);
        cards = CardsTable(db);
        interactions = InteractionsTable(db);
        transactions = TransactionsTable(db);
        orders = OrdersTable(db);
        placesWithMenu = PlacesWithMenuTable(db);
      },
      onCreate: (db, version) async {
        await contacts.create(db);
        await cards.create(db);
        await interactions.create(db);
        await transactions.create(db);
        await orders.create(db);
        await placesWithMenu.create(db);
        return;
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await contacts.migrate(db, oldVersion, newVersion);
        await cards.migrate(db, oldVersion, newVersion);
        await interactions.migrate(db, oldVersion, newVersion);
        await transactions.migrate(db, oldVersion, newVersion);
        await orders.migrate(db, oldVersion, newVersion);
        await placesWithMenu.migrate(db, oldVersion, newVersion);
        return;
      },
      version: 14,
    );

    final db = await databaseFactory.openDatabase(
      path,
      options: options,
    );

    return db;
  }
}
