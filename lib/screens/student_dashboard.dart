import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  List<FeePayment> _feePayments = [];
  int _noticeCount = 0;
  bool _loading = true;
  bool _subscriptionsReady = false;
  RealtimeChannel? _studentChannel;
  RealtimeChannel? _homeworkChannel;
  RealtimeChannel? _testsChannel;
  RealtimeChannel? _timetableChannel;
  RealtimeChannel? _broadcastChannel;
  RealtimeChannel? _feePaymentsChannel;

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
          noticeCount: _noticeCount,
          loading: _loading,
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

  @override
  void dispose() {
    _removeRealtimeSubscriptions();
    super.dispose();
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
      final feePayments = await _db.getFeePaymentsByStudent(student.id);
      final notices = await _db.getBroadcastsForRole('students');

      if (mounted) {
        setState(() {
          _student = student;
          _subjects = subjects;
          _homework = homework;
          _tests = tests;
          _testResults = testResults;
          _timetable = timetable;
          _feePayments = feePayments;
          _noticeCount = notices.length;
          _loading = false;
        });
      }

      if (!_subscriptionsReady) {
        _setupRealtimeSubscriptions(student);
      }
    } catch (e) {
      debugPrint('Error loading student data: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setupRealtimeSubscriptions(Student student) {
    final supabase = Supabase.instance.client;

    _studentChannel = supabase
        .channel('student-row-${student.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'students',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: student.id,
          ),
          callback: (_) => _loadStudentData(),
        )
        .subscribe();

    _homeworkChannel = supabase
        .channel('student-homework-${student.batchId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'homework',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'batch_id',
            value: student.batchId,
          ),
          callback: (_) => _loadStudentData(),
        )
        .subscribe();

    _testsChannel = supabase
        .channel('student-tests-${student.batchId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tests',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'batch_id',
            value: student.batchId,
          ),
          callback: (_) => _loadStudentData(),
        )
        .subscribe();

    _timetableChannel = supabase
        .channel('student-timetable-${student.batchId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'timetables',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'batch_id',
            value: student.batchId,
          ),
          callback: (_) => _loadStudentData(),
        )
        .subscribe();

    _broadcastChannel = supabase
        .channel('student-broadcasts')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'broadcasts',
          callback: (_) => _loadStudentData(),
        )
        .subscribe();

    _feePaymentsChannel = supabase
        .channel('student-fee-payments-${student.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'fee_payments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'student_id',
            value: student.id,
          ),
          callback: (_) => _loadStudentData(),
        )
        .subscribe();

    _subscriptionsReady = true;
  }

  void _removeRealtimeSubscriptions() {
    final supabase = Supabase.instance.client;
    if (_studentChannel != null) supabase.removeChannel(_studentChannel!);
    if (_homeworkChannel != null) supabase.removeChannel(_homeworkChannel!);
    if (_testsChannel != null) supabase.removeChannel(_testsChannel!);
    if (_timetableChannel != null) supabase.removeChannel(_timetableChannel!);
    if (_broadcastChannel != null) supabase.removeChannel(_broadcastChannel!);
    if (_feePaymentsChannel != null) {
      supabase.removeChannel(_feePaymentsChannel!);
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
  final int noticeCount;
  final bool loading;

  const _StudentHomePage({
    required this.student,
    required this.subjects,
    required this.homework,
    required this.tests,
    required this.timetable,
    required this.noticeCount,
    required this.loading,
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
            notificationCount: noticeCount,
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
          _TodayClassBanner(timetable: timetable, subjects: subjects),
          const SizedBox(height: 24),

          // Fees and reminders
          if (student != null) ...[
            _FeesOverviewCard(student: student!),
            const SizedBox(height: 24),
          ],

          // Timetable Today
          const SectionHeader(title: "Today's Timetable"),
          const SizedBox(height: 14),
          _TimetableList(timetable: timetable, subjects: subjects),
          const SizedBox(height: 24),

          // Stats Row — Attendance & Pending Tasks from live data
          _StudentStatsRow(
            student: student,
            homework: homework,
          ),
          const SizedBox(height: 24),

          // Subject Performance - from live test results
          const SectionHeader(title: 'Subject Performance'),
          const SizedBox(height: 14),
          _SubjectPerformanceCard(studentId: student?.id ?? ''),
          const SizedBox(height: 24),

          // Upcoming Exams
          const SectionHeader(title: 'Upcoming Exams'),
          const SizedBox(height: 14),
          if (tests
              .where((t) => t.status == 'scheduled' || t.status == 'ongoing')
              .isEmpty)
            const GlassCard(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No exams scheduled.',
                    style: TextStyle(color: AppColors.textMid)),
              ),
            )
          else
            ...tests
                .where((t) => t.status == 'scheduled' || t.status == 'ongoing')
                .take(2)
                .map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TestItem(
                        title: t.title,
                        date:
                            '${t.testDate.day}/${t.testDate.month}/${t.testDate.year}',
                        marks: t.totalMarks,
                        color: AppColors.studentAccent,
                      ),
                    )),
          const SizedBox(height: 24),

          // Upcoming Assignments (Homework)
          const SectionHeader(title: 'Upcoming Assignments'),
          const SizedBox(height: 14),
          if (homework.isEmpty)
            const GlassCard(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No upcoming assignments.',
                    style: TextStyle(color: AppColors.textMid)),
              ),
            )
          else
            ...homework.take(3).map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AssignmentItem(
                    subject: h.subjectId,
                    title: h.title,
                    dueDate:
                        'Due: ${h.dueDate.day}/${h.dueDate.month}/${h.dueDate.year}',
                    color: AppColors.primary,
                    isUrgent: h.dueDate.difference(DateTime.now()).inDays < 2,
                  ),
                )),
          const SizedBox(height: 24),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ============================================================
