import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/money.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_widgets.dart';
import '../data/payments_providers.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final period = ref.watch(payrollPeriodProvider);
    final periodFilter = ref.watch(paymentsPeriodFilterProvider);
    final selectedSite = ref.watch(paymentsSelectedSiteProvider);
    final projectsAsync = ref.watch(paymentsProjectsProvider);
    final payrollAsync = ref.watch(payrollProvider);
    final summary = ref.watch(payrollSummaryProvider);

    final startFormat = DateFormat('EEE d MMM').format(period.start);
    final endFormat = DateFormat('EEE d MMM yyyy').format(period.end);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Weekly Payroll'),
        backgroundColor: colors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(payrollProvider.notifier).loadPayroll();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Payroll totals can be viewed across all sites, but a payment
          // must always be assigned to one explicit site.
          Container(
            color: colors.surface,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: projectsAsync.when(
              data: (projects) => DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: selectedSite,
                  hint: const Text('Select site'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Sites (view only)'),
                    ),
                    ...projects.map(
                      (project) => DropdownMenuItem<String?>(
                        value: project.id,
                        child: Text(project.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    ref.read(paymentsSelectedSiteProvider.notifier).state = value;
                  },
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Unable to load sites: $error'),
            ),
          ),
          if (selectedSite == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Select a specific site to enable wage payments.',
                style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ),
          // 1. Period Selector & Date Range Banner
          Container(
            color: colors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterChip('This week', 'this_week', periodFilter == 'this_week', colors),
                    const SizedBox(width: 8),
                    _buildFilterChip('Last week', 'last_week', periodFilter == 'last_week', colors),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$startFormat — $endFormat',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // 2. Thursday Payout Reminder Banner (as in Figma)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primary.withValues(alpha: 0.15),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.goldTextLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Wages are calculated Fri-Thu. Standard payouts scheduled on Thursday.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: AppColors.goldTextLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Worker Payroll List
          Expanded(
            child: payrollAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    title: 'No Labourers',
                    subtitle: 'No active labourers found for payroll',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildWorkerPayrollCard(item, colors, theme, canRecordPayment: selectedSite != null);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorState(
                title: 'Error loading payroll',
                message: err.toString(),
                onRetry: () {
                  ref.read(payrollProvider.notifier).loadPayroll();
                },
              ),
            ),
          ),

          // 4. Sticky Bottom Total Payable Bar
          _buildBottomPayableBar(summary, colors, theme),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isSelected, AppColorsValue colors) {
    return GestureDetector(
      onTap: () {
        ref.read(paymentsPeriodFilterProvider.notifier).state = value;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : colors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.textOnGold : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerPayrollCard(
    WorkerPayrollItem item,
    AppColorsValue colors,
    ThemeData theme, {
    required bool canRecordPayment,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Worker avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    item.labour.name.isNotEmpty ? item.labour.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textOnGold),
                  ),
                ),
                const SizedBox(width: 12),
                // Worker Name & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.labour.name,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.daysWorked} days • ${item.overtimeHours.toStringAsFixed(1)}h OT • Rate: Rs. ${item.defaultRate.toDisplayString()}',
                        style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                      ),
                      if (item.advancesDeducted > Money.zero) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Advance deducted: -Rs. ${item.advancesDeducted.toDisplayString()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Net Payable Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ${item.netPayable.toDisplayString()}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Gross: ${item.grossWage.toDisplayString()}',
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Payment Action or Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                item.isPaid
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 14, color: colors.success),
                            const SizedBox(width: 4),
                            Text(
                              'Paid • ${(item.paymentRecord?.method ?? 'cash').toUpperCase()}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colors.success,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Unpaid',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.warning,
                          ),
                        ),
                      ),
                if (canRecordPayment && !item.isPaid && item.netPayable > Money.zero)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.payment, size: 16, color: AppColors.goldTextLight),
                    label: const Text(
                      'Mark Paid',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldTextLight),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    ),
                    onPressed: () => _showMarkPaidDialog(item),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog to select payment method and record payment
  void _showMarkPaidDialog(WorkerPayrollItem item) {
    final pageContext = context;
    String selectedMethod = 'Cash';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Record Wage Payment\n${item.labour.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gross Wages: Rs. ${item.grossWage.toDisplayString()}'),
                  if (item.advancesDeducted > Money.zero)
                    Text('Advance Deducted: -Rs. ${item.advancesDeducted.toDisplayString()}'),
                  const SizedBox(height: 8),
                  Text(
                    'Net Payable: Rs. ${item.netPayable.toDisplayString()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text('Payment Method:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedMethod,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.appColors.surfaceAlt,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: ['Cash', 'Bank Transfer', 'EasyPaisa', 'JazzCash']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedMethod = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                AppButton(
                  label: 'Confirm Payment',
                  isLoading: isSubmitting,
                  onPressed: () async {
                    setDialogState(() => isSubmitting = true);
                    try {
                      await ref.read(payrollProvider.notifier).markPaid(
                            labourId: item.labour.id,
                            gross: item.grossWage,
                            advance: item.advancesDeducted,
                            method: selectedMethod,
                          );
                      if (!pageContext.mounted) return;
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(pageContext).showSnackBar(
                        SnackBar(
                          content: Text('Payment of Rs. ${item.netPayable.toDisplayString()} recorded!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!pageContext.mounted) return;
                      setDialogState(() => isSubmitting = false);
                      ScaffoldMessenger.of(pageContext).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Sticky Bottom Summary
  Widget _buildBottomPayableBar(PayrollSummary summary, AppColorsValue colors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Payable',
                  style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
                Text(
                  'Rs. ${summary.totalNetPayable.toDisplayString()}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: Text(
                '${summary.paidCount} Paid • ${summary.unpaidCount} Pending',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

