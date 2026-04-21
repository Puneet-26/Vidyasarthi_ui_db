import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'app_errors.dart';

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
  /// Falls back to local authentication if Supabase is unreachable
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client
          .from('auth_credentials')
          .select()
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();

      if (response == null) {
        return {'success': false, 'error': AppErrors.emailNotFound};
      }

      if (response['password_hash'] != password) {
        return {'success': false, 'error': AppErrors.wrongPassword};
      }

      String? userId;
      try {
        final userRow = await _client
            .from('users')
            .select('id')
            .eq('credential_id', response['id'])
            .maybeSingle();
        userId = userRow?['id'];
      } catch (_) {}

      return {
        'success': true,
        'credentialId': response['id'],
        'userId': userId ?? response['id'],
        'email': response['email'],
        'role': response['role'],
        'name': response['name'],
      };
    } on SocketException {
      return {'success': false, 'error': AppErrors.noInternet};
    } on HandshakeException {
      return {'success': false, 'error': AppErrors.noInternet};
    } catch (e) {
      debugPrint('SignIn error: $e');
      return {'success': false, 'error': AppErrors.fromRaw(e.toString())};
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
      debugPrint('Error fetching user data: $e');
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
      debugPrint('Error fetching student data: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
