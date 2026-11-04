import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/money.dart';
import '../../../core/models/purchase.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_widgets.dart';
import '../data/purchases_providers.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final purchases = ref.watch(filteredPurchasesProvider);
    final totalAmount = ref.watch(purchasesTotalAmountProvider);
    final purchasesAsync = ref.watch(purchasesListProvider);
    final projectsAsync = ref.watch(purchasesProjectRepoProvider).listProjects();
    final selectedSite = ref.watch(purchasesSelectedSiteProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Material Purchases'),
        backgroundColor: colors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(purchasesListProvider.notifier).loadPurchases();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnGold,
        icon: const Icon(Icons.add),
        label: const Text('Add Purchase', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddEditPurchaseDialog(context, null),
      ),
      body: Column(
        children: [
          // 1. Site Filter and Search Bar
          Container(
            color: colors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Site Dropdown Filter
                FutureBuilder(
                  future: projectsAsync,
                  builder: (context, snapshot) {
                    final projects = snapshot.data ?? [];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: selectedSite,
                          dropdownColor: colors.surface,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Sites / Projects', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            ...projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                          ],
                          onChanged: (val) {
                            ref.read(purchasesSelectedSiteProvider.notifier).state = val;
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Search field
                AppTextField(
                  controller: _searchController,
                  label: '',
                  hint: 'Search item (e.g. Cement, Steel, Bricks)',
                  prefixIcon: Icons.search,
                  onChanged: (val) {
                    ref.read(purchasesSearchProvider.notifier).state = val;
                  },
                ),
              ],
            ),
          ),

          // 2. Summary KPI card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Purchases', style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        'Rs. ${totalAmount.toDisplayString()}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.error,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${purchases.length} Items',
                      style: TextStyle(fontWeight: FontWeight.bold, color: colors.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Purchases List
          Expanded(
            child: purchasesAsync.when(
              data: (_) {
                if (purchases.isEmpty) {
                  return const EmptyState(
                    title: 'No Purchases Recorded',
                    subtitle: 'Tap the + Add Purchase button below to record material bills',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: purchases.length,
                  itemBuilder: (context, index) {
                    final item = purchases[index];
                    final dateStr = DateFormat('d MMM yyyy').format(item.date);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.item,
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.qty.toStringAsFixed(1)} ${item.unit} @ Rs. ${item.rate.toDisplayString()}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateStr,
                                    style: theme.textTheme.bodySmall?.copyWith(color: colors.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs. ${item.amount.toDisplayString()}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.error,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 18),
                                  padding: EdgeInsets.zero,
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showAddEditPurchaseDialog(context, item);
                                    } else if (val == 'delete') {
                                      _confirmDelete(context, item);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
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
                title: 'Error loading purchases',
                message: err.toString(),
                onRetry: () {
                  ref.read(purchasesListProvider.notifier).loadPurchases();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Purchase item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Purchase?'),
        content: Text('Are you sure you want to delete "${item.item}" (Rs. ${item.amount.toDisplayString()})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(purchasesListProvider.notifier).deletePurchase(item.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddEditPurchaseDialog(BuildContext context, Purchase? existing) {
    final pageContext = context;
    final isEditing = existing != null;
    final itemController = TextEditingController(text: existing?.item ?? '');
    final qtyController = TextEditingController(text: existing != null ? existing.qty.toString() : '');
    final rateController = TextEditingController(text: existing != null ? existing.rate.toDisplayString() : '');
    String selectedUnit = existing?.unit ?? 'Bag';
    String? selectedSiteId = existing?.projectId ?? ref.read(purchasesSelectedSiteProvider);
    DateTime selectedDate = existing?.date ?? DateTime.now();
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
            final qty = double.tryParse(qtyController.text) ?? 0.0;
            final rate = double.tryParse(rateController.text) ?? 0.0;
            final computedTotal = qty * rate;

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Purchase' : 'Add Material Purchase',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Project Dropdown
                    FutureBuilder(
                      future: ref.read(purchasesProjectRepoProvider).listProjects(),
                      builder: (context, snapshot) {
                        final projects = snapshot.data ?? [];
                        if (selectedSiteId == null && projects.isNotEmpty) {
                          selectedSiteId = projects.first.id;
                        }
                        return DropdownButtonFormField<String>(
                          initialValue: selectedSiteId,
                          decoration: InputDecoration(
                            labelText: 'Site / Project',
                            filled: true,
                            fillColor: context.appColors.surfaceAlt,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                          onChanged: (val) {
                            if (val != null) setSheetState(() => selectedSiteId = val);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Item Name
                    AppTextField(
                      controller: itemController,
                      label: 'Item Name',
                      hint: 'e.g. Cement, Steel 60 grade, Red Bricks',
                    ),
                    const SizedBox(height: 12),
                    // Qty and Unit
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: qtyController,
                            label: 'Quantity',
                            hint: 'e.g. 50',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setSheetState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedUnit,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              filled: true,
                              fillColor: context.appColors.surfaceAlt,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: ['Bag', 'Pcs', 'Kg', 'Trolley', 'Ton', 'Ft', 'Lot']
                                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setSheetState(() => selectedUnit = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Rate (unit price)
                    AppTextField(
                      controller: rateController,
                      label: 'Rate per Unit (Rs.)',
                      hint: 'e.g. 1450',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: 12),
                    // Computed Total Amount display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: context.appColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.appColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'Rs. ${computedTotal.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: context.appColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: isEditing ? 'Update Purchase' : 'Save Purchase',
                      isLoading: isSaving,
                      onPressed: () async {
                        final item = itemController.text.trim();
                        final qty = double.tryParse(qtyController.text) ?? 0.0;
                        final rate = double.tryParse(rateController.text) ?? 0.0;

                        if (item.isEmpty || qty <= 0 || rate <= 0 || selectedSiteId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all fields with valid numbers')),
                          );
                          return;
                        }

                        setSheetState(() => isSaving = true);
                        try {
                          if (isEditing) {
                            await ref.read(purchasesListProvider.notifier).updatePurchase(
                                  id: existing.id,
                                  item: item,
                                  qty: qty,
                                  unit: selectedUnit,
                                  rate: Money.fromInt(rate.round()),
                                  date: selectedDate,
                                );
                          } else {
                            await ref.read(purchasesListProvider.notifier).addPurchase(
                                  projectId: selectedSiteId!,
                                  item: item,
                                  qty: qty,
                                  unit: selectedUnit,
                                  rate: Money.fromInt(rate.round()),
                                  date: selectedDate,
                                );
                          }
                          if (!pageContext.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(pageContext).showSnackBar(
                            SnackBar(
                              content: Text('Purchase of "$item" saved successfully!'),
                              backgroundColor: Colors.green,
                            ),
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

