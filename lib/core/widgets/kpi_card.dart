import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final String type; // 'income', 'expense', 'profit', 'default'
  final IconData? icon;

  const KpiCard({
    required this.label,
    required this.value,
    this.subtitle,
    this.type = 'default',
    this.icon,
    super.key,
  });

  Color _getColor(bool isDark) {
    if (type == 'income') {
      return isDark ? AppColors.incomeDark : AppColors.incomeLight;
    } else if (type == 'expense') {
      return isDark ? AppColors.expenseDark : AppColors.expenseLight;
    } else if (type == 'profit') {
      return isDark ? AppColors.profitDark : AppColors.profitLight;
    } else {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getColor(isDark);

    return AppCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.labelLight.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              if (icon != null)
                Icon(icon, color: color, size: 24),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTypography.kpiLight.copyWith(color: color),
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTypography.captionLight.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
