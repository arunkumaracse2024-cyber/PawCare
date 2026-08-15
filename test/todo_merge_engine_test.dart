import 'package:flutter_test/flutter_test.dart';
import 'package:petpaw/models/care_note.dart';
import 'package:petpaw/services/todo_merge_engine.dart';

void main() {
  group('TodoMergeEngine Tests', () {
    test('TC1: A shop note and breed-standard item in same category - shop note active, breed-standard marked satisfied', () {
      final breedStandard = [
        CareNote(
          id: 'std_vax_1',
          petId: 'pet_123',
          source: 'breedStandard',
          category: 'vaccination',
          title: 'Core vaccination (DHPP)',
          description: 'Ensure core puppy/kitten vaccines are complete',
          date: DateTime.now().subtract(const Duration(days: 30)),
          sourceLabel: 'Standard care',
          isResolved: false,
        ),
      ];

      final shopNotes = [
        CareNote(
          id: 'shop_vax_1',
          petId: 'pet_123',
          source: 'shop',
          category: 'vaccination',
          title: 'First DHPP vaccine administered by breeder',
          description: 'Breeder administered vaccine on day of sale',
          date: DateTime.now(),
          sourceLabel: 'From your shop',
          isResolved: true,
        ),
      ];

      final merged = TodoMergeEngine.mergeTodos(
        breedStandardItems: breedStandard,
        shopNotes: shopNotes,
        vetInstructions: [],
      );

      // Verify two items are returned: shop note and standard item
      expect(merged.length, equals(2));

      final shopMerged = merged.firstWhere((item) => item.source == 'shop');
      final stdMerged = merged.firstWhere((item) => item.source == 'breedStandard');

      // Shop note is active, not superseded
      expect(shopMerged.isSatisfied, isFalse);
      expect(shopMerged.isDone, isTrue);

      // Breed standard is superseded/satisfied
      expect(stdMerged.isSatisfied, isTrue);
      expect(stdMerged.isDone, isTrue);
      expect(stdMerged.supersededByTitle, equals(shopMerged.title));
    });

    test('TC2: Vet instruction supersedes shop note and breed-standard in same category', () {
      final breedStandard = [
        CareNote(
          id: 'std_vax_1',
          petId: 'pet_123',
          source: 'breedStandard',
          category: 'vaccination',
          title: 'Core vaccination (DHPP)',
          description: 'Standard vaccine schedule',
          date: DateTime.now().subtract(const Duration(days: 30)),
          sourceLabel: 'Standard care',
          isResolved: false,
        ),
      ];

      final shopNotes = [
        CareNote(
          id: 'shop_vax_1',
          petId: 'pet_123',
          source: 'shop',
          category: 'vaccination',
          title: 'First vaccination completed',
          description: 'Administered at shop',
          date: DateTime.now().subtract(const Duration(days: 10)),
          sourceLabel: 'From your shop',
          isResolved: true,
        ),
      ];

      final vetInstructions = [
        CareNote(
          id: 'vet_vax_1',
          petId: 'pet_123',
          source: 'vet',
          category: 'vaccination',
          title: 'Follow-up booster vaccine in 2 weeks',
          description: 'Administer next booster for full immunization',
          date: DateTime.now(),
          sourceLabel: "From Dr. Smith's visit",
          isResolved: false,
        ),
      ];

      final merged = TodoMergeEngine.mergeTodos(
        breedStandardItems: breedStandard,
        shopNotes: shopNotes,
        vetInstructions: vetInstructions,
      );

      expect(merged.length, equals(3));

      final vetMerged = merged.firstWhere((item) => item.source == 'vet');
      final shopMerged = merged.firstWhere((item) => item.source == 'shop');
      final stdMerged = merged.firstWhere((item) => item.source == 'breedStandard');

      // Vet is active
      expect(vetMerged.isSatisfied, isFalse);
      expect(vetMerged.isDone, isFalse);

      // Shop is satisfied
      expect(shopMerged.isSatisfied, isTrue);
      expect(shopMerged.isDone, isTrue);
      expect(shopMerged.supersededByTitle, equals(vetMerged.title));

      // Breed standard is satisfied
      expect(stdMerged.isSatisfied, isTrue);
      expect(stdMerged.isDone, isTrue);
      expect(stdMerged.supersededByTitle, equals(vetMerged.title));
    });

    test('TC3: Unrelated items from all three sources all appear active', () {
      final breedStandard = [
        CareNote(
          id: 'std_groom',
          petId: 'pet_123',
          source: 'breedStandard',
          category: 'grooming',
          title: 'Regular brushing',
          description: 'Brush coat weekly',
          date: DateTime.now(),
          sourceLabel: 'Standard care',
          isResolved: false,
        ),
      ];

      final shopNotes = [
        CareNote(
          id: 'shop_feed',
          petId: 'pet_123',
          source: 'shop',
          category: 'feeding',
          title: 'Feed high-protein kibble',
          description: 'Transition feed instructions',
          date: DateTime.now(),
          sourceLabel: 'From your shop',
          isResolved: false,
        ),
      ];

      final vetInstructions = [
        CareNote(
          id: 'vet_med',
          petId: 'pet_123',
          source: 'vet',
          category: 'medicine',
          title: 'Heartworm preventive tablet',
          description: 'Give monthly',
          date: DateTime.now(),
          sourceLabel: "From Dr. Smith's visit",
          isResolved: false,
        ),
      ];

      final merged = TodoMergeEngine.mergeTodos(
        breedStandardItems: breedStandard,
        shopNotes: shopNotes,
        vetInstructions: vetInstructions,
      );

      // 3 unrelated items: they should all be active (isSatisfied = false)
      expect(merged.length, equals(3));
      for (final item in merged) {
        expect(item.isSatisfied, isFalse);
      }
    });
  });
}
