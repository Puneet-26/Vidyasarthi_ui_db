import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Supabase Configuration
// The anon key is intentionally public — it's safe to embed in client apps.
// It only allows access based on your Row Level Security (RLS) policies.
class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
      '';

  // Legacy property names for backward compatibility
  static String get supabaseUrl => url;
  static String get supabaseAnonKey => anonKey;

  static const String appName = 'VidyaSarathi';
  static bool get isDebugMode => kDebugMode;

  static bool validateConfiguration() {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}
