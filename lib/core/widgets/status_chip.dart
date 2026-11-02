import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final String type; // 'income', 'expense', 'profit', 'warning', 'default'
  final bool selected;

  const StatusChip({
    required this.label,
    required this.type,
    this.selected = false,
    super.key,
  });

  Color _getBackgroundColor(bool isDark) {
    if (type == 'income') {
      return isDark ? AppColors.incomeBgDark : AppColors.incomeBgLight;
    } else if (type == 'expense') {
      return isDark ? AppColors.expenseBgDark : AppColors.expenseBgLight;
    } else if (type == 'profit') {
      return isDark ? AppColors.profitBgDark : AppColors.profitBgLight;
    } else if (type == 'warning') {
      return isDark ? AppColors.warningBgDark : AppColors.warningBgLight;
    } else {
      return isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;
    }
  }

  Color _getTextColor(bool isDark) {
    if (type == 'income') {
      return AppColors.incomeTextLight;
    } else if (type == 'expense') {
      return AppColors.expenseTextLight;
    } else if (type == 'profit') {
      return AppColors.profitTextLight;
    } else if (type == 'warning') {
      return AppColors.warningLight;
    } else {
      return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: _getBackgroundColor(isDark),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: selected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Text(
        label,
        style: AppTypography.labelLight.copyWith(
          color: _getTextColor(isDark),
        ),
      ),
    );
  }
}
