import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/index.dart';
import '../../../l10n/app_localizations.dart';
import '../data/labour_providers.dart';

class LabourScreen extends ConsumerWidget {
  const LabourScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final labour = ref.watch(labourListProvider);
    final searchQuery = ref.watch(labourSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.labour ?? 'Labour'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import from Excel',
            onPressed: () {
              // TODO: Show Excel import sheet
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Show add labour sheet
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: TextEditingController(text: searchQuery),
              label: l10n.search ?? 'Search',
              hint: 'Name or trade',
              icon: Icons.search,
              onChanged: (value) {
                ref.read(labourSearchProvider.notifier).state = value;
              },
            ),
          ),
          // Labour list
          Expanded(
            child: labour.when(
              data: (labourList) => labourList.isEmpty
                  ? EmptyState(
                      icon: Icons.people_outline,
                      title: l10n.noData,
                      description: 'No labour found',
                      action: 'Add Labour',
                      onAction: () {
                        // TODO: Show add labour sheet
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: labourList.length,
                      itemBuilder: (context, index) {
                        final person = labourList[index];
                        return _LabourTile(
                          labour: person,
                          onTap: () {
                            // TODO: Navigate to detail
                          },
                          colors: colors,
                          theme: theme,
                        );
                      },
                    ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => ErrorState(
                error: err.toString(),
                onRetry: () {
                  ref.invalidate(labourListProvider);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabourTile extends StatelessWidget {
  final Labour labour;
  final VoidCallback onTap;
  final AppColorsValue colors;
  final ThemeData theme;

  const _LabourTile({
    required this.labour,
    required this.onTap,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    labour.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: colors.charcoal900,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
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
              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.success.withOpacity(0.1),
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
      ),
    );
  }
}

// Re-export Labour for convenience
export '../../core/models/labour.dart';
