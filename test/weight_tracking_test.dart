import 'package:flutter_test/flutter_test.dart';
import 'package:petpaw/models/weight_record.dart';

void main() {
  group('Weight Tracking Logic Tests', () {
    test('Sorts weight records correctly by date (latest first)', () {
      final records = [
        WeightRecord(
          id: 'w1',
          petId: 'p1',
          weight: 5.0,
          date: DateTime(2023, 1, 1),
        ),
        WeightRecord(
          id: 'w2',
          petId: 'p1',
          weight: 6.0,
          date: DateTime(2023, 3, 1),
        ),
        WeightRecord(
          id: 'w3',
          petId: 'p1',
          weight: 5.5,
          date: DateTime(2023, 2, 1),
        ),
      ];

      records.sort((a, b) => b.date.compareTo(a.date));

      expect(records[0].id, 'w2'); // March (latest)
      expect(records[1].id, 'w3'); // February
      expect(records[2].id, 'w1'); // January
      
      expect(records[0].weight, 6.0); // This would be the sync weight
    });

    test('WeightRecord copyWith and toMap work correctly', () {
      final record = WeightRecord(
        id: 'wt_test',
        petId: 'pet_test',
        weight: 12.5,
        date: DateTime(2024, 5, 10),
        notes: 'Gaining nicely',
      );

      final map = record.toMap();
      expect(map['id'], 'wt_test');
      expect(map['petId'], 'pet_test');
      expect(map['weight'], 12.5);
      expect(map['notes'], 'Gaining nicely');

      final copied = record.copyWith(weight: 13.0, notes: 'A bit heavy');
      expect(copied.id, 'wt_test');
      expect(copied.weight, 13.0);
      expect(copied.notes, 'A bit heavy');

      final fromMap = WeightRecord.fromMap(map);
      expect(fromMap.id, 'wt_test');
      expect(fromMap.weight, 12.5);
      expect(fromMap.date.year, 2024);
    });
  });
}
