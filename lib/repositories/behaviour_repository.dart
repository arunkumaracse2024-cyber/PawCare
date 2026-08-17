import 'package:flutter/foundation.dart';
import '../models/behaviour_log.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import 'package:sqflite/sqflite.dart';

class BehaviourRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveBehaviourLog(BehaviourLog log) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        DatabaseConstants.tableBehaviourLogs,
        {
          DatabaseConstants.colId: log.id,
          DatabaseConstants.colPetId: log.petId,
          DatabaseConstants.colDate: log.date.toIso8601String(),
          DatabaseConstants.colEatingStatus: log.eatingStatus,
          DatabaseConstants.colActivityLevel: log.activityLevel,
          DatabaseConstants.colSleepHours: log.sleepHours,
          DatabaseConstants.colNotes: log.notes,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error saving behaviour log: $e');
      rethrow;
    }
  }

  Future<List<BehaviourLog>> getLogsForPet(String petId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseConstants.tableBehaviourLogs,
        where: '${DatabaseConstants.colPetId} = ?',
        whereArgs: [petId],
        orderBy: '${DatabaseConstants.colDate} DESC',
      );

      return maps.map((map) {
        return BehaviourLog(
          id: map[DatabaseConstants.colId] as String,
          petId: map[DatabaseConstants.colPetId] as String,
          date: DateTime.parse(map[DatabaseConstants.colDate] as String),
          eatingStatus: map[DatabaseConstants.colEatingStatus] as String,
          activityLevel: map[DatabaseConstants.colActivityLevel] as int,
          sleepHours: (map[DatabaseConstants.colSleepHours] as num).toDouble(),
          notes: map[DatabaseConstants.colNotes] as String,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting behaviour logs: $e');
      return [];
    }
  }

  Future<void> deleteBehaviourLog(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        DatabaseConstants.tableBehaviourLogs,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting behaviour log: $e');
      rethrow;
    }
  }
}

