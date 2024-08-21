import 'package:sqflite/sqflite.dart';
import 'package:women_safety/model/contactsm.dart';

class DatabaseHelper {
  String contactTable = 'contactTable';
  String colId = 'id';
  String colContactName = 'name';
  String colContactNumber = 'number';

  DatabaseHelper._createInstance();

  static DatabaseHelper? _databaseHelper;

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  static Database? _database;

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String directoryPath = await getDatabasesPath();
    String dbLocation = '$directoryPath/contact.db';

    var contactDatabase = await openDatabase(dbLocation, version: 1, onCreate: _createDbTable);

    return contactDatabase;
  }

  void _createDbTable(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE $contactTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colContactName TEXT, $colContactNumber TEXT)',
    );
  }

  Future<List<Map<String, dynamic>>> getContactMapList() async {
    Database db = await database;
    return await db.query(contactTable, orderBy: '$colId ASC');
  }

  Future<int> insertContact(Tcontact contact) async {
    Database db = await database;
    return await db.insert(contactTable, contact.toMap());
  }

  Future<int> updateContact(Tcontact contact) async {
    Database db = await database;
    return await db.update(contactTable, contact.toMap(), where: '$colId = ?', whereArgs: [contact.id]);
  }

  Future<int> deleteContact(int id) async {
    Database db = await database;
    return await db.delete(contactTable, where: '$colId = ?', whereArgs: [id]);
  }

  Future<int> getCount() async {
    Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT (*) from $contactTable'))!;
  }

  Future<List<Tcontact>> getContactList() async {
    var contactMapList = await getContactMapList();
    return List<Tcontact>.generate(contactMapList.length, (index) {
      return Tcontact.fromMapObject(contactMapList[index]);
    });
  }
}
