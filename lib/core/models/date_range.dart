import 'package:intl/intl.dart';

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({
    required this.start,
    required this.end,
  });

  /// Today in Asia/Karachi timezone
  static DateRange today() {
    final now = _karachi();
    return DateRange(start: now, end: now);
  }

  /// Current week (Friday to Thursday)
  static DateRange currentWeek() {
    final now = _karachi();
    // Friday is weekday 5 (ISO)
    final daysSinceFriday = (now.weekday - 5) % 7;
    final friday = now.subtract(Duration(days: daysSinceFriday));
    final thursday = friday.add(const Duration(days: 6));
    return DateRange(start: friday, end: thursday);
  }

  /// Current month
  static DateRange currentMonth() {
    final now = _karachi();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    return DateRange(start: start, end: end);
  }

  /// Current year
  static DateRange currentYear() {
    final now = _karachi();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31);
    return DateRange(start: start, end: end);
  }

  /// Custom range
  static DateRange custom(DateTime start, DateTime end) {
    return DateRange(start: start, end: end);
  }

  /// Get current date in Asia/Karachi (UTC+5)
  static DateTime _karachi() {
    final utcNow = DateTime.now().toUtc();
    // Asia/Karachi is UTC+5
    return utcNow.add(const Duration(hours: 5));
  }

  /// Format start and end for display
  String get displayLabel {
    final df = DateFormat('d MMM yyyy');
    if (start == end) {
      return df.format(start);
    }
    return '${df.format(start)} - ${df.format(end)}';
  }

  /// Get dates as ISO strings for API
  Map<String, String> get apiParams => {
        'from': start.toIso8601String(),
        'to': end.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
