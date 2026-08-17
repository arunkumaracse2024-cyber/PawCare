import 'package:flutter_test/flutter_test.dart';
import 'package:petpaw/services/reminder_recurrence_service.dart';

void main() {
  group('ReminderRecurrenceService', () {
    test('calculateNextOccurrence - daily', () {
      final current = DateTime(2023, 10, 15, 10, 30);
      final next = ReminderRecurrenceService.calculateNextOccurrence(current, 'daily');
      
      expect(next.year, 2023);
      expect(next.month, 10);
      expect(next.day, 16);
      expect(next.hour, 10);
      expect(next.minute, 30);
    });

    test('calculateNextOccurrence - weekly', () {
      final current = DateTime(2023, 10, 15, 10, 30);
      final next = ReminderRecurrenceService.calculateNextOccurrence(current, 'weekly');
      
      expect(next.year, 2023);
      expect(next.month, 10);
      expect(next.day, 22);
      expect(next.hour, 10);
      expect(next.minute, 30);
    });

    test('calculateNextOccurrence - monthly simple', () {
      final current = DateTime(2023, 10, 15, 10, 30);
      final next = ReminderRecurrenceService.calculateNextOccurrence(current, 'monthly');
      
      expect(next.year, 2023);
      expect(next.month, 11);
      expect(next.day, 15);
    });

    test('calculateNextOccurrence - monthly year wrap', () {
      final current = DateTime(2023, 12, 15, 10, 30);
      final next = ReminderRecurrenceService.calculateNextOccurrence(current, 'monthly');
      
      expect(next.year, 2024);
      expect(next.month, 1);
      expect(next.day, 15);
    });

    test('calculateNextOccurrence - monthly month end (31 to 30)', () {
      final current = DateTime(2023, 1, 31, 10, 30);
      final next = ReminderRecurrenceService.calculateNextOccurrence(current, 'monthly');
      
      expect(next.year, 2023);
      expect(next.month, 2);
      expect(next.day, 28); // 2023 is not a leap year
    });

    test('calculateNextOccurrence - monthly month end leap year (31 to 29)', () {
      final current = DateTime(2024, 1, 31, 10, 30); // 2024 is a leap year
      final next = ReminderRecurrenceService.calculateNextOccurrence(current, 'monthly');
      
      expect(next.year, 2024);
      expect(next.month, 2);
      expect(next.day, 29);
    });

    test('calculateNextOccurrence - none or unknown', () {
      final current = DateTime(2023, 10, 15, 10, 30);
      final next = ReminderRecurrenceService.calculateNextOccurrence(current, 'none');
      final next2 = ReminderRecurrenceService.calculateNextOccurrence(current, 'yearly');
      
      expect(next, current);
      expect(next2, current);
    });
  });
}