//  LIVE STUDENT STAT WIDGETS
// ============================================================

class _StudentStatsRow extends StatefulWidget {
  final Student? student;
  final List<Homework> homework;

  const _StudentStatsRow({required this.student, required this.homework});

  @override
  State<_StudentStatsRow> createState() => _StudentStatsRowState();
}

class _StudentStatsRowState extends State<_StudentStatsRow> {
  final _db = DatabaseService();
  String _attendancePct = '...';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  @override
  void didUpdateWidget(_StudentStatsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.student?.id != widget.student?.id && widget.student != null) {
      _loadAttendance();
    }
  }

  Future<void> _loadAttendance() async {
    if (widget.student == null || widget.student!.id.isEmpty) {
      if (mounted) {
        setState(() {
          _attendancePct = 'N/A';
          _loading = false;
        });
      }
      return;
    }
    final pct = await _db.getStudentAttendancePercentage(widget.student!.id);
    if (mounted) {
      setState(() {
        _attendancePct = pct;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = widget.homework
        .where((h) => h.status == 'active' && h.dueDate.isAfter(DateTime.now()))
        .length;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (widget.student != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewAttendanceScreen(
                      studentId: widget.student!.id,
                      studentName: widget.student!.name,
                    ),
                  ),
                );
              }
            },
            child: StatCard(
              title: 'Attendance',
              value: _loading ? '...' : '$_attendancePct%',
              icon: Icons.how_to_reg_rounded,
              color: AppColors.success,
              subtitle: 'This month',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Pending Tasks',
            value: '$pendingCount',
            icon: Icons.pending_actions_rounded,
            color: AppColors.error,
            subtitle: 'Due this week',
          ),
        ),
      ],
    );
  }
}

class _SubjectPerformanceCard extends StatefulWidget {
  final String studentId;

  const _SubjectPerformanceCard({required this.studentId});

  @override
  State<_SubjectPerformanceCard> createState() =>
      _SubjectPerformanceCardState();
}

