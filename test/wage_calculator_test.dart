import 'package:buildtrack/core/models/money.dart';
import 'package:buildtrack/core/services/wage_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WageCalculator - Golden test cases from CLAUDE.md section 13', () {
    const fullDayHours = 10.0;
    const overtimeMultiplier = 1.5;

    test('1200 rate, present 08:00-18:00 (10h full day) = 1200', () {
      final calc = WageCalculator(
        rate: Money.fromInt(1200),
        fullDayHours: fullDayHours,
        overtimeMultiplier: overtimeMultiplier,
      );

      final result = calc.calculateDay(
        status: 'present',
        inTime: '08:00',
        outTime: '18:00',
      );

      expect(result.hoursWorked, 10.0);
      expect(result.overtimeHours, 0.0);
      expect(result.basePay, Money.fromInt(1200));
      expect(result.overtimePay, Money.zero);
      expect(result.wageAmount, Money.fromInt(1200));
    });

    test('1200 rate, present 08:00-13:00 (5h half day) = 600', () {
      final calc = WageCalculator(
        rate: Money.fromInt(1200),
        fullDayHours: fullDayHours,
        overtimeMultiplier: overtimeMultiplier,
      );

      final result = calc.calculateDay(
        status: 'present',
        inTime: '08:00',
        outTime: '13:00',
      );

      expect(result.hoursWorked, 5.0);
      expect(result.overtimeHours, 0.0);
      expect(result.basePay, Money.fromInt(600));
      expect(result.overtimePay, Money.zero);
      expect(result.wageAmount, Money.fromInt(600));
    });

    test('1200 rate, present 08:00-12:00 (4h) = 480', () {
      final calc = WageCalculator(
        rate: Money.fromInt(1200),
        fullDayHours: fullDayHours,
        overtimeMultiplier: overtimeMultiplier,
      );

      final result = calc.calculateDay(
        status: 'present',
        inTime: '08:00',
        outTime: '12:00',
      );

      expect(result.hoursWorked, 4.0);
      expect(result.overtimeHours, 0.0);
      expect(result.basePay, Money.fromInt(480));
      expect(result.overtimePay, Money.zero);
      expect(result.wageAmount, Money.fromInt(480));
    });

    test('1200 rate, present 08:00-20:00 (12h) = 1560 (base 1200 + OT 360)',
        () {
      final calc = WageCalculator(
        rate: Money.fromInt(1200),
        fullDayHours: fullDayHours,
        overtimeMultiplier: overtimeMultiplier,
      );

      final result = calc.calculateDay(
        status: 'present',
        inTime: '08:00',
        outTime: '20:00',
      );

      expect(result.hoursWorked, 12.0);
      expect(result.overtimeHours, 2.0);
      expect(result.basePay, Money.fromInt(1200));
      // OT: 2h * (1200/10) * 1.5 = 2 * 120 * 1.5 = 360
      expect(result.overtimePay, Money.fromInt(360));
      expect(result.wageAmount, Money.fromInt(1560));
    });

    test('1200 rate, present, no times = 1200 (full day fast swipe)', () {
      final calc = WageCalculator(
        rate: Money.fromInt(1200),
        fullDayHours: fullDayHours,
        overtimeMultiplier: overtimeMultiplier,
      );

      final result = calc.calculateDay(
        status: 'present',
      );

      expect(result.hoursWorked, null);
      expect(result.overtimeHours, 0.0);
      expect(result.basePay, Money.fromInt(1200));
      expect(result.overtimePay, Money.zero);
      expect(result.wageAmount, Money.fromInt(1200));
    });

    test('1200 rate, present, no times, manual OT 2h = 1560', () {
      final calc = WageCalculator(
        rate: Money.fromInt(1200),
        fullDayHours: fullDayHours,
        overtimeMultiplier: overtimeMultiplier,
      );

      final result = calc.calculateDay(
        status: 'present',
        manualOvertimeHours: 2.0,
      );

      expect(result.hoursWorked, null);
      expect(result.overtimeHours, 2.0);
      expect(result.basePay, Money.fromInt(1200));
      // OT: 2 * 120 * 1.5 = 360
      expect(result.overtimePay, Money.fromInt(360));
      expect(result.wageAmount, Money.fromInt(1560));
    });

    test('1000 rate, present 08:00-15:30 (7.5h) = 750', () {
      final calc = WageCalculator(
        rate: Money.fromInt(1000),
        fullDayHours: fullDayHours,
        overtimeMultiplier: overtimeMultiplier,
      );

      final result = calc.calculateDay(
        status: 'present',
        inTime: '08:00',
        outTime: '15:30',
      );

      expect(result.hoursWorked, 7.5);
      expect(result.overtimeHours, 0.0);
      expect(result.basePay, Money.fromInt(750));
      expect(result.overtimePay, Money.zero);
      expect(result.wageAmount, Money.fromInt(750));
    });

    test('1000 rate, present 08:10-17:55 (9h 45m) ≈ 9.75h = 975', () {
      final calc = WageCalculator(
        rate: Money.fromInt(1000),
        fullDayHours: fullDayHours,
        overtimeMultiplier: overtimeMultiplier,
      );

      final result = calc.calculateDay(
        status: 'present',
        inTime: '08:10',
        outTime: '17:55',
      );

      expect(result.hoursWorked, closeTo(9.75, 0.01));
      expect(result.overtimeHours, 0.0);
      expect(result.basePay.toDouble(), closeTo(975, 0.1));
      expect(result.overtimePay, Money.zero);
      expect(result.wageAmount, Money.fromInt(975));
    });

    test('any rate, absent status = 0', () {
      final calc = WageCalculator(
        rate: Money.fromInt(1200),
        fullDayHours: fullDayHours,
        overtimeMultiplier: overtimeMultiplier,
      );

      final result = calc.calculateDay(status: 'absent');

      expect(result.hoursWorked, null);
      expect(result.overtimeHours, 0.0);
      expect(result.basePay, Money.zero);
      expect(result.overtimePay, Money.zero);
      expect(result.wageAmount, Money.zero);
    });

    test('any rate, leave status = 0', () {
      final calc = WageCalculator(
        rate: Money.fromInt(1200),
        fullDayHours: fullDayHours,
        overtimeMultiplier: overtimeMultiplier,
      );

      final result = calc.calculateDay(status: 'leave');

      expect(result.hoursWorked, null);
      expect(result.overtimeHours, 0.0);
      expect(result.basePay, Money.zero);
      expect(result.overtimePay, Money.zero);
      expect(result.wageAmount, Money.zero);
    });
  });

  group('Money type - arithmetic and formatting', () {
    test('Money.fromInt creates correct value', () {
      final m = Money.fromInt(1234);
      expect(m.toDouble(), 1234.0);
    });

    test('Money.fromString parses decimal', () {
      final m = Money.fromString('1234.56');
      expect(m.toDouble(), 1234.56);
    });

    test('Money addition', () {
      final m1 = Money.fromInt(100);
      final m2 = Money.fromInt(50);
      final result = m1 + m2;
      expect(result.toDouble(), 150.0);
    });

    test('Money subtraction', () {
      final m1 = Money.fromInt(100);
      final m2 = Money.fromInt(30);
      final result = m1 - m2;
      expect(result.toDouble(), 70.0);
    });

    test('Money multiplication', () {
      final m = Money.fromInt(100);
      final result = m * 1.5;
      expect(result.toDouble(), 150.0);
    });

    test('Money division', () {
      final m = Money.fromInt(100);
      final result = m / 4;
      expect(result.toDouble(), 25.0);
    });

    test('Money roundToRupee', () {
      final m = Money.fromString('1234.567');
      final rounded = m.roundToRupee();
      expect(rounded.toDouble(), 1235.0);
    });

    test('Money comparison operators', () {
      final m1 = Money.fromInt(100);
      final m2 = Money.fromInt(50);

      expect(m1 > m2, true);
      expect(m1 < m2, false);
      expect(m1 >= m2, true);
      expect(m1 <= m2, false);
      expect(m1 == m1, true);
    });

    test('Money.zero', () {
      expect(Money.zero.toDouble(), 0.0);
      expect(Money.zero.isZero, true);
    });

    test('Money display string format', () {
      final m = Money.fromInt(1234567);
      final display = m.toDisplayString();
      expect(display, 'Rs. 1,234,567');
    });
  });
}
