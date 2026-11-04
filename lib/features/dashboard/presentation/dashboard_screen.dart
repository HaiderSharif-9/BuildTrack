import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/dashboard_summary.dart';
import '../../../core/models/date_range.dart';
import '../../../core/models/money.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../core/widgets/layout_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_providers.dart';
import '../data/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = context.appColors;
    final role = ref.watch(currentUserRoleProvider).asData?.value;
    final canViewFinance = role == 'admin' || role == 'accountant';
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final siteTotalsAsync = ref.watch(siteTotalsProvider);
    final trendAsync = ref.watch(dailyTrendProvider);
    final activityAsync = ref.watch(recentActivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(siteTotalsProvider);
          ref.invalidate(dailyTrendProvider);
          ref.invalidate(recentActivityProvider);
          await Future.wait([
            ref.read(dashboardSummaryProvider.future),
            ref.read(siteTotalsProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PeriodSelector(l10n: l10n, colors: colors),
            const SizedBox(height: 16),
            _SiteFilter(l10n: l10n, colors: colors),
            const SizedBox(height: 24),
            _KPISection(
              l10n: l10n,
              theme: theme,
              colors: colors,
              summaryAsync: summaryAsync,
              canViewFinance: canViewFinance,
            ),
            if (canViewFinance) ...[
              const SizedBox(height: 28),
              _ChartsSection(
                theme: theme,
                colors: colors,
                trendAsync: trendAsync,
              ),
            ],
            const SizedBox(height: 28),
            _SiteCardsSection(
              theme: theme,
              colors: colors,
              siteTotalsAsync: siteTotalsAsync,
              canViewFinance: canViewFinance,
            ),
            if (canViewFinance) ...[
              const SizedBox(height: 28),
              _RecentActivitySection(
                theme: theme,
                colors: colors,
                activityAsync: activityAsync,
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends ConsumerWidget {
  final AppLocalizations l10n;
  final AppColorsValue colors;

  const _PeriodSelector({required this.l10n, required this.colors});

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _sameRange(DateRange a, DateRange b) =>
      _sameDay(a.start, b.start) && _sameDay(a.end, b.end);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDateRangeProvider);
    final today = DateRange.today();
    final week = DateRange.currentWeek();
    final month = DateRange.currentMonth();
    final year = DateRange.currentYear();

    void select(DateRange range) {
      ref.read(selectedDateRangeProvider.notifier).state = range;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _PeriodChip(label: l10n.today, selected: _sameRange(selected, today), onTap: () => select(today)),
              const SizedBox(width: 8),
              _PeriodChip(label: l10n.thisWeek, selected: _sameRange(selected, week), onTap: () => select(week)),
              const SizedBox(width: 8),
              _PeriodChip(label: l10n.thisMonth, selected: _sameRange(selected, month), onTap: () => select(month)),
              const SizedBox(width: 8),
              _PeriodChip(label: l10n.thisYear, selected: _sameRange(selected, year), onTap: () => select(year)),
              const SizedBox(width: 8),
              _PeriodChip(
                label: l10n.custom,
                selected: !_sameRange(selected, today) &&
                    !_sameRange(selected, week) &&
                    !_sameRange(selected, month) &&
                    !_sameRange(selected, year),
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDateRange: DateTimeRange(start: selected.start, end: selected.end),
                  );
                  if (picked != null) {
                    select(DateRange.custom(picked.start, picked.end));
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          selected.displayLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: context.appColors.surface,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.textOnGold : context.appColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: selected ? AppColors.primary : context.appColors.border),
    );
  }
}

class _SiteFilter extends ConsumerWidget {
  final AppLocalizations l10n;
  final AppColorsValue colors;

  const _SiteFilter({required this.l10n, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSite = ref.watch(selectedSiteProvider);
    final availableSites = ref.watch(availableProjectsProvider);

    return availableSites.when(
      data: (sites) {
        final value = sites.any((site) => site['id'] == selectedSite) ? selectedSite : null;
        return AppCard(
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String?>(
                  value: value,
                  underline: const SizedBox.shrink(),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.allSites),
                    ),
                    ...sites.map(
                      (site) => DropdownMenuItem<String?>(
                        value: site['id'] as String,
                        child: Text(site['name'] as String),
                      ),
                    ),
                  ],
                  onChanged: (next) {
                    ref.read(selectedSiteProvider.notifier).state = next;
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 56, child: ShimmerSkeleton()),
      error: (error, _) => ErrorState(
        title: 'Unable to load sites',
        message: error.toString(),
        onRetry: () => ref.invalidate(availableProjectsProvider),
      ),
    );
  }
}

class _KPISection extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final AppColorsValue colors;
  final AsyncValue<DashboardSummary> summaryAsync;
  final bool canViewFinance;

  const _KPISection({
    required this.l10n,
    required this.theme,
    required this.colors,
    required this.summaryAsync,
    required this.canViewFinance,
  });

  @override
  Widget build(BuildContext context) {
    return summaryAsync.when(
      data: (summary) {
        if (!canViewFinance) {
          return Row(
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Assigned Sites',
                  value: summary.totalProjects.toString(),
                  type: 'default',
                  icon: Icons.business_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  label: 'In Progress',
                  value: summary.inProgressProjects.toString(),
                  type: 'default',
                  icon: Icons.construction_outlined,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    label: l10n.income,
                    value: _compactMoney(summary.totalIncome),
                    type: 'income',
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    label: l10n.expense,
                    value: _compactMoney(summary.siteExpenses + summary.otherExpenses),
                    type: 'expense',
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    label: l10n.profit,
                    value: _compactMoney(summary.netProfit),
                    type: 'profit',
                    icon: Icons.account_balance,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    label: l10n.sites,
                    value: summary.totalProjects.toString(),
                    type: 'default',
                    icon: Icons.business_outlined,
                    subtitle: '${summary.inProgressProjects} in progress',
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const ShimmerSkeleton(height: 116),
      error: (error, _) => ErrorState(
        title: 'Dashboard totals unavailable',
        message: error.toString(),
        onRetry: () {},
      ),
    );
  }
}

class _ChartsSection extends StatelessWidget {
  final ThemeData theme;
  final AppColorsValue colors;
  final AsyncValue<List<DailySummary>> trendAsync;

  const _ChartsSection({
    required this.theme,
    required this.colors,
    required this.trendAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Income vs Expenses'),
        const SizedBox(height: 12),
        trendAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const AppCard(
                child: SizedBox(
                  height: 120,
                  child: Center(child: Text('No transactions in this period')),
                ),
              );
            }
            final visible = items.length > 14 ? items.sublist(items.length - 14) : items;
            final maxValue = visible.fold<double>(
              0,
              (current, item) => math.max(
                current,
                math.max(item.income.toDouble(), item.expenses.toDouble()),
              ),
            );
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _LegendDot(color: colors.success, label: 'Income'),
                      const SizedBox(width: 16),
                      _LegendDot(color: colors.error, label: 'Expenses'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: visible.map((item) {
                        final incomeHeight = maxValue == 0 ? 0.0 : 112 * item.income.toDouble() / maxValue;
                        final expenseHeight = maxValue == 0 ? 0.0 : 112 * item.expenses.toDouble() / maxValue;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: incomeHeight,
                                          decoration: BoxDecoration(
                                            color: colors.success,
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Container(
                                          height: expenseHeight,
                                          decoration: BoxDecoration(
                                            color: colors.error,
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  DateFormat('d').format(item.date),
                                  style: theme.textTheme.labelSmall?.copyWith(color: colors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const ShimmerSkeleton(height: 190),
          error: (error, _) => ErrorState(
            title: 'Chart unavailable',
            message: error.toString(),
            onRetry: () {},
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SiteCardsSection extends StatelessWidget {
  final ThemeData theme;
  final AppColorsValue colors;
  final AsyncValue<List<SiteTotals>> siteTotalsAsync;
  final bool canViewFinance;

  const _SiteCardsSection({
    required this.theme,
    required this.colors,
    required this.siteTotalsAsync,
    required this.canViewFinance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Sites'),
        const SizedBox(height: 12),
        siteTotalsAsync.when(
          data: (sites) {
            if (sites.isEmpty) {
              return const AppCard(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('No active sites found')),
                ),
              );
            }
            return Column(
              children: sites.map((site) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(site.siteName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        if (canViewFinance) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Income: ${_compactMoney(site.income)}', style: theme.textTheme.bodySmall),
                              Text('Expenses: ${_compactMoney(site.expenses)}', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Profit: ${_compactMoney(site.profit)}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                              Text('Budget: ${_compactMoney(site.budget)}', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          if (site.budget.toDouble() > 0) ...[
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: site.budgetProgress / 100,
                              backgroundColor: colors.surfaceAlt,
                              color: site.isOverBudget ? colors.error : colors.success,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              site.isOverBudget
                                  ? 'Over budget'
                                  : '${site.budgetProgress.toStringAsFixed(0)}% of budget used',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: site.isOverBudget ? colors.error : colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const ShimmerSkeleton(height: 120),
          error: (error, _) => ErrorState(
            title: 'Sites unavailable',
            message: error.toString(),
            onRetry: () {},
          ),
        ),
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  final ThemeData theme;
  final AppColorsValue colors;
  final AsyncValue<List<Map<String, dynamic>>> activityAsync;

  const _RecentActivitySection({
    required this.theme,
    required this.colors,
    required this.activityAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recent Activity'),
        const SizedBox(height: 12),
        activityAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const AppCard(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('No recent transactions')),
                ),
              );
            }
            return AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: items.map((item) {
                  final type = item['type'] as String? ?? 'expense';
                  final amount = Money.fromString(item['amount']?.toString() ?? '0');
                  final description = item['description'] as String? ?? 'Transaction';
                  final date = DateTime.parse(item['date'] as String);
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      type == 'income' ? Icons.south_west : Icons.north_east,
                      color: type == 'income' ? colors.success : colors.error,
                    ),
                    title: Text(description, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(DateFormat('d MMM yyyy').format(date)),
                    trailing: Text(
                      amount.toDisplayString(),
                      style: TextStyle(
                        color: type == 'income' ? colors.success : colors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const ShimmerSkeleton(height: 180),
          error: (error, _) => ErrorState(
            title: 'Activity unavailable',
            message: error.toString(),
            onRetry: () {},
          ),
        ),
      ],
    );
  }
}

String _compactMoney(Money money) {
  final amount = money.toDouble();
  final absolute = amount.abs();
  final sign = amount < 0 ? '-' : '';
  if (absolute >= 1000000) {
    return 'Rs. $sign${(absolute / 1000000).toStringAsFixed(1)}M';
  }
  if (absolute >= 1000) {
    return 'Rs. $sign${(absolute / 1000).toStringAsFixed(0)}K';
  }
  return money.toDisplayString();
}
