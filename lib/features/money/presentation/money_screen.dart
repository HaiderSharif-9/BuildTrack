import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../ledger/presentation/ledger_screen.dart';
import '../../payments/presentation/payments_screen.dart';
import '../../purchases/presentation/purchases_screen.dart';

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({super.key});

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Money & Finance'),
        backgroundColor: colors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.goldTextLight,
          unselectedLabelColor: colors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Ledger', icon: Icon(Icons.account_balance_wallet_outlined, size: 20)),
            Tab(text: 'Payroll', icon: Icon(Icons.people_outline, size: 20)),
            Tab(text: 'Purchases', icon: Icon(Icons.shopping_cart_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LedgerScreen(),
          PaymentsScreen(),
          PurchasesScreen(),
        ],
      ),
    );
  }
}

