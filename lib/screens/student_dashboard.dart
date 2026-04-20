import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/database_service.dart';
import '../models/models.dart';
import 'connect_with_us_screen.dart';
import 'faculty_screen.dart';
import 'submit_feedback_screen_premium.dart';
import 'view_attendance_screen.dart';

class StudentDashboard extends StatefulWidget {
  final String studentId;
  const StudentDashboard({super.key, this.studentId = 'student_001'});

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
        ),
        _StudentSubjectsPage(subjects: _subjects, loading: _loading),
        _StudentTasksPage(
            homework: _homework, tests: _tests, loading: _loading),
        _StudentResultsPage(testResults: _testResults, loading: _loading),
        _StudentFeedbackPage(studentId: widget.studentId),
        _StudentProfilePage(student: _student, loading: _loading),
      ];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      // Load student data
      final student = await _db.getStudentById(widget.studentId);
      if (student == null) {
        debugPrint('Student not found: ${widget.studentId}');
        return;
      }

      // Load related data
      final subjects = await _db.getAllSubjects();
      final homework = await _db.getHomeworkByBatch(student.batchId);
      final tests = await _db.getTestsByBatch(student.batchId);
      final testResults = await _db.getTestResultsByStudent(student.id);
      final timetable = await _db.getTimeTableByBatch(student.batchId);

      if (mounted) {
        setState(() {
          _student = student;
          _subjects = subjects;
          _homework = homework;
          _tests = tests;
          _testResults = testResults;
          _timetable = timetable;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading student data: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
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

  const _StudentHomePage({
    required this.student,
    required this.subjects,
    required this.homework,
    required this.tests,
    required this.timetable,
    required this.loading,
  });
  void _showNoticesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Notices & Holidays',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 16),
                const _HolidayNotice(
                    title: 'Holi Holiday',
                    date: 'March 14, 2026',
                    icon: Icons.celebration_rounded,
                    color: AppColors.warning),
                const SizedBox(height: 10),
                const _HolidayNotice(
                    title: 'Good Friday',
                    date: 'April 3, 2026',
                    icon: Icons.church_rounded,
                    color: AppColors.info),
                const SizedBox(height: 10),
                const _HolidayNotice(
                    title: 'Dr. Ambedkar Jayanti',
                    date: 'April 14, 2026',
                    icon: Icons.star_rounded,
                    color: AppColors.primary),
                const SizedBox(height: 10),
                const _HolidayNotice(
                    title: 'Summer Vacation Begins',
                    date: 'May 1, 2026',
                    icon: Icons.wb_sunny_rounded,
                    color: AppColors.error),
                const SizedBox(height: 10),
                const _HolidayNotice(
                    title: 'Independence Day',
                    date: 'August 15, 2026',
                    icon: Icons.flag_rounded,
                    color: AppColors.success),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(
            name: 'Aryan Sharma',
            role: 'STUDENT',
            subtitle: 'Student Dashboard',
            roleColor: AppColors.studentAccent,
            notificationCount: 3,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAttendanceScreen(
                          studentId: widget.studentId,
                          studentName: _student?.name ?? 'Student',
                        ),
                      ),
                    );
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
          const _AssignmentItem(
            subject: 'Mathematics',
            title: 'Chapter 5 - Quadratic Equations',
            dueDate: 'Due Tomorrow',
            color: AppColors.primary,
            isUrgent: true,
          ),
          const SizedBox(height: 10),
          const _AssignmentItem(
            subject: 'Science',
            title: 'Lab Report - Photosynthesis',
            dueDate: 'Due in 3 days',
            color: AppColors.info,
            isUrgent: false,
          ),
          const SizedBox(height: 10),
          const _AssignmentItem(
            subject: 'English',
            title: 'Essay - My Role Model',
            dueDate: 'Due in 5 days',
            color: AppColors.success,
            isUrgent: false,
          ),
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

class _StudentResultsPage extends StatelessWidget {
  final List<TestResult> testResults;
  final bool loading;

  const _StudentResultsPage({required this.testResults, required this.loading});
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Test Results'),
          SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                LabeledProgressBar(
                    label: 'Physics - Unit Test 1 (85/100)',
                    value: 0.85,
                    color: AppColors.primary),
                SizedBox(height: 14),
                LabeledProgressBar(
                    label: 'Chemistry - Unit Test 1 (91/100)',
                    value: 0.91,
                    color: AppColors.info),
                SizedBox(height: 14),
                LabeledProgressBar(
                    label: 'Mathematics - Unit Test 1 (76/100)',
                    value: 0.76,
                    color: AppColors.success),
              ],
            ),
          ),
          SizedBox(height: 30),
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
    // Fee data (replace with real data from Student model when wired up)
    const double totalFees = 50000;
    const double feesPaid = 30000;
    const double feesDue = totalFees - feesPaid;
    const String feeStatus = 'pending'; // 'active', 'pending', 'overdue'

    final List<Map<String, dynamic>> installments = [
      {
        'label': 'Installment 1',
        'amount': 15000.0,
        'due': 'Jan 10, 2026',
        'paid': true
      },
      {
        'label': 'Installment 2',
        'amount': 15000.0,
        'due': 'Feb 10, 2026',
        'paid': true
      },
      {
        'label': 'Installment 3',
        'amount': 10000.0,
        'due': 'Mar 10, 2026',
        'paid': false
      },
      {
        'label': 'Installment 4',
        'amount': 10000.0,
        'due': 'Apr 10, 2026',
        'paid': false
      },
    ];

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (feeStatus) {
      case 'overdue':
        statusColor = AppColors.error;
        statusLabel = 'Overdue';
        statusIcon = Icons.warning_rounded;
        break;
      case 'active':
        statusColor = AppColors.success;
        statusLabel = 'Fully Paid';
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = AppColors.warning;
        statusLabel = 'Partially Paid';
        statusIcon = Icons.pending_rounded;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Center(
              child: GradientAvatar(
                  initials: 'AS', color: AppColors.studentAccent, size: 72)),
          const SizedBox(height: 12),
          const Center(
              child: Text('Aryan Sharma',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark))),
          const Center(
              child: Text('Student • Class 10-A',
                  style: TextStyle(fontSize: 13, color: AppColors.textMid))),
          const SizedBox(height: 24),

          // Personal Info
          const GlassCard(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _ProfileRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'aryan.sharma@students.com'),
                Divider(height: 20),
                _ProfileRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: '+91-9876543210'),
                Divider(height: 20),
                _ProfileRow(
                    icon: Icons.people_outlined,
                    label: 'Parent',
                    value: 'Mr. Rajesh Sharma'),
                Divider(height: 20),
                _ProfileRow(
                    icon: Icons.class_outlined,
                    label: 'Batch',
                    value: 'Class 10-A'),
                Divider(height: 20),
                _ProfileRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Enrolled',
                    value: 'March 2025'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Fee Summary
          const SectionHeader(title: 'Fee Summary'),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: _FeeSummaryTile(
                        label: 'Total Fees',
                        amount: totalFees,
                        color: AppColors.textDark,
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ),
                    Container(width: 1, height: 48, color: AppColors.divider),
                    const Expanded(
                      child: _FeeSummaryTile(
                        label: 'Fees Paid',
                        amount: feesPaid,
                        color: AppColors.success,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ),
                    Container(width: 1, height: 48, color: AppColors.divider),
                    const Expanded(
                      child: _FeeSummaryTile(
                        label: 'Fees Due',
                        amount: feesDue,
                        color:
                            feesDue > 0 ? AppColors.error : AppColors.success,
                        icon: feesDue > 0
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: feesPaid / totalFees,
                    minHeight: 8,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${((feesPaid / totalFees) * 100).round()}% paid',
                        style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 13, color: statusColor),
                          const SizedBox(width: 4),
                          Text(statusLabel,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Installments
          const SectionHeader(title: 'Installments'),
          const SizedBox(height: 12),
          ...installments.map((inst) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _InstallmentTile(
                  label: inst['label'] as String,
                  amount: inst['amount'] as double,
                  dueDate: inst['due'] as String,
                  paid: inst['paid'] as bool,
                ),
              )),
          const SizedBox(height: 20),

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

class _FeeSummaryTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  const _FeeSummaryTile(
      {required this.label,
      required this.amount,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text('₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textLight),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _InstallmentTile extends StatelessWidget {
  final String label;
  final double amount;
  final String dueDate;
  final bool paid;
  const _InstallmentTile(
      {required this.label,
      required this.amount,
      required this.dueDate,
      required this.paid});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (paid ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              paid ? Icons.check_circle_rounded : Icons.schedule_rounded,
              color: paid ? AppColors.success : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                Text('Due: $dueDate',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textLight)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (paid ? AppColors.success : AppColors.warning)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  paid ? 'Paid' : 'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: paid ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
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
