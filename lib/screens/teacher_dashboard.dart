import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/database_service.dart';
import '../services/attendance_service.dart';
import '../services/marks_service.dart';
import '../services/auth_session.dart';
import '../models/models.dart';
import 'login_screen.dart';
import 'placeholder_screens.dart';
import 'select_batch_for_attendance.dart';
import 'schedule_exam_screen.dart';
import 'enter_marks_screen.dart';

class TeacherDashboard extends StatefulWidget {
  final String? teacherEmail;

  const TeacherDashboard({super.key, this.teacherEmail});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  int _noticeCount = 0;
  final _db = DatabaseService();
  Teacher? _currentTeacher;
  bool _loadingTeacher = true;
  List<TimeTable> _teacherTimetable = [];

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    setState(() => _loadingTeacher = true);

    // Use AuthSession - always has the correct logged-in email
    final email = AuthSession.email ?? widget.teacherEmail;

    if (email != null && email.isNotEmpty) {
      final teacher = await _db.getTeacherByEmail(email);
      if (mounted) {
        setState(() {
          // Even if teacher record not found, create a minimal one from email
          _currentTeacher = teacher ??
              Teacher(
                id: '',
                userId: '',
                name: AuthSession.name ??
                    email
                        .split('@')[0]
                        .replaceAll('.', ' ')
                        .split(' ')
                        .map((w) => w.isNotEmpty
                            ? '${w[0].toUpperCase()}${w.substring(1)}'
                            : '')
                        .join(' '),
                email: email,
                phoneNumber: '',
                employeeId: '',
                subjects: [],
                classes: [],
                board: '',
                qualification: null,
                experienceYears: 0,
                salary: 0,
                isActive: true,
                createdAt: DateTime.now(),
              );
          _loadingTeacher = false;
        });

        if (_currentTeacher!.id.isNotEmpty) {
          // Feedback loading is handled inside the profile sheet
        }
        _loadTeacherNotices();
        if ((_currentTeacher!.batchId ?? '').isNotEmpty) {
          _loadTeacherTimetable(_currentTeacher!.batchId!);
        }
      }
    } else {
      setState(() => _loadingTeacher = false);
    }
  }



  Future<void> _loadTeacherNotices() async {
    final notices = await _db.getBroadcastsForRole('teachers');
    if (mounted) setState(() => _noticeCount = notices.length);
  }

  Future<void> _loadTeacherTimetable(String batchId) async {
    final items = await _db.getTimeTableByBatch(batchId);
    if (mounted) setState(() => _teacherTimetable = items);
  }

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home'),
    BottomNavItem(
        icon: Icons.class_outlined,
        activeIcon: Icons.class_rounded,
        label: 'Classes'),
    BottomNavItem(
        icon: Icons.account_circle_outlined,
        activeIcon: Icons.account_circle_rounded,
        label: 'Profile'),
  ];

  List<Widget> get _pages => [
        _TeacherHomePage(
          teacher: _currentTeacher,
          noticeCount: _noticeCount,
          timetable: _teacherTimetable,
        ),
        _TeacherClassesPage(teacher: _currentTeacher),
      ];

  void _showProfileSheet(BuildContext context) {
    if (_currentTeacher == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TeacherProfileSheet(
        teacher: _currentTeacher!,
        onFeedbackRead: () => _currentTeacher!.id.isNotEmpty
            ? _loadApprovedFeedbackCount(_currentTeacher!.id)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingTeacher) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return GradientScaffold(
      bottomNavigationBar: VidyaBottomNav(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: (i) {
          if (i == 2) {
            _showProfileSheet(context);
          } else {
            setState(() => _selectedIndex = i);
          }
        },
        activeColor: AppColors.teacherAccent,
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

// ─── Teacher Profile Sheet with Approved Feedback ─────────────────────────────
class _TeacherProfileSheet extends StatefulWidget {
  final Teacher teacher;
  final VoidCallback onFeedbackRead;

  const _TeacherProfileSheet({
    required this.teacher,
    required this.onFeedbackRead,
  });

  @override
  State<_TeacherProfileSheet> createState() => _TeacherProfileSheetState();
}

class _TeacherProfileSheetState extends State<_TeacherProfileSheet> {
  final _db = DatabaseService();
  List<AnonymousFeedback> _approvedFeedbacks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadApprovedFeedback();
  }

  Future<void> _loadApprovedFeedback() async {
    setState(() => _loading = true);
    final feedbacks =
        await _db.getApprovedFeedbackForTeacher(widget.teacher.id);
    if (mounted) {
      setState(() {
        _approvedFeedbacks = feedbacks;
        _loading = false;
      });
    }
  }

  Future<void> _markAsRead(AnonymousFeedback feedback) async {
    if (!feedback.isReadByTeacher) {
      await _db.markFeedbackAsRead(feedback.id);
      _loadApprovedFeedback();
      widget.onFeedbackRead();
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'teaching':
        return 'Teaching Style';
      case 'behavior':
        return 'Behavior';
      case 'communication':
        return 'Communication';
      case 'subject_knowledge':
        return 'Subject Knowledge';
      case 'punctuality':
        return 'Punctuality';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'teaching':
        return const Color(0xFF667EEA);
      case 'behavior':
        return const Color(0xFFFFA726);
      case 'communication':
        return const Color(0xFF26C6DA);
      case 'subject_knowledge':
        return const Color(0xFF9C27B0);
      case 'punctuality':
        return const Color(0xFFEF5350);
      default:
        return AppColors.textMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _approvedFeedbacks.where((f) => !f.isReadByTeacher).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Profile Header
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.teacherAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school_rounded,
                  color: AppColors.teacherAccent, size: 40),
            ),
            const SizedBox(height: 12),
            const Text(
              'Teacher',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.teacherAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'TEACHER',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.teacherAccent),
              ),
            ),
            const SizedBox(height: 24),

            // Feedback Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Student Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (unreadCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount new',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Feedback List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _approvedFeedbacks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.feedback_outlined,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'No feedback yet',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _approvedFeedbacks.length,
                          itemBuilder: (context, index) {
                            final feedback = _approvedFeedbacks[index];
                            return _TeacherFeedbackCard(
                              feedback: feedback,
                              categoryLabel:
                                  _getCategoryLabel(feedback.category),
                              categoryColor:
                                  _getCategoryColor(feedback.category),
                              onTap: () => _markAsRead(feedback),
                            );
                          },
                        ),
            ),

            const SizedBox(height: 16),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Teacher Feedback Card Widget ─────────────────────────────────────────────
