import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/profile.dart';
import '../../../core/repositories/profile_repository.dart';
import 'auth_service.dart';

/// Profile repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

/// Current user's profile provider
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final profileRepo = ref.watch(profileRepositoryProvider);
  try {
    return await profileRepo.getProfile(user.id);
  } catch (e) {
    return null;
  }
});

/// Whether current user must change password on first login
final mustChangePasswordProvider = FutureProvider<bool>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  return profile?.mustChangePassword ?? false;
});

/// Current user's role (admin, accountant, manager)
final currentUserRoleProvider = FutureProvider<String?>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  return profile?.role;
});

/// Check if current user is admin
final isAdminProvider = FutureProvider<bool>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  return profile?.isAdmin ?? false;
});

/// Check if current user is accountant
final isAccountantProvider = FutureProvider<bool>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  return profile?.isAccountant ?? false;
});

/// Check if current user is manager
final isManagerProvider = FutureProvider<bool>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  return profile?.isManager ?? false;
});
