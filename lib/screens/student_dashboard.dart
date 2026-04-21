import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/database_service.dart';
import '../services/auth_session.dart';
import '../models/models.dart';
import 'connect_with_us_screen.dart';
import 'faculty_screen.dart';
import 'submit_feedback_screen_premium.dart';
import 'view_attendance_screen.dart';

class StudentDashboard extends StatefulWidget {
  final String? studentEmail;
  const StudentDashboard({super.key, this.studentEmail});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  Student? _student;
  List<Subject> _subjects = [];
  List<Homework> _homework = [];
  List<Test> _tests = [];
  List<TestResult> _testResults = [];
  List<TimeTable> _timetable = [];
  List<Broadcast> _broadcasts = [];
  bool _loading = true;

  final _db = DatabaseService();

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home'),
    BottomNavItem(
        icon: Icons.book_outlined,
        activeIcon: Icons.book_rounded,
        label: 'Subjects'),
    BottomNavItem(
        icon: Icons.assignment_outlined,
        activeIcon: Icons.assignment_rounded,
        label: 'Tasks'),
    BottomNavItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
        label: 'Results'),
    BottomNavItem(
        icon: Icons.feedback_outlined,
        activeIcon: Icons.feedback_rounded,
        label: 'Feedback'),
    BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person_rounded,
        label: 'Profile'),
  ];

  List<Widget> get _pages => [
        _StudentHomePage(
          student: _student,
          subjects: _subjects,
          homework: _homework,
          tests: _tests,
          timetable: _timetable,
          loading: _loading,
          broadcasts: _broadcasts,
        ),
        _StudentSubjectsPage(subjects: _subjects, loading: _loading),
        _StudentTasksPage(
            homework: _homework, tests: _tests, loading: _loading),
        _StudentResultsPage(testResults: _testResults, loading: _loading),
        _StudentFeedbackPage(studentId: _student?.id ?? ''),
        _StudentProfilePage(student: _student, loading: _loading),
      ];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      // Use AuthSession - always has the correct logged-in email
      final email = AuthSession.email ?? widget.studentEmail;
      if (email == null || email.isEmpty) {
        debugPrint('No student email in session');
        if (mounted) setState(() => _loading = false);
        return;
      }

      debugPrint('Loading student for email: $email');
      final response = await _db.client
          .from('students')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        debugPrint('Student not found for email: $email');
        if (mounted) setState(() => _loading = false);
        return;
      }

      final student = _db.studentFromRow(response);

      final subjects = await _db.getAllSubjects();
      final homework = await _db.getHomeworkByBatch(student.batchId);
      final tests = await _db.getTestsByBatch(student.batchId);
      final testResults = await _db.getTestResultsByStudent(student.id);
      final timetable = await _db.getTimeTableByBatch(student.batchId);
      final broadcasts = await _db.getBroadcastsForRole('students');

      if (mounted) {
        setState(() {
          _student = student;
          _subjects = subjects;
          _homework = homework;
          _tests = tests;
          _testResults = testResults;
          _timetable = timetable;
          _broadcasts = broadcasts;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading student data: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      bottomNavigationBar: VidyaBottomNav(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: (i) => setState(() => _selectedIndex = i),
        activeColor: AppColors.studentAccent,
      ),
      child: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
    );
  }
}

class _StudentHomePage extends StatelessWidget {
  final Student? student;
  final List<Subject> subjects;
  final List<Homework> homework;
  final List<Test> tests;
  final List<TimeTable> timetable;
  final bool loading;
  final List<Broadcast> broadcasts;

  const _StudentHomePage({
    required this.student,
    required this.subjects,
    required this.homework,
    required this.tests,
    required this.timetable,
    required this.loading,
    required this.broadcasts,
  });

