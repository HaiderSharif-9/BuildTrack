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
    return switch (type) {
      'income' => isDark ? AppColors.incomeBgDark : AppColors.incomeBgLight,
      'expense' => isDark ? AppColors.expenseBgDark : AppColors.expenseBgLight,
      'profit' => isDark ? AppColors.profitBgDark : AppColors.profitBgLight,
      'warning' => isDark ? AppColors.warningBgDark : AppColors.warningBgLight,
      _ => isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
    };
  }

  Color _getTextColor(bool isDark) {
    return switch (type) {
      'income' => AppColors.incomeTextLight,
      'expense' => AppColors.expenseTextLight,
      'profit' => AppColors.profitTextLight,
      'warning' => AppColors.warningLight,
      _ => isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    };
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
