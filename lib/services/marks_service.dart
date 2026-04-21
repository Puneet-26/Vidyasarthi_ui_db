import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class MarksService {
  static final MarksService _instance = MarksService._internal();
  factory MarksService() => _instance;
  MarksService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  /// Enter marks for multiple students for a test
  Future<Map<String, dynamic>> enterMarks({
    required String testId,
    required String batchId,
    required String subjectId,
    required String teacherId,
    required List<Map<String, dynamic>> studentMarks,
  }) async {
    try {
      final marksRecords = <Map<String, dynamic>>[];
      
      for (final record in studentMarks) {
        marksRecords.add({
          'id': _generateUuid(),
          'test_id': testId,
          'student_id': record['student_id'],
          'marks_obtained': record['marks_obtained'],
          'max_marks': record['max_marks'],
          'percentage': record['percentage'],
          'grade': record['grade'],
          'remarks': record['remarks'] ?? '',
          'status': 'evaluated',
        });
      }

      // Delete existing marks for this test (if re-entering)
      await _client
          .from('test_results')
          .delete()
          .eq('test_id', testId);

      // Insert new marks
      await _client.from('test_results').insert(marksRecords);

      debugPrint('✅ Marks entered successfully for ${marksRecords.length} students');
      
      return {
        'success': true,
        'message': 'Marks entered successfully',
        'count': marksRecords.length,
      };
    } catch (e) {
      debugPrint('❌ Error entering marks: $e');
      return {
        'success': false,
        'error': 'Failed to enter marks: ${e.toString()}',
      };
    }
  }

  /// Get marks for a specific test
  Future<List<Map<String, dynamic>>> getMarksByTest({
    required String testId,
  }) async {
    try {
      final response = await _client
          .from('test_results')
          .select('*, students!inner(*, users!inner(name, email))')
          .eq('test_id', testId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching marks: $e');
      return [];
    }
  }

  /// Get all tests for a batch
  Future<List<Map<String, dynamic>>> getTestsByBatch({
    required String batchId,
  }) async {
    try {
      final response = await _client
          .from('tests')
          .select('*')
          .eq('batch_id', batchId)
          .order('test_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching tests: $e');
      return [];
    }
  }

  /// Get student's test results
  Future<List<Map<String, dynamic>>> getStudentResults({
    required String studentId,
    int limit = 50,
  }) async {
    try {
      final response = await _client
          .from('test_results')
          .select('*, tests!inner(*)')
          .eq('student_id', studentId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching student results: $e');
      return [];
    }
  }

  /// Get student's performance summary
  Future<Map<String, dynamic>> getStudentPerformanceSummary({
    required String studentId,
  }) async {
    try {
      final response = await _client
          .from('test_results')
          .select('marks_obtained, max_marks, percentage, grade')
          .eq('student_id', studentId);

      final results = List<Map<String, dynamic>>.from(response);

      if (results.isEmpty) {
        return {
          'total_tests': 0,
          'average_percentage': '0.0',
          'highest_percentage': '0.0',
          'lowest_percentage': '0.0',
          'grade_distribution': {},
        };
      }

      double totalPercentage = 0;
      double highest = 0;
      double lowest = 100;
      Map<String, int> gradeDistribution = {};

      for (final result in results) {
        final percentage = (result['percentage'] ?? 0).toDouble();
        totalPercentage += percentage;
        
        if (percentage > highest) highest = percentage;
        if (percentage < lowest) lowest = percentage;

        final grade = result['grade'] ?? 'N/A';
        gradeDistribution[grade] = (gradeDistribution[grade] ?? 0) + 1;
      }

      final average = totalPercentage / results.length;

      return {
        'total_tests': results.length,
        'average_percentage': average.toStringAsFixed(1),
        'highest_percentage': highest.toStringAsFixed(1),
        'lowest_percentage': lowest.toStringAsFixed(1),
        'grade_distribution': gradeDistribution,
      };
    } catch (e) {
      debugPrint('❌ Error fetching performance summary: $e');
      return {
        'total_tests': 0,
        'average_percentage': '0.0',
        'highest_percentage': '0.0',
        'lowest_percentage': '0.0',
        'grade_distribution': {},
      };
    }
  }

  /// Get students in a batch for marks entry
  Future<List<Map<String, dynamic>>> getStudentsForMarks({
    required String batchId,
  }) async {
    try {
      final response = await _client
          .from('students')
          .select('id, roll_number, users!inner(name, email)')
          .eq('batch_id', batchId)
          .eq('enrollment_status', 'active')
          .order('roll_number');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching students: $e');
      return [];
    }
  }

  /// Calculate grade based on percentage
  String calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';
    return 'F';
  }

  String _generateUuid() {
    final random = Random.secure();
    String hex(int n) => random.nextInt(n).toRadixString(16).padLeft(4, '0');
    return '${hex(65536)}${hex(65536)}-${hex(65536)}-4${hex(4096).substring(1)}-${(8 + random.nextInt(4)).toRadixString(16)}${hex(4096).substring(1)}-${hex(65536)}${hex(65536)}${hex(65536)}';
  }
}
