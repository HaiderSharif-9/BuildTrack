import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/date_range.dart';
import '../../../core/models/dashboard_summary.dart';
import '../auth/data/auth_providers.dart';
import 'dashboard_repository.dart';

/// Dashboard repository provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

/// Selected date range provider (Today by default)
final selectedDateRangeProvider = StateProvider<DateRange>((ref) {
  return DateRange.today();
});

/// Selected project/site filter (null = all sites)
final selectedSiteProvider = StateProvider<String?>((ref) {
  return null;
});

/// Dashboard summary provider (admin/accountant only)
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  final siteId = ref.watch(selectedSiteProvider);

  final params = dateRange.apiParams;
  return repo.getDashboardSummary(
    from: params['from']!,
    to: params['to']!,
    projectId: siteId,
  );
});

/// Daily trend data for chart
final dailyTrendProvider = FutureProvider<List<DailySummary>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  final siteId = ref.watch(selectedSiteProvider);

  final params = dateRange.apiParams;
  return repo.getDailyTrend(
    from: params['from']!,
    to: params['to']!,
    projectId: siteId,
  );
});

/// Site totals for site cards
final siteTotalsProvider = FutureProvider<List<SiteTotals>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);

  final params = dateRange.apiParams;
  return repo.getSiteTotals(
    from: params['from']!,
    to: params['to']!,
  );
});

/// Available projects/sites for dropdown
final availableProjectsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final userRole = await ref.watch(currentUserRoleProvider.future);

  if (userRole == 'manager') {
    return repo.getManagerSites();
  } else {
    return repo.getProjects();
  }
});

/// Recent activity
final recentActivityProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getRecentActivity(limit: 10);
});
