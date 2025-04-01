import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHistorique {
  static final DatabaseHistorique _instance = DatabaseHistorique._internal();
  static Database? _database;

  factory DatabaseHistorique() {
    return _instance;
  }

  DatabaseHistorique._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE historique (
      idHistorique INTEGER PRIMARY KEY AUTOINCREMENT,
      ressource TEXT,
      dateAjout DATE,
      contentId INTEGER
    )
  ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('historique', row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await database;
    return await db.query('historique');
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['idHistorique'];
    return await db.update('historique', row, where: 'idHistorique = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete('historique', where: 'idHistorique = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryRecentRows() async {
    Database db = await database;
    return await db.query(
      'historique',
      orderBy: 'dateAjout DESC',
      limit: 10,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE historique ADD COLUMN contentId INTEGER');
    }
  }
}