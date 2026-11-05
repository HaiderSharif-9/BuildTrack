import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/money.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/index.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_providers.dart';
import '../data/sites_providers.dart';

class SiteDetailScreen extends ConsumerWidget {
  final String siteId;

  const SiteDetailScreen({super.key, required this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final siteDetail = ref.watch(siteDetailProvider(siteId));
    final role = ref.watch(currentUserRoleProvider).asData?.value;
    final canManage = role == 'admin' || role == 'accountant';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Details'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (canManage)
            IconButton(
              tooltip: 'Edit site',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final detail = ref.read(siteDetailProvider(siteId)).asData?.value;
                if (detail != null) {
                  await _showEditSiteDialog(context, ref, detail);
                }
              },
            ),
        ],
      ),
      body: siteDetail.when(
        data: (detail) {
          if (detail == null) {
            return ErrorState(
              title: l10n.error,
              message: 'Site not found',
              onRetry: () => ref.invalidate(siteDetailProvider(siteId)),
            );
          }

          final financeRaw = detail['project_finance'];
          final finance = financeRaw is List
              ? (financeRaw.isNotEmpty ? financeRaw.first as Map<String, dynamic> : null)
              : financeRaw as Map<String, dynamic>?;
          final budgetRaw = finance?['budget'];
          final budget = budgetRaw == null
              ? 'Not set'
              : Money.fromString(budgetRaw.toString()).toDisplayString();
          final clientRaw = detail['clients'];
          final client = clientRaw is Map<String, dynamic> ? clientRaw : null;
          final status = (detail['status'] as String? ?? 'planning');
          final startDate = _formatDate(detail['start_date']);
          final endDate = _formatDate(detail['end_date']);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(detail['name'] as String? ?? 'Unnamed site',
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(detail['location'] as String? ?? 'Location not set',
                              style: theme.textTheme.bodyMedium)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _StatusPill(status: status),
                      if (canManage) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _showEditSiteDialog(context, ref, detail),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit site details / status'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: 'Overview'),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    children: [
                      _DetailRow(icon: Icons.account_balance_wallet_outlined,
                          label: 'Project budget', value: budget),
                      const Divider(height: 22),
                      _DetailRow(icon: Icons.person_outline,
                          label: 'Client', value: client?['name']?.toString() ?? 'Not assigned'),
                      if ((client?['phone']?.toString() ?? '').isNotEmpty) ...[
                        const Divider(height: 22),
                        _DetailRow(icon: Icons.phone_outlined,
                            label: 'Client phone', value: client!['phone'].toString()),
                      ],
                      if ((client?['address']?.toString() ?? '').isNotEmpty) ...[
                        const Divider(height: 22),
                        _DetailRow(icon: Icons.home_outlined,
                            label: 'Client address', value: client!['address'].toString()),
                      ],
                      const Divider(height: 22),
                      _DetailRow(icon: Icons.calendar_today_outlined,
                          label: 'Start date', value: startDate),
                      const Divider(height: 22),
                      _DetailRow(icon: Icons.event_outlined,
                          label: 'Expected completion', value: endDate),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SectionHeader(title: 'Site status'),
                const SizedBox(height: 8),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_statusDescription(status), style: theme.textTheme.bodyMedium),
                      if (canManage) ...[
                        const SizedBox(height: 10),
                        const Text('Status is updated manually by an Admin or Accountant using Edit Site.'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(
          title: l10n.error,
          message: err.toString(),
          onRetry: () => ref.invalidate(siteDetailProvider(siteId)),
        ),
      ),
    );
  }
}

Future<void> _showEditSiteDialog(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic> site,
) async {
  final nameController = TextEditingController(text: site['name']?.toString() ?? '');
  final locationController = TextEditingController(text: site['location']?.toString() ?? '');
  String status = site['status']?.toString() ?? 'planning';

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Text('Edit Site'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: nameController, label: 'Site name'),
              const SizedBox(height: 12),
              AppTextField(controller: locationController, label: 'Location'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Site status'),
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
              if (name.isEmpty || location.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Site name and location are required.')),
                );
                return;
              }
              try {
                await ref.read(sitesRepositoryProvider).updateSite(
                  id: site['id'] as String,
                  name: name,
                  location: location,
                  status: status,
                  clientId: site['client_id'] as String?,
                  startDate: _parseDate(site['start_date']),
                  endDate: _parseDate(site['end_date']),
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                ref.invalidate(siteDetailProvider(site['id'] as String));
                ref.invalidate(sitesListProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Site details updated successfully.')),
                );
              } catch (error) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Could not update site: $error')),
                );
              }
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    ),
  );

  nameController.dispose();
  locationController.dispose();
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String _formatDate(dynamic value) {
  if (value == null || value.toString().isEmpty) return 'Not set';
  final date = DateTime.tryParse(value.toString());
  if (date == null) return 'Not set';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _statusDescription(String status) {
  switch (status) {
    case 'planning':
      return 'Preparation stage. Work has not officially started yet.';
    case 'in_progress':
      return 'Construction is currently active.';
    case 'on_hold':
      return 'Work is temporarily paused. Change back to In Progress when work resumes.';
    case 'completed':
      return 'The project has been marked as finished.';
    default:
      return 'Current site status: $status';
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'planning' => AppColors.warning,
      'in_progress' => AppColors.income,
      'on_hold' => AppColors.lightTextSecondary,
      'completed' => AppColors.primary,
      _ => AppColors.lightTextSecondary,
    };
    final label = switch (status) {
      'planning' => 'Planning',
      'in_progress' => 'In Progress',
      'on_hold' => 'On Hold',
      'completed' => 'Completed',
      _ => status,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 3),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        )),
      ],
    );
  }
}
