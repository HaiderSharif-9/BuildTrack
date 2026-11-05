import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/index.dart';
import '../../../core/widgets/buildtrack_brand.dart';
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
  bool _emailConfirmationRequired = false;
  String _registeredEmail = '';

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
        setState(() {
          _registeredEmail = _emailController.text.trim();
          _emailConfirmationRequired = true;
        });
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

    if (_emailConfirmationRequired) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.charcoal900, AppColors.charcoal700],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: AppCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.mark_email_read_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Check your email',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We sent a verification link to:',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _registeredEmail,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Open the email and tap the confirmation link. '
                        'Check your Spam or Junk folder too. After confirming, '
                        'return here and continue to the login page.',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        onPressed: () => context.go('/login'),
                        label: 'I have confirmed my email — Go to Login',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: AppColors.lightTextPrimary),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const BuildTrackBrand(iconSize: 64),
            const SizedBox(height: 24),
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
                    hint: l10n.confirmPassword,
                    
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
                  if (_errorMessage != null)
                    const SizedBox(height: 16),
                  AppButton(
                    onPressed:
                        _isLoading ? () {} : _handleSignUp,
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
