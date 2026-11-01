import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/index.dart';
import '../../l10n/app_localizations.dart';
import '../data/auth_service.dart';
import '../data/auth_providers.dart';

final languageProvider = StateProvider<String>((ref) {
  return 'en'; // Default to English
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

class MyAccountScreen extends ConsumerStatefulWidget {
  const MyAccountScreen({super.key});

  @override
  ConsumerState<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends ConsumerState<MyAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final language = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myAccount),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: profile.when(
        data: (userProfile) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile card
              AppCard(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(userProfile?.fullName ?? ''),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: colors.charcoal900,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userProfile?.fullName ?? 'User',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleBgColor(
                          userProfile?.role,
                          colors,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getRoleLabel(userProfile?.role, l10n),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getRoleTextColor(
                            userProfile?.role,
                            colors,
                          ),
                        ),
                      ),
                    ),
                    if (userProfile?.phone != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        userProfile!.phone!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings section
              SectionHeader(
                title: l10n.settings,
                action: null,
              ),
              const SizedBox(height: 12),

              // Language
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.language, color: colors.primary),
                        const SizedBox(width: 12),
                        Text(
                          l10n.language,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: language,
                      underline: SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'ur',
                          child: Text('اردو'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(languageProvider.notifier).state = value;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Theme
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.displayMode,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    DropdownButton<ThemeMode>(
                      value: themeMode,
                      underline: SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(l10n.light),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(l10n.dark),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(l10n.system),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(themeModeProvider.notifier).state = value;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              SectionHeader(
                title: l10n.actions,
                action: null,
              ),
              const SizedBox(height: 12),

              // Change password
              AppCard(
                onTap: () {
                  context.push('/change-password');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_outline, color: colors.primary),
                        const SizedBox(width: 12),
                        Text(
                          l10n.changePassword,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward, color: colors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // About
              AppCard(
                onTap: () {
                  context.push('/about');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: colors.primary),
                        const SizedBox(width: 12),
                        Text(
                          l10n.about,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward, color: colors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Logout
              AppButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.logout),
                      content: Text(l10n.confirmLogout),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.logout),
                        ),
                      ],
                    ),
                  );

                  if (confirmed ?? false) {
                    final authService = ref.read(authServiceProvider);
                    await authService.signOut();
                    if (mounted) {
                      context.go('/login');
                    }
                  }
                },
                label: l10n.logout,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('Error loading profile'),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _getRoleLabel(String? role, AppLocalizations l10n) {
    switch (role) {
      case 'admin':
        return l10n.admin;
      case 'accountant':
        return l10n.accountant;
      case 'manager':
        return l10n.manager;
      default:
        return '';
    }
  }

  Color _getRoleBgColor(String? role, AppColors colors) {
    switch (role) {
      case 'admin':
        return colors.primary.withOpacity(0.1);
      case 'accountant':
        return colors.success.withOpacity(0.1);
      case 'manager':
        return colors.info.withOpacity(0.1);
      default:
        return colors.border;
    }
  }

  Color _getRoleTextColor(String? role, AppColors colors) {
    switch (role) {
      case 'admin':
        return colors.primary;
      case 'accountant':
        return colors.success;
      case 'manager':
        return colors.info;
      default:
        return colors.textSecondary;
    }
  }
}
