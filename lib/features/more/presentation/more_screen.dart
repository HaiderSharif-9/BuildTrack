import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/data/auth_service.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final userProfile = ref.watch(currentProfileProvider).valueOrNull;
    final isAdmin = userProfile?.role == 'admin';

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.more),
        backgroundColor: colors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User brief card
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    userProfile?.fullName.isNotEmpty == true ? userProfile!.fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textOnGold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile?.fullName ?? 'User Profile',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userProfile?.role.toUpperCase() ?? 'BUILDTRACK USER',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.goldTextLight),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () => context.push('/more/account'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Management Modules',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colors.textSecondary),
          ),
          const SizedBox(height: 10),

          // Labour Management
          _buildMenuTile(
            icon: Icons.engineering_outlined,
            title: l10n.labour,
            subtitle: 'Workers list, default daily rates & trade categories',
            onTap: () => context.push('/more/labour'),
            colors: colors,
            theme: theme,
          ),
          const SizedBox(height: 10),

          // Reports
          _buildMenuTile(
            icon: Icons.bar_chart_outlined,
            title: l10n.reports,
            subtitle: 'Profit & Loss, Site margins & attendance analytics',
            onTap: () => context.push('/more/reports'),
            colors: colors,
            theme: theme,
          ),
          const SizedBox(height: 10),

          // Team & Users (Admin only)
          if (isAdmin) ...[
            _buildMenuTile(
              icon: Icons.manage_accounts_outlined,
              title: 'Team & Users',
              subtitle: 'View team members and create accounts',
              onTap: () => context.push('/more/users'),
              colors: colors,
              theme: theme,
            ),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 10),
          Text(
            l10n.settings,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colors.textSecondary),
          ),
          const SizedBox(height: 10),

          // My Account
          _buildMenuTile(
            icon: Icons.person_outline,
            title: l10n.myAccount,
            subtitle: 'Password change, theme mode & language',
            onTap: () => context.push('/more/account'),
            colors: colors,
            theme: theme,
          ),
          const SizedBox(height: 10),

          // About BuildTrack
          _buildMenuTile(
            icon: Icons.info_outline,
            title: l10n.about,
            subtitle: 'Care Constructiona Pvt Ltd • Version 1.0.0',
            onTap: () => context.push('/more/about'),
            colors: colors,
            theme: theme,
          ),
          const SizedBox(height: 24),

          // Logout Button
          OutlinedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.red),
            label: Text(l10n.logout, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final auth = ref.read(authServiceProvider);
              await auth.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required AppColorsValue colors,
    required ThemeData theme,
  }) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Icon(icon, color: AppColors.goldTextLight, size: 20),
        ),
        title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary, fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}

