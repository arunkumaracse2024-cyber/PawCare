class ReminderRecurrenceService {
  /// Calculates the next occurrence date based on the current date and repeat option.
  /// Handles month ends (e.g. Jan 31 -> Feb 28) and leap years.
  static DateTime calculateNextOccurrence(DateTime current, String repeatOption) {
    final lowerOption = repeatOption.toLowerCase();

    if (lowerOption == 'daily') {
      return current.add(const Duration(days: 1));
    } else if (lowerOption == 'weekly') {
      return current.add(const Duration(days: 7));
    } else if (lowerOption == 'monthly') {
      int nextMonth = current.month + 1;
      int nextYear = current.year;

      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }

      int nextDay = current.day;
      
      // Handle leap years and month ends to avoid invalid dates
      int maxDaysInNextMonth = _daysInMonth(nextYear, nextMonth);
      if (nextDay > maxDaysInNextMonth) {
        nextDay = maxDaysInNextMonth;
      }

      return DateTime(
        nextYear,
        nextMonth,
        nextDay,
        current.hour,
        current.minute,
        current.second,
      );
    }

    // 'none' or unknown returns current date
    return current;
  }

  /// Returns the number of days in a given month of a given year.
  static int _daysInMonth(int year, int month) {
    if (month == 2) {
      // Leap year logic
      bool isLeapYear = (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
      return isLeapYear ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }
}
