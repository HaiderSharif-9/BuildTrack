import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/money.dart';
import '../../../core/models/transaction.dart';
import '../../../core/repositories/project_repository.dart';
import '../../../core/repositories/transaction_repository.dart';

final ledgerRepoProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(Supabase.instance.client);
});

final ledgerProjectRepoProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(Supabase.instance.client);
});

/// Filter: 'all', 'income', 'expense'
final ledgerTypeFilterProvider = StateProvider<String>((ref) => 'all');

/// Selected site filter (null = all sites / company-wide)
final ledgerSelectedSiteProvider = StateProvider<String?>((ref) => null);

/// Categories list provider
final ledgerCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('categories').select().order('name');
  return (response as List<dynamic>)
      .map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Transactions state notifier
class LedgerNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final Ref ref;

  LedgerNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      final siteId = ref.read(ledgerSelectedSiteProvider);
      final typeFilter = ref.read(ledgerTypeFilterProvider);

      var query = supabase
          .from('transactions')
          .select()
          .isFilter('deleted_at', null);

      if (siteId != null) {
        query = query.eq('project_id', siteId);
      }

      if (typeFilter != 'all') {
        query = query.eq('type', typeFilter);
      }

      final response = await query.order('date', ascending: false);
      final list = (response as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Create transaction
  Future<void> addTransaction({
    required String type, // 'income' or 'expense'
    required String categoryId,
    required String description,
    required Money amount,
    String? projectId,
    required DateTime date,
  }) async {
    final supabase = Supabase.instance.client;
    final dateStr = date.toIso8601String().split('T')[0];

    await supabase.from('transactions').insert({
      'type': type,
      'category_id': categoryId,
      'description': description,
      'amount': amount.toDbString(),
      'project_id': projectId,
      'date': dateStr,
      'source': 'manual',
    });

    await loadTransactions();
  }

  /// Update a manually entered ledger transaction.
  Future<void> updateTransaction({
    required String id,
    required String type,
    required String categoryId,
    required String description,
    required Money amount,
    required String? projectId,
    required DateTime date,
  }) async {
    final supabase = Supabase.instance.client;
    await supabase.from('transactions').update({
      'type': type,
      'category_id': categoryId,
      'description': description,
      'amount': amount.toDbString(),
      'project_id': projectId,
      'date': date.toIso8601String().split('T')[0],
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id).eq('source', 'manual');

    await loadTransactions();
  }

  /// Soft delete transaction
  Future<void> deleteTransaction(String id) async {
    final supabase = Supabase.instance.client;
    await supabase.from('transactions').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);

    await loadTransactions();
  }
}

final ledgerTransactionsProvider =
    StateNotifierProvider<LedgerNotifier, AsyncValue<List<Transaction>>>((ref) {
  ref.watch(ledgerTypeFilterProvider);
  ref.watch(ledgerSelectedSiteProvider);
  return LedgerNotifier(ref);
});

/// Ledger Financial Balance Summary (Income, Expense, Net)
class LedgerBalanceSummary {
  final Money totalIncome;
  final Money totalExpense;
  final Money netBalance;

  LedgerBalanceSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
  });
}

final ledgerBalanceSummaryProvider = Provider<LedgerBalanceSummary>((ref) {
  final txAsync = ref.watch(ledgerTransactionsProvider);

  return txAsync.maybeWhen(
    data: (txs) {
      Money income = Money.zero;
      Money expense = Money.zero;

      for (var tx in txs) {
        if (tx.isIncome) {
          income = income + tx.amount;
        } else if (tx.isExpense) {
          expense = expense + tx.amount;
        }
      }

      final net = income - expense;
      return LedgerBalanceSummary(
        totalIncome: income,
        totalExpense: expense,
        netBalance: net,
      );
    },
    orElse: () => LedgerBalanceSummary(
      totalIncome: Money.zero,
      totalExpense: Money.zero,
      netBalance: Money.zero,
    ),
  );
});

