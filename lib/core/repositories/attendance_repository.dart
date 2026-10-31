import '../models/attendance.dart';
import 'base_repository.dart';

class AttendanceRepository extends BaseRepository {
  AttendanceRepository(super.supabase);

  /// Get a single attendance record
  Future<Attendance> getAttendance(String attendanceId) async {
    try {
      final response = await supabase
          .from('attendance')
          .select()
          .eq('id', attendanceId)
          .single();

      return Attendance.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Get attendance for a labourer on a specific date
  Future<Attendance?> getAttendanceForDate(String labourId, DateTime date) async {
    try {
      final response = await supabase
          .from('attendance')
          .select()
          .eq('labour_id', labourId)
          .eq('date', date.toIso8601String().split('T')[0])
          .maybeSingle();

      if (response == null) return null;
      return Attendance.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// List attendance for a project on a specific date
  Future<List<Attendance>> getAttendanceForProjectDate(String projectId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await supabase
          .from('attendance')
          .select()
          .eq('project_id', projectId)
          .eq('date', dateStr)
          .order('labour_id');

      return (response as List).map((e) => Attendance.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// List attendance for a date range
  Future<List<Attendance>> listAttendanceForRange(
    String projectId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];

      final response = await supabase
          .from('attendance')
          .select()
          .eq('project_id', projectId)
          .gte('date', startStr)
          .lte('date', endStr)
          .order('date')
          .order('labour_id');

      return (response as List).map((e) => Attendance.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// List attendance for a labourer for a date range
  Future<List<Attendance>> listLabourAttendanceForRange(
    String labourId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];

      final response = await supabase
          .from('attendance')
          .select()
          .eq('labour_id', labourId)
          .gte('date', startStr)
          .lte('date', endStr)
          .order('date', ascending: false);

      return (response as List).map((e) => Attendance.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Create or update attendance for a date
  /// If exists, updates; if not, inserts
  Future<Attendance> upsertAttendance(Attendance attendance) async {
    try {
      final response = await supabase
          .from('attendance')
          .upsert(attendance.toJson())
          .eq('project_id', attendance.projectId)
          .eq('labour_id', attendance.labourId)
          .eq('date', attendance.date.toIso8601String().split('T')[0])
          .select()
          .single();

      return Attendance.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Batch upsert attendance (for marking multiple present/absent)
  Future<List<Attendance>> batchUpsertAttendance(List<Attendance> records) async {
    try {
      final jsonData = records.map((r) => r.toJson()).toList();

      final response = await supabase
          .from('attendance')
          .upsert(jsonData)
          .select();

      return (response as List).map((e) => Attendance.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Mark period as locked (after payment)
  Future<void> lockPeriod(String projectId, DateTime startDate, DateTime endDate) async {
    try {
      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];

      await supabase
          .from('attendance')
          .update({'locked': true})
          .eq('project_id', projectId)
          .gte('date', startStr)
          .lte('date', endStr);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Unlock a specific day
  Future<void> unlockDay(String projectId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      await supabase
          .from('attendance')
          .update({'locked': false})
          .eq('project_id', projectId)
          .eq('date', dateStr);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Check if labourer is already present on another project for this date
  /// (enforce one-site-per-day rule)
  Future<String?> checkOtherSitePresent(
    String labourId,
    DateTime date,
    String excludeProjectId,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      final response = await supabase
          .from('attendance')
          .select('project_id')
          .eq('labour_id', labourId)
          .eq('date', dateStr)
          .eq('status', 'present')
          .not('project_id', 'eq', excludeProjectId)
          .maybeSingle();

      if (response != null) {
        return response['project_id'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
