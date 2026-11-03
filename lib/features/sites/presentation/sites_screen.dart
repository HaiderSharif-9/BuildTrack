import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:buildtrack/core/theme/app_theme.dart';
import 'package:buildtrack/core/widgets/index.dart';
import 'package:buildtrack/l10n/app_localizations.dart';
import '../data/sites_providers.dart';

class SitesScreen extends ConsumerWidget {
  const SitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final sites = ref.watch(sitesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sites),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Show add site sheet
            },
          ),
        ],
      ),
      body: sites.when(
        data: (siteList) => siteList.isEmpty
            ? EmptyState(
                icon: Icons.location_off,
                title: l10n.noData,
                description: 'No sites created yet',
                action: 'Add Site',
                onAction: () {
                  // TODO: Show add site sheet
                },
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: siteList.length,
                itemBuilder: (context, index) {
                  final site = siteList[index];
                  return _SiteCard(
                    site: site,
                    onTap: () {
                      context.push('/sites/${site['id']}');
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
            ref.invalidate(sitesListProvider);
          },
        ),
      ),
    );
  }
}

class _SiteCard extends StatelessWidget {
  final Map<String, dynamic> site;
  final VoidCallback onTap;
  final AppColorsValue colors;
  final ThemeData theme;

  const _SiteCard({
    required this.site,
    required this.onTap,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final status = site['status'] as String;
    final statusColor = _getStatusColor(status, colors);

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
                          Icon(Icons.location_on, size: 14, color: colors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              site['location'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
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
                    color: statusColor.withOpacity(0.1),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, AppColorsValue colors) {
    switch (status) {
      case 'planning':
        return colors.warning;
      case 'in_progress':
        return colors.success;
      case 'on_hold':
        return colors.textSecondary;
      case 'completed':
        return colors.info;
      default:
        return colors.textSecondary;
    }
  }
}
