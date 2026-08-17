
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/file_storage_service.dart';

import '../services/reminder_recurrence_service.dart';

import '../models/behaviour_log.dart';
import '../models/health_record.dart';
import '../models/weight_record.dart';

import '../models/user_profile.dart';
import '../models/appointment.dart';
import '../models/vet_profile.dart';
import '../models/shop_profile.dart';
import '../models/care_note.dart';
import '../models/time_slot.dart';
import '../services/local_data_service.dart';
import '../services/todo_merge_engine.dart';
import '../database/database_helper.dart';
import 'encyclopedia_provider.dart';

class AppState extends ChangeNotifier {
  EncyclopediaProvider? encyclopedia;

  void updateEncyclopedia(EncyclopediaProvider ency) {
    encyclopedia = ency;
    notifyListeners();
  }
  final LocalDataService _db = LocalDataService();

  List<Pet> _pets = [];
  Pet? _selectedPet;
  List<PetReminder> _allPetsReminders = [];

  List<PetReminder> _reminders = [];
  List<BehaviourLog> _behaviourLogs = [];
  List<HealthRecord> _healthRecords = [];
  final List<WeightRecord> _weightHistory = [];

  // Connect Role Specifics
  UserProfile? _currentUser;
  VetProfile? _currentVetProfile;
  ShopProfile? _currentShopProfile;
  List<Appointment> _appointments = [];
  List<TimeSlot> _timeSlots = [];
  List<VetProfile> _allVets = [];
  List<CareNote> _careNotes = [];
  List<MergedTodoItem> _mergedTodoFeed = [];
  List<Pet> _shopPets = [];

  bool _isLoading = false;
  bool _isInitializing = true;
  bool _isDarkMode = false;

  // Getters

  List<Pet> get pets => _pets;
  List<PetReminder> get allPetsReminders => _allPetsReminders;

  Pet? get selectedPet => _selectedPet;
  List<PetReminder> get reminders => _reminders;
  List<BehaviourLog> get behaviourLogs => _behaviourLogs;
  List<HealthRecord> get healthRecords => _healthRecords;
  List<WeightRecord> get weightHistory => _weightHistory;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isDarkMode => _isDarkMode;

  UserProfile? get currentUser => _currentUser;
  VetProfile? get currentVetProfile => _currentVetProfile;
  ShopProfile? get currentShopProfile => _currentShopProfile;
  List<Appointment> get appointments => _appointments;
  List<TimeSlot> get timeSlots => _timeSlots;
  List<VetProfile> get allVets => _allVets;
  List<CareNote> get careNotes => _careNotes;
  List<MergedTodoItem> get mergedTodoFeed => _mergedTodoFeed;
  List<Pet> get shopPets => _shopPets;

  String? get currentUserEmail => _currentUser?.email;
  bool get isAuthenticated => _currentUser != null;

  AppState() {
    _initApp();
  }

  Future<void> _initApp() async {
    _setLoading(true);
    await _db.init();
    // Ensure the SQLite database is fully initialized before loading data
    await DatabaseHelper.instance.database;
        if (_db.isAuthenticated) {
      try {
        final uid = _db.currentUid!;
        _currentUser = await _db.getUserProfile(uid);
        await refreshState();
      } catch (e) {
        debugPrint('[AppState] Error restoring auth session: $e');
        await logout();
      }
    }
    _isInitializing = false;
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

  // --- AUTH METHODS ---
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _db.login(email, password);
      await refreshState();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password, String role) async {
    _setLoading(true);
    try {
      _currentUser = await _db.register(name, email, password, role);
      await refreshState();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _db.logout();
      _currentUser = null;
      _currentVetProfile = null;
      _currentShopProfile = null;
      _pets.clear();
      _selectedPet = null;
      _reminders.clear();
      _behaviourLogs.clear();
      _healthRecords.clear();
      _appointments.clear();
      _timeSlots.clear();
      _allVets.clear();
      _careNotes.clear();
      _mergedTodoFeed.clear();
      _shopPets.clear();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    await _db.resetPassword(email);
  }

  Future<void> completeOnboarding() async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(hasCompletedOnboarding: true);
    await _db.saveUserProfile(_currentUser!);
    notifyListeners();
  }

