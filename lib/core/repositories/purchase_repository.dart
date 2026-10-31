import '../models/purchase.dart';
import 'base_repository.dart';

class PurchaseRepository extends BaseRepository {
  PurchaseRepository(super.supabase);

  /// Get a single purchase
  Future<Purchase> getPurchase(String purchaseId) async {
    try {
      final response = await supabase
          .from('purchases')
          .select()
          .eq('id', purchaseId)
          .single();

      return Purchase.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// List purchases for a project in a date range
  Future<List<Purchase>> listPurchases({
    required String projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = supabase
          .from('purchases')
          .select()
          .eq('project_id', projectId);

      if (startDate != null) {
        final startStr = startDate.toIso8601String().split('T')[0];
        query = query.gte('date', startStr);
      }

      if (endDate != null) {
        final endStr = endDate.toIso8601String().split('T')[0];
        query = query.lte('date', endStr);
      }

      final response = await query.order('date', ascending: false);
      return (response as List).map((e) => Purchase.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Create a new purchase
  Future<Purchase> createPurchase(Purchase purchase) async {
    try {
      final response = await supabase
          .from('purchases')
          .insert(purchase.toJson())
          .select()
          .single();

      return Purchase.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Update a purchase (manager can edit own for 24h, admin/accountant anytime)
  Future<Purchase> updatePurchase(Purchase purchase) async {
    try {
      final response = await supabase
          .from('purchases')
          .update(purchase.toJson())
          .eq('id', purchase.id)
          .select()
          .single();

      return Purchase.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Soft delete a purchase
  Future<void> deletePurchase(String purchaseId) async {
    try {
      await supabase
          .from('purchases')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', purchaseId);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}
