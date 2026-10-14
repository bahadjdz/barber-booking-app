import 'package:intl/intl.dart';

class ArabicDates {
  static const List<String> weekdays = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const List<String> months = [
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

  static String getWeekdayName(DateTime date) {
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    return weekdays[date.weekday - 1];
  }

  static String getMonthName(DateTime date) {
    return months[date.month - 1];
  }

  static String formatFullDate(DateTime date) {
    return '${getWeekdayName(date)}، ${date.day} ${getMonthName(date)} ${date.year}';
  }

  static String formatShortDate(DateTime date) {
    return '${getWeekdayName(date)}، ${date.day} ${getMonthName(date)}';
  }

  static String toIsoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime parseIsoDate(String dateStr) {
    return DateTime.tryParse(dateStr) ?? DateTime.now();
  }
}
