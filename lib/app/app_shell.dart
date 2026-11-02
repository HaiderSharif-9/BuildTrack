import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../features/auth/data/auth_providers.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);
    final l10n = AppLocalizations.of(context)!;

    return userRole.when(
      data: (role) {
        // Define visible tabs based on role
        final tabs = _getVisibleTabs(role, l10n);

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              backgroundColor: AppColors.lightSurface,
              indicatorColor: AppColors.primary.withOpacity(0.1),
              height: 64,
              destinations: tabs
                  .map((tab) => NavigationDestination(
                        icon: Icon(tab.icon),
                        selectedIcon: Icon(tab.selectedIcon),
                        label: tab.label,
                      ))
                  .toList(),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Error loading role'),
        ),
      ),
    );
  }

  List<_NavTab> _getVisibleTabs(String? role, AppLocalizations l10n) {
    final allTabs = [
      _NavTab(
        label: l10n.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_filled,
        route: '/home',
      ),
      _NavTab(
        label: l10n.sites,
        icon: Icons.business_outlined,
        selectedIcon: Icons.business,
        route: '/sites',
      ),
      _NavTab(
        label: l10n.attendance,
        icon: Icons.check_circle_outline,
        selectedIcon: Icons.check_circle,
        route: '/attendance',
      ),
      _NavTab(
        label: l10n.money,
        icon: Icons.account_balance_wallet_outlined,
        selectedIcon: Icons.account_balance_wallet,
        route: '/money',
      ),
      _NavTab(
        label: l10n.more,
        icon: Icons.more_horiz,
        selectedIcon: Icons.more_horiz,
        route: '/more',
      ),
    ];

    // Managers see all tabs
    if (role == 'manager') {
      return allTabs;
    }

    // Admin and accountant see all tabs
    return allTabs;
  }
}

class _NavTab {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  _NavTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}
