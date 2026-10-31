class AppSettings {
  final int id;
  final String companyName;
  final String currency;
  final int fullDayHours;
  final double overtimeMultiplier;
  final int weekStartDay; // 5 = Friday (ISO)
  final int payDay; // 4 = Thursday
  final String defaultLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppSettings({
    required this.id,
    required this.companyName,
    required this.currency,
    required this.fullDayHours,
    required this.overtimeMultiplier,
    required this.weekStartDay,
    required this.payDay,
    required this.defaultLanguage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'] as int,
      companyName: json['company_name'] as String,
      currency: json['currency'] as String,
      fullDayHours: json['full_day_hours'] as int,
      overtimeMultiplier: (json['overtime_multiplier'] as num).toDouble(),
      weekStartDay: json['week_start_day'] as int,
      payDay: json['pay_day'] as int,
      defaultLanguage: json['default_language'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_name': companyName,
        'currency': currency,
        'full_day_hours': fullDayHours,
        'overtime_multiplier': overtimeMultiplier,
        'week_start_day': weekStartDay,
        'pay_day': payDay,
        'default_language': defaultLanguage,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  AppSettings copyWith({
    int? id,
    String? companyName,
    String? currency,
    int? fullDayHours,
    double? overtimeMultiplier,
    int? weekStartDay,
    int? payDay,
    String? defaultLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      currency: currency ?? this.currency,
      fullDayHours: fullDayHours ?? this.fullDayHours,
      overtimeMultiplier: overtimeMultiplier ?? this.overtimeMultiplier,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      payDay: payDay ?? this.payDay,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'AppSettings(id=$id, company=$companyName, fullDayHours=$fullDayHours, overtimeMultiplier=$overtimeMultiplier)';
}
