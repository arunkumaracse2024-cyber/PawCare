import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'database_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DatabaseConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (defaultTargetPlatform == TargetPlatform.windows || 
               defaultTargetPlatform == TargetPlatform.linux || 
               defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // Settings Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableSettings} (
        ${DatabaseConstants.colSettingsKey} TEXT PRIMARY KEY,
        ${DatabaseConstants.colSettingsValue} TEXT NOT NULL
      )
    ''');

    // Pets Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tablePets} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colName} TEXT NOT NULL,
        ${DatabaseConstants.colSpecies} TEXT NOT NULL,
        ${DatabaseConstants.colBreed} TEXT NOT NULL,
        ${DatabaseConstants.colAge} REAL NOT NULL,
        ${DatabaseConstants.colWeight} REAL NOT NULL,
        ${DatabaseConstants.colPhotoPath} TEXT NOT NULL,
        ${DatabaseConstants.colOwnerUid} TEXT NOT NULL,
        ${DatabaseConstants.colShopId} TEXT,
        ${DatabaseConstants.colLinkCode} TEXT,
        ${DatabaseConstants.colIsLinked} INTEGER NOT NULL
      )
    ''');

    // Checklists Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableChecklists} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colPetId} TEXT NOT NULL,
        ${DatabaseConstants.colTitle} TEXT NOT NULL,
        ${DatabaseConstants.colCategory} TEXT NOT NULL,
        ${DatabaseConstants.colIsDone} INTEGER NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colPetId}) 
        REFERENCES ${DatabaseConstants.tablePets} (${DatabaseConstants.colId}) 
        ON DELETE CASCADE
      )
    ''');

    // Reminders Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableReminders} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colPetId} TEXT NOT NULL,
        ${DatabaseConstants.colTitle} TEXT NOT NULL,
        ${DatabaseConstants.colType} TEXT NOT NULL,
        ${DatabaseConstants.colDateTime} TEXT NOT NULL,
        ${DatabaseConstants.colRepeatOption} TEXT NOT NULL,
        ${DatabaseConstants.colIsDone} INTEGER NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colPetId}) 
        REFERENCES ${DatabaseConstants.tablePets} (${DatabaseConstants.colId}) 
        ON DELETE CASCADE
      )
    ''');

    // Behaviour Logs Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableBehaviourLogs} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colPetId} TEXT NOT NULL,
        ${DatabaseConstants.colDate} TEXT NOT NULL,
        ${DatabaseConstants.colEatingStatus} TEXT NOT NULL,
        ${DatabaseConstants.colActivityLevel} INTEGER NOT NULL,
        ${DatabaseConstants.colSleepHours} REAL NOT NULL,
        ${DatabaseConstants.colNotes} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colPetId}) 
        REFERENCES ${DatabaseConstants.tablePets} (${DatabaseConstants.colId}) 
        ON DELETE CASCADE
      )
    ''');

    // Health Records Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableHealthRecords} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colPetId} TEXT NOT NULL,
        ${DatabaseConstants.colTitle} TEXT NOT NULL,
        ${DatabaseConstants.colType} TEXT NOT NULL,
        ${DatabaseConstants.colDate} TEXT NOT NULL,
        ${DatabaseConstants.colDetails} TEXT NOT NULL,
        ${DatabaseConstants.colAttachmentPath} TEXT,
        FOREIGN KEY (${DatabaseConstants.colPetId}) 
        REFERENCES ${DatabaseConstants.tablePets} (${DatabaseConstants.colId}) 
        ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    _database = null;
    await db.close();
  }
}
