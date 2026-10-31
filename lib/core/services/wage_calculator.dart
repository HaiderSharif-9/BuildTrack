import '../models/money.dart';

/// Result of wage calculation per attendance day
class WageResult {
  final double? hoursWorked;
  final double? overtimeHours;
  final Money basePay;
  final Money overtimePay;
  final Money wageAmount;

  WageResult({
    required this.hoursWorked,
    required this.overtimeHours,
    required this.basePay,
    required this.overtimePay,
    required this.wageAmount,
  });

  @override
  String toString() =>
      'WageResult(hours=$hoursWorked, ot=$overtimeHours, base=$basePay, otPay=$overtimePay, wage=$wageAmount)';
}

/// Wage calculator per CLAUDE.md section 4.1
///
/// Formula:
/// - hourly_rate = rate / full_day_hours
/// - If times given: hours_worked = out_time - in_time
///   - base_pay = rate * min(hours_worked, full_day_hours) / full_day_hours
///   - overtime_hours = max(hours_worked - full_day_hours, 0)
/// - If no times: base_pay = rate (full day), manual overtime from user
/// - overtime_pay = overtime_hours * hourly_rate * overtime_multiplier
/// - wage_amount = round_half_up(base_pay + overtime_pay)
class WageCalculator {
  final Money rate;
  final double fullDayHours;
  final double overtimeMultiplier;

  WageCalculator({
    required this.rate,
    this.fullDayHours = 10.0,
    this.overtimeMultiplier = 1.5,
  });

  /// Calculate wage for a single day
  ///
  /// [status] 'present', 'absent', or 'leave'
  /// [inTime] hh:mm (e.g., "08:00")
  /// [outTime] hh:mm (e.g., "18:00")
  /// [manualOvertimeHours] used only when no times given
  WageResult calculateDay({
    required String status,
    String? inTime,
    String? outTime,
    double manualOvertimeHours = 0.0,
  }) {
    // Absent or leave: zero wage
    if (status == 'absent' || status == 'leave') {
      return WageResult(
        hoursWorked: null,
        overtimeHours: 0,
        basePay: Money.zero,
        overtimePay: Money.zero,
        wageAmount: Money.zero,
      );
    }

    // Present
    if (status != 'present') {
      return WageResult(
        hoursWorked: null,
        overtimeHours: 0,
        basePay: Money.zero,
        overtimePay: Money.zero,
        wageAmount: Money.zero,
      );
    }

    // If both times given: calculate hours
    if (inTime != null && outTime != null) {
      final hours = _parseTimeAndCalculateHours(inTime, outTime);
      if (hours == null) {
        // Invalid times, treat as full day
        return _calculateFullDay();
      }

      final basePay =
          rate * (hours > fullDayHours ? fullDayHours : hours) / fullDayHours;
      final overtimeHours =
          hours > fullDayHours ? hours - fullDayHours : 0.0;
      final hourlyRate = rate.toDouble() / fullDayHours;
      final overtimePay = Money.fromDouble(overtimeHours * hourlyRate * overtimeMultiplier);

      final wageAmount =
          (basePay + overtimePay).roundToRupee();

      return WageResult(
        hoursWorked: hours,
        overtimeHours: overtimeHours > 0 ? overtimeHours : 0,
        basePay: basePay,
        overtimePay: overtimePay,
        wageAmount: wageAmount,
      );
    }

    // No times given: use rate as full day, add manual overtime if any
    if (manualOvertimeHours > 0) {
      final hourlyRate = rate.toDouble() / fullDayHours;
      final overtimePay = Money.fromDouble(manualOvertimeHours * hourlyRate * overtimeMultiplier);
      final wageAmount = (rate + overtimePay).roundToRupee();

      return WageResult(
        hoursWorked: null,
        overtimeHours: manualOvertimeHours,
        basePay: rate,
        overtimePay: overtimePay,
        wageAmount: wageAmount,
      );
    }

    // No times, no manual overtime: full day rate
    return _calculateFullDay();
  }

  /// Full day present with no times or manual overtime
  WageResult _calculateFullDay() {
    return WageResult(
      hoursWorked: null,
      overtimeHours: 0,
      basePay: rate,
      overtimePay: Money.zero,
      wageAmount: rate,
    );
  }

  /// Parse "HH:MM" format and return hours as double
  double? _parseTimeAndCalculateHours(String inTime, String outTime) {
    try {
      final inParts = inTime.split(':');
      final outParts = outTime.split(':');

      if (inParts.length != 2 || outParts.length != 2) return null;

      final inHour = int.parse(inParts[0]);
      final inMin = int.parse(inParts[1]);
      final outHour = int.parse(outParts[0]);
      final outMin = int.parse(outParts[1]);

      if (inHour < 0 || inHour > 23 || inMin < 0 || inMin > 59) return null;
      if (outHour < 0 || outHour > 23 || outMin < 0 || outMin > 59) return null;

      final inTotalMin = inHour * 60 + inMin;
      final outTotalMin = outHour * 60 + outMin;

      // out must be after in
      if (outTotalMin <= inTotalMin) return null;

      final diffMin = outTotalMin - inTotalMin;
      final hours = diffMin / 60.0;

      // Max 24 hours
      if (hours > 24.0) return null;

      return hours;
    } catch (_) {
      return null;
    }
  }
}
