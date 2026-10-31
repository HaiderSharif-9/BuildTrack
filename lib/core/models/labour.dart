import 'money.dart';

class Labour {
  final String id;
  final String name;
  final String trade;
  final bool active;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Labour({
    required this.id,
    required this.name,
    required this.trade,
    required this.active,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Labour.fromJson(Map<String, dynamic> json) {
    return Labour(
      id: json['id'] as String,
      name: json['name'] as String,
      trade: json['trade'] as String,
      active: json['active'] as bool,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'trade': trade,
        'active': active,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  bool get isDeleted => deletedAt != null;

  @override
  String toString() => 'Labour(id=$id, name=$name, trade=$trade, active=$active)';
}

/// Sensitive labour data: CNIC, phone, default rate
/// Admin/accountant only (separate table for RLS)
class LabourPrivate {
  final String labourId;
  final String? phone;
  final String? cnic; // masked display: 00000-0000000-0
  final Money defaultRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  LabourPrivate({
    required this.labourId,
    this.phone,
    this.cnic,
    required this.defaultRate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LabourPrivate.fromJson(Map<String, dynamic> json) {
    return LabourPrivate(
      labourId: json['labour_id'] as String,
      phone: json['phone'] as String?,
      cnic: json['cnic'] as String?,
      defaultRate: Money.fromString(json['default_rate'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'labour_id': labourId,
        'phone': phone,
        'cnic': cnic,
        'default_rate': defaultRate.toDbString(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Mask CNIC for display: show only last 4 digits
  String get maskedCnic {
    if (cnic == null || cnic!.isEmpty) return '';
    if (cnic!.length < 4) return cnic!;
    return '*' * (cnic!.length - 4) + cnic!.substring(cnic!.length - 4);
  }

  @override
  String toString() => 'LabourPrivate(labour=$labourId, rate=$defaultRate)';
}

/// Site-level labour assignment
class ProjectLabour {
  final String projectId;
  final String labourId;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectLabour({
    required this.projectId,
    required this.labourId,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectLabour.fromJson(Map<String, dynamic> json) {
    return ProjectLabour(
      projectId: json['project_id'] as String,
      labourId: json['labour_id'] as String,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'labour_id': labourId,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  String toString() => 'ProjectLabour(project=$projectId, labour=$labourId)';
}

/// Per-site rate override for labour
class ProjectLabourRate {
  final String projectId;
  final String labourId;
  final Money rateOverride;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectLabourRate({
    required this.projectId,
    required this.labourId,
    required this.rateOverride,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectLabourRate.fromJson(Map<String, dynamic> json) {
    return ProjectLabourRate(
      projectId: json['project_id'] as String,
      labourId: json['labour_id'] as String,
      rateOverride: Money.fromString(json['rate_override'] as String),
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'labour_id': labourId,
        'rate_override': rateOverride.toDbString(),
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  String toString() =>
      'ProjectLabourRate(project=$projectId, labour=$labourId, rate=$rateOverride)';
}
