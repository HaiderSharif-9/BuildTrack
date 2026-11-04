import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/attendance.dart';
import '../../../core/models/labour.dart';
import '../../../core/models/money.dart';
import '../../../core/models/project.dart';
import '../../../core/repositories/attendance_repository.dart';
import '../../../core/repositories/project_repository.dart';
import '../../../core/services/wage_calculator.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(Supabase.instance.client);
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(Supabase.instance.client);
});

/// List of all projects for the site dropdown
final attendanceProjectsProvider = FutureProvider<List<Project>>((ref) async {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.listProjects();
});

/// Currently selected project/site for attendance
final attendanceSelectedSiteProvider = StateProvider<String?>((ref) => null);

/// Currently selected date for attendance (defaults to today)
final attendanceSelectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// UI Item combining Labour details, Attendance record, and computed Wage
class LabourAttendanceItem {
  final Labour labour;
  final Money defaultRate;
  final Attendance? attendance;
  final String status; // 'present', 'absent', 'leave', or 'unmarked'
  final String? inTime;
  final String? outTime;
  final double overtimeHours;
  final WageResult wageResult;
  final bool isLocked;

  LabourAttendanceItem({
    required this.labour,
    required this.defaultRate,
    this.attendance,
    required this.status,
    this.inTime,
    this.outTime,
    this.overtimeHours = 0.0,
    required this.wageResult,
    this.isLocked = false,
  });

