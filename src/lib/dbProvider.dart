import 'package:path/path.dart';
import '../detect_breed.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DbProvider {
  Database db;

  Future<String> _getPath() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'dog_scanner.db');
    return path;
  }

  Future open() async {
    String path = await _getPath();
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table dog ( 
  dbId integer primary key autoincrement, 
  breeds text not null,
  image text not null)
''');
    });
  }

  Future<Dog> insert(Dog dog) async {
    await open();
    dog.dbId = await db.insert('dog', dog.toMap());
    db.close();
    return dog;
  }

  Future<List<Dog>> read() async {
    await open();
    List<Dog> dogs = [];

    List<Map> dbDogs =
        await db.query('dog', columns: ['dbId', 'breeds', 'image']);
    for (Map dbDog in dbDogs) {
      dogs.add(Dog.fromMap(dbDog));
    }
    db.close();
    return dogs.reversed.toList();
  }

  Future<int> delete(int dbId) async {
    await open();
    int recordsDeleted = 0;
    recordsDeleted +=
        await db.delete('dog', where: 'dbId = ?', whereArgs: [dbId]);
    db.close();
    return recordsDeleted;
  }
}