class _SubjectPerformanceCardState extends State<_SubjectPerformanceCard> {
  final _db = DatabaseService();
  List<Map<String, dynamic>> _performance = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_SubjectPerformanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studentId != widget.studentId &&
        widget.studentId.isNotEmpty) {
      _load();
    }
  }

  Future<void> _load() async {
    if (widget.studentId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final perf = await _db.getStudentSubjectPerformance(widget.studentId);
    if (mounted) {
      setState(() {
        _performance = perf;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const GlassCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_performance.isEmpty) {
      return const GlassCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'No test results yet. Performance will appear after exams.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMid),
            ),
          ),
        ),
      );
    }

    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.studentAccent,
    ];

    return GlassCard(
      child: Column(
        children: _performance.asMap().entries.map((e) {
          final p = e.value;
          final color = colors[e.key % colors.length];
          final pct = (p['avg_percentage'] as double).clamp(0.0, 100.0);
          return Padding(
            padding: EdgeInsets.only(
                bottom: e.key < _performance.length - 1 ? 14 : 0),
            child: LabeledProgressBar(
              label: p['subject_name'] ?? 'Subject',
              value: pct / 100.0,
              color: color,
            ),
          );
        }).toList(),
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

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (subjects.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book_outlined, size: 64, color: AppColors.textLight),
              SizedBox(height: 16),
              Text('No subjects assigned yet.',
                  style: TextStyle(color: AppColors.textMid, fontSize: 15)),
            ],
          ),
        ),
      );
    }

    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.studentAccent,
      AppColors.teacherAccent,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'My Subjects'),
          const SizedBox(height: 16),
          ...subjects.asMap().entries.map((e) {
            final s = e.value;
            final color = colors[e.key % colors.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
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
                          Text(s.name,
                              style: TextStyle(
                                  fontSize: Responsive.sp(context, 15),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark)),
                          Text(s.code,
                              style: TextStyle(
                                  fontSize: Responsive.sp(context, 12),
                                  color: AppColors.textMid)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(s.code.isNotEmpty ? s.code : 'Subject',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color)),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 30),
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
    if (loading) return const Center(child: CircularProgressIndicator());

    final pendingHomework =
        homework.where((h) => h.status == 'active').toList();
    final upcomingTests = tests
        .where((t) => t.status == 'scheduled' || t.status == 'ongoing')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Pending Homework (${pendingHomework.length})'),
          const SizedBox(height: 12),
          if (pendingHomework.isEmpty)
            const Text('No pending homework.',
                style: TextStyle(color: AppColors.textMid))
          else
            ...pendingHomework.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TaskItem(
                    title: h.title,
                    subject: h
                        .subjectId, // Ideally join to get name, but ID works for now
                    due:
                        'Due: ${h.dueDate.day}/${h.dueDate.month}/${h.dueDate.year}',
                    urgent: h.dueDate.difference(DateTime.now()).inDays < 2,
                  ),
                )),
          const SizedBox(height: 24),
          SectionHeader(title: 'Upcoming Tests (${upcomingTests.length})'),
          const SizedBox(height: 12),
          if (upcomingTests.isEmpty)
            const Text('No upcoming tests.',
                style: TextStyle(color: AppColors.textMid))
          else
            ...upcomingTests.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TestItem(
                    title: t.title,
                    date:
                        '${t.testDate.day}/${t.testDate.month}/${t.testDate.year}',
                    marks: t.totalMarks,
                    color: AppColors.primary,
                  ),
                )),
          const SizedBox(height: 30),
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
    if (loading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Test Results (${testResults.length})'),
          const SizedBox(height: 16),
          if (testResults.isEmpty)
            const GlassCard(
              child: Center(
                child: Text('No results recorded yet.',
                    style: TextStyle(color: AppColors.textMid)),
              ),
            )
          else
            GlassCard(
              child: Column(
                children: testResults.map((tr) {
                    final percentage = tr.marksObtained / 100.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: LabeledProgressBar(
                        label:
                            '${tr.testId} - ${tr.status} (${tr.marksObtained}/100)',
                        value: percentage.clamp(0.0, 1.0),
                        color: percentage >= 0.75
                            ? AppColors.success
                            : AppColors.primary),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 30),
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
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.textMid))),
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

class _FeesOverviewCard extends StatelessWidget {
  final Student student;
  const _FeesOverviewCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final total = student.totalFees <= 0 ? 1.0 : student.totalFees;
    final paid = student.feesPaid.clamp(0, total);
    final due = (total - paid).clamp(0, total);
    final ratio = (paid / total).clamp(0.0, 1.0);
    final hasDue = due > 0;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Fees & Reminders'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Paid: ₹${paid.toStringAsFixed(0)} / ₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (hasDue ? AppColors.warning : AppColors.success)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasDue ? 'Due ₹${due.toStringAsFixed(0)}' : 'Fully Paid',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: hasDue ? AppColors.warning : AppColors.success,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (hasDue) ...[
            const SizedBox(height: 10),
            const Text(
              'Reminder: Pending fees detected. Please contact reception/account office.',
              style: TextStyle(fontSize: 12, color: AppColors.textMid),
            ),
          ],
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
  final List<Subject> subjects;

  const _TodayClassBanner({required this.timetable, required this.subjects});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = _weekdayName(now.weekday);
    final todays = timetable
        .where((t) => t.day.toLowerCase() == day.toLowerCase())
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final next = todays.cast<TimeTable?>().firstWhere(
          (t) => t != null && t.startTime.compareTo(_time24(now)) >= 0,
          orElse: () => todays.isNotEmpty ? todays.first : null,
        );

    final subject = next?.subjectId.isNotEmpty == true
        ? _subjectName(next!.subjectId, subjects)
        : 'No class';
    final timing = next == null
        ? 'No classes scheduled today'
        : '${_formatTime(next.startTime)} - ${_formatTime(next.endTime)}${next.room != null && next.room!.isNotEmpty ? '  •  Room ${next.room}' : ''}';
    final startsIn = next == null ? 'Enjoy your day' : 'Check timetable below';

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
            color: AppColors.primary.withValues(alpha: 0.35),
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
                  subject,
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
                      timing,
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
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    startsIn,
                    style: const TextStyle(
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

  static String _weekdayName(int day) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[day - 1];
  }

  static String _time24(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  static String _formatTime(String value) {
    final p = value.split(':');
    if (p.length < 2) return value;
    final hour = int.tryParse(p[0]) ?? 0;
    final minute = p[1];
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hr12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hr12:$minute $suffix';
  }

  static String _subjectName(String subjectId, List<Subject> subjects) {
    for (final s in subjects) {
      if (s.id == subjectId) return s.name;
    }
    return subjectId;
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
                    color: AppColors.error.withValues(alpha: 0.1),
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
  final List<Subject> subjects;

  const _TimetableList({required this.timetable, required this.subjects});

  @override
  Widget build(BuildContext context) {
    final day = _TodayClassBanner._weekdayName(DateTime.now().weekday);
    final periods = timetable
        .where((t) => t.day.toLowerCase() == day.toLowerCase())
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (periods.isEmpty) {
      return const GlassCard(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No timetable entries for today.',
            style: TextStyle(color: AppColors.textMid),
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: periods.asMap().entries.map((e) {
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
                    e.value.startTime,
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
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _TodayClassBanner._subjectName(
                            e.value.subjectId, subjects),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (e.value.teacherId.isNotEmpty)
                        Text(
                          '${e.value.teacherId}${e.value.room != null && e.value.room!.isNotEmpty ? ' • Room ${e.value.room}' : ''}',
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
              color: color.withValues(alpha: 0.12),
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
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
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
                color: color.withValues(alpha: 0.12),
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
    final feedback =
        await _db.getMySubmittedFeedback(widget.studentId, 'student');
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

          // Feedback Card (Now clickable)
          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubmitFeedbackScreenPremium(
                    senderRole: 'student',
                    senderId: widget.studentId,
                  ),
                ),
              );
              _loadMyFeedback();
            },
            borderRadius: BorderRadius.circular(20),
            child: const GlassCard(
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.info, size: 28),
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
                          'Your feedback is completely anonymous. Click here to send feedback to a teacher.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMid),
                ],
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
                      Icon(Icons.feedback_outlined,
                          size: 48, color: AppColors.textLight),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    i < feedback.rating!
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
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
          if (feedback.adminNotes != null &&
              feedback.adminNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.divider.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings_rounded,
                      size: 16, color: AppColors.textMid),
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
