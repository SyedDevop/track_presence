import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vcare_attendance/models/profile_model.dart';

class ProfileDB {
  static const _databaseName = "profile.db";
  static const _databaseVersion = 1;

  static const table = 'profile';

  ProfileDB._privateConstructor();
  static final ProfileDB instance = ProfileDB._privateConstructor();

  static late Database _database;
  Future<Database> get database async {
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            id INTEGER PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            department TEXT NOT NULL,
            designation TEXT NOT NULL,
            email TEXT,
            img_path TEXT
          )
          ''');
  }

  Future<int> insert(Profile user) async {
    Database db = await instance.database;
    return await db.insert(table, user.toMap());
  }

  Future<List<Profile>> getById(String id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> prof =
        await db.query(table, limit: 1, where: id);
    return prof.map((u) => Profile.fromMap(u)).toList();
  }

  Future<List<Profile>> queryAllProfile() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> prof = await db.query(table);
    return prof.map((u) => Profile.fromMap(u)).toList();
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
}
