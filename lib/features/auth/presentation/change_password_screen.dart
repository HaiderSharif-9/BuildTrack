import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/index.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_service.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  final bool isForced;

  const ChangePasswordScreen({
    super.key,
    this.isForced = true,
  });

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final l10n = AppLocalizations.of(context)!;

    if (_newPasswordController.text.length < 8) {
      setState(() =>
          _errorMessage = l10n.passwordMustBeAtLeast8Characters);
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = l10n.passwordsDoNotMatch);
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.updatePassword(_newPasswordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.passwordChangedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() =>
          _errorMessage = 'Failed to change password. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: !widget.isForced,
      child: Scaffold(
        appBar: widget.isForced
            ? null
            : AppBar(
                leading: const BackButton(color: AppColors.lightTextPrimary),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            children: [
              if (widget.isForced) ...[
                const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                l10n.changePassword,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.isForced
                    ? l10n.forceChangePasswordMessage
                    : l10n.enterNewPassword,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      controller: _newPasswordController,
                      label: l10n.newPassword,
                      hint: l10n.enterNewPassword,
                      
                      obscure: !_showPassword,
                      suffixIcon: _showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onSuffixTap: () {
                        setState(() => _showPassword = !_showPassword);
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: l10n.confirmPassword,
                      hint: l10n.confirmPassword,
                      
                      obscure: !_showConfirmPassword,
                      suffixIcon: _showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onSuffixTap: () {
                        setState(
                            () => _showConfirmPassword = !_showConfirmPassword);
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.expenseLight.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.expenseLight),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.expenseLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (_errorMessage != null) const SizedBox(height: 16),
                    AppButton(
                      onPressed: _isLoading ? () {} : _handleChangePassword,
                      isLoading: _isLoading,
                      label: l10n.updatePassword,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
