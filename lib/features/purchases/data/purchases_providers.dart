import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/money.dart';
import '../../../core/models/purchase.dart';
import '../../../core/repositories/project_repository.dart';
import '../../../core/repositories/purchase_repository.dart';

final purchasesRepoProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepository(Supabase.instance.client);
});

final purchasesProjectRepoProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(Supabase.instance.client);
});

/// Selected project filter (null = all sites)
final purchasesSelectedSiteProvider = StateProvider<String?>((ref) => null);

/// Search query filter
final purchasesSearchProvider = StateProvider<String>((ref) => '');

/// Notifier managing purchases state
class PurchasesNotifier extends StateNotifier<AsyncValue<List<Purchase>>> {
  final Ref ref;

  PurchasesNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      final selectedSite = ref.read(purchasesSelectedSiteProvider);

      var query = supabase
          .from('purchases')
          .select()
          .isFilter('deleted_at', null);

      if (selectedSite != null) {
        query = query.eq('project_id', selectedSite);
      }

      final response = await query.order('date', ascending: false);
      final list = (response as List<dynamic>)
          .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add new purchase and sync expense to ledger
  Future<void> addPurchase({
    required String projectId,
    required String item,
    required double qty,
    required String unit,
    required Money rate,
    required DateTime date,
    String? supplierId,
  }) async {
    final supabase = Supabase.instance.client;
    final dateStr = date.toIso8601String().split('T')[0];

    // The database trigger creates and maintains the linked Materials
    // transaction atomically with the purchase row.
    await supabase.from('purchases').insert({
      'project_id': projectId,
      'date': dateStr,
      'item': item,
      'qty': qty,
      'unit': unit,
      'rate': rate.toDbString(),
      'supplier_id': supplierId,
    });

    await loadPurchases();
  }

  /// Update existing purchase
  Future<void> updatePurchase({
    required String id,
    required String item,
    required double qty,
    required String unit,
    required Money rate,
    required DateTime date,
  }) async {
    final supabase = Supabase.instance.client;
    final dateStr = date.toIso8601String().split('T')[0];

    await supabase.from('purchases').update({
      'item': item,
      'qty': qty,
      'unit': unit,
      'rate': rate.toDbString(),
      'date': dateStr,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);

    await loadPurchases();
  }

  /// Delete purchase (soft delete)
  Future<void> deletePurchase(String id) async {
    final supabase = Supabase.instance.client;
    await supabase.from('purchases').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);

    await loadPurchases();
  }
}

final purchasesListProvider =
    StateNotifierProvider<PurchasesNotifier, AsyncValue<List<Purchase>>>((ref) {
  ref.watch(purchasesSelectedSiteProvider);
  return PurchasesNotifier(ref);
});

/// Filtered purchases by search query
final filteredPurchasesProvider = Provider<List<Purchase>>((ref) {
  final purchasesAsync = ref.watch(purchasesListProvider);
  final search = ref.watch(purchasesSearchProvider).trim().toLowerCase();

  return purchasesAsync.maybeWhen(
    data: (items) {
      if (search.isEmpty) return items;
      return items.where((p) => p.item.toLowerCase().contains(search)).toList();
    },
    orElse: () => [],
  );
});

/// Total purchases sum
final purchasesTotalAmountProvider = Provider<Money>((ref) {
  final purchases = ref.watch(filteredPurchasesProvider);
  Money total = Money.zero;
  for (var p in purchases) {
    total = total + p.amount;
  }
  return total;
});

