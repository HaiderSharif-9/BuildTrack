import 'package:flutter/material.dart';
import '../widgets/index.dart';
import '../theme/app_theme.dart';

class DebugUiKitScreen extends StatefulWidget {
  const DebugUiKitScreen({super.key});

  @override
  State<DebugUiKitScreen> createState() => _DebugUiKitScreenState();
}

class _DebugUiKitScreenState extends State<DebugUiKitScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? buildDarkTheme() : buildLightTheme(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('BuildTrack UI Kit'),
            actions: [
              IconButton(
                icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buttons
                const SectionHeader(title: 'Buttons', subtitle: 'Primary, Secondary, Small'),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    AppButton(label: 'Primary', onPressed: () {}),
                    AppButton(label: 'Secondary', onPressed: () {}, isSecondary: true),
                    AppButton(label: 'Small', onPressed: () {}, isSmall: true),
                    AppButton(label: 'Loading', onPressed: () {}, isLoading: true),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Cards
                const SectionHeader(title: 'Cards', subtitle: 'Container component'),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Card Title', style: AppTypography.subtitleLight),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'This is a content card with padding and border.',
                        style: AppTypography.bodyLight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // KPI Cards
                const SectionHeader(title: 'KPI Cards', subtitle: 'Data display cards'),
                const SizedBox(height: AppSpacing.md),
                const Column(
                  children: [
                    KpiCard(
                      label: 'Total Income',
                      value: 'Rs. 2,450,000',
                      type: 'income',
                      icon: Icons.trending_up,
                    ),
                    SizedBox(height: AppSpacing.md),
                    KpiCard(
                      label: 'Total Expenses',
                      value: 'Rs. 1,780,000',
                      type: 'expense',
                      icon: Icons.trending_down,
                    ),
                    SizedBox(height: AppSpacing.md),
                    KpiCard(
                      label: 'Net Profit',
                      value: 'Rs. 670,000',
                      type: 'profit',
                      icon: Icons.wallet,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Amount Text
                const SectionHeader(title: 'Amount Text', subtitle: 'Money formatting'),
                const SizedBox(height: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AmountText(
                      amount: '1,200.00',
                      type: 'income',
                      style: AppTypography.kpiLight,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AmountText(
                      amount: '850.50',
                      type: 'expense',
                      style: AppTypography.kpiLight,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Status Chips
                const SectionHeader(title: 'Status Chips', subtitle: 'Semantic colors'),
                const SizedBox(height: AppSpacing.md),
                const Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    StatusChip(label: 'Present', type: 'income'),
                    StatusChip(label: 'Absent', type: 'expense'),
                    StatusChip(label: 'Leave', type: 'warning'),
                    StatusChip(label: 'Selected', type: 'default', selected: true),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Text Input
                const SectionHeader(title: 'Text Input', subtitle: 'Form fields'),
                const SizedBox(height: AppSpacing.md),
                const AppTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  obscure: true,
                  prefixIcon: Icons.lock,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Skeleton Loaders
                const SectionHeader(title: 'Skeleton Loaders', subtitle: 'Loading states'),
                const SizedBox(height: AppSpacing.md),
                const Column(
                  children: [
                    ShimmerSkeleton(height: 60),
                    SizedBox(height: AppSpacing.md),
                    ShimmerSkeleton(height: 40),
                    SizedBox(height: AppSpacing.md),
                    ShimmerSkeleton(height: 80),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Empty States
                const SectionHeader(title: 'States', subtitle: 'Empty, Error, Loading'),
                const SizedBox(height: AppSpacing.md),
                const AppCard(
                  child: EmptyState(
                    title: 'No Data Found',
                    subtitle: 'Check back later',
                    icon: Icons.inbox_outlined,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Color Palette
                const SectionHeader(title: 'Color Palette', subtitle: 'Fixed charcoal + gold'),
                const SizedBox(height: AppSpacing.md),
                _buildColorGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      children: [
        _colorBox('Primary', AppColors.primary),
        _colorBox('Income', AppColors.incomeLight),
        _colorBox('Expense', AppColors.expenseLight),
        _colorBox('Profit', AppColors.profitLight),
        _colorBox('Warning', AppColors.warningLight),
        _colorBox('Charcoal', AppColors.charcoal900),
      ],
    );
  }

  Widget _colorBox(String label, Color color) {
    return AppCard(
      padding: EdgeInsets.zero,
      backgroundColor: color,
      child: Center(
        child: Text(
          label,
          style: AppTypography.labelLight.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
