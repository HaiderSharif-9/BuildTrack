import 'package:supabase_flutter/supabase_flutter.dart';

/// Base repository for Supabase operations with error handling
abstract class BaseRepository {
  final SupabaseClient supabase;

  BaseRepository([SupabaseClient? client])
      : supabase = client ?? Supabase.instance.client;

  /// Handle database errors with friendly messages
  String handleError(dynamic error) {
    if (error is PostgrestException) {
      if (error.message.contains('permission')) {
        return 'You do not have permission to perform this action';
      }
      if (error.message.contains('unique')) {
        return 'This record already exists';
      }
      return error.message;
    }
    return 'An unexpected error occurred';
  }
}
