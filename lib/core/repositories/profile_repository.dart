import '../models/profile.dart';
import 'base_repository.dart';

class ProfileRepository extends BaseRepository {
  ProfileRepository(super.supabase);

  /// Get current user profile
  Future<Profile?> getCurrentProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get profile by ID (admin/accountant can view others)
  Future<Profile> getProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// List all profiles (admin only)
  Future<List<Profile>> listProfiles() async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .order('full_name');

      return (response as List).map((e) => Profile.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// List active users (admin/accountant)
  Future<List<Profile>> listActiveUsers() async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('active', true)
          .order('full_name');

      return (response as List).map((e) => Profile.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Update profile (user can update own, admin can update any)
  Future<Profile> updateProfile(Profile profile) async {
    try {
      final response = await supabase
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Clear must_change_password flag
  Future<void> clearMustChangePassword(String userId) async {
    try {
      if (supabase.auth.currentUser?.id != userId) {
        throw Exception('You can only update your own password-change status');
      }
      await supabase.rpc('clear_own_must_change_password');
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Set user active status (admin only)
  Future<void> setUserActive(String userId, bool active) async {
    try {
      await supabase.rpc(
        'admin_set_active',
        params: {
          'p_user_id': userId,
          'p_active': active,
        },
      );
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}
