import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat(AppConstants.dateFormat);
  static final DateFormat _dateTimeFormat = DateFormat(
    AppConstants.dateTimeFormat,
  );
  static final DateFormat _displayDateFormat = DateFormat(
    AppConstants.displayDateFormat,
  );

  // Format dates for display
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return _displayDateFormat.format(date);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _dateTimeFormat.format(dateTime);
  }

  // Format dates for database storage
  static String formatForDatabase(DateTime date) {
    return date.toIso8601String();
  }

  // Parse dates from strings
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseDateFromDisplay(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _displayDateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Date calculations
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  // Payment due date calculations
  static DateTime calculateNextDueDate(
    DateTime lastPaymentDate,
    int intervalDays,
  ) {
    return addDays(lastPaymentDate, intervalDays);
  }

  static DateTime calculateDueDate(DateTime saleDate, int intervalDays) {
    return addDays(saleDate, intervalDays);
  }

  // Date comparisons
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today);
  }

  static bool isDueToday(DateTime dueDate) {
    return isToday(dueDate);
  }

  static bool isDueSoon(DateTime dueDate, {int daysThreshold = 3}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;
    return difference >= 0 && difference <= daysThreshold;
  }

  // Relative date strings in Arabic
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'اليوم';
    } else if (isTomorrow(date)) {
      return 'غداً';
    } else if (isYesterday(date)) {
      return 'أمس';
    } else {
      final now = DateTime.now();
      final difference = daysBetween(now, date);

      if (difference > 0) {
        if (difference == 1) {
          return 'خلال يوم واحد';
        } else if (difference <= 7) {
          return 'خلال $difference أيام';
        } else if (difference <= 30) {
          final weeks = (difference / 7).round();
          return weeks == 1 ? 'خلال أسبوع واحد' : 'خلال $weeks أسابيع';
        } else {
          final months = (difference / 30).round();
          return months == 1 ? 'خلال شهر واحد' : 'خلال $months أشهر';
        }
      } else {
        final absDifference = difference.abs();
        if (absDifference == 1) {
          return 'منذ يوم واحد';
        } else if (absDifference <= 7) {
          return 'منذ $absDifference أيام';
        } else if (absDifference <= 30) {
          final weeks = (absDifference / 7).round();
          return weeks == 1 ? 'منذ أسبوع واحد' : 'منذ $weeks أسابيع';
        } else {
          final months = (absDifference / 30).round();
          return months == 1 ? 'منذ شهر واحد' : 'منذ $months أشهر';
        }
      }
    }
  }

  // Month and year utilities
  static String getMonthName(int month) {
    const monthNames = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return month >= 1 && month <= 12 ? monthNames[month] : '';
  }

  static String formatMonthYear(DateTime date) {
    return '${getMonthName(date.month)} ${date.year}';
  }

  // Start and end of periods
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  // Week utilities
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  static DateTime endOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }

  // Age calculation
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Time of day utilities
  static String formatTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  // Validation
  static bool isValidDate(String dateString) {
    try {
      parseDateFromDisplay(dateString);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isDateInRange(
    DateTime date,
    DateTime startDate,
    DateTime endDate,
  ) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(endDate.add(const Duration(days: 1)));
  }
}
