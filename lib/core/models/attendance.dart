import 'money.dart';

class Attendance {
  final String id;
  final String projectId;
  final String labourId;
  final DateTime date; // In Asia/Karachi timezone
  final String status; // present, absent, leave
  final String? inTime; // HH:MM
  final String? outTime; // HH:MM
  final double? hoursWorked;
  final double? overtimeHours;
  final String? remarks;
  final bool locked;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.projectId,
    required this.labourId,
    required this.date,
    required this.status,
    this.inTime,
    this.outTime,
    this.hoursWorked,
    this.overtimeHours,
    this.remarks,
    required this.locked,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      labourId: json['labour_id'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      inTime: json['in_time'] as String?,
      outTime: json['out_time'] as String?,
      hoursWorked: json['hours_worked'] != null ? (json['hours_worked'] as num).toDouble() : null,
      overtimeHours: json['overtime_hours'] != null ? (json['overtime_hours'] as num).toDouble() : null,
      remarks: json['remarks'] as String?,
      locked: json['locked'] as bool,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'labour_id': labourId,
        'date': date.toIso8601String(),
        'status': status,
        'in_time': inTime,
        'out_time': outTime,
        'hours_worked': hoursWorked,
        'overtime_hours': overtimeHours,
        'remarks': remarks,
        'locked': locked,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get isLeave => status == 'leave';

  @override
  String toString() =>
      'Attendance(project=$projectId, labour=$labourId, date=$date, status=$status, locked=$locked)';
}

/// Wage computation (admin/accountant only)
class AttendancePay {
  final String attendanceId;
  final Money rate;
  final Money wageAmount;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendancePay({
    required this.attendanceId,
    required this.rate,
    required this.wageAmount,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendancePay.fromJson(Map<String, dynamic> json) {
    return AttendancePay(
      attendanceId: json['attendance_id'] as String,
      rate: Money.fromString(json['rate'] as String),
      wageAmount: Money.fromString(json['wage_amount'] as String),
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'attendance_id': attendanceId,
        'rate': rate.toDbString(),
        'wage_amount': wageAmount.toDbString(),
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  String toString() => 'AttendancePay(attendance=$attendanceId, wage=$wageAmount)';
}
