import 'package:flutter/foundation.dart';

// Supabase Configuration
// The anon key is intentionally public — it's safe to embed in client apps.
// It only allows access based on your Row Level Security (RLS) policies.
class SupabaseConfig {
  static const String url = 'https://qhxrvagofgthruceztpc.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFoeHJ2YWdvZmd0aHJ1Y2V6dHBjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM0OTg4ODEsImV4cCI6MjA4OTA3NDg4MX0.1Gqqki182T49daytZ6vRhNxoF4AIHe8Nbv2HnPYluJw';

  // Legacy property names for backward compatibility
  static const String supabaseUrl = url;
  static const String supabaseAnonKey = anonKey;

  static const String appName = 'VidyaSarathi';
  static bool get isDebugMode => kDebugMode;

  static bool validateConfiguration() {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}
