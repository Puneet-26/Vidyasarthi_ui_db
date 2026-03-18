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
      return {
        'success': true,
        'userId': response['id'],
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
      final id = _generateUuid();
      final response = await _client.from('auth_credentials').insert({
        'id': id,
        'email': email.trim().toLowerCase(),
        'password_hash': password,
        'name': name,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      if (response.isEmpty) {
        throw Exception('Sign up failed');
      }

      return {
        'success': true,
        'userId': response[0]['id'],
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
