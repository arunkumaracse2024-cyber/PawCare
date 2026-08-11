import '../models/pet_breed.dart';
import '../models/pet_food.dart';
import '../models/pet_vaccine.dart';
import '../models/pet_disease.dart';
import '../models/pet_behaviour.dart';
import '../models/pet_environment.dart';
import '../models/pet_growth_stage.dart';
import '../models/pet_care_guide.dart';

abstract class PetDataRepository {
  Future<List<PetBreed>> getBreeds();
  Future<List<PetFood>> getFoods();
  Future<List<PetVaccine>> getVaccines();
  Future<List<PetDisease>> getDiseases();
  Future<List<PetBehaviour>> getBehaviours();
  Future<List<PetEnvironment>> getEnvironments();
  Future<List<PetGrowthStage>> getGrowthStages();
  Future<List<PetCareGuide>> getCareGuides();
}
