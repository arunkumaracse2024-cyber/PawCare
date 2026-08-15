import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_core/firebase_core.dart';

import '../models/pet.dart';
import '../models/reminder.dart';
import '../models/behaviour_log.dart';
import '../models/health_record.dart';
import '../models/user_profile.dart';
import '../models/appointment.dart';
import '../models/vet_profile.dart';
import '../models/shop_profile.dart';
import '../models/care_note.dart';
import '../models/time_slot.dart';

// Storage key used in SharedPreferences for the local mock database.
const _kLocalDbKey = 'pawcare_db';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;
  bool get isRealFirebase => _initialized;

  // In-memory local database used when Firebase is not configured.
  Map<String, dynamic> _localDb = {
    'users': {},
    'pets': {},
    'reminders': {},
    'behaviourLogs': {},
    'healthRecords': {},
    'appointments': {},
    'vetProfiles': {},
    'shopProfiles': {},
    'timeSlots': {},
    'careNotes': {},
    'currentUserEmail': null,
    'currentUid': null,
  };

  // ---------------------------------------------------------------------------
  // Type-safe map helpers (needed because JSON decode produces dynamic maps)
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _getCollection(String key) {
    final val = _localDb[key];
    if (val is Map<String, dynamic>) return val;
    final Map<String, dynamic> converted =
        val is Map ? Map<String, dynamic>.from(val) : <String, dynamic>{};
    _localDb[key] = converted;
    return converted;
  }

  Map<String, dynamic> _castMap(dynamic val) {
    if (val == null) return <String, dynamic>{};
    if (val is Map<String, dynamic>) return val;
    return Map<String, dynamic>.from(val as Map);
  }

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    // Attempt to initialise real Firebase.
    // Firebase.initializeApp() on Web requires FirebaseOptions to be passed
    // explicitly (no google-services.json equivalent on web). If options are
    // not provided, it throws an AssertionError. We catch every error here and
    // fall through to local/demo mode without logging the assertion repeatedly.
    if (Firebase.apps.isNotEmpty) {
      // Firebase was already initialised (e.g. hot-restart in native).
      _initialized = true;
      debugPrint('[FirebaseService] Using already-initialised Firebase SDK.');
      return;
    }

    try {
      // Pass no options — on Web this will throw if no config is embedded.
      // On native it reads google-services.json / GoogleService-Info.plist.
      await Firebase.initializeApp();
      _initialized = true;
      debugPrint('[FirebaseService] Firebase initialised successfully.');
    } catch (_) {
      // Firebase is not configured for this platform/environment.
      // This is expected during local/demo development. Fall through silently.
      _initialized = false;
      debugPrint('[FirebaseService] Firebase not configured — running in local demo mode.');
      await _loadLocalDb();
    }
  }

  // ---------------------------------------------------------------------------
  // Local persistence via SharedPreferences (works on Web, Android, iOS, Win)
  // No dart:io, no path_provider, no File — safe for all platforms.
  // ---------------------------------------------------------------------------

  Future<void> _loadLocalDb() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_kLocalDbKey);
      if (stored != null && stored.isNotEmpty) {
        final decoded = json.decode(stored);
        if (decoded is Map) {
          _localDb = Map<String, dynamic>.from(decoded);
          debugPrint('[FirebaseService] Local database loaded from SharedPreferences.');
        }
      } else {
        debugPrint('[FirebaseService] No existing local database — seeding mock data.');
      }
    } catch (e) {
      debugPrint('[FirebaseService] Could not load local database: $e');
    }
    _seedMockDataIfNeeded();
  }

  Future<void> _saveLocalDb() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocalDbKey, json.encode(_localDb));
    } catch (e) {
      debugPrint('[FirebaseService] Could not save local database: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Mock data seeding
  // ---------------------------------------------------------------------------

  void _seedMockDataIfNeeded() {
    if (_getCollection('pets').isEmpty) {
      debugPrint('[FirebaseService] Seeding initial mock data to local DB...');

      const mockOwnerUid = 'mock_owner_123';
      _getCollection('users')[mockOwnerUid] = {
        'uid': mockOwnerUid,
        'name': 'John Doe',
        'email': 'owner@petpaw.org',
        'password': 'password123',
        'role': 'owner',
        'hasCompletedOnboarding': true,
        'createdAt': DateTime.now().toIso8601String(),
      };

      const mockPetId = 'pet_max';
      _getCollection('pets')[mockPetId] = {
        'id': mockPetId,
        'name': 'Max',
        'species': 'dog',
        'breed': 'Golden Retriever',
        'age': 2.5,
        'weight': 31.0,
        'photoPath': '',
        'checklist': [
          {'id': 'chk_1', 'title': 'Prepare room and bed', 'category': 'Day 1', 'isDone': true},
          {'id': 'chk_2', 'title': 'Buy water and feeding bowls', 'category': 'Day 1', 'isDone': true},
          {'id': 'chk_3', 'title': 'Schedule first checkup at veterinary', 'category': 'Week 1', 'isDone': false},
          {'id': 'chk_4', 'title': 'Introduce leash training', 'category': 'Week 1', 'isDone': false},
        ],
        'ownerUid': mockOwnerUid,
        'isLinked': false,
        'shopNotes': [],
      };

      _getCollection('reminders')['rem_1'] = {
        'id': 'rem_1',
        'petId': mockPetId,
        'title': 'Annual Rabies Vaccine',
        'type': 'Vaccine',
        'dateTime': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'repeatOption': 'None',
        'isDone': false,
      };

      final now = DateTime.now();
      for (int i = 0; i < 3; i++) {
        final logId = 'log_max_$i';
        _getCollection('behaviourLogs')[logId] = {
          'id': logId,
          'petId': mockPetId,
          'date': now.subtract(Duration(days: i)).toIso8601String(),
          'eatingStatus': 'Good',
          'activityLevel': 4,
          'sleepHours': 8.5,
          'notes': 'Normal peaceful day.',
        };
      }

      _getCollection('healthRecords')['hr_1'] = {
        'id': 'hr_1',
        'petId': mockPetId,
        'title': 'First DHPP Vaccination',
        'type': 'Vaccine',
        'date': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
        'details': 'Completed - Administered Pfizer DHPP booster.',
        'attachmentPath': null,
      };

      const mockVetUid = 'mock_vet_123';
      _getCollection('users')[mockVetUid] = {
        'uid': mockVetUid,
        'name': 'Dr. Sarah Smith',
        'email': 'vet@petpaw.org',
        'password': 'password123',
        'role': 'vet',
        'hasCompletedOnboarding': true,
        'createdAt': DateTime.now().toIso8601String(),
      };
      _getCollection('vetProfiles')[mockVetUid] = {
        'uid': mockVetUid,
        'clinicName': 'Downtown Vet Clinic',
        'address': '123 Main St, Metro City',
        'specialization': 'Dogs, Cats & Small Animals',
        'workingHours': {'Mon-Fri': '09:00 - 17:00'},
        'isVerified': true,
        'partnerShopIds': ['mock_shop_123'],
      };

      const mockShopUid = 'mock_shop_123';
      _getCollection('users')[mockShopUid] = {
        'uid': mockShopUid,
        'name': 'Premium Pet Shop',
        'email': 'shop@petpaw.org',
        'password': 'password123',
        'role': 'shop',
        'hasCompletedOnboarding': true,
        'createdAt': DateTime.now().toIso8601String(),
      };
      _getCollection('shopProfiles')[mockShopUid] = {
        'uid': mockShopUid,
        'shopName': 'Premium Pet Shop',
        'address': '456 Oak Avenue, Metro City',
        'partnerVetIds': [mockVetUid],
      };
    }
  }

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  String? get currentUserEmail {
    if (_initialized) return auth.FirebaseAuth.instance.currentUser?.email;
    return _localDb['currentUserEmail'] as String?;
  }

  String? get currentUid {
    if (_initialized) return auth.FirebaseAuth.instance.currentUser?.uid;
    return _localDb['currentUid'] as String?;
  }

  bool get isAuthenticated => currentUid != null;

  Future<UserProfile> login(String email, String password) async {
    if (_initialized) {
      try {
        final credential = await auth.FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        return await getUserProfile(credential.user!.uid);
      } on auth.FirebaseAuthException catch (e) {
        throw Exception(_mapAuthError(e.code));
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final users = _getCollection('users');
    String? foundUid;
    bool emailFound = false;

    users.forEach((uid, val) {
      final u = _castMap(val);
      if ((u['email'] as String).toLowerCase() == email.toLowerCase()) {
        emailFound = true;
        if (u['password'] == password) foundUid = uid;
      }
    });

    if (foundUid != null) {
      _localDb['currentUserEmail'] = email;
      _localDb['currentUid'] = foundUid;
      await _saveLocalDb();
      return UserProfile.fromMap(_castMap(_getCollection('users')[foundUid]));
    } else if (emailFound) {
      throw Exception('Incorrect email or password. Please try again.');
    } else {
      throw Exception('User not found. Please sign up first.');
    }
  }

  Future<UserProfile> register(
      String name, String email, String password, String role) async {
    if (_initialized) {
      try {
        final credential = await auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        final uid = credential.user!.uid;
        final profile = UserProfile(
          uid: uid,
          name: name,
          email: email,
          role: role,
          hasCompletedOnboarding: false,
          createdAt: DateTime.now(),
        );
        await saveUserProfile(profile);
        return profile;
      } on auth.FirebaseAuthException catch (e) {
        throw Exception(_mapAuthError(e.code));
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final users = _getCollection('users');
    users.forEach((uid, val) {
      final u = _castMap(val);
      if ((u['email'] as String).toLowerCase() == email.toLowerCase()) {
        throw Exception('An account with this email already exists.');
      }
    });

    final uid = 'uid_${DateTime.now().millisecondsSinceEpoch}';
    final profile = UserProfile(
      uid: uid,
      name: name,
      email: email,
      role: role,
      hasCompletedOnboarding: false,
      createdAt: DateTime.now(),
    );

    _getCollection('users')[uid] = {...profile.toMap(), 'password': password};
    _localDb['currentUserEmail'] = email;
    _localDb['currentUid'] = uid;

    if (role == 'vet') {
      _getCollection('vetProfiles')[uid] = {
        'uid': uid,
        'clinicName': '$name Clinic',
        'address': 'Update Address in Profile',
        'specialization': 'General Veterinary',
        'workingHours': {'Mon-Fri': '09:00-17:00'},
        'isVerified': false,
        'partnerShopIds': [],
      };
    } else if (role == 'shop') {
      _getCollection('shopProfiles')[uid] = {
        'uid': uid,
        'shopName': '$name Shop',
        'address': 'Update Address in Settings',
        'partnerVetIds': [],
      };
    }

    await _saveLocalDb();
    return profile;
  }

  Future<void> logout() async {
    if (_initialized) {
      await auth.FirebaseAuth.instance.signOut();
    } else {
      _localDb['currentUserEmail'] = null;
      _localDb['currentUid'] = null;
      await _saveLocalDb();
    }
  }

  Future<void> resetPassword(String email) async {
    if (_initialized) {
      try {
        await auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      } on auth.FirebaseAuthException catch (e) {
        throw Exception(_mapAuthError(e.code));
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      debugPrint('[FirebaseService] Mock password reset email sent to $email');
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password. Please try again.';
      case 'weak-password':
        return 'Password is too weak. Must be at least 8 characters.';
      case 'email-already-in-use':
        return 'This email address is already in use by another account.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'Authentication failed: $code';
    }
  }

  // ---------------------------------------------------------------------------
  // User Profiles
  // ---------------------------------------------------------------------------

  Future<UserProfile> getUserProfile(String uid) async {
    if (_initialized) {
      final doc = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) return UserProfile.fromMap(doc.data()!);
      throw Exception('User profile not found.');
    }
    final data = _getCollection('users')[uid];
    if (data != null) return UserProfile.fromMap(_castMap(data));
    throw Exception('User profile not found.');
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(profile.uid)
          .set(profile.toMap());
    } else {
      _getCollection('users')[profile.uid] = profile.toMap();
      await _saveLocalDb();
    }
  }

  // ---------------------------------------------------------------------------
  // Pets
  // ---------------------------------------------------------------------------

  Future<List<Pet>> fetchPets(String ownerUid) async {
    if (_initialized) {
      final snap = await firestore.FirebaseFirestore.instance
          .collection('pets')
          .where('ownerUid', isEqualTo: ownerUid)
          .get();
      return snap.docs.map((d) => Pet.fromMap(d.data())).toList();
    }
    final list = <Pet>[];
    _getCollection('pets').forEach((id, val) {
      final p = Pet.fromMap(_castMap(val));
      if (p.ownerUid == ownerUid) list.add(p);
    });
    return list;
  }

  Future<List<Pet>> fetchShopPets(String shopId) async {
    if (_initialized) {
      final snap = await firestore.FirebaseFirestore.instance
          .collection('pets')
          .where('shopId', isEqualTo: shopId)
          .get();
      return snap.docs.map((d) => Pet.fromMap(d.data())).toList();
    }
    final list = <Pet>[];
    _getCollection('pets').forEach((id, val) {
      final p = Pet.fromMap(_castMap(val));
      if (p.shopId == shopId) list.add(p);
    });
    return list;
  }

  Future<void> savePet(Pet pet) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('pets')
          .doc(pet.id)
          .set(pet.toMap());
    } else {
      _getCollection('pets')[pet.id] = pet.toMap();
      await _saveLocalDb();
    }
  }

  Future<void> deletePet(String petId) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('pets')
          .doc(petId)
          .delete();
    } else {
      _getCollection('pets').remove(petId);
      _getCollection('reminders').removeWhere((k, v) => _castMap(v)['petId'] == petId);
      _getCollection('behaviourLogs').removeWhere((k, v) => _castMap(v)['petId'] == petId);
      _getCollection('healthRecords').removeWhere((k, v) => _castMap(v)['petId'] == petId);
      _getCollection('careNotes').removeWhere((k, v) => _castMap(v)['petId'] == petId);
      await _saveLocalDb();
    }
  }

  Future<Pet?> findPetByLinkCode(String linkCode) async {
    if (_initialized) {
      final snap = await firestore.FirebaseFirestore.instance
          .collection('pets')
          .where('linkCode', isEqualTo: linkCode)
          .get();
      if (snap.docs.isNotEmpty) return Pet.fromMap(snap.docs.first.data());
      return null;
    }
    Pet? found;
    _getCollection('pets').forEach((k, v) {
      final m = _castMap(v);
      if (m['linkCode'] == linkCode) found = Pet.fromMap(m);
    });
    return found;
  }

  // ---------------------------------------------------------------------------
  // Vet Profiles
  // ---------------------------------------------------------------------------

  Future<List<VetProfile>> fetchVetProfiles() async {
    if (_initialized) {
      final snap = await firestore.FirebaseFirestore.instance
          .collection('vetProfiles')
          .get();
      return snap.docs.map((d) => VetProfile.fromMap(d.data())).toList();
    }
    final list = <VetProfile>[];
    _getCollection('vetProfiles').forEach((uid, val) {
      list.add(VetProfile.fromMap(_castMap(val)));
    });
    return list;
  }

  Future<VetProfile> getVetProfile(String uid) async {
    if (_initialized) {
      final doc = await firestore.FirebaseFirestore.instance
          .collection('vetProfiles')
          .doc(uid)
          .get();
      if (doc.exists) return VetProfile.fromMap(doc.data()!);
      throw Exception('Vet profile not found.');
    }
    final data = _getCollection('vetProfiles')[uid];
    if (data != null) return VetProfile.fromMap(_castMap(data));
    throw Exception('Vet profile not found.');
  }

  Future<void> saveVetProfile(VetProfile profile) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('vetProfiles')
          .doc(profile.uid)
          .set(profile.toMap());
    } else {
      _getCollection('vetProfiles')[profile.uid] = profile.toMap();
      await _saveLocalDb();
    }
  }

  // ---------------------------------------------------------------------------
  // Shop Profiles
  // ---------------------------------------------------------------------------

  Future<ShopProfile> getShopProfile(String uid) async {
    if (_initialized) {
      final doc = await firestore.FirebaseFirestore.instance
          .collection('shopProfiles')
          .doc(uid)
          .get();
      if (doc.exists) return ShopProfile.fromMap(doc.data()!);
      throw Exception('Shop profile not found.');
    }
    final data = _getCollection('shopProfiles')[uid];
    if (data != null) return ShopProfile.fromMap(_castMap(data));
    throw Exception('Shop profile not found.');
  }

  Future<void> saveShopProfile(ShopProfile profile) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('shopProfiles')
          .doc(profile.uid)
          .set(profile.toMap());
    } else {
      _getCollection('shopProfiles')[profile.uid] = profile.toMap();
      await _saveLocalDb();
    }
  }

  // ---------------------------------------------------------------------------
  // Reminders
  // ---------------------------------------------------------------------------

  Future<List<PetReminder>> fetchReminders(String petId) async {
    if (_initialized) {
      final snap = await firestore.FirebaseFirestore.instance
          .collection('reminders')
          .where('petId', isEqualTo: petId)
          .get();
      return snap.docs.map((d) => PetReminder.fromMap(d.data())).toList();
    }
    final list = <PetReminder>[];
    _getCollection('reminders').forEach((id, val) {
      final r = PetReminder.fromMap(_castMap(val));
      if (r.petId == petId) list.add(r);
    });
    return list;
  }

  Future<void> saveReminder(PetReminder reminder) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('reminders')
          .doc(reminder.id)
          .set(reminder.toMap());
    } else {
      _getCollection('reminders')[reminder.id] = reminder.toMap();
      await _saveLocalDb();
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('reminders')
          .doc(reminderId)
          .delete();
    } else {
      _getCollection('reminders').remove(reminderId);
      await _saveLocalDb();
    }
  }

  // ---------------------------------------------------------------------------
  // Behaviour Logs
  // ---------------------------------------------------------------------------

  Future<List<BehaviourLog>> fetchBehaviourLogs(String petId) async {
    if (_initialized) {
      final snap = await firestore.FirebaseFirestore.instance
          .collection('behaviourLogs')
          .where('petId', isEqualTo: petId)
          .get();
      final logs = snap.docs.map((d) => BehaviourLog.fromMap(d.data())).toList();
      logs.sort((a, b) => b.date.compareTo(a.date));
      return logs;
    }
    final list = <BehaviourLog>[];
    _getCollection('behaviourLogs').forEach((id, val) {
      final l = BehaviourLog.fromMap(_castMap(val));
      if (l.petId == petId) list.add(l);
    });
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> saveBehaviourLog(BehaviourLog log) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('behaviourLogs')
          .doc(log.id)
          .set(log.toMap());
    } else {
      _getCollection('behaviourLogs')[log.id] = log.toMap();
      await _saveLocalDb();
    }
  }

  Future<void> deleteBehaviourLog(String logId) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('behaviourLogs')
          .doc(logId)
          .delete();
    } else {
      _getCollection('behaviourLogs').remove(logId);
      await _saveLocalDb();
    }
  }

  // ---------------------------------------------------------------------------
  // Health Records
  // ---------------------------------------------------------------------------

  Future<List<HealthRecord>> fetchHealthRecords(String petId) async {
    if (_initialized) {
      final snap = await firestore.FirebaseFirestore.instance
          .collection('healthRecords')
          .where('petId', isEqualTo: petId)
          .get();
      final records = snap.docs.map((d) => HealthRecord.fromMap(d.data())).toList();
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    }
    final list = <HealthRecord>[];
    _getCollection('healthRecords').forEach((id, val) {
      final r = HealthRecord.fromMap(_castMap(val));
      if (r.petId == petId) list.add(r);
    });
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> saveHealthRecord(HealthRecord record) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('healthRecords')
          .doc(record.id)
          .set(record.toMap());
    } else {
      _getCollection('healthRecords')[record.id] = record.toMap();
      await _saveLocalDb();
    }
  }

  Future<void> deleteHealthRecord(String recordId) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('healthRecords')
          .doc(recordId)
          .delete();
    } else {
      _getCollection('healthRecords').remove(recordId);
      await _saveLocalDb();
    }
  }

  // ---------------------------------------------------------------------------
  // Appointments
  // ---------------------------------------------------------------------------

  Future<List<Appointment>> fetchAppointments(String ownerUid) async {
    if (_initialized) {
      final snap = await firestore.FirebaseFirestore.instance
          .collection('appointments')
          .where('ownerUid', isEqualTo: ownerUid)
          .get();
      return snap.docs.map((d) => Appointment.fromMap(d.data())).toList();
    }
    final list = <Appointment>[];
    _getCollection('appointments').forEach((id, val) {
      final a = Appointment.fromMap(_castMap(val));
      if (a.ownerUid == ownerUid) list.add(a);
    });
    return list;
  }

  Future<List<Appointment>> fetchVetAppointments(String vetUid) async {
    if (_initialized) {
      final snap = await firestore.FirebaseFirestore.instance
          .collection('appointments')
          .where('vetUid', isEqualTo: vetUid)
          .get();
      return snap.docs.map((d) => Appointment.fromMap(d.data())).toList();
    }
    final list = <Appointment>[];
    _getCollection('appointments').forEach((id, val) {
      final a = Appointment.fromMap(_castMap(val));
      if (a.vetUid == vetUid) list.add(a);
    });
    return list;
  }

  Future<void> saveAppointment(Appointment appointment) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toMap());
    } else {
      _getCollection('appointments')[appointment.id] = appointment.toMap();
      await _saveLocalDb();
    }
  }

  Future<Appointment?> getAppointment(String appointmentId) async {
    if (_initialized) {
      final doc = await firestore.FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .get();
      if (doc.exists) return Appointment.fromMap(doc.data()!);
      return null;
    }
    final data = _getCollection('appointments')[appointmentId];
    if (data != null) return Appointment.fromMap(_castMap(data));
    return null;
  }

  // ---------------------------------------------------------------------------
  // Time Slots
  // ---------------------------------------------------------------------------

  Future<List<TimeSlot>> fetchTimeSlots(String vetUid) async {
    if (_initialized) {
      final snap = await firestore.FirebaseFirestore.instance
          .collection('timeSlots')
          .where('vetUid', isEqualTo: vetUid)
          .get();
      return snap.docs.map((d) => TimeSlot.fromMap(d.data())).toList();
    }
    final list = <TimeSlot>[];
    _getCollection('timeSlots').forEach((id, val) {
      final s = TimeSlot.fromMap(_castMap(val));
      if (s.vetUid == vetUid) list.add(s);
    });
    return list;
  }

  Future<void> saveTimeSlot(TimeSlot slot) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('timeSlots')
          .doc(slot.id)
          .set(slot.toMap());
    } else {
      _getCollection('timeSlots')[slot.id] = slot.toMap();
      await _saveLocalDb();
    }
  }

  Future<void> deleteTimeSlot(String slotId) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('timeSlots')
          .doc(slotId)
          .delete();
    } else {
      _getCollection('timeSlots').remove(slotId);
      await _saveLocalDb();
    }
  }

  Future<void> updateTimeSlotBooking(String slotId, bool isBooked) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('timeSlots')
          .doc(slotId)
          .update({'isBooked': isBooked});
    } else {
      final raw = _getCollection('timeSlots')[slotId];
      if (raw != null) {
        final m = _castMap(raw);
        m['isBooked'] = isBooked;
        _getCollection('timeSlots')[slotId] = m;
        await _saveLocalDb();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Care Notes
  // ---------------------------------------------------------------------------

  Future<List<CareNote>> fetchCareNotes(String petId) async {
    if (_initialized) {
      final snap = await firestore.FirebaseFirestore.instance
          .collection('careNotes')
          .where('petId', isEqualTo: petId)
          .get();
      return snap.docs.map((d) => CareNote.fromMap(d.data())).toList();
    }
    final list = <CareNote>[];
    _getCollection('careNotes').forEach((id, val) {
      final n = CareNote.fromMap(_castMap(val));
      if (n.petId == petId) list.add(n);
    });
    return list;
  }

  Future<void> saveCareNote(CareNote note) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('careNotes')
          .doc(note.id)
          .set(note.toMap());
    } else {
      _getCollection('careNotes')[note.id] = note.toMap();
      await _saveLocalDb();
    }
  }

  // ---------------------------------------------------------------------------
  // Pet Link
  // ---------------------------------------------------------------------------

  Future<void> acceptPetLink(String petId, String ownerUid) async {
    if (_initialized) {
      await firestore.FirebaseFirestore.instance
          .collection('pets')
          .doc(petId)
          .update({'ownerUid': ownerUid, 'isLinked': true, 'linkCode': null});
    } else {
      final raw = _getCollection('pets')[petId];
      if (raw != null) {
        final m = _castMap(raw);
        m['ownerUid'] = ownerUid;
        m['isLinked'] = true;
        m['linkCode'] = null;
        _getCollection('pets')[petId] = m;
        await _saveLocalDb();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Partner Vet Invitation
  // ---------------------------------------------------------------------------

  Future<bool> invitePartnerVet(String shopUid, String vetEmail) async {
    String? foundVetUid;

    if (_initialized) {
      final snap = await firestore.FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: vetEmail)
          .where('role', isEqualTo: 'vet')
          .get();
      if (snap.docs.isNotEmpty) foundVetUid = snap.docs.first.id;
    } else {
      _getCollection('users').forEach((uid, val) {
        final u = _castMap(val);
        if ((u['email'] as String).toLowerCase() == vetEmail.toLowerCase() &&
            u['role'] == 'vet') {
          foundVetUid = uid;
        }
      });
    }

    if (foundVetUid == null) return false;
    final vetUid = foundVetUid!;

    if (_initialized) {
      final shopDoc = await firestore.FirebaseFirestore.instance
          .collection('shopProfiles')
          .doc(shopUid)
          .get();
      final shop = ShopProfile.fromMap(shopDoc.data()!);
      if (!shop.partnerVetIds.contains(vetUid)) {
        await firestore.FirebaseFirestore.instance
            .collection('shopProfiles')
            .doc(shopUid)
            .update({'partnerVetIds': [...shop.partnerVetIds, vetUid]});
      }

      final vetDoc = await firestore.FirebaseFirestore.instance
          .collection('vetProfiles')
          .doc(vetUid)
          .get();
      final vet = VetProfile.fromMap(vetDoc.data()!);
      if (!vet.partnerShopIds.contains(shopUid)) {
        await firestore.FirebaseFirestore.instance
            .collection('vetProfiles')
            .doc(vetUid)
            .update({'partnerShopIds': [...vet.partnerShopIds, shopUid]});
      }
    } else {
      final shopRaw = _getCollection('shopProfiles')[shopUid];
      if (shopRaw != null) {
        final shopMap = _castMap(shopRaw);
        final vetIds = List<String>.from(shopMap['partnerVetIds'] ?? []);
        if (!vetIds.contains(vetUid)) {
          vetIds.add(vetUid);
          shopMap['partnerVetIds'] = vetIds;
          _getCollection('shopProfiles')[shopUid] = shopMap;
        }
      }

      final vetRaw = _getCollection('vetProfiles')[vetUid];
      if (vetRaw != null) {
        final vetMap = _castMap(vetRaw);
        final shopIds = List<String>.from(vetMap['partnerShopIds'] ?? []);
        if (!shopIds.contains(shopUid)) {
          shopIds.add(shopUid);
          vetMap['partnerShopIds'] = shopIds;
          _getCollection('vetProfiles')[vetUid] = vetMap;
        }
      }
      await _saveLocalDb();
    }
    return true;
  }
}
