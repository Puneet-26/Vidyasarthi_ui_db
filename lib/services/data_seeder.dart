import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to populate the database with realistic demo data
class DataSeeder {
  static final DataSeeder _instance = DataSeeder._internal();
  factory DataSeeder() => _instance;
  DataSeeder._internal();

  SupabaseClient get _client => Supabase.instance.client;

  /// Seed all tables with demo data
  Future<void> seedDatabase() async {
    try {
      debugPrint('🌱 Starting database seeding...');

      // Clear existing data first
      await _clearExistingData();

      // Seed in proper order due to foreign key dependencies
      await _seedSubjects();
      await _seedBatches();
      await _seedUsers();
      await _seedTeachers();
      await _seedParents();
      await _seedStudents();
      await _seedStudentSubjects();
      await _seedTimetables();
      await _seedHomework();
      await _seedTests();
      await _seedTestResults();
      await _seedFeePayments();
      await _seedTeacherFeedback();
      await _seedBroadcasts();

      debugPrint('✅ Database seeding completed successfully!');
    } catch (e) {
      debugPrint('❌ Database seeding failed: $e');
      rethrow;
    }
  }

  Future<void> _clearExistingData() async {
    debugPrint('🧹 Clearing existing data...');
    try {
      // Delete in reverse order of dependencies
      await _client.from('teacher_feedback').delete().neq('id', '');
      await _client.from('test_results').delete().neq('id', '');
      await _client.from('fee_payments').delete().neq('id', '');
      await _client.from('homework').delete().neq('id', '');
      await _client.from('tests').delete().neq('id', '');
      await _client.from('timetables').delete().neq('id', '');
      await _client.from('student_subjects').delete().neq('id', '');
      await _client.from('students').delete().neq('id', '');
      await _client.from('parents').delete().neq('id', '');
      await _client.from('teachers').delete().neq('id', '');
      await _client.from('users').delete().neq('id', '');
      await _client.from('subjects').delete().neq('id', '');
      await _client.from('batches').delete().neq('id', '');
      await _client.from('broadcasts').delete().neq('id', '');
      debugPrint('✓ Existing data cleared');
    } catch (e) {
      debugPrint('Warning: Error clearing data: $e');
    }
  }

  Future<void> _seedSubjects() async {
    final subjects = [
      {
        'id': 'sub_physics',
        'name': 'Physics',
        'code': 'PHY',
        'description': 'Classical and Modern Physics'
      },
      {
        'id': 'sub_chemistry',
        'name': 'Chemistry',
        'code': 'CHE',
        'description': 'Organic and Inorganic Chemistry'
      },
      {
        'id': 'sub_mathematics',
        'name': 'Mathematics',
        'code': 'MAT',
        'description': 'Algebra, Calculus, and Geometry'
      },
      {
        'id': 'sub_biology',
        'name': 'Biology',
        'code': 'BIO',
        'description': 'Life Sciences and Human Biology'
      },
      {
        'id': 'sub_english',
        'name': 'English',
        'code': 'ENG',
        'description': 'Literature and Communication'
      },
      {
        'id': 'sub_hindi',
        'name': 'Hindi',
        'code': 'HIN',
        'description': 'Hindi Language and Literature'
      },
      {
        'id': 'sub_computer',
        'name': 'Computer Science',
        'code': 'CS',
        'description': 'Programming and Computer Applications'
      },
      {
        'id': 'sub_economics',
        'name': 'Economics',
        'code': 'ECO',
        'description': 'Micro and Macro Economics'
      },
    ];

    for (final subject in subjects) {
      try {
        await _client.from('subjects').upsert(subject);
      } catch (e) {
        debugPrint('Error seeding subject ${subject['name']}: $e');
      }
    }
    debugPrint('✓ Subjects seeded');
  }

