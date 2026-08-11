import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/reminder.dart';
import '../models/behaviour_log.dart';
import '../models/health_record.dart';
import '../services/firebase_service.dart';
import '../models/pet_breed.dart';
import '../models/pet_food.dart';
import '../models/pet_vaccine.dart';
import '../models/pet_disease.dart';
import '../models/pet_behaviour.dart';
import '../models/pet_environment.dart';
import '../models/pet_growth_stage.dart';
import '../models/pet_care_guide.dart';
import '../services/pet_data_repository.dart';
import '../services/json_pet_data_repository.dart';
import '../services/care_plan_service.dart';

class AppState extends ChangeNotifier {
  final FirebaseService _db = FirebaseService();

  List<Pet> _pets = [];
  Pet? _selectedPet;
  List<PetReminder> _reminders = [];
  List<BehaviourLog> _behaviourLogs = [];
  List<HealthRecord> _healthRecords = [];

  // Structured Knowledge Data
  List<PetBreed> breeds = [];
  List<PetFood> foods = [];
  List<PetVaccine> vaccines = [];
  List<PetDisease> diseases = [];
  List<PetBehaviour> behaviours = [];
  List<PetEnvironment> environments = [];
  List<PetGrowthStage> growthStages = [];
  List<PetCareGuide> careGuides = [];

  bool _isLoading = false;
  bool isDatasetLoading = false;
  String? datasetError;
  bool _isDarkMode = false;
  
  final PetDataRepository _petDataRepo = JsonPetDataRepository();

  // Getters
  List<Pet> get pets => _pets;
  Pet? get selectedPet => _selectedPet;
  List<PetReminder> get reminders => _reminders;
  List<BehaviourLog> get behaviourLogs => _behaviourLogs;
  List<HealthRecord> get healthRecords => _healthRecords;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  String? get currentUserEmail => _db.currentUserEmail;
  bool get isAuthenticated => _db.isAuthenticated;

  // Constructor
  AppState() {
    _initApp();
  }

  Future<void> _initApp() async {
    _setLoading(true);
    await loadPetDatasets(); // Load structured datasets first
    if (_db.isAuthenticated) {
      await refreshState();
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- DARK MODE THEME ---
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // --- DATASET LOAD ---
  Future<void> loadPetDatasets() async {
    isDatasetLoading = true;
    datasetError = null;
    notifyListeners();

    try {
      breeds = await _petDataRepo.getBreeds();
      foods = await _petDataRepo.getFoods();
      vaccines = await _petDataRepo.getVaccines();
      diseases = await _petDataRepo.getDiseases();
      behaviours = await _petDataRepo.getBehaviours();
      environments = await _petDataRepo.getEnvironments();
      growthStages = await _petDataRepo.getGrowthStages();
      careGuides = await _petDataRepo.getCareGuides();
    } catch (e) {
      datasetError = 'Failed to load datasets: $e';
      debugPrint('[AppState] $datasetError');
    } finally {
      isDatasetLoading = false;
      notifyListeners();
    }
  }



  // --- AUTH METHODS ---
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _db.login(email, password);
      await refreshState();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      await _db.register(email, password);
      await refreshState();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _db.logout();
      _pets.clear();
      _selectedPet = null;
      _reminders.clear();
      _behaviourLogs.clear();
      _healthRecords.clear();
    } finally {
      _setLoading(false);
    }
  }

  // --- STATE REFRESH / SYNC ---
  Future<void> refreshState() async {
    _pets = await _db.fetchPets();
    if (_pets.isNotEmpty) {
      // Retain selection if existing pet is still there, else select first
      if (_selectedPet == null || !_pets.any((p) => p.id == _selectedPet!.id)) {
        _selectedPet = _pets.first;
      } else {
        _selectedPet = _pets.firstWhere((p) => p.id == _selectedPet!.id);
      }
      await refreshSubmodels();
    } else {
      _selectedPet = null;
      _reminders.clear();
      _behaviourLogs.clear();
      _healthRecords.clear();
    }
    notifyListeners();
  }

  Future<void> refreshSubmodels() async {
    if (_selectedPet != null) {
      _reminders = await _db.fetchReminders(_selectedPet!.id);
      _behaviourLogs = await _db.fetchBehaviourLogs(_selectedPet!.id);
      _healthRecords = await _db.fetchHealthRecords(_selectedPet!.id);
    }
  }

  void selectPet(Pet pet) async {
    _selectedPet = pet;
    _setLoading(true);
    await refreshSubmodels();
    _setLoading(false);
  }

