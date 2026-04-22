import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Supabase Configuration
// Values are loaded from the .env file for security and flexibility.
class SupabaseConfig {
  static String get url => dotenv.get('SUPABASE_URL', fallback: 'https://qhxrvagofgthruceztpc.supabase.co');
  static String get anonKey => dotenv.get('SUPABASE_ANON_KEY', fallback: '');
  static String get serviceRoleKey => dotenv.get('SUPABASE_SERVICE_ROLE_KEY', fallback: '');
  
  static String get sbPublishableKey => dotenv.get('SB_PUBLISHABLE_KEY', fallback: '');
  static String get sbSecretKey => dotenv.get('SB_SECRET_KEY', fallback: '');

  // Legacy property names for backward compatibility
  static String get supabaseUrl => url;
  static String get supabaseAnonKey => anonKey;

  static String get appName => dotenv.get('APP_NAME', fallback: 'VidyaSarathi');
  static bool get isDebugMode => kDebugMode || (dotenv.get('DEBUG_MODE', fallback: 'false') == 'true');

  static bool validateConfiguration() {
    return url.isNotEmpty && anonKey.isNotEmpty;
  }
}
