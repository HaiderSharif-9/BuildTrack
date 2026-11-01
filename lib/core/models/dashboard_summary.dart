import '../models/money.dart';

class DashboardSummary {
  final Money totalIncome;
  final Money siteExpenses;
  final Money otherExpenses;
  final Money grossProfit;
  final Money netProfit;
  final int totalProjects;
  final int inProgressProjects;
  final DateTime generatedAt;

  DashboardSummary({
    required this.totalIncome,
    required this.siteExpenses,
    required this.otherExpenses,
    required this.grossProfit,
    required this.netProfit,
    required this.totalProjects,
    required this.inProgressProjects,
    required this.generatedAt,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalIncome: Money.fromString(json['total_income']?.toString() ?? '0'),
      siteExpenses: Money.fromString(json['site_expenses']?.toString() ?? '0'),
      otherExpenses: Money.fromString(json['other_expenses']?.toString() ?? '0'),
      grossProfit: Money.fromString(json['gross_profit']?.toString() ?? '0'),
      netProfit: Money.fromString(json['net_profit']?.toString() ?? '0'),
      totalProjects: (json['total_projects'] as num?)?.toInt() ?? 0,
      inProgressProjects: (json['in_progress_projects'] as num?)?.toInt() ?? 0,
      generatedAt: DateTime.parse(json['generated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_income': totalIncome.toDbString(),
        'site_expenses': siteExpenses.toDbString(),
        'other_expenses': otherExpenses.toDbString(),
        'gross_profit': grossProfit.toDbString(),
        'net_profit': netProfit.toDbString(),
        'total_projects': totalProjects,
        'in_progress_projects': inProgressProjects,
        'generated_at': generatedAt.toIso8601String(),
      };

  @override
  String toString() => 'DashboardSummary(income=$totalIncome, netProfit=$netProfit)';
}

class DailySummary {
  final DateTime date;
  final Money income;
  final Money expenses;
  final Money profit;

  DailySummary({
    required this.date,
    required this.income,
    required this.expenses,
    required this.profit,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: DateTime.parse(json['date'] as String),
      income: Money.fromString(json['income']?.toString() ?? '0'),
      expenses: Money.fromString(json['expenses']?.toString() ?? '0'),
      profit: Money.fromString(json['profit']?.toString() ?? '0'),
    );
  }
}

class SiteTotals {
  final String siteId;
  final String siteName;
  final Money income;
  final Money expenses;
  final Money profit;
  final Money budget;

  SiteTotals({
    required this.siteId,
    required this.siteName,
    required this.income,
    required this.expenses,
    required this.profit,
    required this.budget,
  });

  factory SiteTotals.fromJson(Map<String, dynamic> json) {
    return SiteTotals(
      siteId: json['site_id'] as String,
      siteName: json['site_name'] as String,
      income: Money.fromString(json['income']?.toString() ?? '0'),
      expenses: Money.fromString(json['expenses']?.toString() ?? '0'),
      profit: Money.fromString(json['profit']?.toString() ?? '0'),
      budget: Money.fromString(json['budget']?.toString() ?? '0'),
    );
  }

  /// Budget progress as percentage (0-100)
  double get budgetProgress {
    if (budget.toDouble() <= 0) return 0;
    final used = expenses.toDouble();
    return (used / budget.toDouble() * 100).clamp(0, 100);
  }

  /// Budget remaining
  Money get budgetRemaining {
    final remaining = budget.toDouble() - expenses.toDouble();
    return Money.fromDouble(remaining > 0 ? remaining : 0);
  }

  /// Is over budget?
  bool get isOverBudget => expenses > budget;
}
