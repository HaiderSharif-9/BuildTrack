import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/labour.dart';
import '../../core/models/money.dart';

class LabourRepository {
  final _supabase = Supabase.instance.client;

  /// Get all labour (active only) - managers see assigned only
  Future<List<Labour>> getLabour() async {
    try {
      final response = await _supabase
          .from('labour')
          .select()
          .eq('active', true)
          .isFilter('deleted_at', null)
          .order('name');

      return (response as List)
          .map((item) => Labour.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching labour: $e');
    }
  }

  /// Get labour for a specific site (assigned only)
  Future<List<Map<String, dynamic>>> getSiteLabour(String projectId) async {
    try {
      final response = await _supabase
          .from('project_labour')
          .select('''
            labour(id, name, trade, active),
            project_labour_rate(rate_override)
          ''')
          .eq('project_id', projectId)
          .eq('labour.active', true)
          .isFilter('labour.deleted_at', null)
          .order('labour(name)');

      return (response as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error fetching site labour: $e');
    }
  }

  /// Get labour detail with private data (admin/accountant only)
  Future<Map<String, dynamic>?> getLabourDetail(String labourId) async {
    try {
      final response = await _supabase
          .from('labour')
          .select('''
            id, name, trade, active, created_at, updated_at,
            labour_private(phone, cnic, default_rate)
          ''')
          .eq('id', labourId)
          .isFilter('deleted_at', null)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Error fetching labour detail: $e');
    }
  }

  /// Create labour
  Future<Labour> createLabour({
    required String name,
    required String trade,
    String? phone,
    String? cnic,
    required Money defaultRate,
    String? projectId,
  }) async {
    try {
      // Create labour record
      final labourResponse = await _supabase
          .from('labour')
          .insert({
            'name': name,
            'trade': trade,
            'active': true,
          })
          .select()
          .single();

      final labourId = labourResponse['id'] as String;

      // Always create the private rate row: the server-side attendance
      // wage trigger requires a valid default rate for every labourer.
      await _supabase.from('labour_private').insert({
        'labour_id': labourId,
        'phone': phone,
        'cnic': cnic,
        'default_rate': defaultRate.toDbString(),
      });

      // A labourer must be assigned to a site to appear in that site's sheet.
      if (projectId != null) {
        await _supabase.from('project_labour').insert({
          'project_id': projectId,
          'labour_id': labourId,
        });
      }

      return Labour.fromJson(labourResponse);
    } catch (e) {
      throw Exception('Error creating labour: $e');
    }
  }

  /// Update labour
  Future<Labour> updateLabour({
    required String id,
    required String name,
    required String trade,
  }) async {
    try {
      final response = await _supabase
          .from('labour')
          .update({
            'name': name,
            'trade': trade,
          })
          .eq('id', id)
          .select()
          .single();

      return Labour.fromJson(response);
    } catch (e) {
      throw Exception('Error updating labour: $e');
    }
  }

  /// Update labour private data (admin/accountant only)
  Future<void> updateLabourPrivate({
    required String labourId,
    String? phone,
    String? cnic,
    required Money defaultRate,
  }) async {
    try {
      await _supabase
          .from('labour_private')
          .upsert({
            'labour_id': labourId,
            'phone': phone,
            'cnic': cnic,
            'default_rate': defaultRate.toDbString(),
          })
          .eq('labour_id', labourId);
    } catch (e) {
      throw Exception('Error updating labour private: $e');
    }
  }

  /// Soft delete labour
  Future<void> deleteLabour(String id) async {
    try {
      await _supabase
          .from('labour')
          .update({'active': false, 'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw Exception('Error deleting labour: $e');
    }
  }

  /// Search labour by name or trade
  Future<List<Labour>> searchLabour(String query) async {
    try {
      final response = await _supabase
          .from('labour')
          .select()
          .eq('active', true)
          .isFilter('deleted_at', null)
          .or('name.ilike.%$query%,trade.ilike.%$query%')
          .order('name');

      return (response as List)
          .map((item) => Labour.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error searching labour: $e');
    }
  }

  /// Check for duplicate by phone or CNIC
  Future<bool> hasDuplicateByPhoneOrCnic({
    String? phone,
    String? cnic,
    String? excludeLabourId,
  }) async {
    try {
      if ((phone == null || phone.isEmpty) && (cnic == null || cnic.isEmpty)) {
        return false;
      }

      String query = '';
      if (phone != null && phone.isNotEmpty) {
        query = 'phone.eq.$phone';
      }
      if (cnic != null && cnic.isNotEmpty) {
        if (query.isNotEmpty) query += ',';
        query += 'cnic.eq.$cnic';
      }

      var duplicateQuery = _supabase
          .from('labour_private')
          .select('labour_id')
          .or(query);

      if (excludeLabourId != null) {
        duplicateQuery = duplicateQuery.neq('labour_id', excludeLabourId);
      }

      final response = await duplicateQuery.limit(1);
      return (response as List).isNotEmpty;
    } catch (e) {
      throw Exception('Error checking duplicates: $e');
    }
  }

  /// Batch create labour from import
  Future<List<Labour>> batchCreateLabour(List<Map<String, dynamic>> items) async {
    try {
      final created = <Labour>[];

      for (final item in items) {
        final labour = await createLabour(
          name: item['name'] as String,
          trade: item['trade'] as String,
          phone: item['phone'] as String?,
          cnic: item['cnic'] as String?,
          defaultRate: Money.fromString(item['default_rate']?.toString() ?? '0'),
        );
        created.add(labour);
      }

      return created;
    } catch (e) {
      throw Exception('Error batch creating labour: $e');
    }
  }
}
