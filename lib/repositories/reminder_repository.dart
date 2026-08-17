import 'package:flutter/foundation.dart';
import '../models/reminder.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import 'package:sqflite/sqflite.dart';

class ReminderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveReminder(PetReminder reminder) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        DatabaseConstants.tableReminders,
        {
          DatabaseConstants.colId: reminder.id,
          DatabaseConstants.colPetId: reminder.petId,
          DatabaseConstants.colTitle: reminder.title,
          DatabaseConstants.colType: reminder.type,
          DatabaseConstants.colDateTime: reminder.dateTime.toIso8601String(),
          DatabaseConstants.colRepeatOption: reminder.repeatOption,
          DatabaseConstants.colIsDone: reminder.isDone ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error saving reminder: $e');
      rethrow;
    }
  }

  Future<List<PetReminder>> getRemindersForPet(String petId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseConstants.tableReminders,
        where: '${DatabaseConstants.colPetId} = ?',
        whereArgs: [petId],
      );

      return maps.map((map) {
        return PetReminder(
          id: map[DatabaseConstants.colId] as String,
          petId: map[DatabaseConstants.colPetId] as String,
          title: map[DatabaseConstants.colTitle] as String,
          type: map[DatabaseConstants.colType] as String,
          dateTime: DateTime.parse(map[DatabaseConstants.colDateTime] as String),
          repeatOption: map[DatabaseConstants.colRepeatOption] as String,
          isDone: (map[DatabaseConstants.colIsDone] as int) == 1,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting reminders: $e');
      return [];
    }
  }

  Future<List<PetReminder>> getRemindersForPets(List<String> petIds) async {
    if (petIds.isEmpty) return [];
    try {
      final db = await _dbHelper.database;
      final placeholders = List.filled(petIds.length, '?').join(',');
      final maps = await db.query(
        DatabaseConstants.tableReminders,
        where: '${DatabaseConstants.colPetId} IN ($placeholders)',
        whereArgs: petIds,
      );

      return maps.map((map) {
        return PetReminder(
          id: map[DatabaseConstants.colId] as String,
          petId: map[DatabaseConstants.colPetId] as String,
          title: map[DatabaseConstants.colTitle] as String,
          type: map[DatabaseConstants.colType] as String,
          dateTime: DateTime.parse(map[DatabaseConstants.colDateTime] as String),
          repeatOption: map[DatabaseConstants.colRepeatOption] as String,
          isDone: (map[DatabaseConstants.colIsDone] as int) == 1,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting multi-pet reminders: $e');
      return [];
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        DatabaseConstants.tableReminders,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      rethrow;
    }
  }
}

