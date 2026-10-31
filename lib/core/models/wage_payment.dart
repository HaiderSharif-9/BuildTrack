import 'money.dart';

class LabourAdvance {
  final String id;
  final String labourId;
  final String projectId;
  final DateTime date;
  final Money amount;
  final String? note;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  LabourAdvance({
    required this.id,
    required this.labourId,
    required this.projectId,
    required this.date,
    required this.amount,
    this.note,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory LabourAdvance.fromJson(Map<String, dynamic> json) {
    return LabourAdvance(
      id: json['id'] as String,
      labourId: json['labour_id'] as String,
      projectId: json['project_id'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: Money.fromString(json['amount'] as String),
      note: json['note'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'labour_id': labourId,
        'project_id': projectId,
        'date': date.toIso8601String(),
        'amount': amount.toDbString(),
        'note': note,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  bool get isDeleted => deletedAt != null;

  @override
  String toString() => 'LabourAdvance(labour=$labourId, amount=$amount)';
}

/// Weekly payroll: Fri-Thu week wages with payment status
class WagePayment {
  final String id;
  final String labourId;
  final String projectId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Money gross;
  final Money advancesDeducted;
  final Money net; // = gross - advancesDeducted
  final DateTime paidOn;
  final String method; // cash, bank, easypaisa, jazzcash
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? reopenReason;

  WagePayment({
    required this.id,
    required this.labourId,
    required this.projectId,
    required this.periodStart,
    required this.periodEnd,
    required this.gross,
    required this.advancesDeducted,
    required this.net,
    required this.paidOn,
    required this.method,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.reopenReason,
  });

  factory WagePayment.fromJson(Map<String, dynamic> json) {
    return WagePayment(
      id: json['id'] as String,
      labourId: json['labour_id'] as String,
      projectId: json['project_id'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      gross: Money.fromString(json['gross'] as String),
      advancesDeducted: Money.fromString(json['advances_deducted'] as String),
      net: Money.fromString(json['net'] as String),
      paidOn: DateTime.parse(json['paid_on'] as String),
      method: json['method'] as String,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      reopenReason: json['reopen_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'labour_id': labourId,
        'project_id': projectId,
        'period_start': periodStart.toIso8601String(),
        'period_end': periodEnd.toIso8601String(),
        'gross': gross.toDbString(),
        'advances_deducted': advancesDeducted.toDbString(),
        'net': net.toDbString(),
        'paid_on': paidOn.toIso8601String(),
        'method': method,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'reopen_reason': reopenReason,
      };

  bool get isDeleted => deletedAt != null;

  @override
  String toString() =>
      'WagePayment(labour=$labourId, period=$periodStart to $periodEnd, net=$net, method=$method)';
}
