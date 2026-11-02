import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/index.dart';
import '../../../l10n/app_localizations.dart';
import '../data/sites_providers.dart';

class SitesScreen extends ConsumerWidget {
  const SitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sites = ref.watch(sitesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sites ?? 'Sites'),
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

  const _SiteCard({
    required this.site,
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
