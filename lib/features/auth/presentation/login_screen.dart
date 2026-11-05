import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/index.dart';
import '../../../core/widgets/buildtrack_brand.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _loginIdController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loginIdController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithPhoneOrEmail(
        loginId: _loginIdController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        context.go('/home');
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.charcoal900,
                AppColors.charcoal700,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BuildTrackBrand(iconSize: 80),
                const SizedBox(height: 4),
                Text(
                  l10n.appSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.goldTextLight,
                  ),
                ),
                const SizedBox(height: 32),

                // Login form
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.login,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),

                      // Login ID (phone or email)
                      AppTextField(
                        controller: _loginIdController,
                        label: l10n.phoneOrEmail,
                        hint: l10n.enterPhoneOrEmail,
                        
                        keyboardType: TextInputType.text,
                        
                      ),
                      const SizedBox(height: 16),

                      // Password
                      AppTextField(
                        controller: _passwordController,
                        label: l10n.password,
                        hint: l10n.enterPassword,
                        
                        obscure: !_showPassword,
                        suffixIcon: _showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        onSuffixTap: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // Forgot password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  context.push('/forgot-password');
                                },
                          child: Text(
                            l10n.forgotPassword,
                            style: const TextStyle(
                              color: AppColors.goldTextLight,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Error message
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.expenseLight.withValues(alpha: 0.1),
                            border: Border.all(
                              color: AppColors.expenseLight,
                            ),
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

                      // Login button
                      AppButton(
                        onPressed: () {
                                if (_isLoading) return;
                                if (_loginIdController.text.isEmpty ||
                                    _passwordController.text.isEmpty) {
                                  setState(() {
                                    _errorMessage =
                                        l10n.pleaseEnterCredentials;
                                  });
                                  return;
                                }
                                _handleLogin();
                              },
                        isLoading: _isLoading,
                        label: l10n.login,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
