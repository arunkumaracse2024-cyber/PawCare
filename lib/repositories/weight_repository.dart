import 'package:sqflite/sqflite.dart';
import '../models/weight_record.dart';
import '../database/database_helper.dart';

class WeightRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> insertWeightRecord(WeightRecord record) async {
    final db = await _dbHelper.database;
    await db.insert(
      'weight_history',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateWeightRecord(WeightRecord record) async {
    final db = await _dbHelper.database;
    await db.update(
      'weight_history',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteWeightRecord(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'weight_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<WeightRecord>> getWeightHistory(String petId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'weight_history',
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return WeightRecord.fromMap(maps[i]);
    });
  }
}
