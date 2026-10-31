import '../models/transaction.dart';
import 'base_repository.dart';

class TransactionRepository extends BaseRepository {
  TransactionRepository(super.supabase);

  /// Get a single transaction
  Future<Transaction> getTransaction(String transactionId) async {
    try {
      final response = await supabase
          .from('transactions')
          .select()
          .eq('id', transactionId)
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// List transactions for a date range (admin/accountant only)
  Future<List<Transaction>> listTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? type, // income or expense
    String? projectId, // NULL for company-level
  }) async {
    try {
      var query = supabase
          .from('transactions')
          .select();

      if (startDate != null) {
        final startStr = startDate.toIso8601String().split('T')[0];
        query = query.gte('date', startStr);
      }

      if (endDate != null) {
        final endStr = endDate.toIso8601String().split('T')[0];
        query = query.lte('date', endStr);
      }

      if (type != null) {
        query = query.eq('type', type);
      }

      if (projectId != null) {
        query = query.eq('project_id', projectId);
      }

      final response = await query.order('date', ascending: false);
      return (response as List).map((e) => Transaction.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// List company-level transactions (no project)
  Future<List<Transaction>> listCompanyTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    try {
      var query = supabase
          .from('transactions')
          .select();

      if (startDate != null) {
        final startStr = startDate.toIso8601String().split('T')[0];
        query = query.gte('date', startStr);
      }

      if (endDate != null) {
        final endStr = endDate.toIso8601String().split('T')[0];
        query = query.lte('date', endStr);
      }

      if (type != null) {
        query = query.eq('type', type);
      }

      final response = await query.order('date', ascending: false);
      return (response as List).map((e) => Transaction.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Create a manual transaction (admin/accountant)
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await supabase
          .from('transactions')
          .insert(transaction.toJson())
          .select()
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Update a manual transaction
  Future<Transaction> updateTransaction(Transaction transaction) async {
    try {
      final response = await supabase
          .from('transactions')
          .update(transaction.toJson())
          .eq('id', transaction.id)
          .select()
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Soft delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await supabase
          .from('transactions')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', transactionId);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}
