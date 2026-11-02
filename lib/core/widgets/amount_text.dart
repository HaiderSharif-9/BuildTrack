import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AmountText extends StatelessWidget {
  final String amount;
  final String type; // 'income', 'expense', 'default'
  final TextStyle? style;
  final bool showSign;

  const AmountText({
    required this.amount,
    this.type = 'default',
    this.style,
    this.showSign = true,
    super.key,
  });

  Color _getColor(bool isDark) {
    if (type == 'income') {
      return isDark ? AppColors.incomeDark : AppColors.incomeLight;
    } else if (type == 'expense') {
      return isDark ? AppColors.expenseDark : AppColors.expenseLight;
    } else {
      return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    }
  }

  String _formatAmount() {
    if (!showSign) return amount;
    if (type == 'income') return '+ $amount';
    if (type == 'expense') return '- $amount';
    return amount;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getColor(isDark);

    return Text(
      _formatAmount(),
      style: (style ?? AppTypography.bodyLight).copyWith(
        color: color,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}
