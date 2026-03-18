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

  // ==================== SUBJECTS ====================
  Future<List<Subject>> getAllSubjects() async {
    try {
      final response = await _client.from('subjects').select();
      return (response as List).map((s) => Subject.fromJson(s)).toList();
    } catch (e) {
      print('Error fetching subjects: $e');
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
      print('Error fetching batches: $e');
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
      final response = await _client.from('students').select();
      return (response as List).map((s) => Student.fromJson(s)).toList();
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  Future<List<Student>> getStudentsByBatch(String batchId) async {
    try {
      final response =
          await _client.from('students').select().eq('batch_id', batchId);
      return (response as List).map((s) => Student.fromJson(s)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Student?> getStudentById(String studentId) async {
    try {
      final response =
          await _client.from('students').select().eq('id', studentId).single();
      return Student.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<bool> createStudent(Student student) async {
    try {
      final json = student.toJson();
      if ((json['id'] as String).isEmpty) json.remove('id');
      if ((json['user_id'] as String).isEmpty) json.remove('user_id');
      await _client.from('students').insert(json);
      return true;
    } catch (e) {
      print('Error creating student: $e');
      return false;
    }
  }

  Future<bool> createBatch(Batch batch) async {
    try {
      final json = batch.toJson();
      if ((json['id'] as String).isEmpty) json.remove('id');
      await _client.from('batches').insert(json);
      return true;
    } catch (e) {
      print('Error creating batch: $e');
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
      print('Error updating student: $e');
      return false;
    }
  }

  // ==================== ADMISSIONS ====================
  Future<List<Admission>> getAllAdmissions() async {
    try {
      final response = await _client.from('admissions').select();
      return (response as List).map((a) => Admission.fromJson(a)).toList();
    } catch (e) {
      print('Error fetching admissions: $e');
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
      print('Error creating admission: $e');
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
      print('Error updating admission: $e');
      return false;
    }
  }

  // ==================== TIMETABLES ====================
  Future<List<TimeTable>> getAllTimeTables() async {
    try {
      final response = await _client.from('timetables').select();
      return (response as List).map((t) => TimeTable.fromJson(t)).toList();
    } catch (e) {
      print('Error fetching timetables: $e');
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
      print('Error creating timetable entry: $e');
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
      print('Error creating homework: $e');
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
      print('Error creating test: $e');
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
      print('Error creating test result: $e');
      return false;
    }
  }

  // ==================== FEE PAYMENTS ====================
  Future<List<FeePayment>> getFeePaymentsByStudent(String studentId) async {
    try {
      final response = await _client
          .from('fee_payments')
          .select()
          .eq('student_id', studentId);
      return (response as List).map((f) => FeePayment.fromJson(f)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createFeePayment(FeePayment payment) async {
    try {
      await _client.from('fee_payments').insert(payment.toJson());
      return true;
    } catch (e) {
      print('Error creating fee payment: $e');
      return false;
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
      print('Error fetching broadcasts: $e');
      return [];
    }
  }

  Future<bool> createBroadcast(Broadcast broadcast) async {
    try {
      await _client.from('broadcasts').insert(broadcast.toJson());
      return true;
    } catch (e) {
      print('Error creating broadcast: $e');
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
      print('Error creating doubt: $e');
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
      print('Error fetching feedback: $e');
      return [];
    }
  }

  Future<bool> createFeedback(Feedback feedback) async {
    try {
      await _client.from('feedbacks').insert(feedback.toJson());
      return true;
    } catch (e) {
      print('Error creating feedback: $e');
      return false;
    }
  }
}
