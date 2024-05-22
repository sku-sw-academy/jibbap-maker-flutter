import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class Record {
  String name;
  String? date;

  Record({ required this.name, this.date});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString(),
    };
  }
}

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'record.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE record(
            name TEXT UNIQUE,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertRecord(Record record) async {
    Database db = await database;
    record.date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString();
    return await db.insert('record', record.toMap());
  }

  Future<List<Record>> getRecords() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('record', orderBy: 'date desc');
    return List.generate(maps.length, (index) {
      return Record(
          name: maps[index]['name'],
          date: maps[index]['date']
      );
    });
  }

  Future<void> updateRecord(Record record) async {
    Database db = await database;
    await db.update(
      'record',
      record.toMap(),
      where: 'name = ?',
      whereArgs: [record.name],
    );

  }

  Future<void> deleteRecord(String name) async {
    Database db = await database;
    await db.delete(
      'record',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<bool> checkIfSuggestionExists(String name) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'record',
      where: 'name = ?',
      whereArgs: [name],
    );
    return result.isNotEmpty; // 결과가 비어있지 않으면 해당 suggestion이 존재함
  }

}