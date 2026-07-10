import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/pet.dart';
import '../models/reminder.dart';
import '../models/behaviour_log.dart';
import '../models/health_record.dart';
import '../models/encyclopedia.dart';
import '../services/firebase_service.dart';

class AppState extends ChangeNotifier {
  final FirebaseService _db = FirebaseService();

  List<Species> _speciesList = [];
  List<Pet> _pets = [];
  Pet? _selectedPet;
  List<PetReminder> _reminders = [];
  List<BehaviourLog> _behaviourLogs = [];
  List<HealthRecord> _healthRecords = [];

  bool _isLoading = false;
  bool _isDarkMode = false;

  // Getters
  List<Species> get speciesList => _speciesList;
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
    await loadEncyclopedia();
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

  // --- ENCYCLOPEDIA LOAD ---
  Future<void> loadEncyclopedia() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/pet_encyclopedia.json',
      );
      final Map<String, dynamic> data = json.decode(jsonStr);
      final List<dynamic> list = data['species'] ?? [];
      _speciesList = list
          .map((s) => Species.fromMap(s as Map<String, dynamic>))
          .toList();
      debugPrint(
        '[AppState] Loaded ${_speciesList.length} species from encyclopedia.',
      );
    } catch (e) {
      debugPrint('[AppState] Error loading encyclopedia: $e');
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

      // Auto-generate milestone checklist based on species
      final checklist = [
        ChecklistItem(
          id: '${petId}_chk1',
          title: 'Prepare room and bedding',
          category: 'Day 1',
          isDone: false,
        ),
        ChecklistItem(
          id: '${petId}_chk2',
          title: 'Buy high quality specialized food',
          category: 'Day 1',
          isDone: false,
        ),
        ChecklistItem(
          id: '${petId}_chk3',
          title: 'Install tags and microchip',
          category: 'Week 1',
          isDone: false,
        ),
        ChecklistItem(
          id: '${petId}_chk4',
          title: 'Establish veterinary contact',
          category: 'Week 1',
          isDone: false,
        ),
        ChecklistItem(
          id: '${petId}_chk5',
          title: 'Introduce leash and collar routines',
          category: 'Week 1',
          isDone: false,
        ),
        ChecklistItem(
          id: '${petId}_chk6',
          title: 'Start initial social play training',
          category: 'Month 1',
          isDone: false,
        ),
      ];

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

      // Programmatically schedule reminder recommendations from species checklist if available
      final speciesMatch = _speciesList.firstWhere(
        (s) => s.id == species.toLowerCase(),
        orElse: () => _speciesList.first,
      );
      for (int i = 0; i < speciesMatch.recommendedVaccines.length; i++) {
        final v = speciesMatch.recommendedVaccines[i];
        final reminder = PetReminder(
          id: '${petId}_vax_$i',
          petId: petId,
          title: v.name,
          type: 'Vaccine',
          dateTime: DateTime.now().add(
            Duration(days: (i + 1) * 30),
          ), // spaced reminders
          repeatOption: 'None',
          isDone: false,
        );
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
