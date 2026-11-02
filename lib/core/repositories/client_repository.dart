import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/client.dart';

class ClientRepository {
  final _supabase = Supabase.instance.client;

  /// Get all clients (active only)
  Future<List<Client>> getClients() async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .order('name');

      return (response as List)
          .map((item) => Client.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching clients: $e');
    }
  }

  /// Get single client
  Future<Client?> getClient(String id) async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Client.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching client: $e');
    }
  }

  /// Create client
  Future<Client> createClient({
    required String name,
    String? phone,
    String? address,
    String? notes,
  }) async {
    try {
      final response = await _supabase.from('clients').insert({
        'name': name,
        'phone': phone,
        'address': address,
        'notes': notes,
      }).select().single();

      return Client.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error creating client: $e');
    }
  }

  /// Update client
  Future<Client> updateClient({
    required String id,
    required String name,
    String? phone,
    String? address,
    String? notes,
  }) async {
    try {
      final response = await _supabase
          .from('clients')
          .update({
            'name': name,
            'phone': phone,
            'address': address,
            'notes': notes,
          })
          .eq('id', id)
          .select()
          .single();

      return Client.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error updating client: $e');
    }
  }

  /// Soft delete client
  Future<void> deleteClient(String id) async {
    try {
      await _supabase
          .from('clients')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw Exception('Error deleting client: $e');
    }
  }

  /// Search clients by name
  Future<List<Client>> searchClients(String query) async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .ilike('name', '%$query%')
          .order('name');

      return (response as List)
          .map((item) => Client.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error searching clients: $e');
    }
  }
}
