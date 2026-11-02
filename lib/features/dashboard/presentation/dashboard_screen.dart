import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/money.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/index.dart';
import '../../../l10n/app_localizations.dart';
import '../data/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            _PeriodSelector(l10n: l10n, colors: colors),
            const SizedBox(height: 20),

            // Site filter
            _SiteFilter(l10n: l10n, colors: colors),
            const SizedBox(height: 24),

            // KPI Cards
            _KPISection(l10n: l10n, theme: theme, colors: colors),
            const SizedBox(height: 32),

            // Charts section
            _ChartsSection(l10n: l10n, theme: theme, colors: colors),
            const SizedBox(height: 32),

            // Site cards
            _SiteCardsSection(l10n: l10n, theme: theme, colors: colors),
            const SizedBox(height: 32),

            // Recent activity
            _RecentActivitySection(l10n: l10n, theme: theme, colors: colors),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final AppLocalizations l10n;
  final AppColorsValue colors;

  const _PeriodSelector({
    required this.l10n,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _PeriodChip(
            label: l10n.today,
            onPressed: () {},
            isSelected: true,
            colors: colors,
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: l10n.thisWeek,
            onPressed: () {},
            isSelected: false,
            colors: colors,
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: l10n.thisMonth,
            onPressed: () {},
            isSelected: false,
            colors: colors,
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: l10n.thisYear,
            onPressed: () {},
            isSelected: false,
            colors: colors,
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: l10n.custom,
            onPressed: () {},
            isSelected: false,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;
  final AppColorsValue colors;

  const _PeriodChip({
    required this.label,
    required this.onPressed,
    required this.isSelected,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPressed(),
      backgroundColor: colors.surface,
      selectedColor: colors.primary,
      labelStyle: TextStyle(
        color: isSelected ? colors.charcoal900 : colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: isSelected ? colors.primary : colors.border,
      ),
    );
  }
}

class _SiteFilter extends ConsumerWidget {
  final AppLocalizations l10n;
  final AppColorsValue colors;

  const _SiteFilter({
    required this.l10n,
    required this.colors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSite = ref.watch(selectedSiteProvider);
    final availableSites = ref.watch(availableProjectsProvider);

    return availableSites.when(
      data: (sites) => AppCard(
        child: Row(
          children: [
            Icon(Icons.location_on, color: colors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String?>(
                value: selectedSite,
                underline: SizedBox.shrink(),
                isExpanded: true,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.allSites ?? 'All Sites'),
                  ),
                  ...sites.map((site) => DropdownMenuItem<String?>(
                        value: site['id'] as String,
                        child: Text(site['name'] as String),
                      )),
                ],
                onChanged: (value) {
                  ref.read(selectedSiteProvider.notifier).state = value;
                },
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox(height: 48, child: ShimmerSkeleton()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _KPISection extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final AppColorsValue colors;

  const _KPISection({
    required this.l10n,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCard(
                label: l10n.income,
                value: '2.4M',
                type: 'income',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                label: l10n.expense,
                value: '1.8M',
                type: 'expense',
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
                value: '600K',
                type: 'profit',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                label: l10n.sites ?? 'Sites',
                value: '5',
                type: 'info',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChartsSection extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final AppColorsValue colors;

  const _ChartsSection({
    required this.l10n,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.dashboard),
        const SizedBox(height: 16),
        AppCard(
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Income vs Expense Chart',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(title: l10n.trend ?? 'Daily Trend'),
        const SizedBox(height: 16),
        AppCard(
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Daily Trend Chart',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SiteCardsSection extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final AppColorsValue colors;

  const _SiteCardsSection({
    required this.l10n,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.sites ?? 'Sites'),
        const SizedBox(height: 16),
        // Placeholder site cards
        AppCard(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Site Cards (DHA Villa B-1 550, etc.)',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final AppColorsValue colors;

  const _RecentActivitySection({
    required this.l10n,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.recentActivity ?? 'Recent Activity'),
        const SizedBox(height: 16),
        AppCard(
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Recent Transactions',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
