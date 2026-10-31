import 'money.dart';

class Project {
  final String id;
  final String name;
  final String location;
  final String? clientId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status; // planning, in_progress, on_hold, completed
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Project({
    required this.id,
    required this.name,
    required this.location,
    this.clientId,
    this.startDate,
    this.endDate,
    required this.status,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      clientId: json['client_id'] as String?,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      status: json['status'] as String,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'client_id': clientId,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'status': status,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  bool get isActive => status == 'in_progress';
  bool get isDeleted => deletedAt != null;

  @override
  String toString() => 'Project(id=$id, name=$name, status=$status)';
}

class ProjectFinance {
  final String projectId;
  final Money budget;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectFinance({
    required this.projectId,
    required this.budget,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectFinance.fromJson(Map<String, dynamic> json) {
    return ProjectFinance(
      projectId: json['project_id'] as String,
      budget: Money.fromString(json['budget'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'budget': budget.toDbString(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  String toString() => 'ProjectFinance(project=$projectId, budget=$budget)';
}
