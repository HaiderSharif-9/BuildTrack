import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/labour.dart';
import '../../../core/models/money.dart';
import '../../../core/models/project.dart';
import '../../../core/models/wage_payment.dart';
import '../../../core/repositories/project_repository.dart';
import '../../../core/services/wage_calculator.dart';

final paymentsProjectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(Supabase.instance.client);
});

final paymentsProjectsProvider = FutureProvider<List<Project>>((ref) async {
  return ref.watch(paymentsProjectRepositoryProvider).listProjects();
});

/// Selected project for payments filter (null = all sites)
final paymentsSelectedSiteProvider = StateProvider<String?>((ref) => null);

/// Period selection filter: 'this_week', 'last_week', 'custom'
final paymentsPeriodFilterProvider = StateProvider<String>((ref) => 'this_week');

/// Period dates (start and end)
class PayrollPeriod {
  final DateTime start;
  final DateTime end;
  final String label;

  PayrollPeriod({
    required this.start,
    required this.end,
    required this.label,
  });
}

final payrollPeriodProvider = Provider<PayrollPeriod>((ref) {
  final filter = ref.watch(paymentsPeriodFilterProvider);
  final now = DateTime.now();

  // Find the most recent Friday (start of construction work-week)
  // Friday is weekday 5
  int daysSinceFriday = (now.weekday - DateTime.friday + 7) % 7;
  final thisFriday = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysSinceFriday));
  final thisThursday = thisFriday.add(const Duration(days: 6));

  if (filter == 'last_week') {
    final lastFriday = thisFriday.subtract(const Duration(days: 7));
    final lastThursday = thisThursday.subtract(const Duration(days: 7));
    return PayrollPeriod(
      start: lastFriday,
      end: lastThursday,
      label: 'Last Week',
    );
  }

  return PayrollPeriod(
    start: thisFriday,
    end: thisThursday,
    label: 'This Week',
  );
});

/// Individual worker payroll line item
class WorkerPayrollItem {
  final Labour labour;
  final Money defaultRate;
  final int daysWorked;
  final double overtimeHours;
  final Money grossWage;
  final Money advancesDeducted;
  final Money netPayable;
  final WagePayment? paymentRecord;
  final bool isPaid;

  WorkerPayrollItem({
    required this.labour,
    required this.defaultRate,
    required this.daysWorked,
    required this.overtimeHours,
    required this.grossWage,
    required this.advancesDeducted,
    required this.netPayable,
    this.paymentRecord,
    required this.isPaid,
  });
}

/// Payroll state notifier
class PayrollNotifier extends StateNotifier<AsyncValue<List<WorkerPayrollItem>>> {
  final Ref ref;

  PayrollNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadPayroll();
  }

  Future<void> loadPayroll() async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      final period = ref.read(payrollPeriodProvider);
      final siteId = ref.read(paymentsSelectedSiteProvider);

      final startStr = period.start.toIso8601String().split('T')[0];
      final endStr = period.end.toIso8601String().split('T')[0];

      // 1. Fetch active labour
      final labourRes = await supabase
          .from('labour')
          .select('id, name, trade, active')
          .eq('active', true)
          .isFilter('deleted_at', null)
          .order('name');
      final labourList = (labourRes as List<dynamic>)
          .map((e) => Labour.fromJson(e as Map<String, dynamic>))
          .toList();

      // 2. Fetch default rates
      Map<String, Money> rates = {};
      try {
        final ratesRes = await supabase.from('labour_private').select('labour_id, default_rate');
        for (var r in ratesRes as List<dynamic>) {
          rates[r['labour_id'] as String] = Money.fromString(r['default_rate']?.toString() ?? '1000');
        }
      } catch (_) {}

      // 3. Fetch attendance in this period
      var attQuery = supabase
          .from('attendance')
          .select('labour_id, date, status, in_time, out_time, hours_worked, overtime_hours, project_id')
          .gte('date', startStr)
          .lte('date', endStr)
          .isFilter('deleted_at', null);

      if (siteId != null) {
        attQuery = attQuery.eq('project_id', siteId);
      }

      final attRes = await attQuery;
      final attList = attRes as List<dynamic>;

      // 4. Fetch advances in this period
      var advQuery = supabase
          .from('labour_advances')
          .select('labour_id, amount')
          .gte('date', startStr)
          .lte('date', endStr);

      if (siteId != null) {
        advQuery = advQuery.eq('project_id', siteId);
      }

      Map<String, Money> advancesMap = {};
      try {
        final advRes = await advQuery;
        for (var a in advRes as List<dynamic>) {
          final lId = a['labour_id'] as String;
          final amt = Money.fromString(a['amount']?.toString() ?? '0');
          advancesMap[lId] = (advancesMap[lId] ?? Money.zero) + amt;
        }
      } catch (_) {}

      // 5. Fetch existing payments in this period
      var payQuery = supabase
          .from('wage_payments')
          .select()
          .gte('period_start', startStr)
          .lte('period_end', endStr)
          .isFilter('deleted_at', null);

      if (siteId != null) {
        payQuery = payQuery.eq('project_id', siteId);
      }

      Map<String, WagePayment> paymentsMap = {};
      try {
        final payRes = await payQuery;
        for (var p in payRes as List<dynamic>) {
          final payment = WagePayment.fromJson(p as Map<String, dynamic>);
          paymentsMap[payment.labourId] = payment;
        }
      } catch (_) {}

      // Compute payroll items for each worker
      final List<WorkerPayrollItem> items = [];

      for (var labour in labourList) {
        final rate = rates[labour.id] ?? Money.fromInt(1000);
        final workerAtt = attList.where((a) => a['labour_id'] == labour.id).toList();

        int daysPresent = 0;
        double otHours = 0;
        Money gross = Money.zero;

        final calc = WageCalculator(rate: rate);

        for (var a in workerAtt) {
          final status = a['status'] as String?;
          if (status == 'present') {
            daysPresent++;
            final inT = a['in_time'] as String?;
            final outT = a['out_time'] as String?;
            final ot = (a['overtime_hours'] as num?)?.toDouble() ?? 0.0;
            otHours += ot;

            final result = calc.calculateDay(
              status: 'present',
              inTime: inT,
              outTime: outT,
              manualOvertimeHours: ot,
            );
            gross = gross + result.wageAmount;
          }
        }

        final advance = advancesMap[labour.id] ?? Money.zero;
        final net = gross > advance ? gross - advance : Money.zero;
        final paymentRecord = paymentsMap[labour.id];

        items.add(WorkerPayrollItem(
          labour: labour,
          defaultRate: rate,
          daysWorked: daysPresent,
          overtimeHours: otHours,
          grossWage: gross,
          advancesDeducted: advance,
          netPayable: net,
          paymentRecord: paymentRecord,
          isPaid: paymentRecord != null,
        ));
      }

      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Record payment for a worker and log to ledger
  Future<void> markPaid({
    required String labourId,
    required Money gross,
    required Money advance,
    required String method, // Cash, Bank, EasyPaisa, JazzCash
  }) async {
    final supabase = Supabase.instance.client;
    final period = ref.read(payrollPeriodProvider);
    final siteId = ref.read(paymentsSelectedSiteProvider);

    final startStr = period.start.toIso8601String().split('T')[0];
    final endStr = period.end.toIso8601String().split('T')[0];
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    if (siteId == null) {
      throw StateError('Select a site before recording a wage payment.');
    }

    // Payroll is filtered to this site before payment, so never assign an
    // all-sites total to an arbitrary first project.
    final targetProjectId = siteId;

    // The database trigger creates the matching ledger expense atomically
    // from wage_payments.net. Do not insert a second transaction here.
    await supabase.from('wage_payments').insert({
      'labour_id': labourId,
      'project_id': targetProjectId,
      'period_start': startStr,
      'period_end': endStr,
      'gross': gross.toDbString(),
      'advances_deducted': advance.toDbString(),
      'paid_on': todayStr,
      'method': method.toLowerCase(),
    });

    await loadPayroll();
  }
}

final payrollProvider =
    StateNotifierProvider<PayrollNotifier, AsyncValue<List<WorkerPayrollItem>>>((ref) {
  ref.watch(payrollPeriodProvider);
  ref.watch(paymentsSelectedSiteProvider);
  return PayrollNotifier(ref);
});

/// Total payable summary provider
class PayrollSummary {
  final Money totalGross;
  final Money totalAdvances;
  final Money totalNetPayable;
  final int paidCount;
  final int unpaidCount;

  PayrollSummary({
    required this.totalGross,
    required this.totalAdvances,
    required this.totalNetPayable,
    required this.paidCount,
    required this.unpaidCount,
  });
}

final payrollSummaryProvider = Provider<PayrollSummary>((ref) {
  final payrollAsync = ref.watch(payrollProvider);
  return payrollAsync.maybeWhen(
    data: (items) {
      Money gross = Money.zero;
      Money advances = Money.zero;
      Money net = Money.zero;
      int paid = 0;
      int unpaid = 0;

      for (var item in items) {
        gross = gross + item.grossWage;
        advances = advances + item.advancesDeducted;
        if (!item.isPaid) {
          net = net + item.netPayable;
          unpaid++;
        } else {
          paid++;
        }
      }

      return PayrollSummary(
        totalGross: gross,
        totalAdvances: advances,
        totalNetPayable: net,
        paidCount: paid,
        unpaidCount: unpaid,
      );
    },
    orElse: () => PayrollSummary(
      totalGross: Money.zero,
      totalAdvances: Money.zero,
      totalNetPayable: Money.zero,
      paidCount: 0,
      unpaidCount: 0,
    ),
  );
});