  // --- STATE REFRESH / SYNC ---
  Future<void> refreshState() async {
    if (_currentUser == null) return;

    if (_currentUser!.role == 'owner') {
      _pets = await _db.fetchPets(_currentUser!.uid);
      _allVets = await _db.fetchVetProfiles();
      _appointments = await _db.fetchAppointments(_currentUser!.uid);

      if (_pets.isNotEmpty) {
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
        _careNotes.clear();
        _mergedTodoFeed.clear();
      }
    } else if (_currentUser!.role == 'shop') {
      try {
        _currentShopProfile = await _db.getShopProfile(_currentUser!.uid);
      } catch (e) {
        _currentShopProfile = ShopProfile(
          uid: _currentUser!.uid,
          shopName: '${_currentUser!.name} Shop',
          address: 'Update Address in Settings',
          partnerVetIds: [],
        );
        await _db.saveShopProfile(_currentShopProfile!);
      }
      _shopPets = await _db.fetchShopPets(_currentUser!.uid);
      _allVets = await _db.fetchVetProfiles();
    } else if (_currentUser!.role == 'vet') {
      try {
        _currentVetProfile = await _db.getVetProfile(_currentUser!.uid);
      } catch (e) {
        _currentVetProfile = VetProfile(
          uid: _currentUser!.uid,
          clinicName: '${_currentUser!.name} Clinic',
          address: 'Update Address in Profile',
          specialization: 'General Veterinary',
          workingHours: {'Mon-Fri': '09:00 - 17:00'},
          isVerified: false,
          partnerShopIds: [],
        );
        await _db.saveVetProfile(_currentVetProfile!);
      }
      _appointments = await _db.fetchVetAppointments(_currentUser!.uid);
      _timeSlots = await _db.fetchTimeSlots(_currentUser!.uid);
    }
    notifyListeners();
  }

  Future<void> refreshSubmodels() async {
    if (_selectedPet != null) {
      if (_pets.isNotEmpty) {
        _allPetsReminders = await _db.getRemindersForPets(_pets.map((p) => p.id).toList());
      } else {
        _allPetsReminders = [];
      }
      _reminders = _allPetsReminders.where((r) => r.petId == _selectedPet!.id).toList();
      _behaviourLogs = await _db.fetchBehaviourLogs(_selectedPet!.id);
      _healthRecords = await _db.fetchHealthRecords(_selectedPet!.id);
      _careNotes = await _db.fetchCareNotes(_selectedPet!.id);

      final List<CareNote> standardCareNotes = [];
      final speciesMatch = encyclopedia!.speciesList.firstWhere(
        (s) => s.id == _selectedPet!.species.toLowerCase(),
        orElse: () => encyclopedia!.speciesList.first,
      );

      final timelineMilestones = [
        {'category': 'feeding', 'title': 'Establish feeding schedule', 'desc': 'Set a strict feeding schedule for regular digestion.'},
        {'category': 'grooming', 'title': 'Brush coat', 'desc': 'Regular grooming prevents mats and maintains healthy skin.'},
        {'category': 'checkup', 'title': 'First vet clinic visit', 'desc': 'Schedule first full veterinary exam.'},
        {'category': 'medicine', 'title': 'Deworming treatment', 'desc': 'Administer recommended deworming treatment.'},
      ];

      for (int i = 0; i < timelineMilestones.length; i++) {
        final m = timelineMilestones[i];
        standardCareNotes.add(CareNote(
          id: '${_selectedPet!.id}_std_${m['category']}',
          petId: _selectedPet!.id,
          source: 'breedStandard',
          category: m['category']!,
          title: m['title']!,
          description: m['desc']!,
          date: DateTime.now().subtract(const Duration(days: 5)),
          sourceLabel: 'Standard care',
          isResolved: _selectedPet!.checklist.any((item) => item.category.toLowerCase().contains(m['category']!) && item.isDone),
        ));
      }

      final speciesVaccines = encyclopedia!.vaccines.where((v) => v.species == speciesMatch.id).toList();
      for (int i = 0; i < speciesVaccines.length; i++) {
        final v = speciesVaccines[i];
        standardCareNotes.add(CareNote(
          id: '${_selectedPet!.id}_std_vax_$i',
          petId: _selectedPet!.id,
          source: 'breedStandard',
          category: 'vaccination',
          title: v.name,
          description: 'Suggested age: ${v.suggestedAge}',
          date: DateTime.now().subtract(const Duration(days: 5)),
          sourceLabel: 'Standard care',
          isResolved: _reminders.any((rem) => rem.type.toLowerCase() == 'vaccine' && rem.title == v.name && rem.isDone),
        ));
      }

      final shopCareNotes = _selectedPet!.shopNotes;
      final vetCareNotes = _careNotes.where((note) => note.source == 'vet').toList();

      _mergedTodoFeed = TodoMergeEngine.mergeTodos(
        breedStandardItems: standardCareNotes,
        shopNotes: shopCareNotes,
        vetInstructions: vetCareNotes,
      );
    }
  }

