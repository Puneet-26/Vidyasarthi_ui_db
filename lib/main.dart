import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/student_dashboard.dart';
import 'services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  String? initError;
  
  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✓ Environment variables loaded successfully');
  } catch (e) {
    initError = 'Could not load .env file: $e\nMake sure .env file exists and is in pubspec.yaml assets.';
    debugPrint('⚠ Warning: $initError');
  }
  
  // Validate that required environment variables are set
  if (initError == null && !SupabaseConfig.validateConfiguration()) {
    initError = 'Configuration validation failed. Check your .env file.';
    debugPrint('❌ $initError');
  }
  
  // Initialize Supabase
  if (initError == null) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      debugPrint('✓ Supabase initialized successfully');
      
      // Database and Auth services now dynamically use Supabase.instance.client
      debugPrint('✓ Services ready via dynamic getters');
    } catch (e) {
      initError = 'Supabase initialization error: $e';
      debugPrint('❌ $initError');
    }
  }
  
  if (initError != null) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Failed to initialize app:\n\n$initError\n\nPlease fully restart the app (Hot Restart or Stop/Start) if you just added the .env file.',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
    return;
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
          final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'student';
          return LoadingScreen(role: role);
        },
        '/dashboard': (context) {
          final destination = ModalRoute.of(context)?.settings.arguments as Widget?;
          return destination ?? const StudentDashboard();
        },
      },
    );
  }
}

// ─── No Role Selector Needed - Direct Login ──────────────────────────────────
