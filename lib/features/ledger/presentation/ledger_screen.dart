import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/money.dart';
import '../../../core/models/transaction.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_widgets.dart';
import '../data/ledger_providers.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final txAsync = ref.watch(ledgerTransactionsProvider);
    final balance = ref.watch(ledgerBalanceSummaryProvider);
    final typeFilter = ref.watch(ledgerTypeFilterProvider);
    final selectedSite = ref.watch(ledgerSelectedSiteProvider);
    final projectsAsync = ref.watch(ledgerProjectRepoProvider).listProjects();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Financial Ledger'),
        backgroundColor: colors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(ledgerTransactionsProvider.notifier).loadTransactions();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnGold,
        icon: const Icon(Icons.add),
        label: const Text('Add Entry', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddTransactionDialog(context),
      ),
      body: Column(
        children: [
          // 1. Balance Summary Card (Income, Expense, Net)
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net Balance',
                        style: theme.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                      ),
                      Text(
                        '${balance.netBalance.toDisplayString()}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: balance.netBalance.isPositive ? colors.success : colors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.arrow_downward, color: colors.success, size: 16),
                              const SizedBox(width: 4),
                              Text('Total Income', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${balance.totalIncome.toDisplayString()}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: colors.success, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: colors.border),
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.arrow_upward, color: colors.error, size: 16),
                              const SizedBox(width: 4),
                              Text('Total Expense', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${balance.totalExpense.toDisplayString()}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: colors.error, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. Filter Bar (Type and Site)
          Container(
            color: colors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 'all', typeFilter == 'all', colors),
                const SizedBox(width: 8),
                _buildFilterChip('Income', 'income', typeFilter == 'income', colors),
                const SizedBox(width: 8),
                _buildFilterChip('Expense', 'expense', typeFilter == 'expense', colors),
                const Spacer(),
                // Site filter dropdown
                FutureBuilder(
                  future: projectsAsync,
                  builder: (context, snapshot) {
                    final projects = snapshot.data ?? [];
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: selectedSite,
                        dropdownColor: colors.surface,
                        hint: const Text('All Sites', style: TextStyle(fontSize: 12)),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Sites', style: TextStyle(fontSize: 12))),
                          ...projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name, style: const TextStyle(fontSize: 12)))),
                        ],
                        onChanged: (val) {
                          ref.read(ledgerSelectedSiteProvider.notifier).state = val;
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 3. Transactions List
          Expanded(
            child: txAsync.when(
              data: (txList) {
                if (txList.isEmpty) {
                  return const EmptyState(
                    title: 'No Transactions',
                    subtitle: 'No financial entries recorded yet. Tap + Add Entry below.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: txList.length,
                  itemBuilder: (context, index) {
                    final tx = txList[index];
                    final isIncome = tx.isIncome;
                    final dateStr = DateFormat('d MMM yyyy').format(tx.date);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isIncome
                                  ? colors.success.withValues(alpha: 0.15)
                                  : colors.error.withValues(alpha: 0.15),
                              child: Icon(
                                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isIncome ? colors.success : colors.error,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.description.isNotEmpty ? tx.description : 'Transaction',
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$dateStr • Source: ${tx.source.toUpperCase()}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isIncome ? '+' : '-'} ${tx.amount.toDisplayString()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isIncome ? colors.success : colors.error,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _confirmDeleteTx(context, tx),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorState(
                title: 'Error loading ledger',
                message: err.toString(),
                onRetry: () {
                  ref.read(ledgerTransactionsProvider.notifier).loadTransactions();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isSelected, AppColorsValue colors) {
    return GestureDetector(
      onTap: () {
        ref.read(ledgerTypeFilterProvider.notifier).state = value;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : colors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.textOnGold : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteTx(BuildContext context, Transaction tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: Text('Delete "${tx.description}" of ${tx.amount.toDisplayString()}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(ledgerTransactionsProvider.notifier).deleteTransaction(tx.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final pageContext = context;
    String selectedType = 'expense';
    String? selectedCategoryId;
    String? selectedSiteId;
    final amountController = TextEditingController();
    final descController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final categoriesAsync = ref.watch(ledgerCategoriesProvider);

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add Financial Transaction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    // Type selector (Income or Expense)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => selectedType = 'income'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedType == 'income' ? context.appColors.success : context.appColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Income (+)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedType == 'income' ? Colors.white : context.appColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => selectedType = 'expense'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedType == 'expense' ? context.appColors.error : context.appColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Expense (-)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedType == 'expense' ? Colors.white : context.appColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Category dropdown
                    categoriesAsync.when(
                      data: (cats) {
                        final filtered = cats.where((c) => c.type == selectedType).toList();
                        if (filtered.isNotEmpty && (selectedCategoryId == null || !filtered.any((c) => c.id == selectedCategoryId))) {
                          selectedCategoryId = filtered.first.id;
                        }
                        return DropdownButtonFormField<String>(
                          initialValue: selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            filled: true,
                            fillColor: context.appColors.surfaceAlt,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: filtered.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (val) {
                            if (val != null) setSheetState(() => selectedCategoryId = val);
                          },
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) => Text('Error loading categories: $err'),
                    ),
                    const SizedBox(height: 12),
                    // Amount
                    AppTextField(
                      controller: amountController,
                      label: 'Amount (Rs.)',
                      hint: 'e.g. 50000',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    // Description
                    AppTextField(
                      controller: descController,
                      label: 'Description / Note',
                      hint: 'e.g. Client advance for DHA Villa foundation',
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Save Entry',
                      isLoading: isSaving,
                      onPressed: () async {
                        final amt = double.tryParse(amountController.text) ?? 0.0;
                        final desc = descController.text.trim();

                        if (amt <= 0 || selectedCategoryId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid amount and category')),
                          );
                          return;
                        }

                        setSheetState(() => isSaving = true);
                        try {
                          await ref.read(ledgerTransactionsProvider.notifier).addTransaction(
                                type: selectedType,
                                categoryId: selectedCategoryId!,
                                description: desc.isNotEmpty ? desc : selectedType.toUpperCase(),
                                amount: Money.fromDouble(amt),
                                projectId: selectedSiteId,
                                date: DateTime.now(),
                              );
                          if (!pageContext.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(pageContext).showSnackBar(
                            const SnackBar(content: Text('Transaction saved to ledger!'), backgroundColor: Colors.green),
                          );
                        } catch (e) {
                          if (!pageContext.mounted) return;
                          setSheetState(() => isSaving = false);
                          ScaffoldMessenger.of(pageContext).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