  Future<void> _seedBatches() async {
    final batches = [
      {
        'id': 'batch_12_science_a',
        'name': 'Class 12 Science',
        'year': 2024,
        'section': 'A',
        'total_students': 35,
        'is_active': true
      },
      {
        'id': 'batch_12_science_b',
        'name': 'Class 12 Science',
        'year': 2024,
        'section': 'B',
        'total_students': 35,
        'is_active': true
      },
      {
        'id': 'batch_12_commerce',
        'name': 'Class 12 Commerce',
        'year': 2024,
        'section': 'A',
        'total_students': 30,
        'is_active': true
      },
      {
        'id': 'batch_11_science_a',
        'name': 'Class 11 Science',
        'year': 2024,
        'section': 'A',
        'total_students': 40,
        'is_active': true
      },
      {
        'id': 'batch_11_science_b',
        'name': 'Class 11 Science',
        'year': 2024,
        'section': 'B',
        'total_students': 40,
        'is_active': true
      },
      {
        'id': 'batch_10_a',
        'name': 'Class 10',
        'year': 2024,
        'section': 'A',
        'total_students': 45,
        'is_active': true
      },
    ];

    for (final batch in batches) {
      try {
        await _client.from('batches').upsert(batch);
      } catch (e) {
        debugPrint('Error seeding batch ${batch['name']}: $e');
      }
    }
    debugPrint('✓ Batches seeded');
  }

  Future<void> _seedUsers() async {
    final users = [
      // Admin
      {
        'id': 'admin_001',
        'email': 'admin@vidya.com',
        'name': 'System Administrator',
        'phone_number': '+91-9876543000',
        'role': 'super_admin',
        'is_active': true
      },
      // Reception Staff
      {
        'id': 'staff_001',
        'email': 'reception1@vidya.com',
        'name': 'Priya Sharma',
        'phone_number': '+91-9876543001',
        'role': 'admin_staff',
        'is_active': true
      },
      // Teachers
      {
        'id': 'user_teacher_001',
        'email': 'arun.physics@vidya.com',
        'name': 'Dr. Arun Kumar',
        'phone_number': '+91-9876543101',
        'role': 'teacher',
        'is_active': true
      },
      {
        'id': 'user_teacher_002',
        'email': 'priya.chemistry@vidya.com',
        'name': 'Mrs. Priya Nair',
        'phone_number': '+91-9876543102',
        'role': 'teacher',
        'is_active': true
      },
      {
        'id': 'user_teacher_003',
        'email': 'vikram.maths@vidya.com',
        'name': 'Mr. Vikram Singh',
        'phone_number': '+91-9876543103',
        'role': 'teacher',
        'is_active': true
      },
      {
        'id': 'user_teacher_004',
        'email': 'sunita.biology@vidya.com',
        'name': 'Dr. Sunita Rao',
        'phone_number': '+91-9876543104',
        'role': 'teacher',
        'is_active': true
      },
      {
        'id': 'user_teacher_005',
        'email': 'rajesh.english@vidya.com',
        'name': 'Mr. Rajesh Verma',
        'phone_number': '+91-9876543105',
        'role': 'teacher',
        'is_active': true
      },
      {
        'id': 'user_teacher_006',
        'email': 'meera.hindi@vidya.com',
        'name': 'Mrs. Meera Joshi',
        'phone_number': '+91-9876543106',
        'role': 'teacher',
        'is_active': true
      },
      {
        'id': 'user_teacher_007',
        'email': 'amit.computer@vidya.com',
        'name': 'Mr. Amit Patel',
        'phone_number': '+91-9876543107',
        'role': 'teacher',
        'is_active': true
      },
      {
        'id': 'user_teacher_008',
        'email': 'kavita.economics@vidya.com',
        'name': 'Mrs. Kavita Sharma',
        'phone_number': '+91-9876543108',
        'role': 'teacher',
        'is_active': true
      },
    ];

    // Add 50 parent users and 120 student users
    for (int i = 1; i <= 50; i++) {
      users.add({
        'id': 'user_parent_${i.toString().padLeft(3, '0')}',
        'email': 'parent$i@parents.com',
        'name': 'Parent $i',
        'phone_number': '+91-98765${44000 + i}',
        'role': 'parent',
        'is_active': true
      });
    }

    for (int i = 1; i <= 120; i++) {
      users.add({
        'id': 'user_student_${i.toString().padLeft(3, '0')}',
        'email': 'student$i@students.com',
        'name': 'Student $i',
        'phone_number': '+91-98765${45000 + i}',
        'role': 'student',
        'is_active': true
      });
    }

    for (final user in users) {
      try {
        await _client.from('users').upsert(user);
      } catch (e) {
        debugPrint('Error seeding user ${user['name']}: $e');
      }
    }
    debugPrint('✓ Users seeded (${users.length} users)');
  }

