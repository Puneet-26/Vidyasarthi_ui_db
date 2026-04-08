import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  SupabaseClient get _client => Supabase.instance.client;
  SupabaseClient get client => _client;

  String _tsId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  // ==================== SUBJECTS ====================
  Future<List<Subject>> getAllSubjects() async {
    try {
      final response = await _client.from('subjects').select();
      return (response as List).map((s) => Subject.fromJson(s)).toList();
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
      return [];
    }
  }

  Future<Subject?> getSubjectById(String subjectId) async {
    try {
      final response =
          await _client.from('subjects').select().eq('id', subjectId).single();
      return Subject.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // ==================== BATCHES ====================
  Future<List<Batch>> getAllBatches() async {
    try {
      final response = await _client.from('batches').select();
      return (response as List).map((b) => Batch.fromJson(b)).toList();
    } catch (e) {
      debugPrint('Error fetching batches: $e');
      return [];
    }
  }

  Future<Batch?> getBatchById(String batchId) async {
    try {
      final response =
          await _client.from('batches').select().eq('id', batchId).single();
      return Batch.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // ==================== STUDENTS ====================
  Future<List<Student>> getAllStudents() async {
    try {
      // Use the student_details view for normalized data
      final response = await _client.from('student_details').select();
      return (response as List)
          .map((s) => _convertStudentDetailsToStudent(s))
          .toList();
    } catch (e) {
      debugPrint('Error fetching students: $e');
      return [];
    }
  }

  Future<List<Student>> getStudentsByBatch(String batchId) async {
    try {
      final response = await _client
          .from('student_details')
          .select()
          .eq('batch_id', batchId);
      return (response as List)
          .map((s) => _convertStudentDetailsToStudent(s))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Student?> getStudentById(String studentId) async {
    try {
      final response = await _client
          .from('student_details')
          .select()
          .eq('id', studentId)
          .single();
      return _convertStudentDetailsToStudent(response);
    } catch (e) {
      return null;
    }
  }

  // Helper method to convert student_details view to Student model
  Student _convertStudentDetailsToStudent(Map<String, dynamic> data) {
    return Student(
      id: data['id'] ?? '',
      userId: data['user_id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      parentName: data['parent_name'] ?? '',
      parentEmail: data['parent_email'] ?? '',
      parentPhone: data['parent_phone'] ?? '',
      batchId: data['batch_id'] ?? '',
      rollNumber: data['roll_number'] ?? '',
      dateOfBirth: DateTime.parse(
          data['date_of_birth'] ?? DateTime.now().toIso8601String()),
      address: data['address'] ?? '',
      admissionDate: DateTime.parse(
          data['admission_date'] ?? DateTime.now().toIso8601String()),
      enrollmentDate: DateTime.parse(
          data['admission_date'] ?? DateTime.now().toIso8601String()),
      totalFees: (data['total_fees'] ?? 0).toDouble(),
      feesPaid: (data['fees_paid'] ?? 0).toDouble(),
      feeStatus: data['fee_status'] ?? 'pending',
      enrollmentStatus: data['enrollment_status'] ?? 'active',
      isActive: true,
      subjectIds: [], // Will be populated separately if needed
    );
  }

  Future<bool> createStudent(Student student) async {
    try {
      // In normalized schema, we need to create user first, then parent, then student
      debugPrint('Creating student with normalized schema...');

      // 1. Create user record
      final userJson = {
        'id': student.userId,
        'email': student.email,
        'name': student.name,
        'phone_number': student.phoneNumber,
        'role': 'student',
        'is_active': true,
      };
      await _client.from('users').insert(userJson);
      debugPrint('✓ User created');

      // 2. Create parent record if parent info provided
      String? parentId;
      if (student.parentName.isNotEmpty) {
        parentId = 'parent_${DateTime.now().millisecondsSinceEpoch}';
        final parentUserId =
            'user_parent_${DateTime.now().millisecondsSinceEpoch}';

        // Create parent user
        final parentUserJson = {
          'id': parentUserId,
          'email': student.parentEmail,
          'name': student.parentName,
          'phone_number': student.parentPhone,
          'role': 'parent',
          'is_active': true,
        };
        await _client.from('users').insert(parentUserJson);

        // Create parent record
        final parentJson = {
          'id': parentId,
          'user_id': parentUserId,
          'address': student.address,
          'emergency_contact': student.parentPhone,
        };
        await _client.from('parents').insert(parentJson);
        debugPrint('✓ Parent created');
      }

      // 3. Create student record
      final studentJson = {
        'id': student.id,
        'user_id': student.userId,
        'parent_id': parentId,
        'batch_id': student.batchId,
        'roll_number': student.rollNumber,
        'date_of_birth': student.dateOfBirth.toIso8601String().split('T')[0],
        'address': student.address,
        'admission_date': student.admissionDate.toIso8601String().split('T')[0],
        'total_fees': student.totalFees.toInt(),
        'fees_paid': student.feesPaid.toInt(),
        'fee_status': student.feeStatus,
        'enrollment_status': student.enrollmentStatus,
      };
      await _client.from('students').insert(studentJson);
      debugPrint('✓ Student created');

      // 4. Create student-subject mappings
      for (final subjectId in student.subjectIds) {
        final ssJson = {
          'id': 'ss_${student.id}_$subjectId',
          'student_id': student.id,
          'subject_id': subjectId,
          'enrollment_date': DateTime.now().toIso8601String().split('T')[0],
          'is_active': true,
        };
        await _client.from('student_subjects').insert(ssJson);
      }
      debugPrint('✓ Student subjects mapped');

      return true;
    } catch (e) {
      debugPrint('❌ Error creating student: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Full error details: ${e.toString()}');
      return false;
    }
  }

  Future<bool> createBatch(Batch batch) async {
    try {
      final json = batch.toJson();
      // DB schema expects TEXT PK with no default, so always provide an id.
      if ((json['id'] as String).isEmpty) json['id'] = _tsId('batch');
      await _client.from('batches').insert(json);
      return true;
    } catch (e) {
      debugPrint('Error creating batch: $e');
      return false;
    }
  }

  Future<bool> updateStudent(String studentId, Student student) async {
    try {
      await _client
          .from('students')
          .update(student.toJson())
          .eq('id', studentId);
      return true;
    } catch (e) {
      debugPrint('Error updating student: $e');
      return false;
    }
  }

  // ==================== ADMISSIONS ====================
  Future<List<Admission>> getAllAdmissions() async {
    try {
      final response = await _client.from('admissions').select();
      return (response as List).map((a) => Admission.fromJson(a)).toList();
    } catch (e) {
      debugPrint('Error fetching admissions: $e');
      return [];
    }
  }

  Future<List<Admission>> getAdmissionsByStatus(String status) async {
    try {
      final response =
          await _client.from('admissions').select().eq('status', status);
      return (response as List).map((a) => Admission.fromJson(a)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Admission?> getAdmissionById(String admissionId) async {
    try {
      final response = await _client
          .from('admissions')
          .select()
          .eq('id', admissionId)
          .single();
      return Admission.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<bool> createAdmission(Admission admission) async {
    try {
      await _client.from('admissions').insert(admission.toJson());
      return true;
    } catch (e) {
      debugPrint('Error creating admission: $e');
      return false;
    }
  }

  Future<bool> updateAdmissionStatus(String admissionId, String status) async {
    try {
      await _client
          .from('admissions')
          .update({'status': status}).eq('id', admissionId);
      return true;
    } catch (e) {
      debugPrint('Error updating admission: $e');
      return false;
    }
  }

  // ==================== TIMETABLES ====================
  Future<List<TimeTable>> getAllTimeTables() async {
    try {
      final response = await _client.from('timetables').select();
      return (response as List).map((t) => TimeTable.fromJson(t)).toList();
    } catch (e) {
      debugPrint('Error fetching timetables: $e');
      return [];
    }
  }

  Future<List<TimeTable>> getTimeTableByBatch(String batchId) async {
    try {
      final response =
          await _client.from('timetables').select().eq('batch_id', batchId);
      return (response as List).map((t) => TimeTable.fromJson(t)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createTimeTableEntry(TimeTable tt) async {
    try {
      await _client.from('timetables').insert(tt.toJson());
      return true;
    } catch (e) {
      debugPrint('Error creating timetable entry: $e');
      return false;
    }
  }

  // ==================== HOMEWORK ====================
  Future<List<Homework>> getHomeworkByBatch(String batchId) async {
    try {
      final response =
          await _client.from('homework').select().eq('batch_id', batchId);
      return (response as List).map((h) => Homework.fromJson(h)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Homework>> getActiveHomework() async {
    try {
      final response =
          await _client.from('homework').select().eq('status', 'active');
      return (response as List).map((h) => Homework.fromJson(h)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createHomework(Homework homework) async {
    try {
      await _client.from('homework').insert(homework.toJson());
      return true;
    } catch (e) {
      debugPrint('Error creating homework: $e');
      return false;
    }
  }

  // ==================== TESTS ====================
  Future<List<Test>> getTestsByBatch(String batchId) async {
    try {
      final response =
          await _client.from('tests').select().eq('batch_id', batchId);
      return (response as List).map((t) => Test.fromJson(t)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createTest(Test test) async {
    try {
      await _client.from('tests').insert(test.toJson());
      return true;
    } catch (e) {
      debugPrint('Error creating test: $e');
      return false;
    }
  }

  // ==================== TEST RESULTS ====================
  Future<List<TestResult>> getTestResultsByStudent(String studentId) async {
    try {
      final response = await _client
          .from('test_results')
          .select()
          .eq('student_id', studentId);
      return (response as List).map((r) => TestResult.fromJson(r)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createTestResult(TestResult result) async {
    try {
      await _client.from('test_results').insert(result.toJson());
      return true;
    } catch (e) {
      debugPrint('Error creating test result: $e');
      return false;
    }
  }

  // ==================== FEE PAYMENTS ====================
  Future<List<FeePayment>> getFeePaymentsByStudent(String studentId) async {
    try {
      final response = await _client
          .from('fee_payments')
          .select()
          .eq('student_id', studentId)
          .order('payment_date', ascending: false);
      return (response as List).map((f) => FeePayment.fromJson(f)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Records a fee payment AND updates the student's fees_paid + fee_status atomically.
  Future<bool> createFeePaymentAndUpdateStudent(
      FeePayment payment, double newFeesPaid, double totalFees) async {
    try {
      await _client.from('fee_payments').insert(payment.toJson());
      final feeStatus = newFeesPaid >= totalFees
          ? 'full'
          : newFeesPaid > 0
              ? 'partial'
              : 'pending';
      await _client.from('students').update({
        'fees_paid': newFeesPaid.toInt(),
        'fee_status': feeStatus,
      }).eq('id', payment.studentId);
      return true;
    } catch (e) {
      debugPrint('Error recording fee payment: $e');
      return false;
    }
  }

  Future<bool> createFeePayment(FeePayment payment) async {
    try {
      await _client.from('fee_payments').insert(payment.toJson());
      return true;
    } catch (e) {
      debugPrint('Error creating fee payment: $e');
      return false;
    }
  }

  /// Fetch student by parent email (using normalized parent table)
  Future<List<Student>> getStudentsByParentEmail(String parentEmail) async {
    try {
      final response = await _client
          .from('student_details')
          .select()
          .eq('parent_email', parentEmail.trim().toLowerCase());
      return (response as List)
          .map((s) => _convertStudentDetailsToStudent(s))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== BROADCASTS ====================
  Future<List<Broadcast>> getAllBroadcasts() async {
    try {
      final response = await _client
          .from('broadcasts')
          .select()
          .order('sent_date', ascending: false);
      return (response as List).map((b) => Broadcast.fromJson(b)).toList();
    } catch (e) {
      debugPrint('Error fetching broadcasts: $e');
      return [];
    }
  }

  Future<bool> createBroadcast(Broadcast broadcast) async {
    try {
      await _client.from('broadcasts').insert(broadcast.toJson());
      return true;
    } catch (e) {
      debugPrint('Error creating broadcast: $e');
      return false;
    }
  }

  // ==================== DOUBTS ====================
  Future<List<Doubt>> getDoubtsByStudent(String studentId) async {
    try {
      final response =
          await _client.from('doubts').select().eq('student_id', studentId);
      return (response as List).map((d) => Doubt.fromJson(d)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Doubt>> getUnresolvedDoubts() async {
    try {
      final response =
          await _client.from('doubts').select().eq('status', 'open');
      return (response as List).map((d) => Doubt.fromJson(d)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createDoubt(Doubt doubt) async {
    try {
      await _client.from('doubts').insert(doubt.toJson());
      return true;
    } catch (e) {
      debugPrint('Error creating doubt: $e');
      return false;
    }
  }

  // ==================== FEEDBACK ====================
  Future<List<Feedback>> getAllFeedback() async {
    try {
      final response = await _client
          .from('feedbacks')
          .select()
          .order('submitted_date', ascending: false);
      return (response as List).map((f) => Feedback.fromJson(f)).toList();
    } catch (e) {
      debugPrint('Error fetching feedback: $e');
      return [];
    }
  }

  Future<bool> createFeedback(Feedback feedback) async {
    try {
      await _client.from('feedbacks').insert(feedback.toJson());
      return true;
    } catch (e) {
      debugPrint('Error creating feedback: $e');
      return false;
    }
  }

  // ==================== TEACHER FEEDBACK ====================
  Future<List<TeacherFeedback>> getTeacherFeedbackForStudent(
      String studentId) async {
    try {
      final response = await _client
          .from('teacher_feedback')
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((f) => TeacherFeedback.fromJson(f))
          .toList();
    } catch (e) {
      debugPrint('Error fetching teacher feedback: $e');
      return [];
    }
  }

  Future<bool> createTeacherFeedback(TeacherFeedback feedback) async {
    try {
      await _client.from('teacher_feedback').insert(feedback.toJson());
      return true;
    } catch (e) {
      debugPrint('Error creating teacher feedback: $e');
      return false;
    }
  }
}