  void _showNoticesSheet(BuildContext context) {
    showBroadcastNoticesSheet(context, 'students');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(
            name: student?.name ?? AuthSession.name ?? 'Student',
            role: 'STUDENT',
            subtitle: 'Student Dashboard',
            roleColor: AppColors.studentAccent,
            notificationCount: broadcasts.length,
            onNotification: () => _showNoticesSheet(context),
            actionButtons: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FacultyScreen(),
                  ),
                ),
                child: const GlassCard(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.people_rounded,
                    color: AppColors.studentAccent,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConnectWithUsScreen(),
                  ),
                ),
                child: const GlassCard(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.public_rounded,
                    color: AppColors.studentAccent,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Today's class banner
          _TodayClassBanner(timetable: timetable),
          const SizedBox(height: 24),

          // Timetable Today
          const SectionHeader(title: "Today's Timetable"),
          const SizedBox(height: 14),
          _TimetableList(timetable: timetable),
          const SizedBox(height: 24),

          // Stats Row — Attendance & Pending Tasks only
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (student != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewAttendanceScreen(
                            studentId: student!.id,
                            studentName: student!.name,
                          ),
                        ),
                      );
                    }
                  },
                  child: const StatCard(
                    title: 'Attendance',
                    value: '92%',
                    icon: Icons.how_to_reg_rounded,
                    color: AppColors.success,
                    subtitle: 'This month',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: StatCard(
                  title: 'Pending Tasks',
                  value: '4',
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.error,
                  subtitle: 'Due this week',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Subject Performance
          const SectionHeader(title: 'Subject Performance'),
          const SizedBox(height: 14),
          const GlassCard(
            child: Column(
              children: [
                LabeledProgressBar(
                    label: 'Mathematics',
                    value: 0.85,
                    color: AppColors.primary),
                SizedBox(height: 14),
                LabeledProgressBar(
                    label: 'Science', value: 0.78, color: AppColors.info),
                SizedBox(height: 14),
                LabeledProgressBar(
                    label: 'English', value: 0.91, color: AppColors.success),
                SizedBox(height: 14),
                LabeledProgressBar(
                    label: 'History', value: 0.65, color: AppColors.warning),
                SizedBox(height: 14),
                LabeledProgressBar(
                    label: 'Computer',
                    value: 0.95,
                    color: AppColors.studentAccent),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Upcoming Assignments
          const SectionHeader(title: 'Upcoming Assignments'),
          const SizedBox(height: 14),
          if (homework.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No pending assignments',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                      fontStyle: FontStyle.italic)),
            )
          else
            ...homework
                .take(5)
                .map((hw) {
                  final isUrgent = hw.dueDate.difference(DateTime.now()).inDays <= 1;
                  return Column(
                    children: [
                      _AssignmentItem(
                        subject: hw.subject,
                        title: hw.title,
                        dueDate:
                            'Due ${hw.dueDate.difference(DateTime.now()).inDays} days',
                        color: isUrgent ? AppColors.error : AppColors.primary,
                        isUrgent: isUrgent,
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                })
                .toList(),
          const SizedBox(height: 24),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ============================================================
//  STUDENT TAB PAGES
// ============================================================

class _StudentSubjectsPage extends StatelessWidget {
  final List<Subject> subjects;
  final bool loading;

  const _StudentSubjectsPage({required this.subjects, required this.loading});

  static const _physicsModules = [
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'ongoing'},
    {'status': 'pending'},
    {'status': 'pending'},
    {'status': 'pending'},
    {'status': 'pending'},
  ];
  static const _chemModules = [
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'ongoing'},
    {'status': 'pending'},
    {'status': 'pending'},
    {'status': 'pending'},
  ];
  static const _mathModules = [
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'done'},
    {'status': 'ongoing'},
    {'status': 'pending'},
  ];

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'My Subjects'),
          SizedBox(height: 16),
          _SubjectCard(
              name: 'Physics',
              code: 'PHY101',
              teacher: 'Mr. Arun Kumar',
              progress: 0.65,
              color: AppColors.primary,
              modules: _physicsModules),
          SizedBox(height: 12),
          _SubjectCard(
              name: 'Chemistry',
              code: 'CHM101',
              teacher: 'Mrs. Priya Sharma',
              progress: 0.72,
              color: AppColors.info,
              modules: _chemModules),
          SizedBox(height: 12),
          _SubjectCard(
              name: 'Mathematics',
              code: 'MTH101',
              teacher: 'Mr. Vikram Singh',
              progress: 0.85,
              color: AppColors.success,
              modules: _mathModules),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String name;
  final String code;
  final String teacher;
  final double progress;
  final Color color;
  final List<Map<String, dynamic>> modules;
  const _SubjectCard({
    required this.name,
    required this.code,
    required this.teacher,
    required this.progress,
    required this.color,
    required this.modules,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _SubjectModulesScreen(
            name: name,
            code: code,
            teacher: teacher,
            color: color,
            modules: modules,
          ),
        ),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.book_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: TextStyle(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      Text('$code • $teacher',
                          style: TextStyle(
                              fontSize: Responsive.sp(context, 12),
                              color: AppColors.textMid)),
                    ],
                  ),
                ),
                Text('${(progress * 100).round()}%',
                    style: TextStyle(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w700,
                        color: color)),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textLight, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            LabeledProgressBar(
                label: 'Syllabus completed', value: progress, color: color),
          ],
        ),
      ),
    );
  }
}

