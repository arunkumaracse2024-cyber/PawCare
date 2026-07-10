import 'package:flutter/foundation.dart';
import 'fake_firebase_service.dart';
import '../../models/pet.dart';
import '../../models/reminder.dart';
import '../../models/behaviour_log.dart';
import '../../models/health_record.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FakeFirebaseService _fakeDb = FakeFirebaseService();

  // Flag to indicate whether real Firebase is available.
  // Set to false to force local sandbox fallback database.
  final bool _useRealFirebase = false;

  String? get currentUserEmail {
    if (_useRealFirebase) {
      return null;
    }
    return _fakeDb.currentUserEmail;
  }

  bool get isAuthenticated {
    if (_useRealFirebase) {
      return false;
    }
    return _fakeDb.isAuthenticated;
  }

  // --- AUTH ---
  Future<bool> login(String email, String password) async {
    debugPrint('[FirebaseService] Auth: Logging in via local database.');
    return _fakeDb.login(email, password);
  }

  Future<bool> register(String email, String password) async {
    debugPrint('[FirebaseService] Auth: Registering user via local database.');
    return _fakeDb.register(email, password);
  }

  Future<void> logout() async {
    debugPrint('[FirebaseService] Auth: Logging out user via local database.');
    return _fakeDb.logout();
  }

  // --- PETS ---
  Future<List<Pet>> fetchPets() async {
    debugPrint('[FirebaseService] Firestore: Fetching all pets.');
    return _fakeDb.fetchPets();
  }

  Future<void> savePet(Pet pet) async {
    debugPrint('[FirebaseService] Firestore: Saving pet: ${pet.name}.');
    return _fakeDb.savePet(pet);
  }

  Future<void> deletePet(String petId) async {
    debugPrint('[FirebaseService] Firestore: Deleting pet: $petId.');
    return _fakeDb.deletePet(petId);
  }

  // --- REMINDERS ---
  Future<List<PetReminder>> fetchReminders(String petId) async {
    debugPrint(
      '[FirebaseService] Firestore: Fetching reminders for pet: $petId.',
    );
    return _fakeDb.fetchReminders(petId);
  }

  Future<List<PetReminder>> fetchAllReminders() async {
    debugPrint('[FirebaseService] Firestore: Fetching all reminders.');
    return _fakeDb.fetchAllReminders();
  }

  Future<void> saveReminder(PetReminder reminder) async {
    debugPrint(
      '[FirebaseService] Firestore: Saving reminder: ${reminder.title}.',
    );
    return _fakeDb.saveReminder(reminder);
  }

  Future<void> deleteReminder(String reminderId) async {
    debugPrint('[FirebaseService] Firestore: Deleting reminder: $reminderId.');
    return _fakeDb.deleteReminder(reminderId);
  }

  // --- BEHAVIOUR ---
  Future<List<BehaviourLog>> fetchBehaviourLogs(String petId) async {
    debugPrint(
      '[FirebaseService] Firestore: Fetching behaviour logs for: $petId.',
    );
    return _fakeDb.fetchBehaviourLogs(petId);
  }

  Future<void> saveBehaviourLog(BehaviourLog log) async {
    debugPrint(
      '[FirebaseService] Firestore: Saving behaviour log for pet: ${log.petId}.',
    );
    return _fakeDb.saveBehaviourLog(log);
  }

  Future<void> deleteBehaviourLog(String logId) async {
    debugPrint('[FirebaseService] Firestore: Deleting behaviour log: $logId.');
    return _fakeDb.deleteBehaviourLog(logId);
  }

  // --- HEALTH WALLET ---
  Future<List<HealthRecord>> fetchHealthRecords(String petId) async {
    debugPrint(
      '[FirebaseService] Firestore: Fetching health records for: $petId.',
    );
    return _fakeDb.fetchHealthRecords(petId);
  }

  Future<void> saveHealthRecord(HealthRecord record) async {
    debugPrint(
      '[FirebaseService] Firestore: Saving health record: ${record.title}.',
    );
    return _fakeDb.saveHealthRecord(record);
  }

  Future<void> deleteHealthRecord(String recordId) async {
    debugPrint(
      '[FirebaseService] Firestore: Deleting health record: $recordId.',
    );
    return _fakeDb.deleteHealthRecord(recordId);
  }
}
