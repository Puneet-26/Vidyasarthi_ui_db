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

  // ==================== TEACHERS ====================
  Future<List<Teacher>> getAllTeachers() async {
    try {
      final response = await _client.from('teachers').select();
      return (response as List).map((t) => _teacherFromRow(t)).toList();
    } catch (e) {
      debugPrint('Error fetching teachers: $e');
      return [];
    }
  }

  Future<Teacher?> getTeacherById(String teacherId) async {
    try {
      final response =
          await _client.from('teachers').select().eq('id', teacherId).single();
      return _teacherFromRow(response);
    } catch (e) {
      return null;
    }
  }

  Future<Teacher?> getTeacherByEmail(String email) async {
    try {
      debugPrint('Looking up teacher by email: $email');
      final response = await _client
          .from('teachers')
          .select()
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();
      
      if (response == null) {
        debugPrint('Teacher not found with email: $email');
        // Try case-insensitive search as fallback
        final allTeachers = await _client.from('teachers').select();
        final match = (allTeachers as List).firstWhere(
          (t) => (t['email'] ?? '').toString().toLowerCase() == email.trim().toLowerCase(),
          orElse: () => null,
        );
        if (match == null) {
          debugPrint('Teacher not found in fallback search either');
          return null;
        }
        debugPrint('Teacher found via fallback: ${match['name']}');
        return _teacherFromRow(match);
      }
      
      debugPrint('Teacher found: ${response['name']}');
      return _teacherFromRow(response);
    } catch (e) {
      debugPrint('Error fetching teacher by email: $e');
      return null;
    }
  }

  // Helper: build Teacher from a teachers-table row (name/email stored directly)
  Teacher _teacherFromRow(Map<String, dynamic> d) {
    List<String> parseList(dynamic val) {
      if (val is List) return List<String>.from(val);
      if (val is String && val.isNotEmpty) return val.split(',').map((e) => e.trim()).toList();
      return [];
    }
    return Teacher(
      id: d['id'] ?? '',
      userId: d['user_id'] ?? d['id'] ?? '',
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      phoneNumber: d['phone'] ?? d['phone_number'] ?? '',
      employeeId: d['employee_id'] ?? '',
      subjects: parseList(d['subjects']),
      classes: parseList(d['classes']),
      board: d['board'] ?? 'CBSE',
      batchId: d['batch_id'],
      qualification: d['qualification'],
      experienceYears: d['experience_years'] ?? d['experience'] != null ? 0 : 0,
      salary: (d['salary'] ?? 0).toDouble(),
      joiningDate: d['joining_date'] != null ? DateTime.tryParse(d['joining_date']) : null,
      specialization: d['specialization'],
      isActive: d['is_active'] ?? true,
      createdAt: DateTime.tryParse(d['created_at'] ?? '') ?? DateTime.now(),
    );
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
      final response = await _client.from('students').select();
      return (response as List).map((s) => _studentFromRow(s)).toList();
    } catch (e) {
      debugPrint('Error fetching students: $e');
      return [];
    }
  }

  // Helper: build Student from a students-table row (name/email stored directly)
  Student _studentFromRow(Map<String, dynamic> d) {
    return Student(
      id: d['id'] ?? '',
      userId: d['user_id'] ?? d['id'] ?? '',
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      phoneNumber: d['phone'] ?? d['phone_number'] ?? '',
      parentName: d['parent_name'] ?? '',
      parentEmail: d['parent_email'] ?? '',
      parentPhone: d['parent_phone'] ?? '',
      batchId: d['batch_id'] ?? '',
      rollNumber: d['roll_number'] ?? '',
      dateOfBirth: DateTime.tryParse(d['date_of_birth'] ?? '') ?? DateTime.now(),
      address: d['address'] ?? '',
      admissionDate: DateTime.tryParse(d['admission_date'] ?? '') ?? DateTime.now(),
      enrollmentDate: DateTime.tryParse(d['enrollment_date'] ?? d['admission_date'] ?? '') ?? DateTime.now(),
      totalFees: (d['total_fees'] ?? 0).toDouble(),
      feesPaid: (d['fees_paid'] ?? 0).toDouble(),
      feeStatus: d['fee_status'] ?? 'pending',
      enrollmentStatus: d['enrollment_status'] ?? d['enrollment_st'] ?? 'active',
      isActive: d['is_active'] ?? true,
      subjectIds: [],
      studentClass: d['class'],
      board: d['board'],
    );
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
      studentClass: data['class'],
      board: data['board'],
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

  /// Simple student creation for current database schema
  /// Works with the actual table structure (id, name, email, phone, parent_name, parent_phone, batch_id, enrollment_status)
  Future<bool> addStudentSimple({
    required String name,
    required String email,
    required String phone,
    required String parentName,
    required String parentEmail,
    required String parentPhone,
    required String batchId,
    String? rollNumber,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? address,
    String? medicalConditions,
    String? selectedClass,
    String? selectedBoard,
    List<String>? subjectIds,
    DateTime? admissionDate,
    String? parentOccupation,
    String? emergencyContact,
    String? parentAddress,
    double? totalFees,
    double? feesPaid,
  }) async {
    try {
      debugPrint('Adding student: $name ($email)');

      // 1. Create student auth credentials
      await _client.from('auth_credentials').insert({
        'id': 'cred_student_${DateTime.now().millisecondsSinceEpoch}',
        'email': email.toLowerCase(),
        'password_hash': 'Student@123',
        'name': name,
        'role': 'student',
      });
      debugPrint('✓ Student auth credentials created');

      // 2. Create parent auth credentials
      await _client.from('auth_credentials').insert({
        'id': 'cred_parent_${DateTime.now().millisecondsSinceEpoch}',
        'email': parentEmail.toLowerCase(),
        'password_hash': 'Parent@123',
        'name': parentName,
        'role': 'parent',
      });
      debugPrint('✓ Parent auth credentials created');

      // 3. Insert into students table
      // CRITICAL: parent_name format MUST be "Name (email)" for parent-student isolation
      // This format is used by getStudentsByParentEmail() to filter students
      // DO NOT CHANGE without updating the filtering logic
      final parentNameWithEmail = '$parentName ($parentEmail)';
      await _client.from('students').insert({
        'name': name,
        'email': email,
        'phone': phone,
        'parent_name': parentNameWithEmail,
        'parent_phone': parentPhone,
        'batch_id': batchId,
        'enrollment_status': 'active',
        'class': selectedClass,
        'board': selectedBoard,
        'total_fees': totalFees ?? 0,
        'fees_paid': feesPaid ?? 0,
        'admission_date': admissionDate?.toIso8601String().split('T')[0],
      });
      debugPrint('✓ Student record created');

      return true;
    } on PostgrestException catch (e) {
      debugPrint('❌ Supabase error adding student: ${e.message}');
      debugPrint('Error code: ${e.code}');
      return false;
    } catch (e) {
      debugPrint('❌ Error adding student: $e');
      return false;
    }
  }

  /// Simple teacher creation for current database schema
  /// Auto-generates email and creates auth credentials
  Future<bool> addTeacherSimple({
    required String name,
    required String phoneNumber,
    required List<String> subjects,
    required List<String> classes,
    required String board,
    String? batchId,
    String? qualification,
    int experienceYears = 0,
    double salary = 0.0,
    DateTime? joiningDate,
  }) async {
    try {
      debugPrint('Adding teacher: $name');

      // 1. Auto-generate email from name
      final email = name.toLowerCase().trim().replaceAll(' ', '.') + '@teachers.com';
      final employeeId = 'EMP${DateTime.now().millisecondsSinceEpoch}';

      // 2. Create teacher auth credentials
      await _client.from('auth_credentials').insert({
        'id': 'cred_teacher_${DateTime.now().millisecondsSinceEpoch}',
        'email': email.toLowerCase(),
        'password_hash': 'Teacher@123',
        'name': name,
        'role': 'teacher',
      });
      debugPrint('✓ Teacher auth credentials created');

      // 3. Insert into teachers table
      // Store subjects and classes as comma-separated strings
      final subjectsStr = subjects.join(',');
      final classesStr = classes.join(',');
      
      await _client.from('teachers').insert({
        'id': 'teacher_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'email': email,
        'phone': phoneNumber,
        'employee_id': employeeId,
        'subjects': subjectsStr,
        'classes': classesStr,
        'board': board,
        'batch_id': batchId,
        'qualification': qualification,
        'experience_years': experienceYears,
        'salary': salary,
        'joining_date': joiningDate?.toIso8601String().split('T')[0],
        'specialization': subjects.isNotEmpty ? subjects[0] : null,
        'is_active': true,
      });
      debugPrint('✓ Teacher record created');

      return true;
    } on PostgrestException catch (e) {
      debugPrint('❌ Supabase error adding teacher: ${e.message}');
      debugPrint('Error code: ${e.code}');
      return false;
    } catch (e) {
      debugPrint('❌ Error adding teacher: $e');
      return false;
    }
  }

  Future<bool> createBatch(Batch batch) async {
    try {
      debugPrint('Creating batch: ${batch.name}');
      // Actual DB columns: id (uuid auto), batch_name, subject_id, schedule, created_at
      await _client.from('batches').insert({
        'batch_name': batch.name,
      });
      debugPrint('✓ Batch created successfully');
      return true;
    } on PostgrestException catch (e) {
      debugPrint('❌ Supabase error creating batch: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Error creating batch: $e');
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
  /// CRITICAL: This method filters students by parent email embedded in parent_name field
  /// Format expected: "Parent Name (email@parents.com)"
  /// Used by ParentDashboard to show only the logged-in parent's children
  Future<List<Student>> getStudentsByParentEmail(String parentEmail) async {
    try {
      // Query students table directly and filter by parent name containing email
      // IMPORTANT: This ILIKE query ensures parent-student isolation
      final response = await _client
          .from('students')
          .select()
          .ilike('parent_name', '%$parentEmail%');
      
      if (response == null || (response as List).isEmpty) {
        debugPrint('No students found for parent: $parentEmail');
        return [];
      }
      
      return (response as List).map((data) {
        // Calculate fee status based on actual fees
        final totalFees = (data['total_fees'] ?? 0).toDouble();
        final feesPaid = (data['fees_paid'] ?? 0).toDouble();
        final feeStatus = totalFees > 0
            ? (feesPaid >= totalFees
                ? 'full'
                : feesPaid > 0
                    ? 'partial'
                    : 'pending')
            : 'pending';

        // Get class info - use class column if available, otherwise use batch_id
        final classInfo = data['class'] ?? data['batch_id']?.toString() ?? 'N/A';

        return Student(
          id: data['id']?.toString() ?? '',
          userId: '', // Not in table
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phoneNumber: data['phone'] ?? '',
          parentName: data['parent_name'] ?? '',
          parentEmail: parentEmail, // Use the search email
          parentPhone: data['parent_phone'] ?? '',
          batchId: classInfo, // Use class info for display
          subjectIds: [], // Not in this table
          totalFees: totalFees,
          feesPaid: feesPaid,
          feeStatus: feeStatus,
          enrollmentStatus: data['enrollment_status'] ?? 'active',
          enrollmentDate: data['enrollment_date'] != null 
              ? DateTime.parse(data['enrollment_date'])
              : (data['admission_date'] != null
                  ? DateTime.parse(data['admission_date'])
                  : DateTime.now()),
          rollNumber: data['roll_number'] ?? 'N/A',
          dateOfBirth: data['date_of_birth'] != null
              ? DateTime.parse(data['date_of_birth'])
              : DateTime(2008, 1, 1),
          address: data['address'] ?? 'N/A',
          admissionDate: data['admission_date'] != null
              ? DateTime.parse(data['admission_date'])
              : DateTime.now(),
          isActive: true,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching students by parent email: $e');
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

  // ==================== ANONYMOUS FEEDBACK ====================
  
  /// Get all teachers for feedback selection
  Future<List<Map<String, String>>> getAllTeachersForFeedback() async {
    try {
      // First, get all teacher users
      final usersResponse = await _client
          .from('users')
          .select('id, name, email')
          .eq('role', 'teacher')
          .order('name');
      
      final users = usersResponse as List;
      
      // Then get teacher details for each user
      final List<Map<String, String>> teachersWithSubjects = [];
      
      for (var user in users) {
        try {
          final teacherResponse = await _client
              .from('teachers')
              .select('specialization')
              .eq('user_id', user['id'])
              .maybeSingle();
          
          final specialization = teacherResponse != null 
              ? (teacherResponse['specialization'] as String? ?? 'General')
              : 'General';
          
          teachersWithSubjects.add({
            'id': user['id'] as String,
            'name': user['name'] as String,
            'email': user['email'] as String,
            'subject': specialization,
          });
        } catch (e) {
          // If teacher details not found, add with default subject
          teachersWithSubjects.add({
            'id': user['id'] as String,
            'name': user['name'] as String,
            'email': user['email'] as String,
            'subject': 'General',
          });
        }
      }
      
      return teachersWithSubjects;
    } catch (e) {
      debugPrint('Error fetching teachers: $e');
      return [];
    }
  }

  /// Submit anonymous feedback (student/parent -> admin)
  Future<bool> submitAnonymousFeedback(AnonymousFeedback feedback) async {
    try {
      await _client.from('anonymous_feedback').insert(feedback.toJson());
      debugPrint('✓ Anonymous feedback submitted');
      return true;
    } catch (e) {
      debugPrint('Error submitting anonymous feedback: $e');
      return false;
    }
  }

  /// Get pending feedback for admin review
  Future<List<AnonymousFeedback>> getPendingFeedbackForAdmin() async {
    try {
      final response = await _client
          .from('anonymous_feedback')
          .select()
          .eq('status', 'pending')
          .order('submitted_at', ascending: false);
      
      return (response as List)
          .map((f) => AnonymousFeedback.fromJson(f))
          .toList();
    } catch (e) {
      debugPrint('Error fetching pending feedback: $e');
      return [];
    }
  }

  /// Get all feedback for admin (all statuses)
  Future<List<AnonymousFeedback>> getAllFeedbackForAdmin() async {
    try {
      final response = await _client
          .from('anonymous_feedback')
          .select()
          .order('submitted_at', ascending: false);
      
      return (response as List)
          .map((f) => AnonymousFeedback.fromJson(f))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all feedback: $e');
      return [];
    }
  }

  /// Approve feedback (admin action)
  Future<bool> approveFeedback(String feedbackId, String adminId, String? notes) async {
    try {
      await _client.from('anonymous_feedback').update({
        'status': 'approved',
        'reviewed_by': adminId,
        'reviewed_at': DateTime.now().toIso8601String(),
        'admin_notes': notes,
      }).eq('id', feedbackId);
      
      debugPrint('✓ Feedback approved');
      return true;
    } catch (e) {
      debugPrint('Error approving feedback: $e');
      return false;
    }
  }

  /// Reject feedback (admin action)
  Future<bool> rejectFeedback(String feedbackId, String adminId, String? notes) async {
    try {
      await _client.from('anonymous_feedback').update({
        'status': 'rejected',
        'reviewed_by': adminId,
        'reviewed_at': DateTime.now().toIso8601String(),
        'admin_notes': notes,
      }).eq('id', feedbackId);
      
      debugPrint('✓ Feedback rejected');
      return true;
    } catch (e) {
      debugPrint('Error rejecting feedback: $e');
      return false;
    }
  }

  /// Get approved feedback for a specific teacher
  Future<List<AnonymousFeedback>> getApprovedFeedbackForTeacher(String teacherId) async {
    try {
      final response = await _client
          .from('anonymous_feedback')
          .select()
          .eq('teacher_id', teacherId)
          .eq('status', 'approved')
          .order('submitted_at', ascending: false);
      
      return (response as List)
          .map((f) => AnonymousFeedback.fromJson(f))
          .toList();
    } catch (e) {
      debugPrint('Error fetching teacher feedback: $e');
      return [];
    }
  }

  /// Mark feedback as read by teacher
  Future<bool> markFeedbackAsRead(String feedbackId) async {
    try {
      await _client.from('anonymous_feedback').update({
        'is_read_by_teacher': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('id', feedbackId);
      
      return true;
    } catch (e) {
      debugPrint('Error marking feedback as read: $e');
      return false;
    }
  }

  /// Get feedback submitted by a specific user (for tracking their own submissions)
  Future<List<AnonymousFeedback>> getMySubmittedFeedback(String senderId, String senderRole) async {
    try {
      final response = await _client
          .from('anonymous_feedback')
          .select()
          .eq('sender_id', senderId)
          .eq('sender_role', senderRole)
          .order('submitted_at', ascending: false);
      
      return (response as List)
          .map((f) => AnonymousFeedback.fromJson(f))
          .toList();
    } catch (e) {
      debugPrint('Error fetching my feedback: $e');
      return [];
    }
  }
}
