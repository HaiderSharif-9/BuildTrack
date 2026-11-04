import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/debug/debug_ui_kit.dart';
import '../core/theme/app_theme.dart';
import '../features/attendance/presentation/attendance_screen.dart';
import '../features/auth/presentation/change_password_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/my_account_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/labour/presentation/labour_screen.dart';
import '../features/money/presentation/money_screen.dart';
import '../features/more/presentation/more_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/users_screen.dart';
import '../features/sites/presentation/site_detail_screen.dart';
import '../features/sites/presentation/sites_screen.dart';
import 'app_shell.dart';

/// Router provider for go_router
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Splash screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // Main app with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
        ),
        branches: [
          // 0: Home branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // 1: Sites branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sites',
                builder: (context, state) => const SitesScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => SiteDetailScreen(
                      siteId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 2: Attendance branch (center)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/attendance',
                builder: (context, state) => const AttendanceScreen(),
              ),
            ],
          ),
          // 3: Money branch (Ledger, Payroll, Purchases)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/money',
                builder: (context, state) => const MoneyScreen(),
              ),
            ],
          ),
          // 4: More branch (Labour, Reports, Users, Account, About)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
                routes: [
                  GoRoute(
                    path: 'labour',
                    builder: (context, state) => const LabourScreen(),
                  ),
                  GoRoute(
                    path: 'reports',
                    builder: (context, state) => const ReportsScreen(),
                  ),
                  GoRoute(
                    path: 'users',
                    builder: (context, state) => const UsersScreen(),
                  ),
                  GoRoute(
                    path: 'account',
                    builder: (context, state) => const MyAccountScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Debug UI Kit
      GoRoute(
        path: '/debug',
        builder: (context, state) => const DebugUiKitScreen(),
      ),
    ],
  );
});

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About BuildTrack')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.apartment, size: 40, color: AppColors.textOnGold),
              ),
              const SizedBox(height: 16),
              const Text(
                'BuildTrack',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(height: 4),
              const Text(
                'Care Constructiona Pvt Ltd, Multan',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'BUILDING TODAY | FOR A BETTER TOMORROW',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text('Version 1.0.0+1', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
