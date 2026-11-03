import '../models/supplier.dart';
import 'base_repository.dart';

class SupplierRepository extends BaseRepository {
  SupplierRepository(super.supabase);

  /// Get a single supplier
  Future<Supplier> getSupplier(String supplierId) async {
    try {
      final response = await supabase
          .from('suppliers')
          .select()
          .eq('id', supplierId)
          .single();

      return Supplier.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// List all suppliers (search by name)
  Future<List<Supplier>> listSuppliers({String? search}) async {
    try {
      var query = supabase
          .from('suppliers')
          .select()
          .order('name');

      final response = await query;
      List<Supplier> suppliers = (response as List).map((e) => Supplier.fromJson(e)).toList();

      // Client-side filtering for search
      if (search != null && search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        suppliers = suppliers
            .where((s) => s.name.toLowerCase().contains(searchLower))
            .toList();
      }

      return suppliers;
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Create a new supplier
  Future<Supplier> createSupplier(Supplier supplier) async {
    try {
      final response = await supabase
          .from('suppliers')
          .insert(supplier.toJson())
          .select()
          .single();

      return Supplier.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Update supplier
  Future<Supplier> updateSupplier(Supplier supplier) async {
    try {
      final response = await supabase
          .from('suppliers')
          .update(supplier.toJson())
          .eq('id', supplier.id)
          .select()
          .single();

      return Supplier.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}


