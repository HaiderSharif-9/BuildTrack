import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/dashboard_summary.dart';

class DashboardRepository {
  final _supabase = Supabase.instance.client;

  /// Get dashboard summary (admin/accountant only)
  Future<DashboardSummary> getDashboardSummary({
    required String from,
    required String to,
    String? projectId,
  }) async {
    try {
      final params = {
        'from': from,
        'to': to,
        if (projectId != null) 'project': projectId,
      };

      final response = await _supabase.rpc('dashboard_summary', params: params);

      if (response == null) {
        throw Exception('Failed to fetch dashboard summary');
      }

      // Response is already a Map
      final data = response as Map<String, dynamic>;
      return DashboardSummary.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching dashboard summary: $e');
    }
  }

  /// Get daily trend data for charts
  Future<List<DailySummary>> getDailyTrend({
    required String from,
    required String to,
    String? projectId,
  }) async {
    try {
      final params = {
        'from': from,
        'to': to,
        if (projectId != null) 'project': projectId,
      };

      final response =
          await _supabase.rpc('daily_trend', params: params) as List;

      return response
          .map((item) => DailySummary.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching daily trend: $e');
    }
  }

  /// Get site totals for the period
  Future<List<SiteTotals>> getSiteTotals({
    required String from,
    required String to,
  }) async {
    try {
      final params = {
        'from': from,
        'to': to,
      };

      final response = await _supabase.rpc('site_totals', params: params) as List;

      return response
          .map((item) => SiteTotals.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching site totals: $e');
    }
  }

  /// Get all projects (for site dropdown)
  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final response = await _supabase
          .from('projects')
          .select('id, name, status')
          .isFilter('deleted_at', null)
          .order('name');

      return (response as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  /// Get manager's assigned sites only
  Future<List<Map<String, dynamic>>> getManagerSites() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final response = await _supabase
          .from('project_members')
          .select('project_id, projects(id, name, status)')
          .eq('user_id', userId)
          .isFilter('projects.deleted_at', null)
          .order('projects(name)');

      return (response as List)
          .map((item) => (item['projects'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching manager sites: $e');
    }
  }

  /// Get recent activity (transactions + wage payments)
  Future<List<Map<String, dynamic>>> getRecentActivity({
    int limit = 10,
    String? projectId,
  }) async {
    try {
      var query = _supabase
          .from('transactions')
          .select(
              'id, date, type, category_id, description, amount, categories(name)')
          .isFilter('deleted_at', null);

      if (projectId != null) {
        query = query.eq('project_id', projectId);
      }

      final response = await query
          .order('date', ascending: false)
          .limit(limit);

      return (response as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error fetching recent activity: $e');
    }
  }
}
