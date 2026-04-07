import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  SupabaseClient get _client => Supabase.instance.client;
  SupabaseClient get client => _client;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Sign in with email and password from auth_credentials table
  /// This uses custom authentication (not Supabase Auth)
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Query auth_credentials table
      final response = await _client
          .from('auth_credentials')
          .select()
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();

      if (response == null) {
        return {
          'success': false,
          'error': 'Email not found',
        };
      }

      // For MVP, we're storing plain text passwords (should be bcrypt in production)
      // In production: use bcrypt.checkpw(password, response['password_hash'])
      if (response['password_hash'] != password) {
        return {
          'success': false,
          'error': 'Incorrect password',
        };
      }

      // Authentication successful
      // Map credential -> user row (used by FK relations like students.user_id).
      String? userId;
      try {
        final userRow = await _client
            .from('users')
            .select('id')
            .eq('credential_id', response['id'])
            .maybeSingle();
        userId = userRow?['id'];
      } catch (_) {
        // If users table isn't set up, we can still allow role-based routing.
      }

      return {
        'success': true,
        // Backwards compatible:
        // - credentialId: auth_credentials.id
        // - userId: users.id (UUID) when available
        'credentialId': response['id'],
        'userId': userId ?? response['id'],
        'email': response['email'],
        'role': response['role'],
        'name': response['name'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Authentication error: ${e.toString()}',
      };
    }
  }

  /// Sign up a new user
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      final credentialId = _generateUuid();
      final insertedCreds = await _client.from('auth_credentials').insert({
        'id': credentialId,
        'email': email.trim().toLowerCase(),
        'password_hash': password,
        'name': name,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      if (insertedCreds.isEmpty) {
        throw Exception('Sign up failed');
      }

      // Create matching users row (needed by schema FKs like students.user_id -> users.id).
      // If the users table doesn't exist in a given environment, we still consider signup ok.
      String? userId;
      try {
        final insertedUsers = await _client.from('users').insert({
          // Use the same UUID string; Postgres can cast it into UUID.
          'id': credentialId,
          'email': email.trim().toLowerCase(),
          'name': name,
          'role': role,
          'phone_number': phoneNumber,
          'is_active': true,
          'credential_id': credentialId,
          'created_at': DateTime.now().toIso8601String(),
        }).select();
        if (insertedUsers.isNotEmpty) {
          userId = insertedUsers[0]['id'];
        }
      } catch (_) {
        // Ignore if users table isn't set up; some environments may only use auth_credentials.
      }

      return {
        'success': true,
        'credentialId': insertedCreds[0]['id'],
        'userId': userId ?? insertedCreds[0]['id'],
        'email': email,
        'role': role,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Sign up error: ${e.toString()}',
      };
    }
  }

  String _generateUuid() {
    final random = Random.secure();
    String hex(int n) => random.nextInt(n).toRadixString(16).padLeft(4, '0');
    return '${hex(65536)}${hex(65536)}-${hex(65536)}-4${hex(4096).substring(1)}-${(8 + random.nextInt(4)).toRadixString(16)}${hex(4096).substring(1)}-${hex(65536)}${hex(65536)}${hex(65536)}';
  }

  /// Fetch user data from database
  Future<AppUser?> getUserData(String userId) async {
    try {
      final response =
          await _client.from('users').select().eq('id', userId).maybeSingle();

      if (response == null) return null;

      return AppUser.fromJson(response);
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  /// Fetch student data
  Future<Student?> getStudentData(String studentId) async {
    try {
      final response = await _client
          .from('students')
          .select()
          .eq('id', studentId)
          .maybeSingle();

      if (response == null) return null;

      return Student.fromJson(response);
    } catch (e) {
      print('Error fetching student data: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
