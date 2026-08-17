import 'package:flutter/foundation.dart';
import '../models/pet.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import 'package:sqflite/sqflite.dart';

class PetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> savePet(Pet pet) async {
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        // Save Pet
        await txn.insert(
          DatabaseConstants.tablePets,
          {
            DatabaseConstants.colId: pet.id,
            DatabaseConstants.colName: pet.name,
            DatabaseConstants.colSpecies: pet.species,
            DatabaseConstants.colBreed: pet.breed,
            DatabaseConstants.colAge: pet.age,
            DatabaseConstants.colWeight: pet.weight,
            DatabaseConstants.colPhotoPath: pet.photoPath,
            DatabaseConstants.colOwnerUid: pet.ownerUid,
            DatabaseConstants.colShopId: pet.shopId,
            DatabaseConstants.colLinkCode: pet.linkCode,
            DatabaseConstants.colIsLinked: pet.isLinked ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Delete existing checklists for this pet before inserting new ones
        await txn.delete(
          DatabaseConstants.tableChecklists,
          where: '${DatabaseConstants.colPetId} = ?',
          whereArgs: [pet.id],
        );

        // Save Checklists
        for (var item in pet.checklist) {
          await txn.insert(
            DatabaseConstants.tableChecklists,
            {
              DatabaseConstants.colId: item.id,
              DatabaseConstants.colPetId: pet.id,
              DatabaseConstants.colTitle: item.title,
              DatabaseConstants.colCategory: item.category,
              DatabaseConstants.colIsDone: item.isDone ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      debugPrint('Error saving pet: $e');
      rethrow;
    }
  }

  Future<Pet?> getPet(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseConstants.tablePets,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return await _hydratePet(db, maps.first);
    } catch (e) {
      debugPrint('Error getting pet: $e');
      return null;
    }
  }

  Future<List<Pet>> getPetsByOwner(String ownerUid) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseConstants.tablePets,
        where: '${DatabaseConstants.colOwnerUid} = ?',
        whereArgs: [ownerUid],
      );

      List<Pet> pets = [];
      for (var map in maps) {
        pets.add(await _hydratePet(db, map));
      }
      return pets;
    } catch (e) {
      debugPrint('Error fetching owner pets: $e');
      return [];
    }
  }

  Future<void> deletePet(String id) async {
    try {
      final db = await _dbHelper.database;
      // SQLite CASCADE will handle deleting associated checklists, reminders, etc.
      await db.delete(
        DatabaseConstants.tablePets,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting pet: $e');
      rethrow;
    }
  }

  Future<List<Pet>> getPetsByShop(String shopId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseConstants.tablePets,
        where: '${DatabaseConstants.colShopId} = ?',
        whereArgs: [shopId],
      );

      List<Pet> pets = [];
      for (var map in maps) {
        pets.add(await _hydratePet(db, map));
      }
      return pets;
    } catch (e) {
      debugPrint('Error fetching shop pets: $e');
      return [];
    }
  }

  Future<Pet?> findPetByLinkCode(String linkCode) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseConstants.tablePets,
        where: '${DatabaseConstants.colLinkCode} = ?',
        whereArgs: [linkCode],
      );

      if (maps.isEmpty) return null;
      return await _hydratePet(db, maps.first);
    } catch (e) {
      debugPrint('Error finding pet by link code: $e');
      return null;
    }
  }

  Future<void> acceptPetLink(String petId, String ownerUid) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        DatabaseConstants.tablePets,
        {
          DatabaseConstants.colOwnerUid: ownerUid,
          DatabaseConstants.colIsLinked: 1,
        },
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [petId],
      );
    } catch (e) {
      debugPrint('Error accepting pet link: $e');
      rethrow;
    }
  }

  Future<Pet> _hydratePet(Database db, Map<String, dynamic> petMap) async {
    final petId = petMap[DatabaseConstants.colId] as String;
    
    // Fetch checklist
    final checklistMaps = await db.query(
      DatabaseConstants.tableChecklists,
      where: '${DatabaseConstants.colPetId} = ?',
      whereArgs: [petId],
    );

    List<ChecklistItem> checklist = checklistMaps.map((map) {
      return ChecklistItem(
        id: map[DatabaseConstants.colId] as String,
        title: map[DatabaseConstants.colTitle] as String,
        category: map[DatabaseConstants.colCategory] as String,
        isDone: (map[DatabaseConstants.colIsDone] as int) == 1,
      );
    }).toList();

    return Pet(
      id: petId,
      name: petMap[DatabaseConstants.colName] as String,
      species: petMap[DatabaseConstants.colSpecies] as String,
      breed: petMap[DatabaseConstants.colBreed] as String,
      age: (petMap[DatabaseConstants.colAge] as num).toDouble(),
      weight: (petMap[DatabaseConstants.colWeight] as num).toDouble(),
      photoPath: petMap[DatabaseConstants.colPhotoPath] as String,
      checklist: checklist,
      ownerUid: petMap[DatabaseConstants.colOwnerUid] as String,
      shopId: petMap[DatabaseConstants.colShopId] as String?,
      linkCode: petMap[DatabaseConstants.colLinkCode] as String?,
      isLinked: (petMap[DatabaseConstants.colIsLinked] as int) == 1,
      shopNotes: [], // We are leaving this empty as per standard relations unless we map CareNotes too
    );
  }
}