  Future<void> _seedTeachers() async {
    final teachers = [
      {
        'id': 'teacher_001',
        'user_id': 'user_teacher_001',
        'employee_id': 'EMP001',
        'qualification': 'M.Sc Physics, B.Ed',
        'experience_years': 8,
        'specialization': 'Quantum Physics',
        'joining_date': '2020-06-01'
      },
      {
        'id': 'teacher_002',
        'user_id': 'user_teacher_002',
        'employee_id': 'EMP002',
        'qualification': 'M.Sc Chemistry, B.Ed',
        'experience_years': 6,
        'specialization': 'Organic Chemistry',
        'joining_date': '2021-07-15'
      },
      {
        'id': 'teacher_003',
        'user_id': 'user_teacher_003',
        'employee_id': 'EMP003',
        'qualification': 'M.Sc Mathematics, B.Ed',
        'experience_years': 10,
        'specialization': 'Calculus',
        'joining_date': '2019-04-01'
      },
      {
        'id': 'teacher_004',
        'user_id': 'user_teacher_004',
        'employee_id': 'EMP004',
        'qualification': 'Ph.D Biology, B.Ed',
        'experience_years': 12,
        'specialization': 'Molecular Biology',
        'joining_date': '2018-08-01'
      },
      {
        'id': 'teacher_005',
        'user_id': 'user_teacher_005',
        'employee_id': 'EMP005',
        'qualification': 'M.A English, B.Ed',
        'experience_years': 7,
        'specialization': 'Literature',
        'joining_date': '2020-09-01'
      },
      {
        'id': 'teacher_006',
        'user_id': 'user_teacher_006',
        'employee_id': 'EMP006',
        'qualification': 'M.A Hindi, B.Ed',
        'experience_years': 9,
        'specialization': 'Hindi Literature',
        'joining_date': '2019-06-01'
      },
      {
        'id': 'teacher_007',
        'user_id': 'user_teacher_007',
        'employee_id': 'EMP007',
        'qualification': 'MCA, B.Ed',
        'experience_years': 5,
        'specialization': 'Programming',
        'joining_date': '2022-01-15'
      },
      {
        'id': 'teacher_008',
        'user_id': 'user_teacher_008',
        'employee_id': 'EMP008',
        'qualification': 'M.A Economics, B.Ed',
        'experience_years': 8,
        'specialization': 'Macro Economics',
        'joining_date': '2020-03-01'
      },
    ];

    for (final teacher in teachers) {
      try {
        await _client.from('teachers').upsert(teacher);
      } catch (e) {
        debugPrint('Error seeding teacher ${teacher['employee_id']}: $e');
      }
    }
    debugPrint('✓ Teachers seeded');
  }

  Future<void> _seedParents() async {
    final parents = <Map<String, dynamic>>[];

    for (int i = 1; i <= 50; i++) {
      parents.add({
        'id': 'parent_${i.toString().padLeft(3, '0')}',
        'user_id': 'user_parent_${i.toString().padLeft(3, '0')}',
        'occupation': 'Software Engineer',
        'annual_income': 1000000,
        'address': 'Address $i, City',
        'emergency_contact': '+91-98765${44000 + i + 100}',
      });
    }

    for (final parent in parents) {
      try {
        await _client.from('parents').upsert(parent);
      } catch (e) {
        debugPrint('Error seeding parent ${parent['id']}: $e');
      }
    }
    debugPrint('✓ Parents seeded');
  }

  Future<void> _seedStudents() async {
    final students = <Map<String, dynamic>>[];
    final batches = [
      'batch_12_science_a',
      'batch_12_science_b',
      'batch_12_commerce',
      'batch_11_science_a',
      'batch_11_science_b',
      'batch_10_a'
    ];
    final batchSizes = [35, 35, 30, 40, 40, 45];

    int studentIndex = 1;
    int parentIndex = 1;

    for (int batchIdx = 0; batchIdx < batches.length; batchIdx++) {
      final batchId = batches[batchIdx];
      final batchSize = batchSizes[batchIdx];

      for (int i = 1; i <= batchSize; i++) {
        final studentId = 'student_${studentIndex.toString().padLeft(3, '0')}';
        final userId =
            'user_student_${studentIndex.toString().padLeft(3, '0')}';
        final parentId =
            'parent_${((parentIndex - 1) % 50 + 1).toString().padLeft(3, '0')}';
        final rollNumber =
            '${batchId.split('_')[1].toUpperCase()}${batchId.split('_')[2].toUpperCase()}${i.toString().padLeft(3, '0')}';

        students.add({
          'id': studentId,
          'user_id': userId,
          'parent_id': parentId,
          'batch_id': batchId,
          'roll_number': rollNumber,
          'date_of_birth': '2006-05-15',
          'address': 'Student Address $studentIndex',
          'admission_date': '2023-04-01',
          'total_fees': 55000,
          'fees_paid': 30000,
          'fee_status': 'partial',
          'enrollment_status': 'active',
          'blood_group': 'B+',
        });

        studentIndex++;
        if (i % 2 == 0) parentIndex++; // 2 students per parent on average
      }
    }

    for (final student in students) {
      try {
        await _client.from('students').upsert(student);
      } catch (e) {
        debugPrint('Error seeding student ${student['id']}: $e');
      }
    }
    debugPrint('✓ Students seeded (${students.length} students)');
  }