class _SubjectModulesScreen extends StatelessWidget {
  final String name;
  final String code;
  final String teacher;
  final Color color;
  final List<Map<String, dynamic>> modules;

  const _SubjectModulesScreen({
    required this.name,
    required this.code,
    required this.teacher,
    required this.color,
    required this.modules,
  });

  @override
  Widget build(BuildContext context) {
    final completed = modules.where((m) => m['status'] == 'done').length;
    final total = modules.length;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            Text('$code • $teacher',
                style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress summary
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$completed of $total modules completed',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      Text('${((completed / total) * 100).round()}%',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: completed / total,
                      minHeight: 8,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Modules'),
            const SizedBox(height: 12),
            ...modules.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              final status =
                  m['status'] as String; // 'done', 'ongoing', 'pending'
              Color statusColor;
              IconData statusIcon;
              String statusLabel;
              switch (status) {
                case 'done':
                  statusColor = AppColors.success;
                  statusIcon = Icons.check_circle_rounded;
                  statusLabel = 'Completed';
                  break;
                case 'ongoing':
                  statusColor = color;
                  statusIcon = Icons.play_circle_rounded;
                  statusLabel = 'Ongoing';
                  break;
                default:
                  statusColor = AppColors.textLight;
                  statusIcon = Icons.radio_button_unchecked_rounded;
                  statusLabel = 'Pending';
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Module ${i + 1}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: status == 'done'
                                  ? AppColors.textMid
                                  : AppColors.textDark,
                              decoration: status == 'done'
                                  ? TextDecoration.lineThrough
                                  : null,
                            )),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(statusLabel,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor)),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SyllabusTile extends StatelessWidget {
  final String topic;
  final String subject;
  final bool done;
  const _SyllabusTile(
      {required this.topic, required this.subject, required this.done});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
              done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: done ? AppColors.success : AppColors.textLight,
              size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic,
                    style: TextStyle(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w600,
                        color: done ? AppColors.textMid : AppColors.textDark,
                        decoration: done ? TextDecoration.lineThrough : null)),
                Text(subject,
                    style: TextStyle(
                        fontSize: Responsive.sp(context, 11),
                        color: AppColors.textLight)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (done ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(done ? 'Done' : 'Pending',
                style: TextStyle(
                    fontSize: Responsive.sp(context, 10),
                    fontWeight: FontWeight.w600,
                    color: done ? AppColors.success : AppColors.warning)),
          ),
        ],
      ),
    );
  }
}

class _StudentTasksPage extends StatelessWidget {
  final List<Homework> homework;
  final List<Test> tests;
  final bool loading;

