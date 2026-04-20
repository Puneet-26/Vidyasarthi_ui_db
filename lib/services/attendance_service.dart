import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  /// Mark attendance for multiple students
  Future<Map<String, dynamic>> markAttendance({
    required String batchId,
    required String subjectId,
    required String teacherId,
    required List<Map<String, dynamic>> studentAttendance,
    required DateTime date,
  }) async {
    try {
      final attendanceRecords = <Map<String, dynamic>>[];
      
      for (final record in studentAttendance) {
        attendanceRecords.add({
          'id': _generateUuid(),
          'student_id': record['student_id'],
          'batch_id': batchId,
          'subject_id': subjectId,
          'teacher_id': teacherId,
          'attendance_date': date.toIso8601String().split('T')[0],
          'status': record['status'], // present, absent, late, leave, half_day
          'remarks': record['remarks'] ?? '',
          'marked_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Delete existing attendance for this date, batch, and subject
      await _client
          .from('attendance')
          .delete()
          .eq('batch_id', batchId)
          .eq('subject_id', subjectId)
          .eq('attendance_date', date.toIso8601String().split('T')[0]);

      // Insert new attendance records
      await _client.from('attendance').insert(attendanceRecords);

      debugPrint('✅ Attendance marked successfully for ${attendanceRecords.length} students');
      
      return {
        'success': true,
        'message': 'Attendance marked successfully',
        'count': attendanceRecords.length,
      };
    } catch (e) {
      debugPrint('❌ Error marking attendance: $e');
      return {
        'success': false,
        'error': 'Failed to mark attendance: ${e.toString()}',
      };
    }
  }

  /// Get attendance for a specific date, batch, and subject
  Future<List<Map<String, dynamic>>> getAttendanceByDate({
    required String batchId,
    required String subjectId,
    required DateTime date,
  }) async {
    try {
      final response = await _client
          .from('attendance')
          .select('*, students!inner(*, users!inner(name, email))')
          .eq('batch_id', batchId)
          .eq('subject_id', subjectId)
          .eq('attendance_date', date.toIso8601String().split('T')[0]);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching attendance: $e');
      return [];
    }
  }

  /// Get students in a batch for attendance marking
  Future<List<Map<String, dynamic>>> getStudentsForAttendance({
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

  /// Get attendance summary for a student
  Future<Map<String, dynamic>> getStudentAttendanceSummary({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('attendance')
          .select('status, attendance_date')
          .eq('student_id', studentId);

      if (startDate != null) {
        query = query.gte('attendance_date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.lte('attendance_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query;
      final records = List<Map<String, dynamic>>.from(response);

      int present = 0, absent = 0, late = 0, leave = 0, halfDay = 0;
      
      for (final record in records) {
        switch (record['status']) {
          case 'present':
            present++;
            break;
          case 'absent':
            absent++;
            break;
          case 'late':
            late++;
            break;
          case 'leave':
            leave++;
            break;
          case 'half_day':
            halfDay++;
            break;
        }
      }

      final total = records.length;
      final percentage = total > 0 ? (present / total * 100).toStringAsFixed(1) : '0.0';

      return {
        'present': present,
        'absent': absent,
        'late': late,
        'leave': leave,
        'half_day': halfDay,
        'total': total,
        'percentage': percentage,
      };
    } catch (e) {
      debugPrint('❌ Error fetching attendance summary: $e');
      return {
        'present': 0,
        'absent': 0,
        'late': 0,
        'leave': 0,
        'half_day': 0,
        'total': 0,
        'percentage': '0.0',
      };
    }
  }

  /// Get attendance history for a student
  Future<List<Map<String, dynamic>>> getStudentAttendanceHistory({
    required String studentId,
    int limit = 30,
  }) async {
    try {
      final response = await _client
          .from('attendance')
          .select('*, subjects(name, code), teachers!inner(*, users!inner(name))')
          .eq('student_id', studentId)
          .order('attendance_date', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching attendance history: $e');
      return [];
    }
  }

  /// Get batch attendance summary for a specific date
  Future<Map<String, dynamic>> getBatchAttendanceSummary({
    required String batchId,
    required DateTime date,
  }) async {
    try {
      final response = await _client
          .from('attendance')
          .select('status')
          .eq('batch_id', batchId)
          .eq('attendance_date', date.toIso8601String().split('T')[0]);

      final records = List<Map<String, dynamic>>.from(response);
      
      int present = 0, absent = 0, late = 0, leave = 0;
      
      for (final record in records) {
        switch (record['status']) {
          case 'present':
            present++;
            break;
          case 'absent':
            absent++;
            break;
          case 'late':
            late++;
            break;
          case 'leave':
            leave++;
            break;
        }
      }

      return {
        'present': present,
        'absent': absent,
        'late': late,
        'leave': leave,
        'total': records.length,
      };
    } catch (e) {
      debugPrint('❌ Error fetching batch attendance summary: $e');
      return {
        'present': 0,
        'absent': 0,
        'late': 0,
        'leave': 0,
        'total': 0,
      };
    }
  }

  String _generateUuid() {
    final random = Random.secure();
    String hex(int n) => random.nextInt(n).toRadixString(16).padLeft(4, '0');
    return '${hex(65536)}${hex(65536)}-${hex(65536)}-4${hex(4096).substring(1)}-${(8 + random.nextInt(4)).toRadixString(16)}${hex(4096).substring(1)}-${hex(65536)}${hex(65536)}${hex(65536)}';
  }
}
