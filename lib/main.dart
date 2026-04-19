import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/student_dashboard.dart';
import 'services/supabase_config.dart';
import 'services/data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    debugPrint('✓ Supabase initialized');
  } catch (e) {
    debugPrint('❌ Supabase init error: $e');
  }

  runApp(const VidyaSarathiApp());
}

class VidyaSarathiApp extends StatelessWidget {
  const VidyaSarathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VidyaSarathi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
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

// ─── No Role Selector Needed - Direct Login ──────────────────────────────────
