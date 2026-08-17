import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/encyclopedia.dart';
import '../models/food.dart';
import '../models/disease.dart';
import '../models/behaviour_trait.dart';
import '../models/care_task.dart';
import '../models/growth_stage.dart';
import '../models/environment.dart';

class EncyclopediaProvider extends ChangeNotifier {
  List<Species> _speciesList = [];
  List<Breed> _breeds = [];
  List<Food> _foods = [];
  List<VaccineTemplate> _vaccines = [];
  List<Disease> _diseases = [];
  List<BehaviourTrait> _behaviours = [];
  List<CareTask> _careTasks = [];
  List<GrowthStage> _growthStages = [];
  List<EnvironmentRecommendation> _environments = [];

  bool _isLoading = false;

  List<Species> get speciesList => _speciesList;
  List<Breed> get breeds => _breeds;
  List<Food> get foods => _foods;
  List<VaccineTemplate> get vaccines => _vaccines;
  List<Disease> get diseases => _diseases;
  List<BehaviourTrait> get behaviours => _behaviours;
  List<CareTask> get careTasks => _careTasks;
  List<GrowthStage> get growthStages => _growthStages;
  List<EnvironmentRecommendation> get environments => _environments;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final futures = await Future.wait([
        rootBundle.loadString('assets/data/species.json'),
        rootBundle.loadString('assets/data/breeds.json'),
        rootBundle.loadString('assets/data/foods.json'),
        rootBundle.loadString('assets/data/vaccines.json'),
        rootBundle.loadString('assets/data/diseases.json'),
        rootBundle.loadString('assets/data/behaviours.json'),
        rootBundle.loadString('assets/data/care_guides.json'),
        rootBundle.loadString('assets/data/growth_stages.json'),
        rootBundle.loadString('assets/data/environments.json'),
      ]);

      _speciesList = (json.decode(futures[0])['species'] as List).map((e) => Species.fromMap(e)).toList();
      _breeds = (json.decode(futures[1])['breeds'] as List).map((e) => Breed.fromMap(e)).toList();
      _foods = (json.decode(futures[2])['foods'] as List).map((e) => Food.fromMap(e)).toList();
      _vaccines = (json.decode(futures[3])['vaccines'] as List).map((e) => VaccineTemplate.fromMap(e)).toList();
      _diseases = (json.decode(futures[4])['diseases'] as List).map((e) => Disease.fromMap(e)).toList();
      _behaviours = (json.decode(futures[5])['behaviours'] as List).map((e) => BehaviourTrait.fromMap(e)).toList();
      _careTasks = (json.decode(futures[6])['care_tasks'] as List).map((e) => CareTask.fromMap(e)).toList();
      _growthStages = (json.decode(futures[7])['growth_stages'] as List).map((e) => GrowthStage.fromMap(e)).toList();
      _environments = (json.decode(futures[8])['environments'] as List).map((e) => EnvironmentRecommendation.fromMap(e)).toList();
      
      debugPrint('[EncyclopediaProvider] Loaded encyclopedia datasets successfully.');
    } catch (e) {
      debugPrint('[EncyclopediaProvider] Error loading encyclopedia: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
