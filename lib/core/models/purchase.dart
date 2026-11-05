import 'money.dart';

class Purchase {
  final String id;
  final String projectId;
  final DateTime date;
  final String item;
  final double qty;
  final String unit; // Bag, Pcs, Kg, Trolley, Ton, Ft, Lot, or custom text
  final Money rate;
  final Money amount; // qty * rate (generated column)
  final String? supplierId;
  final String? attachmentPath; // bill photo
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Purchase({
    required this.id,
    required this.projectId,
    required this.date,
    required this.item,
    required this.qty,
    required this.unit,
    required this.rate,
    required this.amount,
    this.supplierId,
    this.attachmentPath,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      date: DateTime.parse(json['date'] as String),
      item: json['item'] as String,
      qty: (json['qty'] as num).toDouble(),
      unit: json['unit'] as String? ?? '',
      rate: Money.fromNum(json['rate'] as num),
      amount: Money.fromNum(json['amount'] as num),
      supplierId: json['supplier_id'] as String?,
      attachmentPath: json['attachment_path'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'date': date.toIso8601String(),
        'item': item,
        'qty': qty,
        'unit': unit,
        'rate': rate.toDbString(),
        'amount': amount.toDbString(),
        'supplier_id': supplierId,
        'attachment_path': attachmentPath,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  bool get isDeleted => deletedAt != null;

  @override
  String toString() => 'Purchase(id=$id, item=$item, qty=$qty, amount=$amount)';
}