class _TeacherFeedbackCard extends StatelessWidget {
  final AnonymousFeedback feedback;
  final String categoryLabel;
  final Color categoryColor;
  final VoidCallback onTap;

  const _TeacherFeedbackCard({
    required this.feedback,
    required this.categoryLabel,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: feedback.isReadByTeacher
              ? Colors.grey[50]
              : const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: feedback.isReadByTeacher
                ? Colors.grey[200]!
                : const Color(0xFFFFB74D),
            width: feedback.isReadByTeacher ? 1 : 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.feedback_outlined,
                      color: categoryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: categoryColor,
                        ),
                      ),
                      Text(
                        'Anonymous ${feedback.senderRole}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating
                if (feedback.rating != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA726).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            color: Color(0xFFFFA726), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${feedback.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFA726),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!feedback.isReadByTeacher) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Feedback Text
            Text(
              feedback.feedbackText,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMid,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Date
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  '${feedback.submittedAt.day}/${feedback.submittedAt.month}/${feedback.submittedAt.year}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
                if (!feedback.isReadByTeacher) ...[
                  const Spacer(),
                  const Text(
                    'Tap to mark as read',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.teacherAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherHomePage extends StatelessWidget {
  final Teacher? teacher;
  final int noticeCount;
  final List<TimeTable> timetable;

  const _TeacherHomePage(
      {this.teacher, this.noticeCount = 0, this.timetable = const []});

  void _showNoticesSheet(BuildContext context) {
    showBroadcastNoticesSheet(context, 'teachers');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(
            name: teacher?.name ?? 'Teacher',
            role: 'TEACHER',
            subtitle: 'Teacher Dashboard',
            roleColor: AppColors.teacherAccent,
            notificationCount: noticeCount,
            onNotification: () => _showNoticesSheet(context),
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 24),

          // Today's Schedule
          const SectionHeader(title: "Today's Schedule"),
          const SizedBox(height: 14),
          _TeacherSchedule(timetable: timetable),
          const SizedBox(height: 24),

          // Attendance Summary
          const SectionHeader(title: 'Attendance Summary'),
          const SizedBox(height: 14),
          _AttendanceSummaryCard(teacher: teacher),
          const SizedBox(height: 24),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _TeacherClassesPage extends StatefulWidget {
  final Teacher? teacher;
  const _TeacherClassesPage({this.teacher});

  @override
  State<_TeacherClassesPage> createState() => _TeacherClassesPageState();
}

class _TeacherClassesPageState extends State<_TeacherClassesPage> {
  List<Map<String, dynamic>> _scheduledExams = [];
  bool _loadingExams = true;

  @override
  void initState() {
    super.initState();
    _loadScheduledExams();
  }

  Future<void> _loadScheduledExams() async {
    setState(() => _loadingExams = true);

    try {
      final response = await Supabase.instance.client
          .from('tests')
          .select()
          .eq('status', 'scheduled')
          .order('test_date', ascending: true);

      if (mounted) {
        setState(() {
          _scheduledExams = List<Map<String, dynamic>>.from(response);
          _loadingExams = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingExams = false);
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const SectionHeader(title: 'My Classes'),
          const SizedBox(height: 16),
          _LiveClassCards(teacher: widget.teacher),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectBatchForAttendanceScreen(
                        teacherId: widget.teacher?.id.isNotEmpty == true
                            ? widget.teacher!.id
                            : 'teacher_001',
                        teacherName: widget.teacher?.name ?? 'Teacher',
                      ),
                    ),
                  ),
                  child: const _QuickActionMiniCard(
                    icon: Icons.how_to_reg_rounded,
                    label: 'Mark Attendance',
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_scheduledExams.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Schedule an exam first to enter marks'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }
                    _openEnterMarks(_scheduledExams.first);
                  },
                  child: const _QuickActionMiniCard(
                    icon: Icons.grading_rounded,
                    label: 'Enter Marks',
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Schedule Exam Widget
          GestureDetector(
            onTap: () async {
              // Use the actual teacher ID from the session
              final teacherId =
                  widget.teacher?.id ?? '00000000-0000-0000-0000-000000000001';
              final teacherName = widget.teacher?.name ?? 'Teacher';

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScheduleExamScreen(
                    teacherId: teacherId,
                    teacherName: teacherName,
                  ),
                ),
              );

              // Reload exams if an exam was scheduled
              if (result == true) {
                _loadScheduledExams();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Exam',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Create and schedule exams for your classes',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Scheduled Exams Section
          const SectionHeader(title: 'Scheduled Exams'),
          const SizedBox(height: 12),

          if (_loadingExams)
            const Center(child: CircularProgressIndicator())
          else if (_scheduledExams.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No exams scheduled yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._scheduledExams.map((exam) => _buildExamCard(exam)),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildExamCard(Map<String, dynamic> exam) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam['title'] ?? 'Untitled Exam',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Batch: ${exam['batch_id'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMid,
                  ),
                ),
                Text(
                  'Date: ${_formatDate(exam['test_date'] ?? '')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${exam['total_marks'] ?? 0} marks',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  exam['status'] ?? 'scheduled',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _openEnterMarks(exam),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Enter Marks',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEnterMarks(Map<String, dynamic> exam) {
    final teacherId = widget.teacher?.id.isNotEmpty == true
        ? widget.teacher!.id
        : 'teacher_001';
    final testId = exam['id']?.toString() ?? '';
    final batchId = exam['batch_id']?.toString() ?? '';
    if (testId.isEmpty || batchId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnterMarksScreen(
          teacherId: teacherId,
          testId: testId,
          testName: exam['title']?.toString() ?? 'Exam',
          batchId: batchId,
          batchName: batchId,
          maxMarks: (exam['total_marks'] as num?)?.toInt() ?? 100,
        ),
      ),
    );
  }
}

class _LiveClassCards extends StatefulWidget {
  final Teacher? teacher;

  const _LiveClassCards({this.teacher});

  @override
  State<_LiveClassCards> createState() => _LiveClassCardsState();
}

class _LiveClassCardsState extends State<_LiveClassCards> {
  final _db = DatabaseService();
  List<Map<String, dynamic>> _classes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_LiveClassCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teacher?.email != widget.teacher?.email) _load();
  }

  Future<void> _load() async {
    final email = widget.teacher?.email ?? '';
    if (email.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final classes = await _db.getTeacherClasses(email);
    if (mounted) {
      setState(() {
        _classes = classes;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_classes.isEmpty) {
      return const GlassCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No classes assigned yet.',
                style: TextStyle(color: AppColors.textMid)),
          ),
        ),
      );
    }

    return Column(
      children: _classes
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ClassCard(
                  batch: c['batch_name'] ?? 'Batch',
                  subject: c['subject'] ?? 'General',
                  students: c['student_count'] ?? 0,
                  room: '',
                  time: '',
                  attendanceStatus: 'Pending',
                  present: 0,
                ),
              ))
          .toList(),
    );
  }
}

class _QuickActionMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickActionMiniCard(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final String batch;
  final String subject;
  final int students;
  final String room;
  final String time;
  final String attendanceStatus;
  final int present;
  const _ClassCard(
      {required this.batch,
      required this.subject,
      required this.students,
      required this.room,
      required this.time,
      required this.attendanceStatus,
      required this.present});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ClassDetailPage(
            batch: batch,
            subject: subject,
            students: students,
            room: room,
            time: time,
            attendanceStatus: attendanceStatus,
            present: present,
          ),
        ),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.teacherAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.class_rounded,
                  color: AppColors.teacherAccent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(batch,
                      style: TextStyle(
                          fontSize: Responsive.sp(context, 14),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  Text('$subject • $room',
                      style: TextStyle(
                          fontSize: Responsive.sp(context, 12),
                          color: AppColors.textMid)),
                  Text(time,
                      style: TextStyle(
                          fontSize: Responsive.sp(context, 11),
                          color: AppColors.textLight)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('$students',
                      style: TextStyle(
                          fontSize: Responsive.sp(context, 13),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textLight, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Removed unused _HomeworkCard widget.

class _ClassDetailPage extends StatefulWidget {
  final String batch;
  final String subject;
  final int students;
  final String room;
  final String time;
  final String attendanceStatus;
  final int present;

  const _ClassDetailPage({
    required this.batch,
    required this.subject,
    required this.students,
    required this.room,
    required this.time,
    required this.attendanceStatus,
    required this.present,
  });

  @override
  State<_ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<_ClassDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
            Text(widget.batch,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            Text('${widget.subject} • ${widget.room}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.teacherAccent,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.teacherAccent,
          tabs: const [
            Tab(icon: Icon(Icons.fact_check_outlined), text: 'Attendance'),
            Tab(icon: Icon(Icons.assessment_outlined), text: 'Marks'),
            Tab(icon: Icon(Icons.feedback_outlined), text: 'Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ClassAttendanceTab(
              batch: widget.batch,
              students: widget.students,
              present: widget.present,
              status: widget.attendanceStatus),
          _ClassMarksTab(batch: widget.batch),
          _ClassFeedbackTab(batch: widget.batch),
        ],
      ),
    );
  }
}

class _ClassAttendanceTab extends StatefulWidget {
  final String batch;
  final int students;
  final int present;
  final String status;

  const _ClassAttendanceTab(
      {required this.batch,
      required this.students,
      required this.present,
      required this.status});

  @override
  State<_ClassAttendanceTab> createState() => _ClassAttendanceTabState();
}

class _ClassAttendanceTabState extends State<_ClassAttendanceTab> {
  final _attendanceService = AttendanceService();
  final _db = DatabaseService();

  int _view = 0;
  DateTime _selectedDate = DateTime.now();

  // Live student roster from DB
  List<Map<String, dynamic>> _students = [];
  // Live history from DB: date string -> list of attendance records
  final Map<String, List<Map<String, dynamic>>> _history = {};

  bool _loadingStudents = true;
  bool _loadingHistory = false;
  bool _saving = false;

  String? _batchId;

  @override
  void initState() {
    super.initState();
    _loadBatchAndStudents();
  }

  Future<void> _loadBatchAndStudents() async {
    setState(() => _loadingStudents = true);
    try {
      // Find batch by name
      final batches = await _db.getAllBatches();
      final matched = batches
          .where((b) =>
              b.name.toLowerCase().contains(widget.batch.toLowerCase()) ||
              widget.batch.toLowerCase().contains(b.name.toLowerCase()))
          .toList();

      if (matched.isNotEmpty) {
        _batchId = matched.first.id;
        final students = await _attendanceService.getStudentsForAttendance(
            batchId: _batchId!);
        if (mounted) {
          setState(() {
            _students = students.map((s) {
              final name = s['users']?['name'] ?? s['name'] ?? 'Student';
              final roll = s['roll_number'] ?? '';
              return {
                'id': s['id']?.toString() ?? '',
                'name': name,
                'roll': roll,
                'status': 'present', // default
              };
            }).toList();
            _loadingStudents = false;
          });
          _loadHistoryForDate(_selectedDate);
        }
      } else {
        if (mounted) setState(() => _loadingStudents = false);
      }
    } catch (e) {
      debugPrint('Error loading students: $e');
      if (mounted) setState(() => _loadingStudents = false);
    }
  }

  Future<void> _loadHistoryForDate(DateTime date) async {
    if (_batchId == null) return;
    setState(() => _loadingHistory = true);
    try {
      final records = await _attendanceService.getAttendanceByDate(
        batchId: _batchId!,
        subjectId: '',
        date: date,
      );
      final key = _dateKey(date);
      if (mounted) {
        setState(() {
          _history[key] = records;
          _loadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int get _presentCount =>
      _students.where((s) => s['status'] == 'present').length;

  Future<void> _saveToday() async {
    if (_batchId == null || _students.isEmpty) return;
    setState(() => _saving = true);

    final records = _students
        .map((s) => {
              'student_id': s['id'],
              'status': s['status'],
            })
        .toList();

    final result = await _attendanceService.markAttendance(
      batchId: _batchId!,
      subjectId: '',
      teacherId: '',
      studentAttendance: records,
      date: DateTime.now(),
    );

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] == true
              ? 'Attendance saved successfully'
              : result['error'] ?? 'Failed to save attendance'),
          backgroundColor:
              result['success'] == true ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      if (result['success'] == true) {
        _loadHistoryForDate(DateTime.now());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingStudents) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.teacherAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _ToggleBtn(
                    label: 'Mark Today',
                    selected: _view == 0,
                    onTap: () => setState(() => _view = 0)),
                _ToggleBtn(
                    label: 'View History',
                    selected: _view == 1,
                    onTap: () {
                      setState(() => _view = 1);
                      _loadHistoryForDate(_selectedDate);
                    }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _view == 0 ? _buildMarkToday() : _buildHistory(),
        ),
      ],
    );
  }

  Widget _buildMarkToday() {
    final absent = _students.length - _presentCount;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                  child: _MiniStat(
                      label: 'Present',
                      value: '$_presentCount',
                      color: AppColors.success)),
              const SizedBox(width: 10),
              Expanded(
                  child: _MiniStat(
                      label: 'Absent',
                      value: '$absent',
                      color: AppColors.error)),
              const SizedBox(width: 10),
              Expanded(
                  child: _MiniStat(
                      label: 'Total',
                      value: '${_students.length}',
                      color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_students.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No students in this batch.',
                  style: TextStyle(color: AppColors.textMid)),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final s = _students[i];
                final status = s['status'] as String;
                final isPresent = status == 'present';
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPresent
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.teacherAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(s['roll'] as String? ?? '',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.teacherAccent)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(s['name'] as String,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                      ),
                      // Status toggle: present / absent / late
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // Cycle: present -> absent -> late -> present
                            final next = status == 'present'
                                ? 'absent'
                                : status == 'absent'
                                    ? 'late'
                                    : 'present';
                            _students[i]['status'] = next;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: status == 'present'
                                ? AppColors.success.withValues(alpha: 0.12)
                                : status == 'late'
                                    ? AppColors.warning.withValues(alpha: 0.12)
                                    : AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status == 'present'
                                ? 'Present'
                                : status == 'late'
                                    ? 'Late'
                                    : 'Absent',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: status == 'present'
                                  ? AppColors.success
                                  : status == 'late'
                                      ? AppColors.warning
                                      : AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _saveToday,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(_saving ? 'Saving...' : 'Save Attendance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teacherAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    final key = _dateKey(_selectedDate);
    final dayRecords = _history[key];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date picker row
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (_, i) {
                final date = DateTime.now().subtract(Duration(days: 13 - i));
                final isSelected = _dateKey(date) == _dateKey(_selectedDate);
                final hasRecord = _history.containsKey(_dateKey(date));
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);
                    _loadHistoryForDate(date);
                  },
                  child: Container(
                    width: 48,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.teacherAccent.withValues(alpha: 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.teacherAccent
                            : AppColors.divider,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ][date.weekday - 1],
                          style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? AppColors.teacherAccent
                                  : AppColors.textLight),
                        ),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.teacherAccent
                                  : AppColors.textDark),
                        ),
                        if (hasRecord)
                          Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.teacherAccent
                                    : AppColors.success,
                                shape: BoxShape.circle,
                              )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_loadingHistory)
            const Center(child: CircularProgressIndicator())
          else if (dayRecords == null || dayRecords.isEmpty)
            const GlassCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No attendance record for this date.',
                      style:
                          TextStyle(color: AppColors.textLight, fontSize: 13)),
                ),
              ),
            )
          else ...[
            Row(
              children: [
                _MiniStat(
                    label: 'Present',
                    value:
                        '${dayRecords.where((r) => r['status'] == 'present').length}',
                    color: AppColors.success),
                const SizedBox(width: 10),
                _MiniStat(
                    label: 'Absent',
                    value:
                        '${dayRecords.where((r) => r['status'] == 'absent').length}',
                    color: AppColors.error),
                const SizedBox(width: 10),
                _MiniStat(
                    label: 'Late',
                    value:
                        '${dayRecords.where((r) => r['status'] == 'late').length}',
                    color: AppColors.warning),
              ],
            ),
            const SizedBox(height: 12),
            ...dayRecords.map((record) {
              final status = record['status'] ?? 'absent';
              final studentData = record['students'];
              final name = studentData?['users']?['name'] ??
                  studentData?['name'] ??
                  'Student';
              final roll = studentData?['roll_number'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: status == 'present'
                          ? AppColors.success.withValues(alpha: 0.3)
                          : status == 'late'
                              ? AppColors.warning.withValues(alpha: 0.3)
                              : AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (roll.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                AppColors.teacherAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(roll,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.teacherAccent)),
                        ),
                      if (roll.isNotEmpty) const SizedBox(width: 12),
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: status == 'present'
                              ? AppColors.success.withValues(alpha: 0.12)
                              : status == 'late'
                                  ? AppColors.warning.withValues(alpha: 0.12)
                                  : AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status == 'present'
                              ? 'Present'
                              : status == 'late'
                                  ? 'Late'
                                  : 'Absent',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: status == 'present'
                                ? AppColors.success
                                : status == 'late'
                                    ? AppColors.warning
                                    : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleBtn(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.teacherAccent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.teacherAccent : AppColors.textMid,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
        ],
      ),
    );
  }
}

// ─── Test model (kept for backward compat with _ClassMarksTab) ───────────────
// Removed unused _TestEntry model.

class _ClassMarksTab extends StatefulWidget {
  final String batch;
  const _ClassMarksTab({required this.batch});

  @override
  State<_ClassMarksTab> createState() => _ClassMarksTabState();
}

class _ClassMarksTabState extends State<_ClassMarksTab> {
  final _db = DatabaseService();
  final _marksService = MarksService();
  List<Map<String, dynamic>> _tests = [];
  bool _loading = true;
  String? _batchId;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    setState(() => _loading = true);
    try {
      final batches = await _db.getAllBatches();
      final matched = batches
          .where((b) =>
              b.name.toLowerCase().contains(widget.batch.toLowerCase()) ||
              widget.batch.toLowerCase().contains(b.name.toLowerCase()))
          .toList();

      if (matched.isNotEmpty) {
        _batchId = matched.first.id;
        final tests = await _marksService.getTestsByBatch(batchId: _batchId!);
        if (mounted) {
          setState(() {
            _tests = tests;
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_tests.isEmpty)
            const GlassCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No tests scheduled for this batch.',
                      style: TextStyle(color: AppColors.textMid)),
                ),
              ),
            )
          else
            ..._tests.map((test) {
              final status = test['status'] ?? 'scheduled';
              Color statusColor;
              switch (status) {
                case 'completed':
                  statusColor = AppColors.success;
                  break;
                case 'ongoing':
                  statusColor = AppColors.warning;
                  break;
                default:
                  statusColor = AppColors.info;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              test['title'] ?? 'Untitled',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${_formatDate(test['test_date']?.toString())} • ${test['total_marks'] ?? 0} marks',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMid),
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

class _TeacherAttendancePage extends StatelessWidget {
  const _TeacherAttendancePage();
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Attendance'),
          SizedBox(height: 12),
          GlassCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Use "Mark Attendance" from the Classes tab to record attendance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMid),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _TeacherMarksPage extends StatelessWidget {
  const _TeacherMarksPage();
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Test Results'),
          SizedBox(height: 12),
          GlassCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Use "Enter Marks" from the Classes tab to record test results.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMid),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _MarksTestCard extends StatelessWidget {
  final String title;
  final String batch;
  final String status;
  const _MarksTestCard(
      {required this.title, required this.batch, required this.status});
  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Graded'
        ? AppColors.success
        : status == 'Upcoming'
            ? AppColors.info
            : AppColors.warning;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.quiz_rounded,
              color: AppColors.teacherAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                Text(batch,
                    style: TextStyle(
                        fontSize: Responsive.sp(context, 11),
                        color: AppColors.textMid)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Text(status,
                style: TextStyle(
                    fontSize: Responsive.sp(context, 11),
                    fontWeight: FontWeight.w600,
                    color: statusColor)),
          ),
        ],
      ),
    );
  }
}

class _TeacherMessagesPage extends StatelessWidget {
  final Teacher? teacher;

  const _TeacherMessagesPage({this.teacher});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 14),
          _QuickActionsGrid(
            teacherId: teacher?.id,
            teacherName: teacher?.name,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final String title;
  final String from;
  final String time;
  final String priority;
  const _NoticeCard(
      {required this.title,
      required this.from,
      required this.time,
      required this.priority});
  @override
  Widget build(BuildContext context) {
    final isHigh = priority == 'high';
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
              isHigh
                  ? Icons.priority_high_rounded
                  : Icons.notifications_rounded,
              color: isHigh ? AppColors.error : AppColors.teacherAccent,
              size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                Text('From $from • $time',
                    style: TextStyle(
                        fontSize: Responsive.sp(context, 11),
                        color: AppColors.textMid)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final String? teacherId;
  final String? teacherName;

  const _QuickActionsGrid({
    this.teacherId,
    this.teacherName,
  });

  final List<Map<String, dynamic>> actions = const [
    {
      'label': 'Mark\nAttendance',
      'icon': Icons.how_to_reg_rounded,
      'color': AppColors.success,
      'screen': 0
    },
    {
      'label': 'Upload\nAssignment',
      'icon': Icons.upload_file_rounded,
      'color': AppColors.teacherAccent,
      'screen': 1
    },
    {
      'label': 'Enter\nMarks',
      'icon': Icons.edit_note_rounded,
      'color': AppColors.warning,
      'screen': 2
    },
    {
      'label': 'Student\nReports',
      'icon': Icons.analytics_rounded,
      'color': AppColors.info,
      'screen': 5
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (_, i) {
        final item = actions[i];
        final color = item['color'] as Color;
        return GestureDetector(
          onTap: () {
            _navigateToScreen(context, item['screen'] as int);
          },
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  item['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToScreen(BuildContext context, int screenIndex) {
    // For Mark Attendance (index 0), show batch selection
    if (screenIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelectBatchForAttendanceScreen(
            teacherId: teacherId ?? 'teacher_001',
            teacherName: teacherName ?? 'Teacher',
          ),
        ),
      );
      return;
    }

    final List<Widget> screens = [
      const TimetableManagementScreen(), // Mark Attendance (not used, handled above)
      const HomeworkSystemScreen(), // Upload Assignment
      const TestsAndPracticeScreen(), // Enter Marks
      const LiveClassScreen(), // Send Notice
      const TestsAndPracticeScreen(), // Schedule Test
      const SyllabusTrackingScreen(), // Student Reports
    ];

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screens[screenIndex]),
    );
  }
}

class _TeacherSchedule extends StatelessWidget {
  final List<TimeTable> timetable;
  const _TeacherSchedule({this.timetable = const []});

  final List<Map<String, String>> fallbackSchedule = const [
    {
      'time': '09:00 AM',
      'class': 'Class 8-A',
      'subject': 'Chemistry',
      'room': 'Room 204',
      'endTime': '10:00 AM'
    },
    {
      'time': '10:30 AM',
      'class': 'Class 9-B',
      'subject': 'Chemistry',
      'room': 'Room 301',
      'endTime': '11:30 AM'
    },
    {
      'time': '12:30 PM',
      'class': 'Class 7-C',
      'subject': 'Chemistry',
      'room': 'Room 105',
      'endTime': '01:30 PM'
    },
    {
      'time': '02:00 PM',
      'class': 'Class 10-A',
      'subject': 'Chemistry',
      'room': 'Room 204',
      'endTime': '03:00 PM'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final schedule = timetable.isNotEmpty
        ? timetable
            .map((t) => {
                  'time': _formatTime(t.startTime),
                  'class': t.batchId,
                  'subject': t.subjectId,
                  'room': (t.room ?? 'Room -'),
                  'endTime': _formatTime(t.endTime),
                })
            .toList()
        : fallbackSchedule;
    return Column(
      children: schedule.map((s) {
        final status = _getClassStatus(s['time']!, s['endTime']!);
        Color statusColor;
        String statusLabel;

        switch (status) {
          case 'done':
            statusColor = AppColors.textLight;
            statusLabel = 'Done';
            break;
          case 'current':
            statusColor = AppColors.success;
            statusLabel = 'Ongoing';
            break;
          default:
            statusColor = AppColors.teacherAccent;
            statusLabel = 'Upcoming';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            color: status == 'current'
              ? AppColors.success.withValues(alpha: 0.08)
              : null,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['time']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      s['room']!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Container(width: 1, height: 36, color: AppColors.divider),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['class']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        s['subject']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatTime(String raw) {
    final p = raw.split(':');
    if (p.length < 2) return raw;
    final hour = int.tryParse(p[0]) ?? 0;
    final minute = p[1];
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hh = hour % 12 == 0 ? 12 : hour % 12;
    return '$hh:$minute $suffix';
  }

  String _getClassStatus(String startTimeStr, String endTimeStr) {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);

    final startTime = _parseTimeString(startTimeStr);
    final endTime = _parseTimeString(endTimeStr);

    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
      return 'current';
    } else if (currentMinutes >= endMinutes) {
      return 'done';
    } else {
      return 'upcoming';
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    try {
      // Parse time like "09:00 AM" or "02:00 PM"
      final parts = timeStr.split(' ');
      final timePart = parts[0];
      final period = parts[1];

      final hourMinute = timePart.split(':');
      int hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);

      // Convert to 24-hour format
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }
}

class _ClassPerformanceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        children: [
          LabeledProgressBar(
              label: 'Class 8-A  (32 students)',
              value: 0.82,
              color: AppColors.success),
          SizedBox(height: 14),
          LabeledProgressBar(
              label: 'Class 9-B  (38 students)',
              value: 0.74,
              color: AppColors.teacherAccent),
          SizedBox(height: 14),
          LabeledProgressBar(
              label: 'Class 7-C  (35 students)',
              value: 0.68,
              color: AppColors.warning),
          SizedBox(height: 14),
          LabeledProgressBar(
              label: 'Class 10-A (40 students)',
              value: 0.88,
              color: AppColors.primary),
        ],
      ),
    );
  }
}

class _AttendanceSummaryCard extends StatefulWidget {
  final Teacher? teacher;

  const _AttendanceSummaryCard({this.teacher});

  @override
  State<_AttendanceSummaryCard> createState() => _AttendanceSummaryCardState();
}

class _AttendanceSummaryCardState extends State<_AttendanceSummaryCard> {
  final _db = DatabaseService();
  int _present = 0;
  int _absent = 0;
  int _leave = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_AttendanceSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teacher?.email != widget.teacher?.email) _load();
  }

  Future<void> _load() async {
    final email = widget.teacher?.email ?? '';
    if (email.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final summary = await _db.getTeacherAttendanceSummary(email);
    if (mounted) {
      setState(() {
        _present = summary['present'] ?? 0;
        _absent = summary['absent'] ?? 0;
        _leave = summary['leave'] ?? 0;
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

    final total = _present + _absent + _leave;
    if (total == 0) {
      return const GlassCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No attendance data for this month.',
                style: TextStyle(color: AppColors.textMid)),
          ),
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _AttendanceStat(
                    label: 'Present',
                    value: '$_present',
                    color: AppColors.success),
              ),
              Container(width: 1, height: 48, color: AppColors.divider),
              Expanded(
                child: _AttendanceStat(
                    label: 'Absent', value: '$_absent', color: AppColors.error),
              ),
              Container(width: 1, height: 48, color: AppColors.divider),
              Expanded(
                child: _AttendanceStat(
                    label: 'Leave', value: '$_leave', color: AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (_present > 0)
                  Expanded(
                    flex: _present,
                    child: Container(height: 10, color: AppColors.success),
                  ),
                if (_absent > 0)
                  Expanded(
                    flex: _absent,
                    child: Container(height: 10, color: AppColors.error),
                  ),
                if (_leave > 0)
                  Expanded(
                    flex: _leave,
                    child: Container(height: 10, color: AppColors.warning),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AttendanceStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(context, 22),
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMid,
          ),
        ),
      ],
    );
  }
}

class _SubmissionItem extends StatelessWidget {
  final String student;
  final String assignment;
  final String time;
  final bool isLate;

  const _SubmissionItem({
    required this.student,
    required this.assignment,
    required this.time,
    required this.isLate,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          GradientAvatar(
            initials: student.substring(0, student.length.clamp(0, 2)),
            color: AppColors.teacherAccent,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  assignment,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMid,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isLate)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'LATE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                time,
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

// ─── Teacher Feedback Tab ─────────────────────────────────────────────────────
class _ClassFeedbackTab extends StatefulWidget {
  final String batch;
  const _ClassFeedbackTab({required this.batch});
  @override
  State<_ClassFeedbackTab> createState() => _ClassFeedbackTabState();
}

class _ClassFeedbackTabState extends State<_ClassFeedbackTab> {
  final _db = DatabaseService();

  // Sample students for this class (in real app, load from DB by batch)
  final List<Map<String, String>> _students = const [
    {'id': 'stu_001', 'name': 'Aryan Sharma'},
    {'id': 'stu_002', 'name': 'Priya Singh'},
  ];

  List<TeacherFeedback> _feedbacks = [];
  bool _loading = true;

  // Teacher info (in real app, pass from login session)
  static const _teacherId = 'a0000001-0000-0000-0000-000000000005';
  static const _teacherName = 'Mrs. Priya Sharma';
  static const _subjectId = 'subj_chemistry';
  static const _subjectName = 'Chemistry';

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() => _loading = true);
    // Load feedback for all students in this batch
    final List<TeacherFeedback> all = [];
    for (final s in _students) {
      final f = await _db.getTeacherFeedbackForStudent(s['id']!);
      all.addAll(f);
    }
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (mounted) {
      setState(() {
        _feedbacks = all;
        _loading = false;
      });
    }
  }

  void _showAddFeedbackDialog() {
    String? selectedStudentId;
    String selectedCategory = 'academic';
    final msgCtrl = TextEditingController();

    showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
              builder: (ctx, setS) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Text('Send Feedback to Parent',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                content: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Student', border: OutlineInputBorder()),
                    items: _students
                        .map((s) => DropdownMenuItem(
                            value: s['id'], child: Text(s['name']!)))
                        .toList(),
                    onChanged: (v) => setS(() => selectedStudentId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                        labelText: 'Category', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(
                          value: 'academic', child: Text('Academic')),
                      DropdownMenuItem(
                          value: 'behaviour', child: Text('Behaviour')),
                      DropdownMenuItem(
                          value: 'attendance', child: Text('Attendance')),
                      DropdownMenuItem(
                          value: 'general', child: Text('General')),
                    ],
                    onChanged: (v) => setS(() => selectedCategory = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: msgCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Message to Parent',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true),
                  ),
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teacherAccent,
                        foregroundColor: Colors.white),
                    onPressed: () async {
                      if (selectedStudentId == null ||
                          msgCtrl.text.trim().isEmpty) {
                        return;
                      }
                      final studentName = _students.firstWhere(
                          (s) => s['id'] == selectedStudentId)['name']!;
                      final feedback = TeacherFeedback(
                        id: 'tf_${DateTime.now().microsecondsSinceEpoch}',
                        teacherId: _teacherId,
                        teacherName: _teacherName,
                        studentId: selectedStudentId!,
                        studentName: studentName,
                        subjectId: _subjectId,
                        subjectName: _subjectName,
                        message: msgCtrl.text.trim(),
                        category: selectedCategory,
                        createdAt: DateTime.now(),
                      );
                      Navigator.pop(ctx);
                      final ok = await _db.createTeacherFeedback(feedback);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? 'Feedback sent to parent'
                              : 'Failed to send feedback'),
                          backgroundColor:
                              ok ? AppColors.success : AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ));
                        if (ok) _loadFeedbacks();
                      }
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ));
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'academic':
        return AppColors.primary;
      case 'behaviour':
        return AppColors.warning;
      case 'attendance':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          const Expanded(
              child: Text('Feedback Sent to Parents',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark))),
          ElevatedButton.icon(
            onPressed: _showAddFeedbackDialog,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teacherAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _feedbacks.isEmpty
                  ? const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                              'No feedback sent yet.\nTap Add to send feedback to a parent.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.textLight, fontSize: 13))))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _feedbacks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final f = _feedbacks[i];
                        final color = _categoryColor(f.category);
                        return GlassCard(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                            color:
                                                color.withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: Text(
                                            f.category[0].toUpperCase() +
                                                f.category.substring(1),
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: color))),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text(f.studentName,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textDark))),
                                    Text(
                                        '${f.createdAt.day}/${f.createdAt.month}/${f.createdAt.year}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textLight)),
                                  ]),
                                  const SizedBox(height: 6),
                                  Text(f.message,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMid,
                                          height: 1.4)),
                                ]));
                      },
                    )),
    ]);
  }
}

class _TeacherProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TeacherProfileInfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.teacherAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.teacherAccent, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
