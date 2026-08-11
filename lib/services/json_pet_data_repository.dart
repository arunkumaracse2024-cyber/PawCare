import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/pet_breed.dart';
import '../models/pet_food.dart';
import '../models/pet_vaccine.dart';
import '../models/pet_disease.dart';
import '../models/pet_behaviour.dart';
import '../models/pet_environment.dart';
import '../models/pet_growth_stage.dart';
import '../models/pet_care_guide.dart';
import 'pet_data_repository.dart';
import 'data_validator.dart';

class JsonPetDataRepository implements PetDataRepository {
  Future<List<dynamic>> _loadJsonAsset(String path) async {
    try {
      final jsonStr = await rootBundle.loadString(path);
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded;
      } else {
        debugPrint('[JsonPetDataRepository] File $path does not contain a JSON array.');
        return [];
      }
    } catch (e) {
      debugPrint('[JsonPetDataRepository] Missing or invalid asset $path: $e');
      return [];
    }
  }

  @override
  Future<List<PetBreed>> getBreeds() async {
    final rawList = await _loadJsonAsset('assets/data/breeds.json');
    final List<PetBreed> parsed = [];
    for (final item in rawList) {
      if (item is Map<String, dynamic> && DataValidator.validateBreedRecord(item)) {
        try {
          parsed.add(PetBreed.fromJson(item));
        } catch (e) {
          debugPrint('[JsonPetDataRepository] Failed to parse breed: $e');
        }
      } else {
        debugPrint('[JsonPetDataRepository] Invalid breed record found.');
      }
    }
    return parsed;
  }

  @override
  Future<List<PetFood>> getFoods() async {
    final rawList = await _loadJsonAsset('assets/data/foods.json');
    final List<PetFood> parsed = [];
    for (final item in rawList) {
      if (item is Map<String, dynamic> && DataValidator.validateFoodRecord(item)) {
        try {
          parsed.add(PetFood.fromJson(item));
        } catch (e) {
          debugPrint('[JsonPetDataRepository] Failed to parse food: $e');
        }
      }
    }
    return parsed;
  }

  @override
  Future<List<PetVaccine>> getVaccines() async {
    final rawList = await _loadJsonAsset('assets/data/vaccines.json');
    final List<PetVaccine> parsed = [];
    for (final item in rawList) {
      if (item is Map<String, dynamic> && DataValidator.validateVaccineRecord(item)) {
        try {
          parsed.add(PetVaccine.fromJson(item));
        } catch (e) {
          debugPrint('[JsonPetDataRepository] Failed to parse vaccine: $e');
        }
      }
    }
    return parsed;
  }

  @override
  Future<List<PetDisease>> getDiseases() async {
    final rawList = await _loadJsonAsset('assets/data/diseases.json');
    final List<PetDisease> parsed = [];
    for (final item in rawList) {
      if (item is Map<String, dynamic> && DataValidator.validateDiseaseRecord(item)) {
        try {
          parsed.add(PetDisease.fromJson(item));
        } catch (e) {
          debugPrint('[JsonPetDataRepository] Failed to parse disease: $e');
        }
      }
    }
    return parsed;
  }

  @override
  Future<List<PetBehaviour>> getBehaviours() async {
    final rawList = await _loadJsonAsset('assets/data/behaviours.json');
    final List<PetBehaviour> parsed = [];
    for (final item in rawList) {
      if (item is Map<String, dynamic> && DataValidator.validateBehaviourRecord(item)) {
        try {
          parsed.add(PetBehaviour.fromJson(item));
        } catch (e) {
          debugPrint('[JsonPetDataRepository] Failed to parse behaviour: $e');
        }
      }
    }
    return parsed;
  }

  @override
  Future<List<PetEnvironment>> getEnvironments() async {
    final rawList = await _loadJsonAsset('assets/data/environments.json');
    final List<PetEnvironment> parsed = [];
    for (final item in rawList) {
      if (item is Map<String, dynamic> && DataValidator.validateEnvironmentRecord(item)) {
        try {
          parsed.add(PetEnvironment.fromJson(item));
        } catch (e) {
          debugPrint('[JsonPetDataRepository] Failed to parse environment: $e');
        }
      }
    }
    return parsed;
  }

  @override
  Future<List<PetGrowthStage>> getGrowthStages() async {
    final rawList = await _loadJsonAsset('assets/data/growth_stages.json');
    final List<PetGrowthStage> parsed = [];
    for (final item in rawList) {
      if (item is Map<String, dynamic> && DataValidator.validateGrowthStageRecord(item)) {
        try {
          parsed.add(PetGrowthStage.fromJson(item));
        } catch (e) {
          debugPrint('[JsonPetDataRepository] Failed to parse growth stage: $e');
        }
      }
    }
    return parsed;
  }

  @override
  Future<List<PetCareGuide>> getCareGuides() async {
    final rawList = await _loadJsonAsset('assets/data/care_guides.json');
    final List<PetCareGuide> parsed = [];
    for (final item in rawList) {
      if (item is Map<String, dynamic> && DataValidator.validateCareGuideRecord(item)) {
        try {
          parsed.add(PetCareGuide.fromJson(item));
        } catch (e) {
          debugPrint('[JsonPetDataRepository] Failed to parse care guide: $e');
        }
      }
    }
    return parsed;
  }
}
