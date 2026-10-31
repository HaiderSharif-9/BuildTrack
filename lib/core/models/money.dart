import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// BuildTrack Money - wraps Decimal for financial calculations
/// Never use double for money. Always use Money.
class Money {
  final Decimal value;

  const Money(this.value);

  /// Create from integer (rupees)
  factory Money.fromInt(int rupees) => Money(Decimal.fromInt(rupees));

  /// Create from double (converted to Decimal internally)
  factory Money.fromDouble(double amount) {
    return Money(Decimal.parse(amount.toString()));
  }

  /// Create from string (e.g., "1234.56")
  factory Money.fromString(String amount) {
    return Money(Decimal.parse(amount));
  }

  /// Create from database numeric
  factory Money.fromNum(num amount) {
    return Money(Decimal.parse(amount.toString()));
  }

  /// Zero money
  static Money get zero => Money(Decimal.zero);

  /// Check if zero
  bool get isZero => value == Decimal.zero;

  /// Check if positive
  bool get isPositive => value > Decimal.zero;

  /// Check if negative
  bool get isNegative => value < Decimal.zero;

  /// Round to nearest rupee (half up)
  Money roundToRupee() {
    return Money(value.round());
  }

  /// Add
  Money operator +(Money other) => Money(value + other.value);

  /// Subtract
  Money operator -(Money other) => Money(value - other.value);

  /// Multiply
  Money operator *(num scalar) => Money(value * Decimal.parse(scalar.toString()));

  /// Divide
  Money operator /(num scalar) {
    final result = value / Decimal.parse(scalar.toString());
    return Money(Decimal.parse(result.toString()));
  }

  /// Greater than
  bool operator >(Money other) => value > other.value;

  /// Less than
  bool operator <(Money other) => value < other.value;

  /// Greater than or equal
  bool operator >=(Money other) => value >= other.value;

  /// Less than or equal
  bool operator <=(Money other) => value <= other.value;

  /// Equality
  @override
  bool operator ==(Object other) {
    if (other is Money) return value == other.value;
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  /// Format for display: Rs. 1,234,567
  String toDisplayString() {
    final formatter = NumberFormat('#,##0.##', 'en_US');
    return 'Rs. ${formatter.format(value.toDouble())}';
  }

  /// Format for display with decimal places
  String toDisplayStringWithDecimals(int decimals) {
    final pattern = '#,##0.${'0' * decimals}';
    final formatter = NumberFormat(pattern, 'en_US');
    return 'Rs. ${formatter.format(value.toDouble())}';
  }

  /// Export as Decimal
  Decimal toDecimal() => value;

  /// Export as double
  double toDouble() => value.toDouble();

  /// Export as string for database
  String toDbString() => value.toString();

  @override
  String toString() => 'Money($value)';
}

/// Extension for num to Money
extension MoneyExtension on num {
  Money get rupees => Money.fromNum(this);
}
