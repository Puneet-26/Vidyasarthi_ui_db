import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/services/data_seeder.dart';
import 'lib/services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  print('🚀 Starting database seeding...');

  try {
    final seeder = DataSeeder();
    await seeder.seedDatabase();
    print('✅ Database seeding completed successfully!');
  } catch (e) {
    print('❌ Database seeding failed: $e');
  }
}
