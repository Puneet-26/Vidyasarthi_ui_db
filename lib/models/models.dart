// Data models compatible with Supabase
// All models include fromJson() and toJson() for database serialization

// User/Auth Models
class AppUser {
  final String id;
  final String email;
  final String name;
  final String role; // super_admin, admin_staff, teacher, student, parent
  final String phoneNumber;
  final String? profileImage;
  final bool isActive;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phoneNumber,
    this.profileImage,
    this.isActive = true,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'student',
      phoneNumber: json['phone_number'] ?? '',
      profileImage: json['profile_image'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'phone_number': phoneNumber,
    'profile_image': profileImage,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
  };
}

// Subject Model
class Subject {
  final String id;
  final String name;
  final String code;
  final String description;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    this.description = '',
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'description': description,
  };
}

// Batch/Class Model
class Batch {
  final String id;
  final String name;
  final String level; // 10th, 11th, 12th, etc
  final List<String> subjects;
  final DateTime createdAt;

  Batch({
    required this.id,
    required this.name,
    required this.level,
    required this.subjects,
    required this.createdAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      subjects: List<String>.from(json['subject_ids'] ?? []),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
    'subject_ids': subjects,
    'created_at': createdAt.toIso8601String(),
  };
}

// Student Model
class Student {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String parentPhone;
  final String parentName;
  final String parentEmail;
  final String batchId;
  final List<String> subjectIds;
  final double totalFees;
  final double feesPaid;
  final String feeStatus; // active, pending, overdue
  final String enrollmentStatus; // active, inactive, dropped
  final DateTime enrollmentDate;
  final String? profileImage;

  Student({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.parentPhone,
    required this.parentName,
    required this.parentEmail,
    required this.batchId,
    required this.subjectIds,
    required this.totalFees,
    required this.feesPaid,
    required this.feeStatus,
    required this.enrollmentStatus,
    required this.enrollmentDate,
    this.profileImage,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone'] ?? '',
      parentPhone: json['parent_phone'] ?? '',
      parentName: json['parent_name'] ?? '',
      parentEmail: json['parent_email'] ?? '',
      batchId: json['batch_id'] ?? '',
      subjectIds: List<String>.from(json['subject_ids'] ?? []),
      totalFees: (json['total_fees'] ?? 0).toDouble(),
      feesPaid: (json['fees_paid'] ?? 0).toDouble(),
      feeStatus: json['fee_status'] ?? 'pending',
      enrollmentStatus: json['enrollment_status'] ?? 'active',
      enrollmentDate: DateTime.parse(json['enrollment_date'] ?? DateTime.now().toIso8601String()),
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'email': email,
    'phone': phoneNumber,
    'parent_phone': parentPhone,
    'parent_name': parentName,
    'parent_email': parentEmail,
    'batch_id': batchId,
    'subject_ids': subjectIds,
    'total_fees': totalFees.toInt(),
    'fees_paid': feesPaid.toInt(),
    'fee_status': feeStatus,
    'enrollment_status': enrollmentStatus,
    'enrollment_date': enrollmentDate.toIso8601String(),
    'profile_image': profileImage,
  };
}

// Admission Model
class Admission {
  final String id;
  final String studentName;
  final String parentName;
  final String email;
  final String phoneNumber;
  final String parentPhone;
  final String appliedBatchId;
  final List<String> requestedSubjectIds;
  final String status; // pending, approved, rejected
  final DateTime appliedDate;
  final String? notes;

  Admission({
    required this.id,
    required this.studentName,
    required this.parentName,
    required this.email,
    required this.phoneNumber,
    required this.parentPhone,
    required this.appliedBatchId,
    required this.requestedSubjectIds,
    required this.status,
    required this.appliedDate,
    this.notes,
  });