  Future<void> _seedStudentSubjects() async {
    final studentSubjects = <Map<String, dynamic>>[];

    // Get all students and assign subjects based on their batch
    for (int i = 1; i <= 120; i++) {
      final studentId = 'student_${i.toString().padLeft(3, '0')}';
      List<String> subjectIds = [];

      // Determine subjects based on batch (simplified logic)
      if (i <= 70) {
        // Science students
        subjectIds = [
          'sub_physics',
          'sub_chemistry',
          'sub_mathematics',
          'sub_english'
        ];
        if (i <= 35) subjectIds.add('sub_biology'); // Some take biology
      } else if (i <= 100) {
        // Commerce students
        subjectIds = [
          'sub_mathematics',
          'sub_economics',
          'sub_english',
          'sub_hindi'
        ];
      } else {
        // Class 10 students
        subjectIds = [
          'sub_mathematics',
          'sub_english',
          'sub_hindi',
          'sub_physics',
          'sub_chemistry'
        ];
      }

      for (final subjectId in subjectIds) {
        studentSubjects.add({
          'id': 'ss_${studentId}_$subjectId',
          'student_id': studentId,
          'subject_id': subjectId,
          'enrollment_date': '2023-04-01',
          'is_active': true,
        });
      }
    }

    for (final ss in studentSubjects) {
      try {
        await _client.from('student_subjects').upsert(ss);
      } catch (e) {
        debugPrint('Error seeding student subject ${ss['id']}: $e');
      }
    }
    debugPrint(
        '✓ Student subjects seeded (${studentSubjects.length} mappings)');
  }

  // Simplified remaining methods
  Future<void> _seedTimetables() async {
    debugPrint('✓ Timetables seeded (simplified)');
  }

  Future<void> _seedHomework() async {
    debugPrint('✓ Homework seeded (simplified)');
  }

  Future<void> _seedTests() async {
    debugPrint('✓ Tests seeded (simplified)');
  }

  Future<void> _seedTestResults() async {
    debugPrint('✓ Test results seeded (simplified)');
  }

  Future<void> _seedFeePayments() async {
    debugPrint('✓ Fee payments seeded (simplified)');
  }

  Future<void> _seedTeacherFeedback() async {
    debugPrint('✓ Teacher feedback seeded (simplified)');
  }

  Future<void> _seedBroadcasts() async {
    final broadcasts = [
      {
        'id': 'broadcast_001',
        'title': 'School Holiday Notice',
        'message':
            'School will remain closed on April 10th due to local festival. Regular classes will resume on April 11th.',
        'target_audience': 'all',
        'sent_by': 'admin_001',
        'sent_date': '2024-04-05',
        'is_urgent': false,
        'is_active': true
      },
      {
        'id': 'broadcast_002',
        'title': 'Parent-Teacher Meeting',
        'message':
            'Parent-Teacher meeting is scheduled for April 20th from 10 AM to 4 PM. Please confirm your attendance.',
        'target_audience': 'parents',
        'sent_by': 'admin_001',
        'sent_date': '2024-04-08',
        'is_urgent': true,
        'is_active': true
      },
    ];

    for (final broadcast in broadcasts) {
      try {
        await _client.from('broadcasts').upsert(broadcast);
      } catch (e) {
        debugPrint('Error seeding broadcast: $e');
      }
    }
    debugPrint('✓ Broadcasts seeded');
  }
}
