import '../models/project.dart';
import 'base_repository.dart';

class ProjectRepository extends BaseRepository {
  ProjectRepository(super.supabase);

  /// Get a single project by ID
  Future<Project> getProject(String projectId) async {
    try {
      final response = await supabase
          .from('projects')
          .select()
          .eq('id', projectId)
          .single();

      return Project.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// List all active projects (excluding soft-deleted)
  Future<List<Project>> listProjects({
    String? status, // optional filter: planning, in_progress, on_hold, completed
  }) async {
    try {
      var query = supabase
          .from('projects')
          .select();

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('name');
      return (response as List).map((e) => Project.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// List projects assigned to current manager
  Future<List<Project>> listMyProjects() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final response = await supabase
          .from('projects')
          .select('''
            *,
            project_members!inner(user_id)
          ''')
          .eq('project_members.user_id', userId)
          .order('name');

      return (response as List).map((e) => Project.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Create a new project (admin/accountant)
  Future<Project> createProject(Project project) async {
    try {
      final response = await supabase
          .from('projects')
          .insert(project.toJson())
          .select()
          .single();

      return Project.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Update project (admin/accountant)
  Future<Project> updateProject(Project project) async {
    try {
      final response = await supabase
          .from('projects')
          .update(project.toJson())
          .eq('id', project.id)
          .select()
          .single();

      return Project.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Soft delete project
  Future<void> deleteProject(String projectId) async {
    try {
      await supabase
          .from('projects')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', projectId);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}

class ProjectFinanceRepository extends BaseRepository {
  ProjectFinanceRepository(super.supabase);

  /// Get budget and finance info for a project (admin/accountant only)
  Future<ProjectFinance?> getProjectFinance(String projectId) async {
    try {
      final response = await supabase
          .from('project_finance')
          .select()
          .eq('project_id', projectId)
          .single();

      return ProjectFinance.fromJson(response);
    } catch (e) {
      // Budget entry may not exist yet
      return null;
    }
  }

  /// Update project budget (admin/accountant only)
  Future<ProjectFinance> updateBudget(String projectId, ProjectFinance finance) async {
    try {
      final response = await supabase
          .from('project_finance')
          .upsert(finance.toJson())
          .eq('project_id', projectId)
          .select()
          .single();

      return ProjectFinance.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}
