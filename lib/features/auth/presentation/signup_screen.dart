import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/index.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_service.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final l10n = AppLocalizations.of(context)!;

    // Validation
    if (_fullNameController.text.isEmpty) {
      setState(() => _errorMessage = l10n.pleaseEnterFullName);
      return;
    }
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = l10n.pleaseEnterEmail);
      return;
    }
    if (_passwordController.text.length < 8) {
      setState(() =>
          _errorMessage = l10n.passwordMustBeAtLeast8Characters);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = l10n.passwordsDoNotMatch);
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUpFirstAdmin(
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Show success and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.accountCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login');
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() =>
          _errorMessage = 'Sign up failed. Please try again.');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: AppColors.lightTextPrimary),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              l10n.createFirstAdminAccount,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.devModeMessage,
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
                    controller: _fullNameController,
                    label: l10n.fullName,
                    hint: l10n.enterFullName,
                    
                    
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _emailController,
                    label: l10n.email,
                    hint: l10n.enterEmail,
                    
                    keyboardType: TextInputType.emailAddress,
                    
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    label: l10n.password,
                    hint: l10n.enterPassword,
                    
                    obscure: !_showPassword,
                    suffixIcon: _showPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onSuffixTap: () {
                      setState(() =>
                          _showPassword = !_showPassword);
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _confirmPasswordController,
                    label: l10n.confirmPassword,
                    hint: l10n.confirmPasswordHint,
                    
                    obscure: !_showConfirmPassword,
                    suffixIcon: _showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onSuffixTap: () {
                      setState(() =>
                          _showConfirmPassword = !_showConfirmPassword);
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.expenseLight.withOpacity(0.1),
                        border: Border.all(color: AppColors.expenseLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: AppColors.expenseLight,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (_errorMessage != null)
                    const SizedBox(height: 16),
                  AppButton(
                    onPressed:
                        _isLoading ? null : _handleSignUp,
                    isLoading: _isLoading,
                    label: l10n.createAccount,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
