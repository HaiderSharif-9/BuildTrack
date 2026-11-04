import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_providers.dart';
import '../data/attendance_providers.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = context.appColors;
    final role = ref.watch(currentUserRoleProvider).asData?.value;
    final canViewWages = role == 'admin' || role == 'accountant';

    final projectsAsync = ref.watch(attendanceProjectsProvider);
    final selectedSite = ref.watch(attendanceSelectedSiteProvider);
    final selectedDate = ref.watch(attendanceSelectedDateProvider);
    final sheetAsync = ref.watch(attendanceSheetProvider);
    final summary = ref.watch(attendanceSummaryProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.attendance),
        backgroundColor: colors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(attendanceSheetProvider.notifier).loadAttendanceSheet();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Site Selector Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colors.surface,
            child: projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) {
                  return Text(
                    'No active sites available',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                  );
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedSite ?? projects.first.id,
                      dropdownColor: colors.surface,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: projects.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(
                            p.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(attendanceSelectedSiteProvider.notifier).state = val;
                        }
                      },
                    ),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error loading sites: $err'),
            ),
          ),

          // 2. Horizontal Date Picker Strip (Week view)
          _buildDatePickerStrip(selectedDate, colors, theme),

          // 3. Helper Instruction Strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: isDark ? AppColors.charcoal700 : const Color(0xFFF0EBE1),
            child: Text(
              'Swipe card or tap buttons to mark attendance | Tap details for custom hours & OT',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 4. Labour Attendance List
          Expanded(
            child: sheetAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    title: l10n.noData,
                    subtitle: 'No labourers assigned to this site',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildLabourAttendanceCard(item, colors, theme, canViewWages: canViewWages);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorState(
                title: l10n.error,
                message: err.toString(),
                onRetry: () {
                  ref.read(attendanceSheetProvider.notifier).loadAttendanceSheet();
                },
              ),
            ),
          ),

          // 5. Bottom Sticky Summary & Action Bar
          _buildSummaryBar(summary, colors, theme, canViewWages: canViewWages),
        ],
      ),
    );
  }

  /// Horizontal calendar strip (past 3 days, today, next 3 days)
  Widget _buildDatePickerStrip(DateTime selectedDate, AppColorsValue colors, ThemeData theme) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (i) => today.subtract(Duration(days: 3 - i)));

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days.map((date) {
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          final isCurrentDay = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          return GestureDetector(
            onTap: () {
              ref.read(attendanceSelectedDateProvider.notifier).state = date;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isCurrentDay ? colors.surfaceAlt : Colors.transparent),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isCurrentDay ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected ? AppColors.textOnGold : colors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isSelected ? AppColors.textOnGold : colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Worker attendance card with swipe and quick status buttons
  Widget _buildLabourAttendanceCard(
    LabourAttendanceItem item,
    AppColorsValue colors,
    ThemeData theme, {
    required bool canViewWages,
  }) {
    final isPresent = item.status == 'present';
    final isAbsent = item.status == 'absent';
    final isLeave = item.status == 'leave';

    Color badgeBg;
    Color badgeText;
    String statusLabel;

    if (isPresent) {
      badgeBg = colors.success.withValues(alpha: 0.15);
      badgeText = colors.success;
      statusLabel = 'Present';
    } else if (isAbsent) {
      badgeBg = colors.error.withValues(alpha: 0.15);
      badgeText = colors.error;
      statusLabel = 'Absent';
    } else if (isLeave) {
      badgeBg = colors.warning.withValues(alpha: 0.15);
      badgeText = colors.warning;
      statusLabel = 'Leave';
    } else {
      badgeBg = colors.border;
      badgeText = colors.textMuted;
      statusLabel = 'Unmarked';
    }

    return Dismissible(
      key: ValueKey('att_${item.labour.id}_${item.attendance?.date.toIso8601String() ?? 'draft'}'),
      direction: item.isLocked ? DismissDirection.none : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right -> Present
          ref.read(attendanceSheetProvider.notifier).setStatus(item.labour.id, 'present');
        } else if (direction == DismissDirection.endToStart) {
          // Swipe left -> Absent
          ref.read(attendanceSheetProvider.notifier).setStatus(item.labour.id, 'absent');
        }
        return false; // Don't remove tile from view, just update state
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.success,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Row(
          children: [
            Icon(Icons.check, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text('Present (08:00 - 18:00)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Absent', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.close, color: Colors.white, size: 28),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with initials
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: isPresent ? colors.success : AppColors.primary,
                    child: Text(
                      item.labour.name.isNotEmpty ? item.labour.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnGold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Trade
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.labour.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.labour.trade}${canViewWages ? " • Rs. ${item.defaultRate.toDisplayString()}/day" : ""}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calculated wage amount (hidden from manager accounts)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (canViewWages)
                        Text(
                        'Rs. ${item.wageResult.wageAmount.toDisplayString()}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPresent ? colors.success : colors.textPrimary,
                        ),
                      ),
                      if (canViewWages) const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: badgeText,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Hours and Overtime details
              if (isPresent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: colors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        item.inTime != null && item.outTime != null
                            ? '${item.inTime} - ${item.outTime} (${item.wageResult.hoursWorked?.toStringAsFixed(1) ?? '10'}h)'
                            : 'Full Day (08:00 - 18:00)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                      if (item.overtimeHours > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '+${item.overtimeHours.toStringAsFixed(1)}h OT',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldTextLight,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showTimeOtDialog(item),
                        child: const Text(
                          'Edit Times',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (isPresent) const SizedBox(height: 8),

              // Quick action buttons: Present, Absent, Leave
              Row(
                children: [
                  _buildQuickStatusChip(
                    label: 'Present',
                    icon: Icons.check,
                    isSelected: isPresent,
                    color: colors.success,
                    onTap: () {
                      ref.read(attendanceSheetProvider.notifier).setStatus(item.labour.id, 'present');
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildQuickStatusChip(
                    label: 'Absent',
                    icon: Icons.close,
                    isSelected: isAbsent,
                    color: colors.error,
                    onTap: () {
                      ref.read(attendanceSheetProvider.notifier).setStatus(item.labour.id, 'absent');
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildQuickStatusChip(
                    label: 'Leave',
                    icon: Icons.beach_access,
                    isSelected: isLeave,
                    color: colors.warning,
                    onTap: () {
                      ref.read(attendanceSheetProvider.notifier).setStatus(item.labour.id, 'leave');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatusChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dialog to edit in/out times and manual overtime
  void _showTimeOtDialog(LabourAttendanceItem item) {
    String inTime = item.inTime ?? '08:00';
    String outTime = item.outTime ?? '18:00';
    double ot = item.overtimeHours;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Work Hours & Overtime: ${item.labour.name}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('In Time', style: TextStyle(fontSize: 12)),
                          subtitle: Text(inTime, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: const Icon(Icons.access_time, size: 20),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: context.appColors.border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onTap: () async {
                            final parts = inTime.split(':');
                            final initial = TimeOfDay(
                              hour: int.tryParse(parts[0]) ?? 8,
                              minute: int.tryParse(parts[1]) ?? 0,
                            );
                            final picked = await showTimePicker(context: context, initialTime: initial);
                            if (picked != null) {
                              setSheetState(() {
                                inTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ListTile(
                          title: const Text('Out Time', style: TextStyle(fontSize: 12)),
                          subtitle: Text(outTime, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: const Icon(Icons.access_time, size: 20),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: context.appColors.border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onTap: () async {
                            final parts = outTime.split(':');
                            final initial = TimeOfDay(
                              hour: int.tryParse(parts[0]) ?? 18,
                              minute: int.tryParse(parts[1]) ?? 0,
                            );
                            final picked = await showTimePicker(context: context, initialTime: initial);
                            if (picked != null) {
                              setSheetState(() {
                                outTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Additional Overtime Hours:'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: ot > 0 ? () => setSheetState(() => ot = (ot - 0.5).clamp(0.0, 10.0)) : null,
                          ),
                          Text('${ot.toStringAsFixed(1)} h', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setSheetState(() => ot = (ot + 0.5).clamp(0.0, 10.0)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Apply Hours',
                    onPressed: () {
                      ref.read(attendanceSheetProvider.notifier).setStatus(
                            item.labour.id,
                            'present',
                            inTime: inTime,
                            outTime: outTime,
                            overtime: ot,
                          );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Sticky bottom summary and Save button bar
  Widget _buildSummaryBar(AttendanceSummary summary, AppColorsValue colors, ThemeData theme, {required bool canViewWages}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Counters strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCounter('Present', summary.presentCount.toString(), colors.success),
                _buildCounter('Absent', summary.absentCount.toString(), colors.error),
                _buildCounter('OT', '${summary.totalOvertimeHours.toStringAsFixed(1)}h', AppColors.goldTextLight),
                if (canViewWages)
                  _buildCounter('Total Wages', 'Rs. ${summary.totalWages.toDisplayString()}', colors.textPrimary),
              ],
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(attendanceSheetProvider.notifier).markAllPresent();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Mark All Present',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldTextLight),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Save Attendance',
                    isLoading: _isSaving,
                    onPressed: () async {
                      setState(() => _isSaving = true);
                      try {
                        await ref.read(attendanceSheetProvider.notifier).saveAttendance();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Attendance saved successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isSaving = false);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

