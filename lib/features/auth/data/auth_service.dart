import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception for auth operations
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Auth service for Supabase operations
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user session
  Session? get currentSession => _supabase.auth.currentSession;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Stream of auth state changes
  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;

  /// Sign up with email and password (first admin only, dev mode)
  Future<void> signUpFirstAdmin({
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw AuthException('Sign up failed');
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Sign up error: ${e.toString()}');
    }
  }

  /// Sign in with phone or email + password
  Future<void> signInWithPhoneOrEmail({
    required String loginId, // phone or email
    required String password,
  }) async {
    try {
      // If it looks like a phone number, convert to synthetic email
      String email = loginId;
      if (_isPhoneNumber(loginId)) {
        email = _phoneToSyntheticEmail(loginId);
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Invalid phone/email or password');
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        throw AuthException('Invalid phone/email or password');
      }
      throw AuthException('Sign in error: ${e.toString()}');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException('Password reset error: ${e.toString()}');
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      await _supabase.rpc('clear_own_must_change_password');
    } catch (e) {
      throw AuthException('Password update error: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException('Sign out error: ${e.toString()}');
    }
  }

  /// Refresh session
  Future<void> refreshSession() async {
    try {
      await _supabase.auth.refreshSession();
    } catch (e) {
      throw AuthException('Session refresh error: ${e.toString()}');
    }
  }

  // Helper: check if string is a phone number (digits only, 10-12 chars)
  bool _isPhoneNumber(String value) {
    return RegExp(r'^[0-9]{10,12}$').hasMatch(value.replaceAll(RegExp(r'\D'), ''));
  }

  // Helper: convert phone to synthetic email
  String _phoneToSyntheticEmail(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return '$digits@users.careconstructiona.app';
  }
}

/// Riverpod provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth state provider - listens to Supabase auth changes
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateStream;
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  // Recompute the current user whenever Supabase emits a sign-in/sign-out event.
  ref.watch(authStateProvider);
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});

/// Current session provider
final currentSessionProvider = Provider<Session?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentSession;
});