  void selectPet(Pet pet) async {
    _selectedPet = pet;
    _setLoading(true);
    await refreshSubmodels();
    _setLoading(false);
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
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

      final speciesMatch = encyclopedia!.speciesList.firstWhere(
        (s) => s.id == species.toLowerCase(),
        orElse: () => encyclopedia!.speciesList.first,
      );

      final checklist = <ChecklistItem>[];
      
      final relevantTasks = encyclopedia!.careTasks.where((t) => t.species == speciesMatch.id || t.species == 'all').toList();
      for (int i = 0; i < relevantTasks.length; i++) {
         checklist.add(ChecklistItem(
            id: 'sys_${petId}_chk_$i',
            title: relevantTasks[i].title,
            category: _capitalize(relevantTasks[i].category),
            isDone: false,
         ));
      }
      
      final relevantStages = encyclopedia!.growthStages.where((g) => g.species == speciesMatch.id).toList();
      for (int i = 0; i < relevantStages.length; i++) {
         final g = relevantStages[i];
         checklist.add(ChecklistItem(
            id: 'sys_${petId}_stage_$i',
            title: 'Read about ${g.stageName} stage',
            category: 'Milestones',
            isDone: false,
         ));
      }
      
      if (checklist.isEmpty) {
         checklist.add(ChecklistItem(id: 'sys_${petId}_gen1', title: 'Establish veterinary contact', category: 'General', isDone: false));
         checklist.add(ChecklistItem(id: 'sys_${petId}_gen2', title: 'Setup feeding area', category: 'General', isDone: false));
      }

      final newPet = Pet(
        id: petId,
        name: name,
        species: species,
        breed: breed,
        age: age,
        weight: weight,
        photoPath: photoPath,
        checklist: checklist,
        ownerUid: _currentUser!.uid,
        isLinked: false,
        shopNotes: [],
      );

      await _db.savePet(newPet);


      final speciesVaccines = encyclopedia!.vaccines.where((v) => v.species == speciesMatch.id).toList();
      for (int i = 0; i < speciesVaccines.length; i++) {
        final v = speciesVaccines[i];
        final reminder = PetReminder(
          id: '${petId}_vax_$i',
          petId: petId,
          title: v.name,
          type: 'Vaccine',
          dateTime: DateTime.now().add(Duration(days: (i + 1) * 30)),
          repeatOption: 'None',
          isDone: false,
        );
        await _db.saveReminder(reminder);
      }

      await refreshState();
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

  Future<void> addChecklistItem(ChecklistItem item) async {
    if (_selectedPet == null) return;
    final updatedChecklist = List<ChecklistItem>.from(_selectedPet!.checklist)..add(item);
    final updatedPet = _selectedPet!.copyWith(checklist: updatedChecklist);
    await updatePet(updatedPet);
  }

  Future<void> updateChecklistItem(ChecklistItem updatedItem) async {
    if (_selectedPet == null) return;
    final updatedChecklist = _selectedPet!.checklist.map((item) {
      if (item.id == updatedItem.id) return updatedItem;
      return item;
    }).toList();
    final updatedPet = _selectedPet!.copyWith(checklist: updatedChecklist);
    await updatePet(updatedPet);
  }

  Future<void> deleteChecklistItem(String itemId) async {
    if (_selectedPet == null) return;
    final updatedChecklist = _selectedPet!.checklist.where((item) => item.id != itemId).toList();
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
      await NotificationService().scheduleReminderNotification(reminder, _selectedPet!.name);
      await refreshSubmodels();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateReminder(PetReminder reminder) async {
    _setLoading(true);
    try {
      // 1. Cancel the old notification to be safe
      await NotificationService().cancelReminderNotification(reminder.id);
      
      // 2. Save the updated reminder in SQLite
      await _db.saveReminder(reminder);
      
      // 3. Reschedule if it's not done
      if (!reminder.isDone) {
         final pet = _pets.firstWhere((p) => p.id == reminder.petId, orElse: () => _selectedPet!);
         await NotificationService().scheduleReminderNotification(reminder, pet.name);
      }
      
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
      final original = _reminders[index];
      final updated = original.copyWith(isDone: isDone);
      await _db.saveReminder(updated);
      
      if (isDone) {
        // Cancel the current notification
        await NotificationService().cancelReminderNotification(id);
        
        // If it's recurring, create the next occurrence
        if (original.repeatOption.toLowerCase() != 'none') {
           final nextDate = ReminderRecurrenceService.calculateNextOccurrence(original.dateTime, original.repeatOption);
           
           // Check for duplicates to prevent spamming next occurrences
           final bool duplicateExists = _reminders.any((r) => r.title == original.title && r.type == original.type && r.dateTime == nextDate);
           if (!duplicateExists) {
               final nextReminder = PetReminder(
                  id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
                  petId: original.petId,
                  title: original.title,
                  type: original.type,
                  dateTime: nextDate,
                  repeatOption: original.repeatOption,
                  isDone: false,
               );
               await _db.saveReminder(nextReminder);
               await NotificationService().scheduleReminderNotification(nextReminder, _selectedPet!.name);
           }
        }
      } else {
        // Unchecked: Re-schedule the current reminder notification
        await NotificationService().scheduleReminderNotification(updated, _selectedPet!.name);
      }
      await refreshSubmodels();
    } catch (e) {
      debugPrint('[AppState] Error toggling reminder: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteReminder(String id) async {
    _setLoading(true);
    try {
      await _db.deleteReminder(id);
      await NotificationService().cancelReminderNotification(id);
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

  Future<void> updateHealthRecord(HealthRecord updatedRecord) async {
    _setLoading(true);
    try {
      await _db.saveHealthRecord(updatedRecord);
      await refreshSubmodels();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteHealthRecord(String recordId) async {
    _setLoading(true);
    try {
      final index = _healthRecords.indexWhere((r) => r.id == recordId);
      if (index != -1) {
        final record = _healthRecords[index];
        if (record.attachmentPath != null) {
          await FileStorageService.deleteAttachment(record.attachmentPath);
        }
      }
      
      await _db.deleteHealthRecord(recordId);
      await refreshSubmodels();
    } finally {
      _setLoading(false);
    }
  }

  // --- PET LINKING (SHOP TO OWNER) ---
  Future<bool> linkPet(String linkCode) async {
    if (_currentUser == null || _currentUser!.role != 'owner') return false;
    _setLoading(true);
    try {
      final targetPet = await _db.findPetByLinkCode(linkCode);
      if (targetPet != null) {
        await _db.acceptPetLink(targetPet.id, _currentUser!.uid);
        await refreshState();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[AppState] Error linking pet: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- VET CLINIC PROFILE ---
  Future<void> updateVetProfile({
    required String clinicName,
    required String address,
    required String specialization,
    required Map<String, dynamic> workingHours,
    required bool isVerified,
  }) async {
    if (_currentVetProfile == null) return;
    _setLoading(true);
    try {
      _currentVetProfile = _currentVetProfile!.copyWith(
        clinicName: clinicName,
        address: address,
        specialization: specialization,
        workingHours: workingHours,
        isVerified: isVerified,
      );
      await _db.saveVetProfile(_currentVetProfile!);
      await refreshState();
    } finally {
      _setLoading(false);
    }
  }

  // --- APPOINTMENTS & SLOTS ---
  Future<void> addTimeSlot(DateTime date, String startTime, String endTime) async {
    if (_currentUser == null || _currentUser!.role != 'vet') return;
    _setLoading(true);
    try {
      final id = 'slot_${DateTime.now().millisecondsSinceEpoch}';
      final slot = TimeSlot(
        id: id,
        vetUid: _currentUser!.uid,
        date: date,
        startTime: startTime,
        endTime: endTime,
        isBooked: false,
      );
      await _db.saveTimeSlot(slot);
      await refreshState();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTimeSlot(String slotId) async {
    _setLoading(true);
    try {
      await _db.deleteTimeSlot(slotId);
      await refreshState();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> bookAppointment({
    required String petId,
    required String vetUid,
    required String slotId,
    required DateTime dateTime,
    required String notes,
  }) async {
    if (_currentUser == null || _currentUser!.role != 'owner') return;
    _setLoading(true);
    try {
      final id = 'appt_${DateTime.now().millisecondsSinceEpoch}';
      final appt = Appointment(
        id: id,
        petId: petId,
        ownerUid: _currentUser!.uid,
        vetUid: vetUid,
        dateTime: dateTime,
        slotId: slotId,
        status: 'pending',
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _db.saveAppointment(appt);
      await _db.updateTimeSlotBooking(slotId, true);
      await refreshState();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status, {String? postVisitNotes, String? category, String? instructionTitle}) async {
    _setLoading(true);
    try {
      final appt = await _db.getAppointment(appointmentId);
      if (appt == null) return;

      final updatedAppt = appt.copyWith(status: status);
      await _db.saveAppointment(updatedAppt);

      if (status == 'completed' && postVisitNotes != null && postVisitNotes.isNotEmpty) {
        final finalCategory = category ?? 'checkup';
        final finalTitle = instructionTitle ?? 'Post-visit Instructions';

        final noteId = 'cn_${DateTime.now().millisecondsSinceEpoch}';
        final vetName = _currentUser?.name ?? "Dr. Veterinarian";
        final careNote = CareNote(
          id: noteId,
          petId: appt.petId,
          source: 'vet',
          category: finalCategory,
          title: finalTitle,
          description: postVisitNotes,
          date: DateTime.now(),
          sourceLabel: "From Dr. $vetName's visit",
          appointmentId: appointmentId,
          isResolved: false,
        );
        await _db.saveCareNote(careNote);

        final recordId = 'hrec_${DateTime.now().millisecondsSinceEpoch}';
        final record = HealthRecord(
          id: recordId,
          petId: appt.petId,
          title: 'Vet Visit Note: $finalTitle',
          type: 'Medical Report',
          date: DateTime.now(),
          details: 'Doctor Notes:\n$postVisitNotes\n\nPrescription category: $finalCategory',
        );
        await _db.saveHealthRecord(record);
      }

      if (status == 'rejected' || status == 'cancelled') {
        await _db.updateTimeSlotBooking(appt.slotId, false);
      }

      await refreshState();
    } finally {
      _setLoading(false);
    }
  }

  // --- SHOP MANAGEMENT ---
  Future<void> addCatalogPet({
    required String name,
    required String species,
    required String breed,
    required double age,
    required double weight,
    required String healthNotes,
  }) async {
    if (_currentUser == null || _currentUser!.role != 'shop') return;
    _setLoading(true);
    try {
      final petId = 'shop_pet_${DateTime.now().millisecondsSinceEpoch}';
      final newPet = Pet(
        id: petId,
        name: name,
        species: species,
        breed: breed,
        age: age,
        weight: weight,
        photoPath: '',
        checklist: [],
        ownerUid: '',
        shopId: _currentUser!.uid,
        isLinked: false,
        shopNotes: [
          CareNote(
            id: '${petId}_initial_health',
            petId: petId,
            source: 'shop',
            category: 'checkup',
            title: 'Initial Health Check',
            description: healthNotes.isNotEmpty ? healthNotes : 'Healthy at listing.',
            date: DateTime.now(),
            sourceLabel: 'From your shop',
            isResolved: true,
          )
        ],
      );
      await _db.savePet(newPet);
      await refreshState();
    } finally {
      _setLoading(false);
    }
  }

  Future<String> recordSaleAndGenerateCode({
    required String petId,
    required String saleVaccinationNote,
    required String saleFeedingNote,
  }) async {
    if (_currentUser == null || _currentUser!.role != 'shop') return '';
    _setLoading(true);
    try {
      final petIndex = _shopPets.indexWhere((p) => p.id == petId);
      if (petIndex == -1) return '';
      final pet = _shopPets[petIndex];

      final linkCode = 'CODE-${(1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toInt()}';
      final List<CareNote> saleNotes = [];

      if (saleVaccinationNote.isNotEmpty) {
        saleNotes.add(CareNote(
          id: '${petId}_sale_vax',
          petId: petId,
          source: 'shop',
          category: 'vaccination',
          title: 'First Vaccination Note',
          description: saleVaccinationNote,
          date: DateTime.now(),
          sourceLabel: 'From your shop',
          isResolved: true,
        ));
      }

      if (saleFeedingNote.isNotEmpty) {
        saleNotes.add(CareNote(
          id: '${petId}_sale_feed',
          petId: petId,
          source: 'shop',
          category: 'feeding',
          title: 'Transition Feeding Plan',
          description: saleFeedingNote,
          date: DateTime.now(),
          sourceLabel: 'From your shop',
          isResolved: false,
        ));
      }

      final updatedPet = pet.copyWith(
        linkCode: linkCode,
        shopNotes: saleNotes,
      );

      await _db.savePet(updatedPet);
      await refreshState();
      return linkCode;
    } catch (e) {
      debugPrint('[AppState] Error generating sale link: $e');
      return '';
    } finally {
      _setLoading(false);
    }
  }

  // --- SHOP & VET PARTNERSHIP INVITES ---
  Future<bool> invitePartnerVet(String vetEmail) async {
    if (_currentUser == null || _currentUser!.role != 'shop') return false;
    _setLoading(true);
    try {
      final success = await _db.invitePartnerVet(_currentUser!.uid, vetEmail);
      await refreshState();
      return success;
    } catch (e) {
      debugPrint('[AppState] Error partnering vet: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  // --- WEIGHT HISTORY MANAGEMENT ---
  
  Future<void> _syncPetWeight() async {
    if (_selectedPet == null) return;
    if (_weightHistory.isEmpty) return;
    
    // Sort descending by date (latest first)
    _weightHistory.sort((a, b) => b.date.compareTo(a.date));
    
    final latestWeight = _weightHistory.first.weight;
    if (_selectedPet!.weight != latestWeight) {
      final updatedPet = _selectedPet!.copyWith(weight: latestWeight);
      await updatePet(updatedPet); 
    }
  }

  Future<void> addWeightRecord(WeightRecord record) async {
    await _db.addWeightRecord(record);
    _weightHistory.add(record);
    await _syncPetWeight();
    notifyListeners();
  }

  Future<void> updateWeightRecord(WeightRecord record) async {
    await _db.updateWeightRecord(record);
    final index = _weightHistory.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _weightHistory[index] = record;
      await _syncPetWeight();
      notifyListeners();
    }
  }

  Future<void> deleteWeightRecord(String id) async {
    await _db.deleteWeightRecord(id);
    _weightHistory.removeWhere((r) => r.id == id);
    await _syncPetWeight();
    notifyListeners();
  }
}




