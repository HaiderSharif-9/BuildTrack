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
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buttons
                SectionHeader(title: 'Buttons', subtitle: 'Primary, Secondary, Small'),
                SizedBox(height: AppSpacing.md),
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
                SizedBox(height: AppSpacing.xxl),

                // Cards
                SectionHeader(title: 'Cards', subtitle: 'Container component'),
                SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Card Title', style: AppTypography.subtitleLight),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'This is a content card with padding and border.',
                        style: AppTypography.bodyLight,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xxl),

                // KPI Cards
                SectionHeader(title: 'KPI Cards', subtitle: 'Data display cards'),
                SizedBox(height: AppSpacing.md),
                Column(
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
                SizedBox(height: AppSpacing.xxl),

                // Amount Text
                SectionHeader(title: 'Amount Text', subtitle: 'Money formatting'),
                SizedBox(height: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AmountText(
                      amount: '1,200.00',
                      type: 'income',
                      style: AppTypography.kpiLight,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AmountText(
                      amount: '850.50',
                      type: 'expense',
                      style: AppTypography.kpiLight,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xxl),

                // Status Chips
                SectionHeader(title: 'Status Chips', subtitle: 'Semantic colors'),
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    StatusChip(label: 'Present', type: 'income'),
                    StatusChip(label: 'Absent', type: 'expense'),
                    StatusChip(label: 'Leave', type: 'warning'),
                    StatusChip(label: 'Selected', type: 'default', selected: true),
                  ],
                ),
                SizedBox(height: AppSpacing.xxl),

                // Text Input
                SectionHeader(title: 'Text Input', subtitle: 'Form fields'),
                SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  obscure: true,
                  prefixIcon: Icons.lock,
                ),
                SizedBox(height: AppSpacing.xxl),

                // Skeleton Loaders
                SectionHeader(title: 'Skeleton Loaders', subtitle: 'Loading states'),
                SizedBox(height: AppSpacing.md),
                Column(
                  children: [
                    ShimmerSkeleton(height: 60),
                    SizedBox(height: AppSpacing.md),
                    ShimmerSkeleton(height: 40),
                    SizedBox(height: AppSpacing.md),
                    ShimmerSkeleton(height: 80),
                  ],
                ),
                SizedBox(height: AppSpacing.xxl),

                // Empty States
                SectionHeader(title: 'States', subtitle: 'Empty, Error, Loading'),
                SizedBox(height: AppSpacing.md),
                AppCard(
                  child: EmptyState(
                    title: 'No Data Found',
                    subtitle: 'Check back later',
                    icon: Icons.inbox_outlined,
                  ),
                ),
                SizedBox(height: AppSpacing.xxl),

                // Color Palette
                SectionHeader(title: 'Color Palette', subtitle: 'Fixed charcoal + gold'),
                SizedBox(height: AppSpacing.md),
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
      physics: NeverScrollableScrollPhysics(),
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