  const _StudentTasksPage(
      {required this.homework, required this.tests, required this.loading});
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Pending Homework'),
          SizedBox(height: 12),
          _TaskItem(
              title: 'Laws of Motion Problems',
              subject: 'Physics',
              due: 'Due in 3 days',
              urgent: false),
          SizedBox(height: 10),
          _TaskItem(
              title: 'Chemical Bonding Worksheet',
              subject: 'Chemistry',
              due: 'Due in 5 days',
              urgent: false),
          SizedBox(height: 10),
          _TaskItem(
              title: 'Integration Practice',
              subject: 'Mathematics',
              due: 'Due Tomorrow',
              urgent: true),
          SizedBox(height: 24),
          SectionHeader(title: 'Upcoming Tests'),
          SizedBox(height: 12),
          _TestItem(
              title: 'Mid-Term Physics Exam',
              date: 'Mar 28, 2026',
              marks: 100,
              color: AppColors.primary),
          SizedBox(height: 10),
          _TestItem(
              title: 'Mid-Term Mathematics Exam',
              date: 'Apr 1, 2026',
              marks: 100,
              color: AppColors.studentAccent),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String title;
  final String subject;
  final String due;
  final bool urgent;
  const _TaskItem(
      {required this.title,
      required this.subject,
      required this.due,
      required this.urgent});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: urgent ? AppColors.error : AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                Text(subject,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMid)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (urgent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5)),
                  child: const Text('URGENT',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error)),
                ),
              Text(due,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestItem extends StatelessWidget {
  final String title;
  final String date;
  final int marks;
  final Color color;
  const _TestItem(
      {required this.title,
      required this.date,
      required this.marks,
      required this.color});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.quiz_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                Text('$date • $marks marks',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMid)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Text('Scheduled',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}

class _StudentResultsPage extends StatefulWidget {
  final List<TestResult> testResults;
  final bool loading;

  const _StudentResultsPage({required this.testResults, required this.loading});
  
  @override
  State<_StudentResultsPage> createState() => _StudentResultsPageState();
}

class _StudentResultsPageState extends State<_StudentResultsPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.testResults.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Test Results'),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your test results will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Test Results'),
          const SizedBox(height: 16),
          ...widget.testResults.asMap().entries.map((entry) {
            final result = entry.value;
            final percentage = result.percentage ?? 0;
            final grade = result.grade ?? 'N/A';
            
            return _TestResultCard(
              subject: result.subject ?? 'Unknown Subject',
              testName: result.testName ?? 'Unknown Test',
              marksObtained: result.marksObtained ?? 0,
              maxMarks: result.maxMarks ?? 100,
              percentage: percentage,
              grade: grade,
              status: result.status ?? 'completed',
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _TestResultCard extends StatelessWidget {
  final String subject;
  final String testName;
  final double marksObtained;
  final double maxMarks;
  final double percentage;
  final String grade;
  final String status;

  const _TestResultCard({
    required this.subject,
    required this.testName,
    required this.marksObtained,
    required this.maxMarks,
    required this.percentage,
    required this.grade,
    required this.status,
  });

  Color _getGradeColor() {
    if (percentage >= 90) return const Color(0xFF4CAF50);
    if (percentage >= 80) return const Color(0xFF2196F3);
    if (percentage >= 70) return const Color(0xFFFFC107);
    if (percentage >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      testName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMid,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getGradeColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      grade,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _getGradeColor(),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getGradeColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Marks: ${marksObtained.toStringAsFixed(0)}/$maxMarks',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation(_getGradeColor()),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentProfilePage extends StatelessWidget {
  final Student? student;
  final bool loading;

  const _StudentProfilePage({required this.student, required this.loading});

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
              child: GradientAvatar(
                  initials: student != null && student!.name.isNotEmpty
                      ? student!.name.substring(0, 1).toUpperCase()
                      : 'S',
                  color: AppColors.studentAccent,
                  size: 72)),
          const SizedBox(height: 12),
          Center(
              child: Text(student?.name ?? AuthSession.name ?? 'Student',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark))),
          Center(
              child: Text('Student • ${student?.studentClass ?? 'N/A'}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMid))),
          const SizedBox(height: 24),

          // Personal Info
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ProfileRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: student?.email ?? AuthSession.email ?? '-'),
                const Divider(height: 20),
                _ProfileRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: student?.phoneNumber ?? '-'),
                const Divider(height: 20),
                _ProfileRow(
                    icon: Icons.people_outlined,
                    label: 'Parent',
                    value: student?.parentName.split('(').first.trim() ?? '-'),
                const Divider(height: 20),
                _ProfileRow(
                    icon: Icons.class_outlined,
                    label: 'Class',
                    value: student?.studentClass ?? '-'),
                const Divider(height: 20),
                _ProfileRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Enrolled',
                    value: student != null
                        ? '${student!.enrollmentDate.month}/${student!.enrollmentDate.year}'
                        : '-'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (_) => false),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textLight)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ],
        ),
      ],
    );
  }
}

class _TodayClassBanner extends StatelessWidget {
  final List<TimeTable> timetable;

  const _TodayClassBanner({required this.timetable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Class',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 12),
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mathematics',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 20),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        color: Colors.white70,
                        size: Responsive.sp(context, 14)),
                    const SizedBox(width: 4),
                    Text(
                      '10:30 AM  •  Room 204',
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 12),
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Starts in 25 min',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.calculate_rounded, size: 64, color: Colors.white24),
        ],
      ),
    );
  }
}

