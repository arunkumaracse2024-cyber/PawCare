import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/pet.dart';
import '../../models/reminder.dart';
import '../../models/behaviour_log.dart';
import '../../models/health_record.dart';

class FakeFirebaseService {
  static final FakeFirebaseService _instance = FakeFirebaseService._internal();
  factory FakeFirebaseService() => _instance;
  FakeFirebaseService._internal() {
    _seedInitialData();
  }

  // Local Memory Storage
  String? _currentUserEmail;
  final List<Pet> _pets = [];
  final List<PetReminder> _reminders = [];
  final List<BehaviourLog> _behaviourLogs = [];
  final List<HealthRecord> _healthRecords = [];

  // Simulated latency helper
  Future<void> _latency() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  String? get currentUserEmail => _currentUserEmail;
  bool get isAuthenticated => _currentUserEmail != null;

  // --- AUTH SERVICES ---
  Future<bool> login(String email, String password) async {
    await _latency();
    if (email.contains('@') && password.length >= 6) {
      _currentUserEmail = email;
      debugPrint('[FakeFirebase] User logged in: $email');
      return true;
    }
    throw Exception('Invalid email or password (min 6 chars)');
  }

  Future<bool> register(String email, String password) async {
    await _latency();
    if (email.contains('@') && password.length >= 6) {
      _currentUserEmail = email;
      debugPrint('[FakeFirebase] User registered: $email');
      return true;
    }
    throw Exception(
      'Registration failed: Invalid email or password (min 6 chars)',
    );
  }

  Future<void> logout() async {
    await _latency();
    debugPrint('[FakeFirebase] User logged out: $_currentUserEmail');
    _currentUserEmail = null;
  }

  // --- FIRESTORE PETS SERVICES ---
  Future<List<Pet>> fetchPets() async {
    await _latency();
    return List.from(_pets);
  }

  Future<void> savePet(Pet pet) async {
    await _latency();
    final index = _pets.indexWhere((p) => p.id == pet.id);
    if (index != -1) {
      _pets[index] = pet;
      debugPrint('[FakeFirebase] Updated pet: ${pet.name}');
    } else {
      _pets.add(pet);
      debugPrint('[FakeFirebase] Added new pet: ${pet.name}');
    }
  }

  Future<void> deletePet(String petId) async {
    await _latency();
    _pets.removeWhere((p) => p.id == petId);
    _reminders.removeWhere((r) => r.petId == petId);
    _behaviourLogs.removeWhere((l) => l.petId == petId);
    _healthRecords.removeWhere((h) => h.petId == petId);
    debugPrint('[FakeFirebase] Deleted pet ID: $petId');
  }

  // --- FIRESTORE REMINDERS ---
  Future<List<PetReminder>> fetchReminders(String petId) async {
    await _latency();
    return _reminders.where((r) => r.petId == petId).toList();
  }

  Future<List<PetReminder>> fetchAllReminders() async {
    await _latency();
    return List.from(_reminders);
  }

  Future<void> saveReminder(PetReminder reminder) async {
    await _latency();
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
    } else {
      _reminders.add(reminder);
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    await _latency();
    _reminders.removeWhere((r) => r.id == reminderId);
  }

  // --- FIRESTORE BEHAVIOUR LOGS ---
  Future<List<BehaviourLog>> fetchBehaviourLogs(String petId) async {
    await _latency();
    final list = _behaviourLogs.where((l) => l.petId == petId).toList();
    list.sort((a, b) => b.date.compareTo(a.date)); // Newest first
    return list;
  }

  Future<void> saveBehaviourLog(BehaviourLog log) async {
    await _latency();
    final index = _behaviourLogs.indexWhere((l) => l.id == log.id);
    if (index != -1) {
      _behaviourLogs[index] = log;
    } else {
      _behaviourLogs.add(log);
    }
  }

  Future<void> deleteBehaviourLog(String logId) async {
    await _latency();
    _behaviourLogs.removeWhere((l) => l.id == logId);
  }

