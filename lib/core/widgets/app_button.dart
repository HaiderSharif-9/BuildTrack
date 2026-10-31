import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;
  final bool isSmall;
  final IconData? icon;

  const AppButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.isSmall = false,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = isSmall
        ? EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm)
        : EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg);

    final backgroundColor = isSecondary
        ? (isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt)
        : AppColors.primary;

    final foregroundColor = isSecondary
        ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
        : AppColors.textOnGold;

    final child = isLoading
        ? SizedBox(
            width: isSmall ? 16 : 20,
            height: isSmall ? 16 : 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: isSmall ? 16 : 20),
                SizedBox(width: AppSpacing.sm),
              ],
              Text(label),
            ],
          );

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      child: child,
    );
  }
}
