import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:petpaw/models/pet.dart';
import 'package:petpaw/models/reminder.dart';
import 'package:petpaw/repositories/pet_repository.dart';
import 'package:petpaw/repositories/reminder_repository.dart';
import 'package:petpaw/database/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  test('Database CRUD Verification Flow', () async {
    final petRepo = PetRepository();
    final reminderRepo = ReminderRepository();

    // 1. Create a Pet
    final pet = Pet(
      id: 'test_pet_1',
      name: 'Buddy',
      species: 'Dog',
      breed: 'Golden Retriever',
      age: 2,
      weight: 30,
      photoPath: '',
      ownerUid: 'owner_123',
      checklist: [
        ChecklistItem(id: 'chk_1', title: 'Buy food', category: 'Day 1', isDone: false),
      ],
    );

    await petRepo.savePet(pet);

    // 2. Read Pet
    final savedPet = await petRepo.getPet('test_pet_1');
    expect(savedPet, isNotNull);
    expect(savedPet!.name, 'Buddy');
    expect(savedPet.checklist.length, 1);
    expect(savedPet.checklist.first.title, 'Buy food');

    // 3. Create a Reminder for the Pet
    final reminder = PetReminder(
      id: 'rem_1',
      petId: 'test_pet_1',
      title: 'Vaccine',
      type: 'Medical',
      dateTime: DateTime.now(),
      repeatOption: 'None',
      isDone: false,
    );

    await reminderRepo.saveReminder(reminder);

    // Verify Reminder exists
    final reminders = await reminderRepo.getRemindersForPet('test_pet_1');
    expect(reminders.length, 1);
    expect(reminders.first.title, 'Vaccine');

    // 4. Update Pet
    final updatedPet = savedPet.copyWith(weight: 35, checklist: [
      ChecklistItem(id: 'chk_1', title: 'Buy food', category: 'Day 1', isDone: true),
      ChecklistItem(id: 'chk_2', title: 'Vet visit', category: 'Week 1', isDone: false),
    ]);

    await petRepo.savePet(updatedPet);

    // Verify Update
    final updatedReadPet = await petRepo.getPet('test_pet_1');
    expect(updatedReadPet!.weight, 35);
    expect(updatedReadPet.checklist.length, 2);
    expect(updatedReadPet.checklist.first.isDone, true);

    // 5. Delete Pet
    await petRepo.deletePet('test_pet_1');

    // Verify Deletion (Pet)
    final deletedPet = await petRepo.getPet('test_pet_1');
    expect(deletedPet, isNull);

    // Verify Cascading Deletion (Reminder)
    final deletedReminders = await reminderRepo.getRemindersForPet('test_pet_1');
    expect(deletedReminders.isEmpty, true, reason: 'Reminders should cascade delete when pet is deleted');
  });
}
