import '../models/pet.dart';
import '../models/reminder.dart';
import '../models/pet_care_guide.dart';
import '../models/pet_vaccine.dart';
import '../models/pet_growth_stage.dart';

class CarePlanService {
  static List<ChecklistItem> generateChecklist({
    required String petId,
    required String species,
    required String breed,
    required double age,
    required List<PetCareGuide> careGuides,
    required List<PetGrowthStage> growthStages,
  }) {
    final List<ChecklistItem> checklist = [];
    final normalizedSpecies = species.toLowerCase();

    // 1. Determine Life Stage
    String currentStage = 'adult'; // default
    for (final gs in growthStages) {
      if (gs.species == normalizedSpecies) {
        // Simplified age check - ideally we'd parse the ageRange string, but for now we do a basic mapping
        if (age < 1.0 && gs.stage == 'puppy') currentStage = 'puppy';
        if (age < 1.0 && gs.stage == 'kitten') currentStage = 'kitten';
        if (age >= 1.0 && age < 7.0 && gs.stage == 'adult') currentStage = 'adult';
        if (age >= 7.0 && gs.stage == 'senior') currentStage = 'senior';
      }
    }

    // 2. Find relevant Care Guide
    final relevantGuides = careGuides.where((guide) => 
      guide.species == normalizedSpecies && 
      (guide.lifeStage == currentStage || guide.category == 'new_pet')
    ).toList();

    int idCounter = 1;

    // 3. Generate Checklist Items from Care Guide
    if (relevantGuides.isNotEmpty) {
      for (final guide in relevantGuides) {
        for (final item in guide.checklistItems) {
          checklist.add(
            ChecklistItem(
              id: '${petId}_cg_${idCounter++}',
              title: item.title,
              category: guide.recommendedTiming.isNotEmpty ? guide.recommendedTiming : 'General Care',
              isDone: false,
            ),
          );
        }
      }
    } else {
      // Fallback checklist if no data available
      checklist.addAll([
        ChecklistItem(
          id: '${petId}_fallback_1',
          title: 'Prepare room and bedding',
          category: 'Day 1',
          isDone: false,
        ),
        ChecklistItem(
          id: '${petId}_fallback_2',
          title: 'Buy appropriate food and bowls',
          category: 'Day 1',
          isDone: false,
        ),
        ChecklistItem(
          id: '${petId}_fallback_3',
          title: 'Schedule first vet checkup',
          category: 'Week 1',
          isDone: false,
        ),
      ]);
    }

    return checklist;
  }

  static List<PetReminder> generateReminders({
    required String petId,
    required String species,
    required List<PetVaccine> vaccines,
  }) {
    final List<PetReminder> generatedReminders = [];
    final normalizedSpecies = species.toLowerCase();

    final speciesVaccines = vaccines.where((v) => v.species == normalizedSpecies).toList();
    
    int idCounter = 1;
    for (final vax in speciesVaccines) {
      // Create a candidate reminder spaced out (mock logic for demonstration)
      generatedReminders.add(
        PetReminder(
          id: '${petId}_vaxGen_${idCounter++}',
          petId: petId,
          title: vax.vaccineName,
          type: 'Vaccine',
          dateTime: DateTime.now().add(Duration(days: idCounter * 30)),
          repeatOption: 'None',
          isDone: false,
        )
      );
    }
    
    return generatedReminders;
  }
}
