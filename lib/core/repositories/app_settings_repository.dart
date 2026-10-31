import '../models/app_settings.dart';
import 'base_repository.dart';

class AppSettingsRepository extends BaseRepository {
  AppSettingsRepository(super.supabase);

  /// Fetch the single app settings row
  Future<AppSettings> getSettings() async {
    try {
      final response = await supabase
          .from('app_settings')
          .select()
          .limit(1)
          .single();

      return AppSettings.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// Fetch only full_day_hours (public, used by managers)
  Future<int> getFullDayHours() async {
    try {
      final response = await supabase.rpc(
        'public_config',
      );

      if (response is Map) {
        return response['full_day_hours'] as int;
      }
      return 10; // fallback
    } catch (e) {
      return 10; // fallback
    }
  }

  /// Update app settings (admin only)
  Future<AppSettings> updateSettings(AppSettings settings) async {
    try {
      final response = await supabase
          .from('app_settings')
          .update(settings.toJson())
          .eq('id', settings.id)
          .select()
          .single();

      return AppSettings.fromJson(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}
