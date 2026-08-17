import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import 'package:sqflite/sqflite.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveSetting(String key, String value) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        DatabaseConstants.tableSettings,
        {
          DatabaseConstants.colSettingsKey: key,
          DatabaseConstants.colSettingsValue: value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error saving setting: $e');
    }
  }

  Future<String?> getSetting(String key) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseConstants.tableSettings,
        where: '${DatabaseConstants.colSettingsKey} = ?',
        whereArgs: [key],
      );

      if (maps.isNotEmpty) {
        return maps.first[DatabaseConstants.colSettingsValue] as String?;
      }
    } catch (e) {
      debugPrint('Error getting setting: $e');
    }
    return null;
  }

  Future<void> deleteSetting(String key) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        DatabaseConstants.tableSettings,
        where: '${DatabaseConstants.colSettingsKey} = ?',
        whereArgs: [key],
      );
    } catch (e) {
      debugPrint('Error deleting setting: $e');
    }
  }
}