  // --- PET MANAGEMENT ---
  Future<void> addPet({
    required String name,
    required String species,
    required String breed,
    required double age,
    required double weight,
    required String photoPath,
  }) async {
    _setLoading(true);
    try {
      final petId = 'pet_${DateTime.now().millisecondsSinceEpoch}';

      // Auto-generate milestone checklist based on CarePlanService
      final checklist = CarePlanService.generateChecklist(
        petId: petId,
        species: species,
        breed: breed,
        age: age,
        careGuides: careGuides,
        growthStages: growthStages,
      );

      final newPet = Pet(
        id: petId,
        name: name,
        species: species,
        breed: breed,
        age: age,
        weight: weight,
        photoPath: photoPath,
        checklist: checklist,
      );

      await _db.savePet(newPet);

      // Programmatically schedule reminder recommendations from CarePlanService
      final generatedReminders = CarePlanService.generateReminders(
        petId: petId,
        species: species,
        vaccines: vaccines,
      );
      
      for (final reminder in generatedReminders) {
        await _db.saveReminder(reminder);
      }

      await refreshState();
      // Set the newly created pet as selected
      final newPetIndex = _pets.indexWhere((p) => p.id == petId);
      if (newPetIndex != -1) {
        _selectedPet = _pets[newPetIndex];
      }
      await refreshSubmodels();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePet(Pet pet) async {
    _setLoading(true);
    try {
      await _db.savePet(pet);
      await refreshState();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePet(String petId) async {
    _setLoading(true);
    try {
      await _db.deletePet(petId);
      if (_selectedPet?.id == petId) {
        _selectedPet = null;
      }
      await refreshState();
    } finally {
      _setLoading(false);
    }
  }

  // --- CHECKLIST MANAGEMENT ---
  Future<void> toggleChecklistItem(String itemId, bool isDone) async {
    if (_selectedPet == null) return;

    final updatedChecklist = _selectedPet!.checklist.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isDone: isDone);
      }
      return item;
    }).toList();

    final updatedPet = _selectedPet!.copyWith(checklist: updatedChecklist);
    await updatePet(updatedPet);
  }

  // --- REMINDER MANAGEMENT ---
  Future<void> addReminder({
    required String title,
    required String type,
    required DateTime dateTime,
    required String repeatOption,
  }) async {
    if (_selectedPet == null) return;
    _setLoading(true);
    try {
      final reminder = PetReminder(
        id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
        petId: _selectedPet!.id,
        title: title,
        type: type,
        dateTime: dateTime,
        repeatOption: repeatOption,
        isDone: false,
      );
      await _db.saveReminder(reminder);
      await refreshSubmodels();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleReminderDone(String id, bool isDone) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _setLoading(true);
    try {
      final updated = _reminders[index].copyWith(isDone: isDone);
      await _db.saveReminder(updated);
      await refreshSubmodels();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteReminder(String id) async {
    _setLoading(true);
    try {
      await _db.deleteReminder(id);
      await refreshSubmodels();
    } finally {
      _setLoading(false);
    }
  }

  // --- BEHAVIOUR LOGGER ---
  Future<void> addBehaviourLog({
    required String eatingStatus,
    required int activityLevel,
    required double sleepHours,
    required String notes,
  }) async {
    if (_selectedPet == null) return;
    _setLoading(true);
    try {
      final log = BehaviourLog(
        id: 'blog_${DateTime.now().millisecondsSinceEpoch}',
        petId: _selectedPet!.id,
        date: DateTime.now(),
        eatingStatus: eatingStatus,
        activityLevel: activityLevel,
        sleepHours: sleepHours,
        notes: notes,
      );
      await _db.saveBehaviourLog(log);
      await refreshSubmodels(); // updates trend list
    } finally {
      _setLoading(false);
    }
  }

  // --- HEALTH RECORDS ---
  Future<void> addHealthRecord({
    required String title,
    required String type,
    required DateTime date,
    required String details,
    String? attachmentPath,
  }) async {
    if (_selectedPet == null) return;
    _setLoading(true);
    try {
      final record = HealthRecord(
        id: 'hrec_${DateTime.now().millisecondsSinceEpoch}',
        petId: _selectedPet!.id,
        title: title,
        type: type,
        date: date,
        details: details,
        attachmentPath: attachmentPath,
      );
      await _db.saveHealthRecord(record);
      await refreshSubmodels();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteHealthRecord(String recordId) async {
    _setLoading(true);
    try {
      await _db.deleteHealthRecord(recordId);
      await refreshSubmodels();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteBehaviourLog(String logId) async {
    _setLoading(true);
    try {
      await _db.deleteBehaviourLog(logId);
      await refreshSubmodels();
    } finally {
      _setLoading(false);
    }
  }
}
