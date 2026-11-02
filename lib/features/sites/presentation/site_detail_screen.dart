import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/index.dart';
import '../../../l10n/app_localizations.dart';
import '../data/sites_providers.dart';

class SiteDetailScreen extends ConsumerWidget {
  final String siteId;

  const SiteDetailScreen({
    super.key,
    required this.siteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final siteDetail = ref.watch(siteDetailProvider(siteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Details'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: siteDetail.when(
        data: (detail) {
          if (detail == null) {
            return ErrorState(
              error: 'Site not found',
              onRetry: () {
                ref.invalidate(siteDetailProvider(siteId));
              },
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Site header
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail['name'] as String,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: colors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            detail['location'] as String,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (detail['status'] as String).replaceAll('_', ' '),
                          style: TextStyle(color: colors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tabs placeholder
                SectionHeader(title: l10n.overview ?? 'Overview'),
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
                        'Tabs: Overview, Labour, Purchases, Ledger',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () {
            ref.invalidate(siteDetailProvider(siteId));
          },
        ),
      ),
    );
  }
}
