import 'package:flutter/foundation.dart';
import '../models/health_record.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import 'package:sqflite/sqflite.dart';

class HealthRecordRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveHealthRecord(HealthRecord record) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        DatabaseConstants.tableHealthRecords,
        {
          DatabaseConstants.colId: record.id,
          DatabaseConstants.colPetId: record.petId,
          DatabaseConstants.colTitle: record.title,
          DatabaseConstants.colType: record.type,
          DatabaseConstants.colDate: record.date.toIso8601String(),
          DatabaseConstants.colDetails: record.details,
          DatabaseConstants.colAttachmentPath: record.attachmentPath,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error saving health record: $e');
      rethrow;
    }
  }

  Future<List<HealthRecord>> getRecordsForPet(String petId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseConstants.tableHealthRecords,
        where: '${DatabaseConstants.colPetId} = ?',
        whereArgs: [petId],
        orderBy: '${DatabaseConstants.colDate} DESC',
      );

      return maps.map((map) {
        return HealthRecord(
          id: map[DatabaseConstants.colId] as String,
          petId: map[DatabaseConstants.colPetId] as String,
          title: map[DatabaseConstants.colTitle] as String,
          type: map[DatabaseConstants.colType] as String,
          date: DateTime.parse(map[DatabaseConstants.colDate] as String),
          details: map[DatabaseConstants.colDetails] as String,
          attachmentPath: map[DatabaseConstants.colAttachmentPath] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting health records: $e');
      return [];
    }
  }

  Future<void> deleteHealthRecord(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        DatabaseConstants.tableHealthRecords,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting health record: $e');
      rethrow;
    }
  }
}

