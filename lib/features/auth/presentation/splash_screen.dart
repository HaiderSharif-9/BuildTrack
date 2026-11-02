import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_service.dart';
import '../data/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _checkAuthState();
    });
  }

  void _checkAuthState() async {
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;

    if (!mounted) return;

    if (currentUser == null) {
      // No session, go to login
      context.go('/login');
      return;
    }

    // User is logged in, check if they must change password
    try {
      final profile = await ref.read(currentProfileProvider.future);
      if (mounted) {
        if (profile?.mustChangePassword ?? false) {
          context.go('/change-password');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.charcoal900,
              AppColors.charcoal700,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder (SVG will be here)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '◆',
                    style: TextStyle(
                      fontSize: 48,
                      color: AppColors.charcoal900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'BuildTrack',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'by Care Constructiona Pvt Ltd',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Building Today | For A Better Tomorrow',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.goldTextLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