  LabourAttendanceItem copyWith({
    Attendance? attendance,
    String? status,
    String? inTime,
    String? outTime,
    double? overtimeHours,
    WageResult? wageResult,
    bool? isLocked,
  }) {
    return LabourAttendanceItem(
      labour: labour,
      defaultRate: defaultRate,
      attendance: attendance ?? this.attendance,
      status: status ?? this.status,
      inTime: inTime ?? this.inTime,
      outTime: outTime ?? this.outTime,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      wageResult: wageResult ?? this.wageResult,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

/// State notifier managing attendance items for the selected site and date
class AttendanceSheetNotifier extends StateNotifier<AsyncValue<List<LabourAttendanceItem>>> {
  final Ref ref;

  AttendanceSheetNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadAttendanceSheet();
  }

  Future<void> loadAttendanceSheet() async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      final selectedSite = ref.read(attendanceSelectedSiteProvider);
      final selectedDate = ref.read(attendanceSelectedDateProvider);

      // If no site is selected yet, try to pick the first active project
      String? siteId = selectedSite;
      if (siteId == null) {
        final projects = await ref.read(attendanceProjectsProvider.future);
        if (projects.isNotEmpty) {
          siteId = projects.first.id;
          ref.read(attendanceSelectedSiteProvider.notifier).state = siteId;
        } else {
          state = const AsyncValue.data([]);
          return;
        }
      }

      final dateStr = selectedDate.toIso8601String().split('T')[0];

      // 1. Get all active labourers
      final labourResponse = await supabase
          .from('labour')
          .select('id, name, trade, active')
          .eq('active', true)
          .order('name');

      final List<dynamic> labourList = labourResponse as List<dynamic>;

      // 2. Get rates from labour_private (if accessible)
      Map<String, Money> ratesMap = {};
      try {
        final ratesResponse = await supabase
            .from('labour_private')
            .select('labour_id, default_rate');
        for (var r in ratesResponse as List<dynamic>) {
          final lId = r['labour_id'] as String;
          final rateVal = r['default_rate']?.toString() ?? '1000';
          ratesMap[lId] = Money.fromString(rateVal);
        }
      } catch (_) {
        // Fallback default rate if private table is restricted for user role
      }

      // 3. Get existing attendance for this site and date
      final attendanceResponse = await supabase
          .from('attendance')
          .select()
          .eq('project_id', siteId)
          .eq('date', dateStr);

      Map<String, Attendance> existingAttendance = {};
      for (var a in attendanceResponse as List<dynamic>) {
        final record = Attendance.fromJson(a as Map<String, dynamic>);
        existingAttendance[record.labourId] = record;
      }

      // Build sheet items
      final List<LabourAttendanceItem> items = [];
      for (var l in labourList) {
        final labour = Labour.fromJson(l as Map<String, dynamic>);
        final rate = ratesMap[labour.id] ?? Money.fromInt(1000);
        final att = existingAttendance[labour.id];

        final calculator = WageCalculator(rate: rate);
        final status = att?.status ?? 'unmarked';
        final inTime = att?.inTime;
        final outTime = att?.outTime;
        final ot = att?.overtimeHours ?? 0.0;

        final wageResult = calculator.calculateDay(
          status: status == 'unmarked' ? 'absent' : status,
          inTime: inTime,
          outTime: outTime,
          manualOvertimeHours: ot,
        );

        items.add(LabourAttendanceItem(
          labour: labour,
          defaultRate: rate,
          attendance: att,
          status: status,
          inTime: inTime,
          outTime: outTime,
          overtimeHours: ot,
          wageResult: wageResult,
          isLocked: att?.locked ?? false,
        ));
      }

      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Mark single labourer status (present, absent, leave)
  void setStatus(String labourId, String newStatus, {String? inTime, String? outTime, double? overtime}) {
    state.whenData((items) {
      final updated = items.map((item) {
        if (item.labour.id != labourId) return item;

        final effectiveInTime = newStatus == 'present' ? (inTime ?? item.inTime ?? '08:00') : null;
        final effectiveOutTime = newStatus == 'present' ? (outTime ?? item.outTime ?? '18:00') : null;
        final effectiveOt = newStatus == 'present' ? (overtime ?? item.overtimeHours) : 0.0;

        final calculator = WageCalculator(rate: item.defaultRate);
        final wage = calculator.calculateDay(
          status: newStatus,
          inTime: effectiveInTime,
          outTime: effectiveOutTime,
          manualOvertimeHours: effectiveOt,
        );

        return item.copyWith(
          status: newStatus,
          inTime: effectiveInTime,
          outTime: effectiveOutTime,
          overtimeHours: effectiveOt,
          wageResult: wage,
        );
      }).toList();

      state = AsyncValue.data(updated);
    });
  }

  /// Mark all unmarked/absent workers as Present (08:00 - 18:00 default)
  void markAllPresent() {
    state.whenData((items) {
      final updated = items.map((item) {
        if (item.isLocked) return item;
        final calculator = WageCalculator(rate: item.defaultRate);
        const inT = '08:00';
        const outT = '18:00';
        final wage = calculator.calculateDay(
          status: 'present',
          inTime: inT,
          outTime: outT,
          manualOvertimeHours: 0.0,
        );

        return item.copyWith(
          status: 'present',
          inTime: inT,
          outTime: outT,
          overtimeHours: 0.0,
          wageResult: wage,
        );
      }).toList();

      state = AsyncValue.data(updated);
    });
  }

  /// Save all marked records to Supabase
  Future<void> saveAttendance() async {
    final currentItems = state.valueOrNull;
    final siteId = ref.read(attendanceSelectedSiteProvider);
    final date = ref.read(attendanceSelectedDateProvider);

    if (currentItems == null || siteId == null) return;

    final supabase = Supabase.instance.client;
    final dateStr = date.toIso8601String().split('T')[0];

    final recordsToSave = currentItems
        .where((item) => item.status != 'unmarked' && !item.isLocked)
        .map((item) {
      return {
        'project_id': siteId,
        'labour_id': item.labour.id,
        'date': dateStr,
        'status': item.status,
        'in_time': item.status == 'present' ? item.inTime : null,
        'out_time': item.status == 'present' ? item.outTime : null,
        'overtime_hours': item.status == 'present' ? item.overtimeHours : 0,
        'remarks': item.attendance?.remarks,
      };
    }).toList();

    if (recordsToSave.isEmpty) return;

    // Upsert into Supabase attendance table
    await supabase.from('attendance').upsert(
      recordsToSave,
      onConflict: 'project_id,labour_id,date',
    );

    // Refresh sheet from DB to get generated IDs and triggers
    await loadAttendanceSheet();
  }
}

final attendanceSheetProvider =
    StateNotifierProvider<AttendanceSheetNotifier, AsyncValue<List<LabourAttendanceItem>>>((ref) {
  // Re-load when site or date changes
  ref.watch(attendanceSelectedSiteProvider);
  ref.watch(attendanceSelectedDateProvider);
  return AttendanceSheetNotifier(ref);
});

/// Attendance summary counters
class AttendanceSummary {
  final int presentCount;
  final int absentCount;
  final int leaveCount;
  final double totalOvertimeHours;
  final Money totalWages;

  AttendanceSummary({
    required this.presentCount,
    required this.absentCount,
    required this.leaveCount,
    required this.totalOvertimeHours,
    required this.totalWages,
  });
}

final attendanceSummaryProvider = Provider<AttendanceSummary>((ref) {
  final sheet = ref.watch(attendanceSheetProvider);
  return sheet.maybeWhen(
    data: (items) {
      int present = 0;
      int absent = 0;
      int leave = 0;
      double ot = 0;
      Money wages = Money.zero;

      for (var item in items) {
        if (item.status == 'present') {
          present++;
          ot += item.overtimeHours;
          wages = wages + item.wageResult.wageAmount;
        } else if (item.status == 'absent') {
          absent++;
        } else if (item.status == 'leave') {
          leave++;
        }
      }

      return AttendanceSummary(
        presentCount: present,
        absentCount: absent,
        leaveCount: leave,
        totalOvertimeHours: ot,
        totalWages: wages,
      );
    },
    orElse: () => AttendanceSummary(
      presentCount: 0,
      absentCount: 0,
      leaveCount: 0,
      totalOvertimeHours: 0,
      totalWages: Money.zero,
    ),
  );
});