  // --- FIRESTORE HEALTH RECORDS ---
  Future<List<HealthRecord>> fetchHealthRecords(String petId) async {
    await _latency();
    final list = _healthRecords.where((h) => h.petId == petId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> saveHealthRecord(HealthRecord record) async {
    await _latency();
    final index = _healthRecords.indexWhere((h) => h.id == record.id);
    if (index != -1) {
      _healthRecords[index] = record;
    } else {
      _healthRecords.add(record);
    }
  }

  Future<void> deleteHealthRecord(String recordId) async {
    await _latency();
    _healthRecords.removeWhere((h) => h.id == recordId);
  }

  // --- SEED INITIAL DATA FOR PRESENTATION ---
  void _seedInitialData() {
    debugPrint('[FakeFirebase] Seeding mock data for presentation mode...');

    // Seed dummy pet: Max the Golden Retriever
    final maxId = 'pet_max';
    final maxPet = Pet(
      id: maxId,
      name: 'Max',
      species: 'dog',
      breed: 'Golden Retriever',
      age: 2.5,
      weight: 31.0,
      photoPath: '',
      checklist: [
        ChecklistItem(
          id: 'chk_1',
          title: 'Prepare room and bed',
          category: 'Day 1',
          isDone: true,
        ),
        ChecklistItem(
          id: 'chk_2',
          title: 'Buy water and feeding bowls',
          category: 'Day 1',
          isDone: true,
        ),
        ChecklistItem(
          id: 'chk_3',
          title: 'Schedule first checkup at veterinary',
          category: 'Week 1',
          isDone: false,
        ),
        ChecklistItem(
          id: 'chk_4',
          title: 'Introduce leash training',
          category: 'Week 1',
          isDone: false,
        ),
        ChecklistItem(
          id: 'chk_5',
          title: 'Begin basic command training',
          category: 'Month 1',
          isDone: false,
        ),
      ],
    );
    _pets.add(maxPet);

    // Seed dummy pet: Whiskers the Persian Cat
    final whiskersId = 'pet_whiskers';
    final whiskersPet = Pet(
      id: whiskersId,
      name: 'Whiskers',
      species: 'cat',
      breed: 'Persian Cat',
      age: 1.2,
      weight: 4.8,
      photoPath: '',
      checklist: [
        ChecklistItem(
          id: 'chk_6',
          title: 'Setup litter box and scratching post',
          category: 'Day 1',
          isDone: true,
        ),
        ChecklistItem(
          id: 'chk_7',
          title: 'Buy kitten grooming brush',
          category: 'Week 1',
          isDone: true,
        ),
        ChecklistItem(
          id: 'chk_8',
          title: 'Vaccination booster clinic visit',
          category: 'Month 1',
          isDone: false,
        ),
      ],
    );
    _pets.add(whiskersPet);

    // Seed reminders for Max
    _reminders.add(
      PetReminder(
        id: 'rem_1',
        petId: maxId,
        title: 'Annual Rabies Vaccine',
        type: 'Vaccine',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        repeatOption: 'None',
        isDone: false,
      ),
    );
    _reminders.add(
      PetReminder(
        id: 'rem_2',
        petId: maxId,
        title: 'Deworming Tablet',
        type: 'Medicine',
        dateTime: DateTime.now().subtract(const Duration(hours: 4)),
        repeatOption: 'Monthly',
        isDone: true,
      ),
    );

    // Seed reminders for Whiskers
    _reminders.add(
      PetReminder(
        id: 'rem_3',
        petId: whiskersId,
        title: 'Comb Fluffy Coat',
        type: 'Grooming',
        dateTime: DateTime.now().add(const Duration(hours: 6)),
        repeatOption: 'Daily',
        isDone: false,
      ),
    );

    // Seed behaviour logs for Max (14 days past)
    final now = DateTime.now();
    for (int i = 13; i >= 0; i--) {
      final logDate = now.subtract(Duration(days: i));
      _behaviourLogs.add(
        BehaviourLog(
          id: 'log_max_$i',
          petId: maxId,
          date: logDate,
          eatingStatus: (i == 4 || i == 9) ? 'Fair' : 'Good',
          activityLevel: (i == 2 || i == 6) ? 2 : 4,
          sleepHours: (i == 4 || i == 9) ? 6.5 : 8.5,
          notes: i == 4
              ? 'Wary of dry kibble today'
              : 'Energetic, ate everything.',
        ),
      );
    }

    // Seed behavior logs for Whiskers (14 days past)
    for (int i = 13; i >= 0; i--) {
      final logDate = now.subtract(Duration(days: i));
      _behaviourLogs.add(
        BehaviourLog(
          id: 'log_whiskers_$i',
          petId: whiskersId,
          date: logDate,
          eatingStatus: 'Excellent',
          activityLevel: (i == 5) ? 5 : 3,
          sleepHours: (i == 7) ? 5.0 : 9.5,
          notes: i == 5 ? 'Zoomed around at 3am!' : 'Normal peaceful day.',
        ),
      );
    }

    // Seed health records
    _healthRecords.add(
      HealthRecord(
        id: 'hr_1',
        petId: maxId,
        title: 'First DHPP Vaccination',
        type: 'Vaccine',
        date: DateTime.now().subtract(const Duration(days: 90)),
        details: 'Completed - Administered Pfizer DHPP booster. Good vitals.',
      ),
    );
    _healthRecords.add(
      HealthRecord(
        id: 'hr_2',
        petId: maxId,
        title: 'Ear Drops Prescription',
        type: 'Prescription',
        date: DateTime.now().subtract(const Duration(days: 30)),
        details:
            '2 drops in canal twice daily for 7 days. Ear redness cleared.',
      ),
    );
  }
}
