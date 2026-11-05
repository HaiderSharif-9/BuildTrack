import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/money.dart';
import '../../auth/data/auth_providers.dart';
import '../../../core/widgets/index.dart';
import '../../../l10n/app_localizations.dart';
import '../data/sites_providers.dart';

class SitesScreen extends ConsumerWidget {
  const SitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sites = ref.watch(sitesListProvider);
    final role = ref.watch(currentUserRoleProvider).asData?.value;
    final canManage = role == 'admin' || role == 'accountant';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sites),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (canManage)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add site',
              onPressed: () => _showAddSiteDialog(context, ref),
            ),
        ],
      ),
      body: sites.when(
        data: (siteList) => siteList.isEmpty
            ? EmptyState(
                
                title: l10n.noData,
                subtitle: 'No sites created yet',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: siteList.length,
                itemBuilder: (context, index) {
                  final site = siteList[index];
                  return _SiteCard(
                    site: site,
                    canManage: canManage,
                    onDelete: () => _confirmArchiveSite(context, ref, site),
                    onTap: () {
                      context.push('/sites/${site['id']}');
                    },
                  );
                },
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => ErrorState(
          title: l10n.error,
          message: err.toString(),
          onRetry: () {
            ref.invalidate(sitesListProvider);
          },
        ),
      ),
    );
  }
}


Future<void> _confirmArchiveSite(BuildContext context, WidgetRef ref, Map<String, dynamic> site) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Archive Site?'),
      content: Text('Archive ${site['name']}? The site will disappear from active lists, while its attendance, purchases and financial history will be preserved.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Archive', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await ref.read(sitesRepositoryProvider).deleteSite(site['id'] as String);
    if (!context.mounted) return;
    ref.invalidate(sitesListProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Site archived. Historical records were preserved.')),
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not archive site: $error')),
    );
  }
}

Future<void> _showAddSiteDialog(BuildContext context, WidgetRef ref) async {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final budgetController = TextEditingController();
  String status = 'planning';

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Text('Add Construction Site'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: nameController, label: 'Site name'),
              const SizedBox(height: 12),
              AppTextField(controller: locationController, label: 'Location'),
              const SizedBox(height: 12),
              AppTextField(
                controller: budgetController,
                label: 'Project budget (Rs.)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'planning', child: Text('Planning')),
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'on_hold', child: Text('On Hold')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                ],
                onChanged: (value) {
                  if (value != null) setDialogState(() => status = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final location = locationController.text.trim();
              final budgetText = budgetController.text.trim();
              final budget = double.tryParse(budgetText);
              if (name.isEmpty || location.isEmpty || budget == null || budget <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a site name, location and valid budget.')),
                );
                return;
              }
              try {
                await ref.read(sitesRepositoryProvider).createSite(
                  name: name,
                  location: location,
                  status: status,
                  budget: Money.fromString(budgetText),
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                ref.invalidate(sitesListProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Site created successfully.')),
                );
              } catch (error) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Could not create site: $error')),
                );
              }
            },
            child: const Text('Create Site'),
          ),
        ],
      ),
    ),
  );

  nameController.dispose();
  locationController.dispose();
  budgetController.dispose();
}

class _SiteCard extends StatelessWidget {
  final Map<String, dynamic> site;
  final bool canManage;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SiteCard({
    required this.site,
    required this.canManage,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = site['status'] as String;
    final statusColor = _getStatusColor(status, isDark);

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site['name'] as String,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              site['location'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    border: Border.all(color: statusColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                    ),
                  ),
                ),
                if (canManage)
                  PopupMenuButton<String>(
                    tooltip: 'Site actions',
                    onSelected: (value) {
                      if (value == 'archive') onDelete();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'archive',
                        child: Text('Archive site', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status) {
      case 'planning':
        return AppColors.warning;
      case 'in_progress':
        return AppColors.income;
      case 'on_hold':
        return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
      case 'completed':
        return AppColors.primary;
      default:
        return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    }
  }
}
