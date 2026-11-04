import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/labour.dart';
import '../../../core/models/money.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_providers.dart';
import '../data/labour_providers.dart';

class LabourScreen extends ConsumerWidget {
  const LabourScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final labour = ref.watch(labourListProvider);
    final searchQuery = ref.watch(labourSearchProvider);
    final colors = context.appColors;
    final role = ref.watch(currentUserRoleProvider).asData?.value;
    final canManage = role == 'admin' || role == 'accountant';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.labour),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (canManage)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              tooltip: 'Add labourer',
              onPressed: () => _showAddLabourDialog(context, ref),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: TextEditingController(text: searchQuery),
              label: l10n.search,
              hint: 'Name or trade',
              prefixIcon: Icons.search,
              onChanged: (value) {
                ref.read(labourSearchProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: labour.when(
              data: (labourList) => labourList.isEmpty
                  ? EmptyState(
                      title: l10n.noData,
                      subtitle: canManage
                          ? 'Add labourers and assign them to a construction site.'
                          : 'No labourers are assigned to your sites.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: labourList.length,
                      itemBuilder: (context, index) {
                        final person = labourList[index];
                        return _LabourTile(
                          labour: person,
                          colors: colors,
                          theme: theme,
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => ErrorState(
                title: l10n.error,
                message: err.toString(),
                onRetry: () => ref.invalidate(labourListProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLabourDialog(BuildContext context, WidgetRef ref) {
    final pageContext = context;
    final nameController = TextEditingController();
    final tradeController = TextEditingController();
    final phoneController = TextEditingController();
    final cnicController = TextEditingController();
    final rateController = TextEditingController();
    final projectsFuture = ref.read(labourProjectsProvider.future);
    String? selectedProjectId;
    bool isSaving = false;

    showModalBottomSheet<void>(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: pageContext.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Labourer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: nameController,
                    label: 'Full Name',
                    hint: 'e.g. Muhammad Ali',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: tradeController,
                    label: 'Trade',
                    hint: 'e.g. Mason, Electrician, Helper',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: phoneController,
                    label: 'Phone (optional)',
                    hint: '03XX-XXXXXXX',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: cnicController,
                    label: 'CNIC (optional)',
                    hint: 'XXXXX-XXXXXXX-X',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: rateController,
                    label: 'Default Daily Rate (Rs.)',
                    hint: 'e.g. 1200',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder(
                    future: projectsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Unable to load sites: ${snapshot.error}');
                      }
                      final projects = snapshot.data ?? [];
                      if (projects.isEmpty) {
                        return const Text('Create a site before adding labourers.');
                      }
                      if (selectedProjectId == null ||
                          !projects.any((project) => project.id == selectedProjectId)) {
                        selectedProjectId = projects.first.id;
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: selectedProjectId,
                        decoration: InputDecoration(
                          labelText: 'Assign to Site',
                          filled: true,
                          fillColor: context.appColors.surfaceAlt,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: projects
                            .map(
                              (project) => DropdownMenuItem<String>(
                                value: project.id,
                                child: Text(project.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setSheetState(() => selectedProjectId = value);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Save Labourer',
                    isLoading: isSaving,
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final trade = tradeController.text.trim();
                      final phone = phoneController.text.trim();
                      final cnic = cnicController.text.trim();
                      final rate = double.tryParse(rateController.text.trim());

                      if (name.isEmpty ||
                          trade.isEmpty ||
                          rate == null ||
                          rate <= 0 ||
                          selectedProjectId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enter name, trade, a valid daily rate and select a site.'),
                          ),
                        );
                        return;
                      }

                      setSheetState(() => isSaving = true);
                      try {
                        final repository = ref.read(labourRepositoryProvider);
                        final hasDuplicate = await repository.hasDuplicateByPhoneOrCnic(
                          phone: phone.isEmpty ? null : phone,
                          cnic: cnic.isEmpty ? null : cnic,
                        );
                        if (hasDuplicate) {
                          throw StateError('A labourer with this phone or CNIC already exists.');
                        }

                        await repository.createLabour(
                          name: name,
                          trade: trade,
                          phone: phone.isEmpty ? null : phone,
                          cnic: cnic.isEmpty ? null : cnic,
                          defaultRate: Money.fromDouble(rate),
                          projectId: selectedProjectId,
                        );

                        if (!pageContext.mounted) return;
                        Navigator.pop(sheetContext);
                        ref.invalidate(labourListProvider);
                        ScaffoldMessenger.of(pageContext).showSnackBar(
                          SnackBar(
                            content: Text('$name added and assigned to the selected site.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (error) {
                        if (!pageContext.mounted) return;
                        setSheetState(() => isSaving = false);
                        ScaffoldMessenger.of(pageContext).showSnackBar(
                          SnackBar(
                            content: Text('Unable to add labourer: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      nameController.dispose();
      tradeController.dispose();
      phoneController.dispose();
      cnicController.dispose();
      rateController.dispose();
    });
  }
}

class _LabourTile extends StatelessWidget {
  final Labour labour;
  final AppColorsValue colors;
  final ThemeData theme;

  const _LabourTile({
    required this.labour,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final initial = labour.name.isNotEmpty ? labour.name.substring(0, 1).toUpperCase() : '?';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    color: colors.charcoal900,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labour.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labour.trade,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Active',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
