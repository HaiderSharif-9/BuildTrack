import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/money.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

final reportsPeriodFilterProvider = StateProvider<String>((ref) => 'year');

/// Reports financial and site summary provider
class FinancialReportData {
  final Money totalIncome;
  final Money siteExpenses;
  final Money grossProfit;
  final Money otherExpenses;
  final Money netProfit;
  final double profitMargin;
  final List<SiteProfitItem> siteProfits;
  final int totalAttendanceDays;
  final double totalOvertimeHours;
  final Money totalPurchasesAmount;

  FinancialReportData({
    required this.totalIncome,
    required this.siteExpenses,
    required this.grossProfit,
    required this.otherExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.siteProfits,
    required this.totalAttendanceDays,
    required this.totalOvertimeHours,
    required this.totalPurchasesAmount,
  });
}

class SiteProfitItem {
  final String siteName;
  final Money income;
  final Money expense;
  final Money net;

  SiteProfitItem({
    required this.siteName,
    required this.income,
    required this.expense,
    required this.net,
  });
}

final reportsDataProvider = FutureProvider<FinancialReportData>((ref) async {
  final period = ref.watch(reportsPeriodFilterProvider);
  final supabase = Supabase.instance.client;

  final now = DateTime.now();
  DateTime startDate;

  if (period == 'month') {
    startDate = DateTime(now.year, now.month, 1);
  } else if (period == 'quarter') {
    final currentQuarter = (now.month - 1) ~/ 3;
    startDate = DateTime(now.year, currentQuarter * 3 + 1, 1);
  } else {
    // year
    startDate = DateTime(now.year, 1, 1);
  }

  final startStr = startDate.toIso8601String().split('T')[0];

  // 1. Fetch transactions
  final txRes = await supabase
      .from('transactions')
      .select('type, amount, project_id, projects(name)')
      .gte('date', startStr)
      .isFilter('deleted_at', null);

  Money totalIncome = Money.zero;
  Money siteExpenses = Money.zero;
  Money otherExpenses = Money.zero;
  Map<String, Map<String, Money>> siteMap = {};

  for (var tx in txRes as List<dynamic>) {
    final type = tx['type'] as String;
    final amt = Money.fromString(tx['amount']?.toString() ?? '0');
    final pId = tx['project_id'] as String?;
    final pName = tx['projects'] != null ? (tx['projects']['name'] as String? ?? 'Site') : 'Company Office';

    if (type == 'income') {
      totalIncome = totalIncome + amt;
      siteMap.putIfAbsent(pName, () => {'income': Money.zero, 'expense': Money.zero});
      siteMap[pName]!['income'] = siteMap[pName]!['income']! + amt;
    } else {
      if (pId != null) {
        siteExpenses = siteExpenses + amt;
      } else {
        otherExpenses = otherExpenses + amt;
      }
      siteMap.putIfAbsent(pName, () => {'income': Money.zero, 'expense': Money.zero});
      siteMap[pName]!['expense'] = siteMap[pName]!['expense']! + amt;
    }
  }

  final gross = totalIncome > siteExpenses ? totalIncome - siteExpenses : Money.zero;
  final totalExp = siteExpenses + otherExpenses;
  final net = totalIncome - totalExp;
  final margin = totalIncome.isPositive ? (net.toDouble() / totalIncome.toDouble()) * 100 : 0.0;

  final List<SiteProfitItem> siteProfits = [];
  siteMap.forEach((name, data) {
    final inc = data['income']!;
    final exp = data['expense']!;
    siteProfits.add(SiteProfitItem(
      siteName: name,
      income: inc,
      expense: exp,
      net: inc - exp,
    ));
  });

  // 2. Fetch Attendance Summary
  int attDays = 0;
  double otHours = 0;
  try {
    final attRes = await supabase
        .from('attendance')
        .select('status, overtime_hours')
        .gte('date', startStr)
        .eq('status', 'present')
        .isFilter('deleted_at', null);

    for (var a in attRes as List<dynamic>) {
      attDays++;
      otHours += (a['overtime_hours'] as num?)?.toDouble() ?? 0.0;
    }
  } catch (_) {}

  // 3. Fetch Purchases Summary
  Money purchasesTotal = Money.zero;
  try {
    final purRes = await supabase
        .from('purchases')
        .select('amount')
        .gte('date', startStr)
        .isFilter('deleted_at', null);

    for (var p in purRes as List<dynamic>) {
      purchasesTotal = purchasesTotal + Money.fromString(p['amount']?.toString() ?? '0');
    }
  } catch (_) {}

  return FinancialReportData(
    totalIncome: totalIncome,
    siteExpenses: siteExpenses,
    grossProfit: gross,
    otherExpenses: otherExpenses,
    netProfit: net,
    profitMargin: margin,
    siteProfits: siteProfits,
    totalAttendanceDays: attDays,
    totalOvertimeHours: otHours,
    totalPurchasesAmount: purchasesTotal,
  );
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final period = ref.watch(reportsPeriodFilterProvider);
    final reportAsync = ref.watch(reportsDataProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Profit & Loss Reports'),
        backgroundColor: colors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(reportsDataProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Period Selector Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPeriodChip(ref, 'Month', 'month', period == 'month', colors),
                const SizedBox(width: 8),
                _buildPeriodChip(ref, 'Quarter', 'quarter', period == 'quarter', colors),
                const SizedBox(width: 8),
                _buildPeriodChip(ref, 'Year', 'year', period == 'year', colors),
              ],
            ),
            const SizedBox(height: 16),

            reportAsync.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Net Profit Card (Matching Figma Screen 4)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net profit — ${period.toUpperCase()}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${data.netProfit.toDisplayString()}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: data.netProfit.isPositive ? colors.success : colors.error,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (data.profitMargin >= 0 ? colors.success : colors.error).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${data.profitMargin.toStringAsFixed(1)}% margin',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: data.profitMargin >= 0 ? colors.success : colors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Financial Breakdown Visual Bars
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Financial Breakdown', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildBreakdownRow('Total Income', data.totalIncome, colors.success, isPositive: true),
                        const SizedBox(height: 10),
                        _buildBreakdownRow('Site Expenses', data.siteExpenses, colors.error, isPositive: false),
                        const SizedBox(height: 10),
                        _buildBreakdownRow('Gross Profit', data.grossProfit, colors.info, isPositive: true),
                        const SizedBox(height: 10),
                        _buildBreakdownRow('Company Overheads', data.otherExpenses, colors.warning, isPositive: false),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        _buildBreakdownRow('Net Profit', data.netProfit, data.netProfit.isPositive ? colors.success : colors.error, isPositive: data.netProfit.isPositive, isBold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Operational Summary (Attendance & Purchases)
                  Row(
                    children: [
                      Expanded(
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Attendance', style: theme.textTheme.labelMedium?.copyWith(color: colors.textSecondary)),
                              const SizedBox(height: 4),
                              Text('${data.totalAttendanceDays} Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('+${data.totalOvertimeHours.toStringAsFixed(1)}h OT', style: TextStyle(color: colors.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Materials', style: theme.textTheme.labelMedium?.copyWith(color: colors.textSecondary)),
                              const SizedBox(height: 4),
                              Text('${data.totalPurchasesAmount.toDisplayString()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Text('Total Purchases', style: TextStyle(color: AppColors.incomeLight, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. Site-by-Site Margin Breakdown
                  if (data.siteProfits.isNotEmpty) ...[
                    Text('Site Profitability', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...data.siteProfits.map((sp) {
                      final isPositive = sp.net.isPositive;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sp.siteName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text('Income: ${sp.income.toDisplayString()} • Exp: ${sp.expense.toDisplayString()}', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
                                ],
                              ),
                              Text(
                                '${isPositive ? '+' : ''}${sp.net.toDisplayString()}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: isPositive ? colors.success : colors.error),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
              error: (err, _) => Center(child: Text('Error loading report: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(WidgetRef ref, String label, String value, bool isSelected, AppColorsValue colors) {
    return GestureDetector(
      onTap: () {
        ref.read(reportsPeriodFilterProvider.notifier).state = value;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : colors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.textOnGold : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, Money amount, Color color, {required bool isPositive, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          ],
        ),
        Text(
          '${amount.toDisplayString()}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
        ),
      ],
    );
  }
}

