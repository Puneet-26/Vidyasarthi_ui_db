import 'package:flutter_dotenv/flutter_dotenv.dart';

// Supabase Configuration loaded from environment variables
class SupabaseConfig {
  /// Get Supabase URL from environment variable
  /// Loaded from .env file at runtime
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL environment variable is not set. Check your .env file.');
    }
    return url;
  }

  /// Get Supabase Anonymous Key from environment variable
  /// Loaded from .env file at runtime
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY environment variable is not set. Check your .env file.');
    }
    return key;
  }

  /// Get app name from environment variable
  static String get appName {
    return dotenv.env['APP_NAME'] ?? 'VidyaSarathi';
  }

  /// Check if app is in debug mode
  static bool get isDebugMode {
    final debug = dotenv.env['DEBUG_MODE'] ?? 'false';
    return debug.toLowerCase() == 'true';
  }

  /// Validate that all required environment variables are set
  static bool validateConfiguration() {
    try {
      // Try to access each required variable
      supabaseUrl;
      supabaseAnonKey;
      return true;
    } catch (e) {
      print('Configuration validation error: $e');
      return false;
    }
  }
}

// Database tables to create in Supabase:
/*
1. users (auth_uid, email, name, role, phone_number, profile_image, is_active, created_at)
2. subjects (id, name, code, description, created_at)
3. batches (id, name, level, subject_ids, created_at)
4. students (id, user_id, name, email, phone, parent_name, parent_email, parent_phone, batch_id, subject_ids, total_fees, fees_paid, fee_status, enrollment_status, enrollment_date)
5. admissions (id, student_name, parent_name, email, phone, parent_phone, applied_batch_id, requested_subject_ids, status, applied_date, notes)
6. timetables (id, batch_id, subject_id, teacher_id, day, start_time, end_time, room, proxy_teacher_id, created_at)
7. syllabus_items (id, subject_id, topic, description, order, is_completed, completed_date)
8. homework (id, batch_id, subject_id, teacher_id, title, description, due_date, assigned_students, status)
9. homework_submissions (id, homework_id, student_id, status, submitted_date, remarks)
10. tests (id, batch_id, subject_id, teacher_id, title, test_date, total_marks, status)
11. test_results (id, test_id, student_id, marks_obtained, status)
12. fee_payments (id, student_id, amount, payment_method, payment_date, status, reference)
13. broadcasts (id, title, message, sent_by, sent_date, target_audience, priority)
14. doubts (id, student_id, subject_id, title, description, raised_date, status, resolved_by, resolution)
15. feedbacks (id, student_id, parent_id, message, submitted_date, status, admin_notes)

Row Level Security (RLS) Policies to implement:
- Students can only view their own records
- Parents can only view their child's records
- Teachers can only view their assigned batches and students
- Admin staff can view and manage all academic records
- Super admin has full access to everything
*/
