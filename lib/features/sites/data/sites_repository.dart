import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/project.dart';
import '../../core/models/money.dart';

class SitesRepository {
  final _supabase = Supabase.instance.client;

  /// Get all sites with finance data (admin/accountant only)
  Future<List<Map<String, dynamic>>> getSitesWithFinance() async {
    try {
      final response = await _supabase
          .from('projects')
          .select('''
            id, name, location, client_id, start_date, end_date, status,
            created_at, updated_at, deleted_at,
            project_finance(budget)
          ''')
          .eq('deleted_at', null)
          .order('name');

      return (response as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error fetching sites: $e');
    }
  }

  /// Get sites assigned to current manager
  Future<List<Project>> getManagerSites() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final response = await _supabase
          .from('project_members')
          .select('''
            projects(
              id, name, location, client_id, start_date, end_date, status,
              created_at, updated_at, deleted_at
            )
          ''')
          .eq('user_id', userId)
          .order('projects(name)');

      return (response as List)
          .where((item) => item['projects'] != null)
          .map((item) => Project.fromJson(item['projects'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching manager sites: $e');
    }
  }

  /// Get single site with finance data
  Future<Map<String, dynamic>?> getSiteDetail(String siteId) async {
    try {
      final response = await _supabase
          .from('projects')
          .select('''
            id, name, location, client_id, start_date, end_date, status,
            created_at, updated_at, deleted_at,
            project_finance(budget),
            clients(id, name, phone, address)
          ''')
          .eq('id', siteId)
          .eq('deleted_at', null)
          .maybeSingle();

      return response as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Error fetching site detail: $e');
    }
  }

  /// Create site
  Future<Project> createSite({
    required String name,
    required String location,
    required String status,
    String? clientId,
    DateTime? startDate,
    DateTime? endDate,
    required Money budget,
  }) async {
    try {
      // Create project
      final projectResponse = await _supabase
          .from('projects')
          .insert({
            'name': name,
            'location': location,
            'client_id': clientId,
            'start_date': startDate?.toIso8601String(),
            'end_date': endDate?.toIso8601String(),
            'status': status,
          })
          .select()
          .single();

      final projectId = projectResponse['id'] as String;

      // Create project_finance
      await _supabase.from('project_finance').insert({
        'project_id': projectId,
        'budget': budget.toDbString(),
      });

      return Project.fromJson(projectResponse as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error creating site: $e');
    }
  }

  /// Update site
  Future<Project> updateSite({
    required String id,
    required String name,
    required String location,
    required String status,
    String? clientId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _supabase
          .from('projects')
          .update({
            'name': name,
            'location': location,
            'client_id': clientId,
            'start_date': startDate?.toIso8601String(),
            'end_date': endDate?.toIso8601String(),
            'status': status,
          })
          .eq('id', id)
          .select()
          .single();

      return Project.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error updating site: $e');
    }
  }

  /// Update site budget
  Future<void> updateSiteBudget(String siteId, Money budget) async {
    try {
      await _supabase
          .from('project_finance')
          .update({'budget': budget.toDbString()})
          .eq('project_id', siteId);
    } catch (e) {
      throw Exception('Error updating budget: $e');
    }
  }

  /// Soft delete site
  Future<void> deleteSite(String id) async {
    try {
      await _supabase
          .from('projects')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw Exception('Error deleting site: $e');
    }
  }

  /// Assign manager to site
  Future<void> assignManager(String siteId, String userId) async {
    try {
      await _supabase.from('project_members').insert({
        'project_id': siteId,
        'user_id': userId,
      });
    } catch (e) {
      throw Exception('Error assigning manager: $e');
    }
  }

  /// Remove manager from site
  Future<void> removeManager(String siteId, String userId) async {
    try {
      await _supabase
          .from('project_members')
          .delete()
          .eq('project_id', siteId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Error removing manager: $e');
    }
  }
}
