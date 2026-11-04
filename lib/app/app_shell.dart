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

  void _goBranch(int branchIndex) {
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.appColors;

    return userRole.when(
      data: (role) {
        final tabs = _getVisibleTabs(role, l10n);
        final selectedTabIndex = tabs.indexWhere((tab) => tab.branchIndex == navigationShell.currentIndex);

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                top: BorderSide(
                  color: colors.border,
                  width: 1,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: selectedTabIndex < 0 ? 0 : selectedTabIndex,
              onDestinationSelected: (index) => _goBranch(tabs[index].branchIndex),
              backgroundColor: colors.surface,
              indicatorColor: AppColors.primary.withValues(alpha: 0.15),
              height: 64,
              destinations: tabs.map((tab) {
                if (tab.route == '/attendance') {
                  return NavigationDestination(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: AppColors.textOnGold, size: 20),
                    ),
                    selectedIcon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: AppColors.textOnGold, size: 20),
                    ),
                    label: tab.label,
                  );
                }
                return NavigationDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.selectedIcon),
                  label: tab.label,
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => const Scaffold(
        body: Center(
          child: Text('Error loading role'),
        ),
      ),
    );
  }

  List<_NavTab> _getVisibleTabs(String? role, AppLocalizations l10n) {
    final tabs = <_NavTab>[
      _NavTab(
        branchIndex: 0,
        label: l10n.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_filled,
        route: '/home',
      ),
      _NavTab(
        branchIndex: 1,
        label: l10n.sites,
        icon: Icons.business_outlined,
        selectedIcon: Icons.business,
        route: '/sites',
      ),
      _NavTab(
        branchIndex: 2,
        label: l10n.attendance,
        icon: Icons.check_circle_outline,
        selectedIcon: Icons.check_circle,
        route: '/attendance',
      ),
    ];

    if (role == 'admin' || role == 'accountant') {
      tabs.add(
        _NavTab(
          branchIndex: 3,
          label: l10n.money,
          icon: Icons.account_balance_wallet_outlined,
          selectedIcon: Icons.account_balance_wallet,
          route: '/money',
        ),
      );
    }

    tabs.add(
      _NavTab(
        branchIndex: 4,
        label: l10n.more,
        icon: Icons.more_horiz,
        selectedIcon: Icons.more_horiz,
        route: '/more',
      ),
    );
    return tabs;
  }
}}

class _NavTab {
  final int branchIndex;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  _NavTab({
    required this.branchIndex,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}
