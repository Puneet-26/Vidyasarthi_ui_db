import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/student_dashboard.dart';
import 'services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✓ .env loaded');
  } catch (e) {
    debugPrint('❌ Dotenv load error: $e');
  }

  // Log and validate environment configuration.
  SupabaseConfig.logValidation();
  final supabaseOk = SupabaseConfig.validateConfiguration();

  if (supabaseOk) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      debugPrint('✓ Supabase initialized');
    } catch (e) {
      debugPrint('❌ Supabase init error: $e');
    }
  } else {
    debugPrint('⚠️ Skipping Supabase.initialize() due to missing config.');
  }

  runApp(VidyaSarathiApp(supabaseAvailable: supabaseOk));
}

class VidyaSarathiApp extends StatelessWidget {
  final bool supabaseAvailable;

  const VidyaSarathiApp({super.key, this.supabaseAvailable = true});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VidyaSarathi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: supabaseAvailable ? const LoginScreen() : _StartupErrorScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/loading': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map) {
            return LoadingScreen(
              role: (args['role'] as String?) ?? 'student',
              userEmail: args['email'] as String?,
            );
          }
          final role = args as String? ?? 'student';
          return LoadingScreen(role: role);
        },
        '/dashboard': (context) {
          final destination =
              ModalRoute.of(context)?.settings.arguments as Widget?;
          return destination ?? const StudentDashboard();
        },
      },
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Configuration Error')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Supabase configuration is missing or invalid.\nPlease add SUPABASE_URL and SUPABASE_ANON_KEY to your .env file and include it in pubspec.yaml assets.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  SupabaseConfig.logValidation();
                },
                child: const Text('Re-check configuration (logs)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── No Role Selector Needed - Direct Login ──────────────────────────────────
