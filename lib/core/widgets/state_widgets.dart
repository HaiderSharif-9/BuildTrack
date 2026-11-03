import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? action;
  final VoidCallback? onAction;

  const EmptyState({
    required this.title,
    this.subtitle,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.onRetry,
    this.action,
    this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSubtitle = subtitle ?? description;
    final actionCallback = onAction ?? onRetry;
    final buttonLabel = action ?? 'Try Again';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.subtitleLight.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (textSubtitle != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                textSubtitle,
                style: AppTypography.bodyLight.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionCallback != null) ...[
              SizedBox(height: AppSpacing.lg),
              AppButton(
                label: buttonLabel,
                onPressed: actionCallback,
                isSmall: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String? title;
  final String? message;
  final String? error;
  final VoidCallback? onRetry;

  const ErrorState({
    this.title,
    this.message,
    this.error,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: title ?? 'Error',
      subtitle: message ?? error,
      icon: Icons.error_outline,
      onRetry: onRetry,
    );
  }
}

class ShimmerSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerSkeleton({
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
    super.key,
  });

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;
    final highlightColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [baseColor, highlightColor, baseColor],
          stops: [
            0,
            _controller.value,
            1,
          ],
        ).createShader(bounds);
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(AppRadius.button),
        ),
      ),
    );
  }
}
