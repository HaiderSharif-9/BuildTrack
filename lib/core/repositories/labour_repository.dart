import '../models/labour.dart';
import 'base_repository.dart';

class LabourRepository extends BaseRepository {
  LabourRepository(super.supabase);

  /// Get a single labour record (name, trade only - public)
  Future<Labour> getLabour(String labourId) async {
    try {
      final response = await supabase
          .from('labour')
          .select()
          .eq('id', labourId)
          .single();

      return Labour.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// List all active labour
  Future<List<Labour>> listLabour() async {
    try {
      final response = await supabase
          .from('labour')
          .select()
          .eq('active', true)
          .order('name');

      return (response as List).map((e) => Labour.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// List labour assigned to a project
  Future<List<Labour>> listProjectLabour(String projectId) async {
    try {
      final response = await supabase
          .from('labour')
          .select('''
            *,
            project_labour!inner(project_id)
          ''')
          .eq('project_labour.project_id', projectId)
          .eq('active', true)
          .order('name');

      return (response as List).map((e) => Labour.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Create new labour (any role can add to their assigned sites)
  Future<Labour> createLabour(Labour labour) async {
    try {
      final response = await supabase
          .from('labour')
          .insert(labour.toJson())
          .select()
          .single();

      return Labour.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Update labour (admin/accountant only)
  Future<Labour> updateLabour(Labour labour) async {
    try {
      final response = await supabase
          .from('labour')
          .update(labour.toJson())
          .eq('id', labour.id)
          .select()
          .single();

      return Labour.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Soft delete labour
  Future<void> deleteLabour(String labourId) async {
    try {
      await supabase
          .from('labour')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', labourId);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}

class LabourPrivateRepository extends BaseRepository {
  LabourPrivateRepository(super.supabase);

  /// Get sensitive labour data (admin/accountant only)
  Future<LabourPrivate> getLabourPrivate(String labourId) async {
    try {
      final response = await supabase
          .from('labour_private')
          .select()
          .eq('labour_id', labourId)
          .single();

      return LabourPrivate.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Update labour private info (admin/accountant only)
  Future<LabourPrivate> updateLabourPrivate(LabourPrivate labourPrivate) async {
    try {
      final response = await supabase
          .from('labour_private')
          .upsert(labourPrivate.toJson())
          .eq('labour_id', labourPrivate.labourId)
          .select()
          .single();

      return LabourPrivate.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}

class ProjectLabourRateRepository extends BaseRepository {
  ProjectLabourRateRepository(super.supabase);

  /// Get rate override for a specific project+labour (admin/accountant only)
  Future<ProjectLabourRate?> getRate(String projectId, String labourId) async {
    try {
      final response = await supabase
          .from('project_labour_rate')
          .select()
          .eq('project_id', projectId)
          .eq('labour_id', labourId)
          .single();

      return ProjectLabourRate.fromJson(response);
    } catch (e) {
      // No override; use default rate
      return null;
    }
  }

  /// Set rate override (admin/accountant only)
  Future<ProjectLabourRate> setRate(ProjectLabourRate rate) async {
    try {
      final response = await supabase
          .from('project_labour_rate')
          .upsert(rate.toJson())
          .eq('project_id', rate.projectId)
          .eq('labour_id', rate.labourId)
          .select()
          .single();

      return ProjectLabourRate.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Remove rate override (use default again)
  Future<void> removeRateOverride(String projectId, String labourId) async {
    try {
      await supabase
          .from('project_labour_rate')
          .delete()
          .eq('project_id', projectId)
          .eq('labour_id', labourId);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}