  factory Admission.fromJson(Map<String, dynamic> json) {
    return Admission(
      id: json['id'] ?? '',
      studentName: json['student_name'] ?? '',
      parentName: json['parent_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone'] ?? '',
      parentPhone: json['parent_phone'] ?? '',
      appliedBatchId: json['applied_batch_id'] ?? '',
      requestedSubjectIds: List<String>.from(json['requested_subject_ids'] ?? []),
      status: json['status'] ?? 'pending',
      appliedDate: DateTime.parse(json['applied_date'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'student_name': studentName,
    'parent_name': parentName,
    'email': email,
    'phone': phoneNumber,
    'parent_phone': parentPhone,
    'applied_batch_id': appliedBatchId,
    'requested_subject_ids': requestedSubjectIds,
    'status': status,
    'applied_date': appliedDate.toIso8601String(),
    'notes': notes,
  };
}

// TimeTable Model
class TimeTable {
  final String id;
  final String batchId;
  final String subjectId;
  final String teacherId;
  final String day; // Monday, Tuesday, etc
  final String startTime;
  final String endTime;
  final String? room;
  final String? proxyTeacherId;
  final DateTime createdAt;

  TimeTable({
    required this.id,
    required this.batchId,
    required this.subjectId,
    required this.teacherId,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.room,
    this.proxyTeacherId,
    required this.createdAt,
  });

  factory TimeTable.fromJson(Map<String, dynamic> json) {
    return TimeTable(
      id: json['id'] ?? '',
      batchId: json['batch_id'] ?? '',
      subjectId: json['subject_id'] ?? '',
      teacherId: json['teacher_id'] ?? '',
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      room: json['room'],
      proxyTeacherId: json['proxy_teacher_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'batch_id': batchId,
    'subject_id': subjectId,
    'teacher_id': teacherId,
    'day': day,
    'start_time': startTime,
    'end_time': endTime,
    'room': room,
    'proxy_teacher_id': proxyTeacherId,
    'created_at': createdAt.toIso8601String(),
  };
}

// Syllabus/Portion Model
class SyllabusItem {
  final String id;
  final String subjectId;
  final String topic;
  final String description;
  final int order;
  final bool isCompleted;
  final DateTime? completedDate;

  SyllabusItem({
    required this.id,
    required this.subjectId,
    required this.topic,
    required this.description,
    required this.order,
    required this.isCompleted,
    this.completedDate,
  });

  factory SyllabusItem.fromJson(Map<String, dynamic> json) {
    return SyllabusItem(
      id: json['id'] ?? '',
      subjectId: json['subject_id'] ?? '',
      topic: json['topic'] ?? '',
      description: json['description'] ?? '',
      order: json['ordering'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      completedDate: json['completed_date'] != null ? DateTime.parse(json['completed_date']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject_id': subjectId,
    'topic': topic,
    'description': description,
    'ordering': order,
    'is_completed': isCompleted,
    'completed_date': completedDate?.toIso8601String(),
  };
}

// Homework Model
class Homework {
  final String id;
  final String batchId;
  final String subjectId;
  final String teacherId;
  final String title;
  final String description;
  final DateTime dueDate;
  final List<String> assignedStudents; // student IDs
  final String status; // active, completed, overdue

  Homework({
    required this.id,
    required this.batchId,
    required this.subjectId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.assignedStudents,
    required this.status,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json['id'] ?? '',
      batchId: json['batch_id'] ?? '',
      subjectId: json['subject_id'] ?? '',
      teacherId: json['teacher_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      assignedStudents: List<String>.from(json['assigned_students'] ?? []),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'batch_id': batchId,
    'subject_id': subjectId,
    'teacher_id': teacherId,
    'title': title,
    'description': description,
    'due_date': dueDate.toIso8601String(),
    'assigned_students': assignedStudents,
    'status': status,
  };
}

// Homework Submission Model
class HomeworkSubmission {
  final String id;
  final String homeworkId;
  final String studentId;
  final String status; // submitted, pending, not_submitted
  final DateTime? submittedDate;
  final String? remarks;

  HomeworkSubmission({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.status,
    this.submittedDate,
    this.remarks,
  });

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) {
    return HomeworkSubmission(
      id: json['id'] ?? '',
      homeworkId: json['homework_id'] ?? '',
      studentId: json['student_id'] ?? '',
      status: json['status'] ?? 'pending',
      submittedDate: json['submitted_date'] != null ? DateTime.parse(json['submitted_date']) : null,
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'homework_id': homeworkId,
    'student_id': studentId,
    'status': status,
    'submitted_date': submittedDate?.toIso8601String(),
    'remarks': remarks,
  };
}

// Test/Exam Model
class Test {
  final String id;
  final String batchId;
  final String subjectId;
  final String teacherId;
  final String title;
  final DateTime testDate;
  final int totalMarks;
  final String status; // scheduled, completed, cancelled

  Test({
    required this.id,
    required this.batchId,
    required this.subjectId,
    required this.teacherId,
    required this.title,
    required this.testDate,
    required this.totalMarks,
    required this.status,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'] ?? '',
      batchId: json['batch_id'] ?? '',
      subjectId: json['subject_id'] ?? '',
      teacherId: json['teacher_id'] ?? '',
      title: json['title'] ?? '',
      testDate: DateTime.parse(json['test_date'] ?? DateTime.now().toIso8601String()),
      totalMarks: json['total_marks'] ?? 100,
      status: json['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'batch_id': batchId,
    'subject_id': subjectId,
    'teacher_id': teacherId,
    'title': title,
    'test_date': testDate.toIso8601String(),
    'total_marks': totalMarks,
    'status': status,
  };
}

// Test Result Model
class TestResult {
  final String id;
  final String testId;
  final String studentId;
  final int marksObtained;
  final String status; // evaluated, pending

  TestResult({
    required this.id,
    required this.testId,
    required this.studentId,
    required this.marksObtained,
    required this.status,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'] ?? '',
      testId: json['test_id'] ?? '',
      studentId: json['student_id'] ?? '',
      marksObtained: json['marks_obtained'] ?? 0,
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'test_id': testId,
    'student_id': studentId,
    'marks_obtained': marksObtained,
    'status': status,
  };
}

// Fee Payment Model
class FeePayment {
  final String id;
  final String studentId;
  final double amount;
  final String paymentMethod; // cash, card, bank_transfer, upi
  final DateTime paymentDate;
  final String status; // confirmed, pending, failed
  final String reference;

  FeePayment({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.status,
    required this.reference,
  });

  factory FeePayment.fromJson(Map<String, dynamic> json) {
    return FeePayment(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'cash',
      paymentDate: DateTime.parse(json['payment_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      reference: json['reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'student_id': studentId,
    'amount': amount.toInt(),
    'payment_method': paymentMethod,
    'payment_date': paymentDate.toIso8601String(),
    'status': status,
    'reference': reference,
  };
}

// Broadcast/Notice Model
class Broadcast {
  final String id;
  final String title;
  final String message;
  final String sentBy;
  final DateTime sentDate;
  final String targetAudience; // all, students, parents, teachers, staff
  final String priority; // normal, high, urgent

  Broadcast({
    required this.id,
    required this.title,
    required this.message,
    required this.sentBy,
    required this.sentDate,
    required this.targetAudience,
    required this.priority,
  });

  factory Broadcast.fromJson(Map<String, dynamic> json) {
    return Broadcast(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      sentBy: json['sent_by'] ?? '',
      sentDate: DateTime.parse(json['sent_date'] ?? DateTime.now().toIso8601String()),
      targetAudience: json['target_audience'] ?? 'all',
      priority: json['priority'] ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'sent_by': sentBy,
    'sent_date': sentDate.toIso8601String(),
    'target_audience': targetAudience,
    'priority': priority,
  };
}

// Doubt/Query Model
class Doubt {
  final String id;
  final String studentId;
  final String subjectId;
  final String title;
  final String description;
  final DateTime raisedDate;
  final String status; // open, resolved, closed
  final String? resolvedBy;
  final String? resolution;

  Doubt({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.raisedDate,
    required this.status,
    this.resolvedBy,
    this.resolution,
  });

  factory Doubt.fromJson(Map<String, dynamic> json) {
    return Doubt(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      subjectId: json['subject_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      raisedDate: DateTime.parse(json['raised_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'open',
      resolvedBy: json['resolved_by'],
      resolution: json['resolution'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'student_id': studentId,
    'subject_id': subjectId,
    'title': title,
    'description': description,
    'raised_date': raisedDate.toIso8601String(),
    'status': status,
    'resolved_by': resolvedBy,
    'resolution': resolution,
  };
}

// Feedback Model
class Feedback {
  final String id;
  final String? studentId;
  final String parentId;
  final String message;
  final DateTime submittedDate;
  final String status; // submitted, reviewed, approved
  final String? adminNotes;

  Feedback({
    required this.id,
    this.studentId,
    required this.parentId,
    required this.message,
    required this.submittedDate,
    required this.status,
    this.adminNotes,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'] ?? '',
      studentId: json['student_id'],
      parentId: json['parent_id'] ?? '',
      message: json['message'] ?? '',
      submittedDate: DateTime.parse(json['submitted_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'submitted',
      adminNotes: json['admin_notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'student_id': studentId,
    'parent_id': parentId,
    'message': message,
    'submitted_date': submittedDate.toIso8601String(),
    'status': status,
    'admin_notes': adminNotes,
  };
}
