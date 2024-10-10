   import 'dart:async';
   import 'package:path/path.dart';
   import 'package:sqflite/sqflite.dart';

   class DatabaseHelper {
     static final DatabaseHelper _instance = DatabaseHelper._internal();
     factory DatabaseHelper() => _instance;
     static Database? _database;

     DatabaseHelper._internal();

     Future<Database> get database async {
       if (_database != null) return _database!;
       _database = await _initDatabase();
       return _database!;
     }

     Future<Database> _initDatabase() async {
       String path = join(await getDatabasesPath(), 'user_database.db');
       return await openDatabase(
         path,
         version: 1,
         onCreate: _onCreate,
       );
     }

     Future _onCreate(Database db, int version) async {
       await db.execute('''
         CREATE TABLE users (
           id INTEGER PRIMARY KEY,
           name TEXT NOT NULL,
           email TEXT NOT NULL,
           birthdate TEXT NOT NULL,
           address TEXT NOT NULL,
           password TEXT NOT NULL
         )
       ''');
     }

     Future<int> insertUser(Map<String, dynamic> user) async {
       Database db = await database;
       return await db.insert('users', user);
     }

     Future<List<Map<String, dynamic>>> getUsers() async {
       Database db = await database;
       return await db.query('users');
     }

     Future<int> deleteUser(int id) async {
       Database db = await database;
       return await db.delete('users', where: 'id = ?', whereArgs: [id]);
     }
   }