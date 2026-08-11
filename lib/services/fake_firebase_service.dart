import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/pet.dart';
import '../../models/reminder.dart';
import '../../models/behaviour_log.dart';
import '../../models/health_record.dart';

class FakeFirebaseService {
  static final FakeFirebaseService _instance = FakeFirebaseService._internal();
  factory FakeFirebaseService() => _instance;
  FakeFirebaseService._internal();

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


}
