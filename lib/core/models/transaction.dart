import 'money.dart';

class Category {
  final String id;
  final String name;
  final String type; // income, expense
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? json['created_at']) as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  @override
  String toString() => 'Category(id=$id, name=$name, type=$type)';
}

/// Ledger transaction: income or expense
class Transaction {
  final String id;
  final String? projectId; // NULL = company-level
  final DateTime date;
  final String type; // income, expense
  final String categoryId;
  final String description;
  final Money amount;
  final String source; // manual, purchase, wage
  final String? sourceId; // UUID of purchase or wage_payment if source != manual
  final String? attachmentPath;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Transaction({
    required this.id,
    this.projectId,
    required this.date,
    required this.type,
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.source,
    this.sourceId,
    this.attachmentPath,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      projectId: json['project_id'] as String?,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      categoryId: json['category_id'] as String,
      description: json['description'] as String? ?? '',
      amount: Money.fromNum(json['amount'] as num),
      source: json['source'] as String,
      sourceId: json['source_id'] as String?,
      attachmentPath: json['attachment_path'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? json['created_at']) as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'date': date.toIso8601String(),
        'type': type,
        'category_id': categoryId,
        'description': description,
        'amount': amount.toDbString(),
        'source': source,
        'source_id': sourceId,
        'attachment_path': attachmentPath,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  bool get isDeleted => deletedAt != null;
  bool get isSiteLevel => projectId != null;
  bool get isCompanyLevel => projectId == null;
  bool get isReadOnly => source != 'manual'; // auto-generated from purchase or wage

  @override
  String toString() =>
      'Transaction(id=$id, type=$type, amount=$amount, source=$source)';
}
