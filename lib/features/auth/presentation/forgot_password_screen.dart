import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/index.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_service.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late TextEditingController _emailController;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final l10n = AppLocalizations.of(context)!;

    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = l10n.pleaseEnterEmail);
      return;
    }

    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendPasswordResetEmail(_emailController.text.trim());

      setState(() =>
          _successMessage = l10n.passwordResetEmailSent);

      // Auto-close after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          context.pop();
        }
      });
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() =>
          _errorMessage = 'Failed to send reset email. Please try again.');
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
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: colors.textPrimary),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.mail_outline,
              size: 48,
              color: colors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.resetPassword,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.enterEmailToResetPassword,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppCard(
              child: Column(
                children: [
                  AppTextField(
                    controller: _emailController,
                    label: l10n.email,
                    hint: l10n.enterEmail,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.error.withOpacity(0.1),
                        border: Border.all(color: colors.error),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: colors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (_successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.success.withOpacity(0.1),
                        border: Border.all(color: colors.success),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: TextStyle(
                                color: colors.success,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_errorMessage != null || _successMessage != null)
                    const SizedBox(height: 16),
                  AppButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    isLoading: _isLoading,
                    label: l10n.sendResetEmail,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