class _AssignmentItem extends StatelessWidget {
  final String subject;
  final String title;
  final String dueDate;
  final Color color;
  final bool isUrgent;

  const _AssignmentItem({
    required this.subject,
    required this.title,
    required this.dueDate,
    required this.color,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 11),
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isUrgent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                dueDate,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimetableList extends StatelessWidget {
  final List<TimeTable> timetable;

  const _TimetableList({required this.timetable});
  final List<Map<String, String>> periods = const [
    {
      'time': '08:00',
      'subject': 'English',
      'teacher': 'Mrs. Priya Nair',
      'room': '101'
    },
    {
      'time': '09:00',
      'subject': 'Mathematics',
      'teacher': 'Mr. Rajan Kumar',
      'room': '204'
    },
    {
      'time': '10:30',
      'subject': 'Science',
      'teacher': 'Dr. Shalini Rao',
      'room': 'Lab 2'
    },
    {'time': '12:00', 'subject': 'Lunch Break', 'teacher': '', 'room': ''},
    {
      'time': '13:00',
      'subject': 'History',
      'teacher': 'Mr. Anand Joshi',
      'room': '108'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: periods.asMap().entries.map((e) {
          final isLunch = e.value['subject'] == 'Lunch Break';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: e.key < periods.length - 1
                  ? const Border(
                      bottom: BorderSide(color: AppColors.divider, width: 1))
                  : null,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    e.value['time']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isLunch ? AppColors.warning : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.value['subject']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isLunch ? AppColors.warning : AppColors.textDark,
                        ),
                      ),
                      if (e.value['teacher']!.isNotEmpty)
                        Text(
                          '${e.value['teacher']} • Room ${e.value['room']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NoticeItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color color;

  const _NoticeItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
        ],
      ),
    );
  }
}

class _HolidayNotice extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final Color color;

  const _HolidayNotice(
      {required this.title,
      required this.date,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                Text(date,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMid)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6)),
            child: Text('Holiday',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }
}


// ============================================================
//  STUDENT FEEDBACK PAGE
// ============================================================

class _StudentFeedbackPage extends StatefulWidget {
  final String studentId;
  
  const _StudentFeedbackPage({required this.studentId});

  @override
  State<_StudentFeedbackPage> createState() => _StudentFeedbackPageState();
}

class _StudentFeedbackPageState extends State<_StudentFeedbackPage> {
  final _db = DatabaseService();
  List<AnonymousFeedback> _myFeedback = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMyFeedback();
  }

  Future<void> _loadMyFeedback() async {
    final feedback = await _db.getMySubmittedFeedback(widget.studentId, 'student');
    if (mounted) {
      setState(() {
        _myFeedback = feedback;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Anonymous Feedback'),
          const SizedBox(height: 14),
          
          // Info card
          const GlassCard(
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.info, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Anonymous Feedback',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your feedback is completely anonymous. Teachers will not know who sent it.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Send Feedback Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubmitFeedbackScreenPremium(
                      senderRole: 'student',
                      senderId: widget.studentId,
                    ),
                  ),
                );
                _loadMyFeedback(); // Refresh after returning
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Send Feedback to Teacher'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.studentAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // My Submitted Feedback
          const SectionHeader(title: 'My Submitted Feedback'),
          const SizedBox(height: 14),
          
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_myFeedback.isEmpty)
            const GlassCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.feedback_outlined, size: 48, color: AppColors.textLight),
                      SizedBox(height: 12),
                      Text(
                        'No feedback submitted yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ..._myFeedback.map((feedback) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FeedbackStatusCard(feedback: feedback),
            )),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _FeedbackStatusCard extends StatelessWidget {
  final AnonymousFeedback feedback;

  const _FeedbackStatusCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (feedback.status) {
      case 'approved':
        statusColor = AppColors.success;
        statusLabel = 'Approved';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusLabel = 'Rejected';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.warning;
        statusLabel = 'Pending Review';
        statusIcon = Icons.pending_rounded;
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To: ${feedback.teacherName}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback.category.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMid,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback.feedbackText,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (feedback.rating != null) ...[
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < feedback.rating! ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                '${feedback.submittedAt.day}/${feedback.submittedAt.month}/${feedback.submittedAt.year}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          if (feedback.adminNotes != null && feedback.adminNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.divider.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings_rounded, size: 16, color: AppColors.textMid),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Admin: ${feedback.adminNotes}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMid,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
