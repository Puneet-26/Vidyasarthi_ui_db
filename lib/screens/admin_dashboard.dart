import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/database_service.dart';
import '../models/models.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SimpleAdminProfileSheet(),
    );
  }

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        label: 'Dashboard'),
    BottomNavItem(
        icon: Icons.school_outlined,
        activeIcon: Icons.school_rounded,
        label: 'Students'),
    BottomNavItem(
        icon: Icons.people_outlined,
        activeIcon: Icons.people_rounded,
        label: 'Teachers'),
    BottomNavItem(
        icon: Icons.admin_panel_settings_outlined,
        activeIcon: Icons.admin_panel_settings_rounded,
        label: 'Staff'),
    BottomNavItem(
        icon: Icons.family_restroom_outlined,
        activeIcon: Icons.family_restroom_rounded,
        label: 'Parents'),
    BottomNavItem(
        icon: Icons.account_circle_outlined,
        activeIcon: Icons.account_circle_rounded,
        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      bottomNavigationBar: VidyaBottomNav(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: (i) {
          if (i == 5) {
            _showProfileSheet(context);
          } else {
            setState(() => _selectedIndex = i);
          }
        },
        activeColor: AppColors.adminAccent,
      ),
      child: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _DashboardTab(),
            _StudentsTab(),
            _TeachersTab(),
            _StaffTab(),
            _ParentsTab(),
          ],
        ),
      ),
    );
  }
}

void _showNotificationsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            const Text('Alerts & Notices',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: const [
                  _NotificationItem(
                    title: 'Fee Reminder',
                    desc: '45 parents have pending Q4 fees',
                    time: '1 hour ago',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.warning,
                  ),
                  _NotificationItem(
                    title: 'New Admission',
                    desc: 'Rohan Mehta application pending approval',
                    time: '3 hours ago',
                    icon: Icons.person_add_rounded,
                    color: AppColors.primary,
                  ),
                  _NotificationItem(
                    title: 'Timetable Conflict',
                    desc: '2 scheduling conflicts detected in Class 10',
                    time: '5 hours ago',
                    icon: Icons.warning_rounded,
                    color: AppColors.error,
                  ),
                  _NotificationItem(
                    title: 'New Teacher Onboarded',
                    desc: 'Ms. Kavita Singh joined as Science teacher',
                    time: '2 days ago',
                    icon: Icons.person_rounded,
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NotificationItem extends StatelessWidget {
  final String title;
  final String desc;
  final String time;
  final IconData icon;
  final Color color;

  const _NotificationItem({
    required this.title,
    required this.desc,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 4),
                Text(time,
                    style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(
            name: 'Admin',
            role: 'ADMIN',
            roleColor: AppColors.adminAccent,
            notificationCount: 8,
            onNotification: () => _showNotificationsSheet(context),
          ),
          const SizedBox(height: 24),
          _SchoolSummaryBanner(),
          const SizedBox(height: 24),
          const SectionHeader(
              title: 'Department Attendance', action: 'Full Report'),
          const SizedBox(height: 14),
          const GlassCard(
            child: Column(
              children: [
                LabeledProgressBar(
                    label: 'Primary (Std 1-5)',
                    value: 0.96,
                    color: AppColors.success),
                SizedBox(height: 14),
                LabeledProgressBar(
                    label: 'Middle (Std 6-8)',
                    value: 0.91,
                    color: AppColors.primary),
                SizedBox(height: 14),
                LabeledProgressBar(
                    label: 'Secondary (Std 9-10)',
                    value: 0.88,
                    color: AppColors.teacherAccent),
                SizedBox(height: 14),
                LabeledProgressBar(
                    label: 'Senior (Std 11-12)',
                    value: 0.94,
                    color: AppColors.warning),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Top Performing Classes'),
          const SizedBox(height: 14),
          _TopClassesList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Reports'),
          SizedBox(height: 14),
          GlassCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Reports coming soon',
                    style: TextStyle(color: AppColors.textLight)),
              ),
            ),
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ActivitiesTab extends StatefulWidget {
  const _ActivitiesTab();

  @override
  State<_ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<_ActivitiesTab> {
  final _db = DatabaseService();
  List<Map<String, dynamic>> _activities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _loading = true);
    try {
      // Load real activities from the system
      final broadcasts = await _db.getAllBroadcasts();
      final students = await _db.getAllStudents();
      
      List<Map<String, dynamic>> activities = [];
      
      // Add recent broadcasts
      for (final broadcast in broadcasts.take(3)) {
        activities.add({
          'title': 'Announcement Sent',
          'desc': broadcast.title,
          'time': broadcast.sentDate,
          'icon': Icons.campaign_rounded,
          'color': AppColors.info,
        });
      }
      
      // Add recent students (assuming we can get their creation date from enrollment_date)
      // For now, we'll show generic "New Student" entries
      if (students.isNotEmpty) {
        activities.add({
          'title': 'New Students Enrolled',
          'desc': '${students.length} active students in the system',
          'time': students.isNotEmpty ? students.first.enrollmentDate : DateTime.now(),
          'icon': Icons.person_add_rounded,
          'color': AppColors.success,
        });
      }
      
      // Add a general activity
      activities.add({
        'title': 'System Activity',
        'desc': 'Administrative tasks completed',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': Icons.check_circle_rounded,
        'color': AppColors.success,
      });

      // Sort by time (most recent first)
      activities.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

      if (mounted) {
        setState(() {
          _activities = activities;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading activities: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Recent Activities'),
          const SizedBox(height: 14),
          if (_activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No recent activities',
                  style: TextStyle(color: AppColors.textLight)),
            )
          else
            ..._activities.map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ActivityItem(
                title: activity['title'] as String,
                desc: activity['desc'] as String,
                time: _timeAgo(activity['time'] as DateTime),
                icon: activity['icon'] as IconData,
                color: activity['color'] as Color,
              ),
            )).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ============================================================
//  NEW COMPREHENSIVE ADMIN TABS
// ============================================================

class _StudentsTab extends StatefulWidget {
  const _StudentsTab();

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  final _db = DatabaseService();
  List<AnonymousFeedback> _studentFeedbacks = [];
  List<Student> _recentStudents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentFeedback();
  }

  Future<void> _loadStudentFeedback() async {
    setState(() => _loading = true);
    final allFeedbacks = await _db.getPendingFeedbackForAdmin();
    final studentFeedbacks = allFeedbacks.where((f) => f.senderRole == 'student').toList();
    final allStudents = await _db.getAllStudents();
    // Sort by enrollment date descending, take last 5
    final recent = allStudents.reversed.take(5).toList();
    if (mounted) {
      setState(() {
        _studentFeedbacks = studentFeedbacks;
        _recentStudents = recent;
        _loading = false;
      });
    }
  }

  Future<void> _approveFeedback(AnonymousFeedback feedback) async {
    final success = await _db.approveFeedback(feedback.id, 'admin_001', null);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback approved and sent to teacher'),
          backgroundColor: Colors.green,
        ),
      );
      _loadStudentFeedback();
    }
  }

  Future<void> _rejectFeedback(AnonymousFeedback feedback) async {
    final success = await _db.rejectFeedback(feedback.id, 'admin_001', 'Not appropriate');
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback rejected'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadStudentFeedback();
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Student Management'),
          const SizedBox(height: 16),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.person_add_rounded,
                  label: 'Add Student',
                  color: AppColors.success,
                  onTap: () async {
                    final added = await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => _AddStudentScreen()));
                    if (added == true) _loadStudentFeedback(); // refresh list
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.class_rounded,
                  label: 'Add Batch',
                  color: AppColors.adminAccent,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => _AddBatchScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.list_alt_rounded,
                  label: 'View All',
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => _AllStudentsScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.campaign_rounded,
                  label: 'Send Notice',
                  color: AppColors.info,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const _SendNoticeScreen(target: 'Students'))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Student Stats
          const SectionHeader(title: 'Student Overview'),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Students',
                  value: '60',
                  icon: Icons.school_rounded,
                  color: AppColors.primary,
                  subtitle: 'Active',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'New This Month',
                  value: '5',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.success,
                  subtitle: 'Admissions',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Avg Attendance',
                  value: '94%',
                  icon: Icons.how_to_reg_rounded,
                  color: AppColors.info,
                  subtitle: 'This month',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Fee Pending',
                  value: '6',
                  icon: Icons.warning_rounded,
                  color: AppColors.warning,
                  subtitle: 'Students',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Students - from database
          const SectionHeader(title: 'Recent Admissions'),
          const SizedBox(height: 14),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_recentStudents.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Text('No students yet',
                    style: TextStyle(color: Colors.grey[500])),
              ),
            )
          else
            ...(_recentStudents.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StudentListItem(
                name: s.name,
                batch: s.studentClass != null ? 'Class ${s.studentClass}' : s.email,
                status: s.enrollmentStatus == 'active' ? 'Active' : 'Pending',
                statusColor: s.enrollmentStatus == 'active' ? AppColors.success : AppColors.warning,
              ),
            ))).toList(),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // Student Feedback Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader(title: 'Student Feedback Review'),
              if (_studentFeedbacks.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_studentFeedbacks.length} pending',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _studentFeedbacks.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No pending student feedback',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _studentFeedbacks.map((feedback) {
                        return _FeedbackCard(
                          feedback: feedback,
                          categoryLabel: _getCategoryLabel(feedback.category),
                          categoryColor: _getCategoryColor(feedback.category),
                          onApprove: () => _approveFeedback(feedback),
                          onReject: () => _rejectFeedback(feedback),
                        );
                      }).toList(),
                    ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _TeachersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Teacher Management'),
          const SizedBox(height: 16),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.person_add_rounded,
                  label: 'Add Teacher',
                  color: AppColors.teacherAccent,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => _AddTeacherScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.list_alt_rounded,
                  label: 'View All',
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => _AllTeachersScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.campaign_rounded,
                  label: 'Send Notice',
                  color: AppColors.warning,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const _SendNoticeScreen(target: 'Teachers'))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Teacher Stats
          const SectionHeader(title: 'Teacher Overview'),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Teachers',
                  value: '3',
                  icon: Icons.person_rounded,
                  color: AppColors.teacherAccent,
                  subtitle: 'Active',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Classes Today',
                  value: '10',
                  icon: Icons.class_rounded,
                  color: AppColors.primary,
                  subtitle: 'Scheduled',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Attendance',
                  value: '98%',
                  icon: Icons.how_to_reg_rounded,
                  color: AppColors.success,
                  subtitle: 'Marked',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'On Leave',
                  value: '1',
                  icon: Icons.event_busy_rounded,
                  color: AppColors.warning,
                  subtitle: 'Today',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Teacher List
          const SectionHeader(title: 'Teaching Staff'),
          const SizedBox(height: 14),
          const _TeacherListItem(
              name: 'Mrs. Priya Nair',
              subject: 'Physics',
              classes: '3 Classes',
              statusColor: AppColors.success),
          const SizedBox(height: 8),
          const _TeacherListItem(
              name: 'Mr. Arun Kumar',
              subject: 'Mathematics',
              classes: '4 Classes',
              statusColor: AppColors.success),
          const SizedBox(height: 8),
          const _TeacherListItem(
              name: 'Dr. Meena Verma',
              subject: 'Chemistry',
              classes: '3 Classes',
              statusColor: AppColors.success),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StaffTab extends StatefulWidget {
  const _StaffTab();

  @override
  State<_StaffTab> createState() => _StaffTabState();
}

class _StaffTabState extends State<_StaffTab> {
  final _db = DatabaseService();
  int _pendingFeesCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingFees();
  }

  Future<void> _loadPendingFees() async {
    setState(() => _loading = true);
    final students = await _db.getAllStudents();
    // Count students with pending fees (fees_paid < total_fees)
    final withPendingFees = students.where((s) => s.feesPaid < s.totalFees).length;
    if (mounted) {
      setState(() {
        _pendingFeesCount = withPendingFees;
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
          const SectionHeader(title: 'Staff Operations'),
          const SizedBox(height: 16),

          // Staff Actions Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _StaffActionCard(
                icon: Icons.person_add_rounded,
                label: 'Admissions',
                color: AppColors.primary,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => _AdminAdmissionsScreen())),
              ),
              _StaffActionCard(
                icon: Icons.schedule_rounded,
                label: 'Timetable',
                color: AppColors.info,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => _AdminTimetableScreen())),
              ),
              _StaffActionCard(
                icon: Icons.campaign_rounded,
                label: 'Send Notice',
                color: AppColors.warning,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => _AdminBroadcastScreen())),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Fee Reminders - Only Active Task
          const SectionHeader(title: 'Active Tasks'),
          const SizedBox(height: 14),
          GlassCard(
            child: _loading
                ? const Center(child: SizedBox(height: 60, child: CircularProgressIndicator()))
                : _PendingTaskItem(
                    title: 'Fee Reminders',
                    count: '$_pendingFeesCount',
                    icon: Icons.notifications_rounded,
                    color: AppColors.warning,
                  ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ParentsTab extends StatefulWidget {
  const _ParentsTab();

  @override
  State<_ParentsTab> createState() => _ParentsTabState();
}

class _ParentsTabState extends State<_ParentsTab> {
  final _db = DatabaseService();
  List<AnonymousFeedback> _pendingFeedbacks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingFeedback();
  }

  Future<void> _loadPendingFeedback() async {
    setState(() => _loading = true);
    final allFeedbacks = await _db.getPendingFeedbackForAdmin();
    final parentFeedbacks = allFeedbacks.where((f) => f.senderRole == 'parent').toList();
    if (mounted) {
      setState(() {
        _pendingFeedbacks = parentFeedbacks;
        _loading = false;
      });
    }
  }

  Future<void> _approveFeedback(AnonymousFeedback feedback) async {
    final success = await _db.approveFeedback(feedback.id, 'admin_001', null);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback approved and sent to teacher'),
          backgroundColor: Colors.green,
        ),
      );
      _loadPendingFeedback();
    }
  }

  Future<void> _rejectFeedback(AnonymousFeedback feedback) async {
    final success = await _db.rejectFeedback(feedback.id, 'admin_001', 'Not appropriate');
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback rejected'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadPendingFeedback();
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Parent Management'),
          const SizedBox(height: 16),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.family_restroom_rounded,
                  label: 'View All',
                  color: AppColors.parentAccent,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => _AllParentsScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.message_rounded,
                  label: 'Send Notice',
                  color: AppColors.info,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const _SendNoticeScreen(target: 'Parents'))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Fee Management',
                  color: AppColors.success,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => _AdminFeesScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Parent Stats
          const SectionHeader(title: 'Parent Overview'),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Active Users',
                  value: '48',
                  icon: Icons.verified_user_rounded,
                  color: AppColors.success,
                  subtitle: 'This month',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Fee Paid',
                  value: '42',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  subtitle: 'Parents',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Fee Pending',
                  value: '8',
                  icon: Icons.pending_rounded,
                  color: AppColors.warning,
                  subtitle: 'Parents',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Messages Sent',
                  value: '15',
                  icon: Icons.message_rounded,
                  color: AppColors.info,
                  subtitle: 'This week',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Parent Activity
          const SectionHeader(title: 'Recent Activity'),
          const SizedBox(height: 14),
          const _ParentActivityItem(
            parentName: 'Mr. Rajesh Sharma',
            activity: 'Paid fees for Aryan Sharma',
            time: '2 hours ago',
            icon: Icons.payment_rounded,
            color: AppColors.success,
          ),
          const SizedBox(height: 8),
          const _ParentActivityItem(
            parentName: 'Mrs. Sunita Patel',
            activity: 'Viewed report card',
            time: '5 hours ago',
            icon: Icons.description_rounded,
            color: AppColors.info,
          ),
          const SizedBox(height: 8),
          const _ParentActivityItem(
            parentName: 'Mr. Vikram Mehta',
            activity: 'Sent message to teacher',
            time: 'Yesterday',
            icon: Icons.message_rounded,
            color: AppColors.primary,
          ),

          const SizedBox(height: 32),

          // Pending Feedback Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader(title: 'Parent Feedback Review'),
              if (_pendingFeedbacks.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_pendingFeedbacks.length} pending',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _pendingFeedbacks.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No pending parent feedback',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _pendingFeedbacks.map((feedback) {
                        return _FeedbackCard(
                          feedback: feedback,
                          categoryLabel: _getCategoryLabel(feedback.category),
                          categoryColor: _getCategoryColor(feedback.category),
                          onApprove: () => _approveFeedback(feedback),
                          onReject: () => _rejectFeedback(feedback),
                        );
                      }).toList(),
                    ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SchoolSummaryBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.adminAccent, Color(0xFFE84040)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.adminAccent.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
                      'VIDYASARATHI',
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 18),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Academic Year 2025-2026',
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 12),
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Q4 • March',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 12),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              _BannerStat(label: 'Classes', value: '6'),
              SizedBox(width: 24),
              _BannerStat(label: 'Staff', value: '12'),
              SizedBox(width: 24),
              _BannerStat(label: 'NAAC Grade', value: 'A+'),
              SizedBox(width: 24),
              _BannerStat(label: 'Passing', value: '98%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;

  const _BannerStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(context, 20),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(context, 11),
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String desc;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.desc,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 12),
                    color: AppColors.textMid,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: Responsive.sp(context, 10),
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        children: [
          _AlertRow(
            title: '23 Leave Applications pending approval',
            priority: 'HIGH',
            color: AppColors.error,
          ),
          Divider(color: AppColors.divider, height: 20),
          _AlertRow(
            title: '5 Teacher timetable conflicts to resolve',
            priority: 'MED',
            color: AppColors.warning,
          ),
          Divider(color: AppColors.divider, height: 20),
          _AlertRow(
            title: 'Board exam schedule needs to be published',
            priority: 'HIGH',
            color: AppColors.error,
          ),
          Divider(color: AppColors.divider, height: 20),
          _AlertRow(
            title: '8 New admission forms under review',
            priority: 'LOW',
            color: AppColors.info,
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final String title;
  final String priority;
  final Color color;

  const _AlertRow(
      {required this.title, required this.priority, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: Responsive.sp(context, 12),
              fontWeight: FontWeight.w500,
              color: AppColors.textMid,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            priority,
            style: TextStyle(
              fontSize: Responsive.sp(context, 9),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopClassesList extends StatelessWidget {
  final List<Map<String, dynamic>> classes = const [
    {
      'name': 'Class 10-A',
      'teacher': 'Mr. Arun Pillai',
      'score': 92,
      'color': AppColors.success
    },
    {
      'name': 'Class 12-S',
      'teacher': 'Dr. Meena Verma',
      'score': 89,
      'color': AppColors.primary
    },
    {
      'name': 'Class 9-B',
      'teacher': 'Mrs. Sunita Rao',
      'score': 87,
      'color': AppColors.teacherAccent
    },
    {
      'name': 'Class 11-C',
      'teacher': 'Mr. Kiran Shah',
      'score': 85,
      'color': AppColors.warning
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: classes.asMap().entries.map((e) {
          final cls = e.value;
          final color = cls['color'] as Color;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: e.key < classes.length - 1
                  ? const Border(bottom: BorderSide(color: AppColors.divider))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#${e.key + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls['name'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        cls['teacher'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${cls['score']}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
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

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.adminAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.adminAccent, size: 18),
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

// ============================================================
//  SUPPORTING WIDGETS
// ============================================================

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StaffActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentListItem extends StatelessWidget {
  final String name;
  final String batch;
  final String status;
  final Color statusColor;

  const _StudentListItem({
    required this.name,
    required this.batch,
    required this.status,
    required this.statusColor,
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
              color: AppColors.studentAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.studentAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  batch,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 11),
                    color: AppColors.textMid,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: Responsive.sp(context, 10),
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherListItem extends StatelessWidget {
  final String name;
  final String subject;
  final String classes;
  final Color statusColor;

  const _TeacherListItem({
    required this.name,
    required this.subject,
    required this.classes,
    required this.statusColor,
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
              color: AppColors.teacherAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.teacherAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '$subject • $classes',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 11),
                    color: AppColors.textMid,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textLight, size: 20),
        ],
      ),
    );
  }
}

class _PendingTaskItem extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _PendingTaskItem({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: Responsive.sp(context, 13),
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count,
            style: TextStyle(
              fontSize: Responsive.sp(context, 13),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _ParentActivityItem extends StatelessWidget {
  final String parentName;
  final String activity;
  final String time;
  final IconData icon;
  final Color color;

  const _ParentActivityItem({
    required this.parentName,
    required this.activity,
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parentName,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  activity,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 11),
                    color: AppColors.textMid,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: Responsive.sp(context, 10),
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  PLACEHOLDER DETAIL SCREENS
// ============================================================

class _AddStudentScreen extends StatefulWidget {
  const _AddStudentScreen();

  @override
  State<_AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<_AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();
  bool _isSubmitting = false;
  bool _loadingBatches = true;

  // Student Details
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _dateOfBirth;
  DateTime? _admissionDate = DateTime.now();

  // Academic Details
  String _selectedClass = '7th';
  String _selectedBoard = 'CBSE';
  String? _selectedBatch;
  List<String> _selectedSubjects = [];

  // Parent Details
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentAddressController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  // Fee Details
  final _totalFeesController = TextEditingController(text: '0');
  final _feesPaidController = TextEditingController(text: '0');

  final List<String> _classes = ['7th', '8th', '9th', '10th', '11th', '12th'];
  final List<String> _boards = ['CBSE', 'SSC'];
  
  // Sample subjects (you can load from database)
  final List<Map<String, String>> _availableSubjects = [
    {'id': 'sub_math', 'name': 'Mathematics'},
    {'id': 'sub_sci', 'name': 'Science'},
    {'id': 'sub_eng', 'name': 'English'},
    {'id': 'sub_hindi', 'name': 'Hindi'},
    {'id': 'sub_sst', 'name': 'Social Studies'},
  ];

  // Batches loaded from database
  List<Map<String, String>> _availableBatches = [];

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    setState(() => _loadingBatches = true);
    final batches = await _db.getAllBatches();
    if (mounted) {
      setState(() {
        _availableBatches = batches.map((b) => {
          'id': b.id,
          'name': b.name,
        }).toList();
        _loadingBatches = false;
      });
    }
  }

  // Generate email from name
  String _generateEmail(String name, String domain) {
    // Convert name to lowercase, replace spaces with dots
    final emailName = name.toLowerCase().trim().replaceAll(' ', '.');
    return '$emailName@$domain';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _parentAddressController.dispose();
    _emergencyContactController.dispose();
    _totalFeesController.dispose();
    _feesPaidController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a batch'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Auto-generate emails from names
      final studentEmail = _generateEmail(_nameController.text, 'students.com');
      final parentEmail = _generateEmail(_parentNameController.text, 'parents.com');

      // Call the simple database method
      final success = await _db.addStudentSimple(
        name: _nameController.text.trim(),
        email: studentEmail,
        phone: _phoneController.text.trim(),
        parentName: _parentNameController.text.trim(),
        parentEmail: parentEmail,
        parentPhone: _parentPhoneController.text.trim(),
        batchId: _selectedBatch!,
        dateOfBirth: _dateOfBirth,
        address: _addressController.text.trim(),
        selectedClass: _selectedClass,
        selectedBoard: _selectedBoard,
        subjectIds: _selectedSubjects,
        admissionDate: _admissionDate,
        emergencyContact: _emergencyContactController.text.trim(),
        parentAddress: _parentAddressController.text.trim(),
        totalFees: double.tryParse(_totalFeesController.text),
        feesPaid: double.tryParse(_feesPaidController.text),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ Student added successfully!'),
                  const SizedBox(height: 4),
                  Text('Student Email: $studentEmail', style: const TextStyle(fontSize: 12)),
                  Text('Parent Email: $parentEmail', style: const TextStyle(fontSize: 12)),
                  const Text('Password: Student@123 / Parent@123', style: TextStyle(fontSize: 12)),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
          Navigator.pop(context, true); // true = student was added, trigger refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Failed to add student. Check console for details.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add New Student',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Email will be auto-generated as: name@students.com and parentname@parents.com',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Student Details Section
              _buildSectionHeader('Student Details', Icons.person_rounded),
              const SizedBox(height: 16),
              _buildTextField('Full Name *', _nameController, 'Enter student name'),
              const SizedBox(height: 12),
              _buildTextField('Phone', _phoneController, '10-digit mobile number', keyboardType: TextInputType.phone, maxLength: 10),
              const SizedBox(height: 12),
              _buildDateField('Date of Birth', _dateOfBirth, (date) => setState(() => _dateOfBirth = date)),
              const SizedBox(height: 12),
              _buildTextField('Address', _addressController, 'Enter full address', maxLines: 2),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              // Academic Details Section
              _buildSectionHeader('Academic Details', Icons.school_rounded),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown('Class *', _selectedClass, _classes, (value) => setState(() => _selectedClass = value!), isRequired: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown('Board *', _selectedBoard, _boards, (value) => setState(() => _selectedBoard = value!), isRequired: true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _availableBatches.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                          SizedBox(width: 8),
                          Text('No batches found. Create a batch first.',
                              style: TextStyle(fontSize: 13, color: Colors.orange)),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Batch *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedBatch,
                          hint: const Text('Select a batch'),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          items: _availableBatches.map((b) => DropdownMenuItem<String>(
                            value: b['id'],
                            child: Text(b['name']!),
                          )).toList(),
                          onChanged: (value) => setState(() => _selectedBatch = value),
                          validator: (value) => value == null ? 'Please select a batch' : null,
                        ),
                      ],
                    ),
              const SizedBox(height: 12),
              _buildDateField('Admission Date *', _admissionDate, (date) => setState(() => _admissionDate = date)),
              const SizedBox(height: 12),
              _buildSubjectSelector(),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              // Parent Details Section
              _buildSectionHeader('Parent/Guardian Details', Icons.family_restroom_rounded),
              const SizedBox(height: 16),
              _buildTextField('Parent Name *', _parentNameController, 'Enter parent name'),
              const SizedBox(height: 12),
              _buildTextField('Parent Phone *', _parentPhoneController, '10-digit mobile number', keyboardType: TextInputType.phone, maxLength: 10),
              const SizedBox(height: 12),
              _buildTextField('Emergency Contact', _emergencyContactController, '10-digit mobile number', keyboardType: TextInputType.phone, maxLength: 10),
              const SizedBox(height: 12),
              _buildTextField('Parent Address', _parentAddressController, 'Enter address', maxLines: 2),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              // Fee Details Section
              _buildSectionHeader('Fee Details', Icons.account_balance_wallet_rounded),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Total Fees', _totalFeesController, '0', keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField('Fees Paid', _feesPaidController, '0', keyboardType: TextInputType.number),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add Student',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            counterText: maxLength != null ? '' : null, // hide the counter
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: label.contains('*') ? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(1990),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? '${date.day}/${date.month}/${date.year}' : 'Select date',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? AppColors.textDark : Colors.grey[500],
                  ),
                ),
                const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Subjects *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSubjects.map((subject) {
            final isSelected = _selectedSubjects.contains(subject['id']);
            return FilterChip(
              label: Text(subject['name']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSubjects.add(subject['id']!);
                  } else {
                    _selectedSubjects.remove(subject['id']);
                  }
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ============================================================
//  ADD BATCH SCREEN
// ============================================================

class _AddBatchScreen extends StatefulWidget {
  const _AddBatchScreen();

  @override
  State<_AddBatchScreen> createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends State<_AddBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();
  bool _isSubmitting = false;
  List<Batch> _existingBatches = [];
  bool _loadingBatches = true;

  // Batch Details
  final _batchNameController = TextEditingController();
  String _selectedClass = '7th';
  String _selectedDiv = 'A';
  String _selectedBoard = 'CBSE';

  final List<String> _classes = ['7th', '8th', '9th', '10th', '11th', '12th'];
  final List<String> _divisions = ['A', 'B', 'C', 'D', 'E'];
  final List<String> _boards = ['CBSE', 'SSC'];

  @override
  void initState() {
    super.initState();
    _updateBatchName();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    setState(() => _loadingBatches = true);
    final batches = await _db.getAllBatches();
    if (mounted) {
      setState(() {
        _existingBatches = batches;
        _loadingBatches = false;
      });
    }
  }

  void _updateBatchName() {
    final batchName = '$_selectedClass-$_selectedDiv ($_selectedBoard)';
    _batchNameController.text = batchName;
  }

  @override
  void dispose() {
    _batchNameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final batch = Batch(
        id: '',
        name: _batchNameController.text.trim(),
        level: _selectedClass,
        subjects: [],
        createdAt: DateTime.now(),
      );

      final success = await _db.createBatch(batch);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ Batch created successfully!'),
                  const SizedBox(height: 4),
                  Text('Batch: ${_batchNameController.text}', 
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          // Reload batches list and stay on screen
          _loadBatches();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Failed to create batch. Check console for details.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add New Batch',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.adminAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.adminAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.adminAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Batch name will be auto-generated based on class, division, and board',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.adminAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Batch Details Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.adminAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.class_rounded, color: AppColors.adminAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Batch Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Class Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Class *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedClass,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.adminAccent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: _classes.map((cls) => DropdownMenuItem(
                      value: cls, 
                      child: Text(cls)
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value!;
                        _updateBatchName();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Division Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Division *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedDiv,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.adminAccent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: _divisions.map((div) => DropdownMenuItem(
                      value: div, 
                      child: Text(div)
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDiv = value!;
                        _updateBatchName();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Board Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Board *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedBoard,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.adminAccent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: _boards.map((board) => DropdownMenuItem(
                      value: board, 
                      child: Text(board)
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBoard = value!;
                        _updateBatchName();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Generated Batch Name (Read-only)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Batch Name (Auto-generated)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      _batchNameController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.adminAccent,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.adminAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Batch',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),

              // ── Existing Batches ──────────────────────────────────
              const Divider(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Existing Batches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (!_loadingBatches)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.adminAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_existingBatches.length} total',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.adminAccent,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _loadingBatches
                  ? const Center(child: CircularProgressIndicator())
                  : _existingBatches.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.class_outlined, size: 40, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'No batches created yet',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: _existingBatches.map((batch) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.adminAccent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.class_rounded,
                                        color: AppColors.adminAccent, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      batch.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Active',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllStudentsScreen extends StatefulWidget {
  const _AllStudentsScreen();

  @override
  State<_AllStudentsScreen> createState() => _AllStudentsScreenState();
}

class _AllStudentsScreenState extends State<_AllStudentsScreen> {
  final _db = DatabaseService();
  List<Student> _students = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _loading = true);
    final students = await _db.getAllStudents();
    if (mounted) {
      setState(() {
        _students = students;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('All Students (${_students.length})',
            style: const TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No students found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add students to see them here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final student = _students[i];
                    final statusColor = student.enrollmentStatus == 'active'
                        ? AppColors.success
                        : AppColors.warning;
                    final feeStatusColor = student.feeStatus == 'full'
                        ? AppColors.success
                        : student.feeStatus == 'partial'
                            ? AppColors.warning
                            : AppColors.error;

                    return GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.studentAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: AppColors.studentAccent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student.name,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark)),
                                const SizedBox(height: 2),
                                Text(
                                    '${student.studentClass ?? 'N/A'} ${student.board != null ? '(${student.board})' : ''} • ${student.email}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMid)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        student.enrollmentStatus.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: feeStatusColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Fee: ${student.feeStatus.toUpperCase()}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: feeStatusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${student.feesPaid.toInt()}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                              Text(
                                'of ₹${student.totalFees.toInt()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _AddTeacherScreen extends StatefulWidget {
  const _AddTeacherScreen();

  @override
  State<_AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<_AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();
  bool _isSubmitting = false;
  bool _loadingBatches = true;

  // Teacher Details
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController(text: '0');

  // Subject and Class Assignment
  List<String> _selectedSubjects = [];
  List<String> _selectedClasses = [];
  String _selectedBoard = 'CBSE';
  String? _selectedBatch;

  final List<String> _boards = ['CBSE', 'SSC'];
  final List<String> _classes = ['7th', '8th', '9th', '10th', '11th', '12th'];
  final List<String> _subjects = [
    'Mathematics',
    'Science',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Hindi',
    'Social Studies',
    'Computer Science',
    'Physical Education',
  ];

  // Batches loaded from database
  List<Map<String, String>> _availableBatches = [];

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    setState(() => _loadingBatches = true);
    final batches = await _db.getAllBatches();
    if (mounted) {
      setState(() {
        _availableBatches = batches.map((b) => {
          'id': b.id,
          'name': b.name,
        }).toList();
        _loadingBatches = false;
      });
    }
  }

  // Generate email from name
  String _generateEmail(String name) {
    final emailName = name.toLowerCase().trim().replaceAll(' ', '.');
    return '$emailName@teachers.com';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one subject'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one class'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final teacherEmail = _generateEmail(_nameController.text);

      final success = await _db.addTeacherSimple(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        subjects: _selectedSubjects,
        classes: _selectedClasses,
        board: _selectedBoard,
        batchId: _selectedBatch,
        qualification: _qualificationController.text.trim(),
        experienceYears: int.tryParse(_experienceController.text) ?? 0,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ Teacher added successfully!'),
                  const SizedBox(height: 4),
                  Text('Email: $teacherEmail', style: const TextStyle(fontSize: 12)),
                  const Text('Password: Teacher@123', style: TextStyle(fontSize: 12)),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Failed to add teacher. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add New Teacher',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Email will be auto-generated as: name@teachers.com',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Teacher Details Section
              _buildSectionHeader('Teacher Details', Icons.person_rounded),
              const SizedBox(height: 16),
              _buildTextField('Full Name *', _nameController, 'Enter teacher name'),
              const SizedBox(height: 12),
              _buildTextField('Phone Number *', _phoneController, '10-digit mobile number', keyboardType: TextInputType.phone, maxLength: 10),
              const SizedBox(height: 12),
              _buildTextField('Qualification', _qualificationController, 'e.g., M.Sc, B.Ed'),
              const SizedBox(height: 12),
              _buildTextField('Experience (Years)', _experienceController, '0', keyboardType: TextInputType.number),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              // Subject and Class Assignment Section
              _buildSectionHeader('Subject & Class Assignment', Icons.school_rounded),
              const SizedBox(height: 16),
              _buildSubjectSelector(),
              const SizedBox(height: 16),
              _buildClassSelector(),
              const SizedBox(height: 12),
              _buildDropdown('Board *', _selectedBoard, _boards, (value) => setState(() => _selectedBoard = value!), isRequired: true),
              const SizedBox(height: 12),
              if (_availableBatches.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Batch (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedBatch,
                      hint: const Text('Select a batch'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: _availableBatches.map((b) => DropdownMenuItem<String>(
                        value: b['id'],
                        child: Text(b['name']!),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedBatch = value),
                    ),
                  ],
                ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teacherAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add Teacher',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.teacherAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.teacherAccent, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            counterText: maxLength != null ? '' : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: label.contains('*') ? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(1990),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? '${date.day}/${date.month}/${date.year}' : 'Select date',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? AppColors.textDark : Colors.grey[500],
                  ),
                ),
                const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Subjects *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _subjects.map((subject) {
            final isSelected = _selectedSubjects.contains(subject);
            return FilterChip(
              label: Text(subject),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSubjects.add(subject);
                  } else {
                    _selectedSubjects.remove(subject);
                  }
                });
              },
              selectedColor: AppColors.teacherAccent.withValues(alpha: 0.2),
              checkmarkColor: AppColors.teacherAccent,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.teacherAccent : AppColors.textMid,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildClassSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Classes *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _classes.map((cls) {
            final isSelected = _selectedClasses.contains(cls);
            return FilterChip(
              label: Text(cls),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedClasses.add(cls);
                  } else {
                    _selectedClasses.remove(cls);
                  }
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textMid,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AllTeachersScreen extends StatefulWidget {
  const _AllTeachersScreen();

  @override
  State<_AllTeachersScreen> createState() => _AllTeachersScreenState();
}

class _AllTeachersScreenState extends State<_AllTeachersScreen> {
  final _db = DatabaseService();
  List<Teacher> _teachers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    setState(() => _loading = true);
    final teachers = await _db.getAllTeachers();
    if (mounted) {
      setState(() {
        _teachers = teachers;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('All Teachers (${_teachers.length})',
            style: const TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadTeachers,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _teachers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No teachers found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add teachers to see them here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _teachers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final teacher = _teachers[i];
                    final subjectsText = teacher.subjects.isNotEmpty
                        ? teacher.subjects.join(', ')
                        : 'No subjects';
                    final classesText = teacher.classes.isNotEmpty
                        ? '${teacher.classes.length} Classes'
                        : 'No classes';

                    return GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.teacherAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: AppColors.teacherAccent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(teacher.name,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark)),
                                const SizedBox(height: 2),
                                Text('$subjectsText • $classesText',
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.textMid)),
                                const SizedBox(height: 2),
                                Text(teacher.email,
                                    style: const TextStyle(
                                        fontSize: 10, color: AppColors.textLight)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textLight, size: 20),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _AdminAdmissionsScreen extends StatefulWidget {
  @override
  State<_AdminAdmissionsScreen> createState() => _AdminAdmissionsScreenState();
}

class _AdminAdmissionsScreenState extends State<_AdminAdmissionsScreen> {
  final _db = DatabaseService();
  List<Student> _students = [];
  List<Batch> _batches = [];
  String? _selectedBatchId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _db.getAllStudents(),
      _db.getAllBatches(),
    ]);
    if (mounted) {
      setState(() {
        _students = results[0] as List<Student>;
        _batches = results[1] as List<Batch>;
        _loading = false;
      });
    }
  }

  List<Student> _getFilteredStudents() {
    if (_selectedBatchId == null) return _students;
    return _students.where((s) => s.batchId == _selectedBatchId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredStudents();
    
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Admissions',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Batch Filter
                  const Text('Filter by Batch',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: _selectedBatchId,
                        hint: const Text('All Batches'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Batches'),
                          ),
                          ..._batches.map((b) => DropdownMenuItem<String?>(
                            value: b.id,
                            child: Text(b.name),
                          )).toList(),
                        ],
                        onChanged: (value) => setState(() => _selectedBatchId = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Total',
                          value: '${filtered.length}',
                          icon: Icons.school_rounded,
                          color: AppColors.primary,
                          subtitle: 'Students',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Active',
                          value: '${filtered.where((s) => s.enrollmentStatus == 'active').length}',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                          subtitle: 'Enrolled',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Students List
                  const Text('Admitted Students',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.person_add_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('No students found',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filtered.map((student) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student.name,
                                      style: const TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Batch: ${student.batchId?.split('_').last ?? 'N/A'} • Status: ${student.enrollmentStatus}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMid),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(student.email,
                                      style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: student.enrollmentStatus == 'active'
                                    ? AppColors.success.withValues(alpha: 0.12)
                                    : AppColors.warning.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                student.enrollmentStatus == 'active' ? '✓ Active' : 'Pending',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: student.enrollmentStatus == 'active'
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}

class _AdminTimetableScreen extends StatefulWidget {
  @override
  State<_AdminTimetableScreen> createState() => _AdminTimetableScreenState();
}

class _AdminTimetableScreenState extends State<_AdminTimetableScreen> {
  final _db = DatabaseService();
  List<TimeTable> _timetables = [];
  List<Batch> _batches = [];
  List<Subject> _subjects = [];
  List<Teacher> _teachers = [];
  String? _selectedBatchId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _db.getAllTimeTables(),
      _db.getAllBatches(),
      _db.getAllSubjects(),
      _db.getAllTeachers(),
    ]);
    if (mounted) {
      setState(() {
        _timetables = results[0] as List<TimeTable>;
        _batches = results[1] as List<Batch>;
        _subjects = results[2] as List<Subject>;
        _teachers = results[3] as List<Teacher>;
        _loading = false;
      });
    }
  }

  List<TimeTable> _getFilteredTimetables() {
    if (_selectedBatchId == null) return _timetables;
    return _timetables.where((t) => t.batchId == _selectedBatchId).toList();
  }

  Future<void> _assignClass() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => _AssignClassToTimetable(
          batches: _batches,
          subjects: _subjects,
          teachers: _teachers,
          db: _db,
          onSuccess: _loadData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredTimetables();
    
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Timetable',
            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _assignClass,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Batch Filter
                  const Text('Filter by Batch',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: _selectedBatchId,
                        hint: const Text('All Batches'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Batches'),
                          ),
                          ..._batches.map((b) => DropdownMenuItem<String?>(
                            value: b.id,
                            child: Text(b.name),
                          )).toList(),
                        ],
                        onChanged: (value) => setState(() => _selectedBatchId = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Total',
                          value: '${filtered.length}',
                          icon: Icons.schedule_rounded,
                          color: AppColors.info,
                          subtitle: 'Classes',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Batches',
                          value: '${_batches.length}',
                          icon: Icons.class_rounded,
                          color: AppColors.primary,
                          subtitle: 'Total',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Timetable List
                  const Text('Class Timetable',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.schedule_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('No timetable entries found',
                                style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Text('Tap + to create one',
                                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filtered.map((tt) {
                      final batch = _batches.firstWhere(
                        (b) => b.id == tt.batchId,
                        orElse: () => Batch(
                          id: '', name: 'Unknown', level: '', subjects: [], createdAt: DateTime.now()
                        ),
                      );
                      final subject = _subjects.firstWhere(
                        (s) => s.id == tt.subjectId,
                        orElse: () => Subject(id: '', name: 'Unknown', code: '', description: ''),
                      );
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.schedule_rounded,
                                        color: AppColors.info, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(subject.name,
                                            style: const TextStyle(
                                                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                                        Text(batch.name,
                                            style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '✓ Active',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}

class _AdminBroadcastScreen extends StatefulWidget {
  @override
  State<_AdminBroadcastScreen> createState() => _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends State<_AdminBroadcastScreen> {
  final _db = DatabaseService();
  List<Broadcast> _broadcasts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBroadcasts();
  }

  Future<void> _loadBroadcasts() async {
    setState(() => _loading = true);
    final broadcasts = await _db.getAllBroadcasts();
    if (mounted) {
      setState(() {
        _broadcasts = broadcasts;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recent = _broadcasts.reversed.take(10).toList();
    
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Send Notices',
            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: Colors.transparent,
              child: DraggableScrollableSheet(
                expand: false,
                builder: (_, controller) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Send Notice To',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 20),
                          _BroadcastTargetButton(
                            label: 'All Students',
                            icon: Icons.school_rounded,
                            color: AppColors.primary,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const _SendNoticeScreen(target: 'Students'),
                                ),
                              ).then((_) => _loadBroadcasts());
                            },
                          ),
                          const SizedBox(height: 12),
                          _BroadcastTargetButton(
                            label: 'All Teachers',
                            icon: Icons.person_rounded,
                            color: AppColors.teacherAccent,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const _SendNoticeScreen(target: 'Teachers'),
                                ),
                              ).then((_) => _loadBroadcasts());
                            },
                          ),
                          const SizedBox(height: 12),
                          _BroadcastTargetButton(
                            label: 'All Parents',
                            icon: Icons.family_restroom_rounded,
                            color: AppColors.parentAccent,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const _SendNoticeScreen(target: 'Parents'),
                                ),
                              ).then((_) => _loadBroadcasts());
                            },
                          ),
                          const SizedBox(height: 12),
                          _BroadcastTargetButton(
                            label: 'Everyone',
                            icon: Icons.public_rounded,
                            color: AppColors.adminAccent,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const _SendNoticeScreen(target: 'All'),
                                ),
                              ).then((_) => _loadBroadcasts());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        backgroundColor: AppColors.warning,
        child: const Icon(Icons.add_rounded),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Broadcasts',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                        onPressed: _loadBroadcasts,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (recent.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.campaign_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('No broadcasts sent yet',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    )
                  else
                    ...recent.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(b.title,
                                          style: const TextStyle(
                                              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                          maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(b.message,
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMid),
                                          maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.info.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    b.targetAudience.substring(0, 1).toUpperCase() + 
                                    b.targetAudience.substring(1),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.info,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${b.sentDate.day}/${b.sentDate.month}/${b.sentDate.year}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}

class _BroadcastTargetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BroadcastTargetButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _AdminFeesScreen extends StatefulWidget {
  @override
  State<_AdminFeesScreen> createState() => _AdminFeeScreenState();
}

class _AdminFeeScreenState extends State<_AdminFeesScreen> {
  final _db = DatabaseService();
  List<Student> _students = [];
  String _filterStatus = 'all'; // all, pending, paid
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final students = await _db.getAllStudents();
    if (mounted) {
      setState(() {
        _students = students;
        _loading = false;
      });
    }
  }

  List<Student> _getFilteredStudents() {
    switch (_filterStatus) {
      case 'pending':
        return _students.where((s) => s.feesPaid < s.totalFees).toList();
      case 'paid':
        return _students.where((s) => s.feesPaid >= s.totalFees).toList();
      default:
        return _students;
    }
  }

  double _getTotalFees() => _students.fold(0, (sum, s) => sum + s.totalFees);
  double _getTotalPaid() => _students.fold(0, (sum, s) => sum + s.feesPaid);
  double _getTotalPending() => _getTotalFees() - _getTotalPaid();

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredStudents();
    
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Fee Management',
            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Statistics
                  const Text('Fee Summary',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.success, Color(0xFF81C784)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Fees Collected',
                            style: TextStyle(fontSize: 12, color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text('₹${_getTotalPaid().toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('of ₹${_getTotalFees().toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pending',
                                  style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('₹${_getTotalPending().toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.warning)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Students',
                                  style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('${_students.length}',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Filter Buttons
                  const Text('Filter Students',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _FilterChip(
                        label: 'All',
                        count: _students.length,
                        isSelected: _filterStatus == 'all',
                        onTap: () => setState(() => _filterStatus = 'all'),
                      ),
                      _FilterChip(
                        label: 'Paid',
                        count: _students.where((s) => s.feesPaid >= s.totalFees).length,
                        isSelected: _filterStatus == 'paid',
                        onTap: () => setState(() => _filterStatus = 'paid'),
                        color: AppColors.success,
                      ),
                      _FilterChip(
                        label: 'Pending',
                        count: _students.where((s) => s.feesPaid < s.totalFees).length,
                        isSelected: _filterStatus == 'pending',
                        onTap: () => setState(() => _filterStatus = 'pending'),
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Students List
                  const Text('Student Fees',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('No students found',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filtered.map((student) {
                      final feePaid = student.feesPaid;
                      final totalFee = student.totalFees;
                      final pending = totalFee - feePaid;
                      final percentage = totalFee > 0 ? (feePaid / totalFee * 100) : 0;
                      final isPaid = pending <= 0;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isPaid
                                          ? AppColors.success.withValues(alpha: 0.12)
                                          : AppColors.warning.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isPaid ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                      color: isPaid ? AppColors.success : AppColors.warning,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(student.name,
                                            style: const TextStyle(
                                                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                                        Text(student.email,
                                            style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation(
                                    isPaid ? AppColors.success : AppColors.warning,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Paid: ₹${feePaid.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMid, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Pending: ₹${pending.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isPaid ? AppColors.success : AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(0)}%',
                                    style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final finalColor = color ?? AppColors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? finalColor.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? finalColor : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? finalColor : AppColors.textMid,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: finalColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: finalColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllParentsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> parents = const [
    {'name': 'Mr. Rajesh Sharma', 'children': '1 Child', 'status': 'Active'},
    {'name': 'Mrs. Sunita Patel', 'children': '2 Children', 'status': 'Active'},
    {'name': 'Mr. Vikram Mehta', 'children': '1 Child', 'status': 'Active'},
    {'name': 'Mrs. Priya Iyer', 'children': '1 Child', 'status': 'Active'},
    {'name': 'Mr. Karan Singh', 'children': '2 Children', 'status': 'Active'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('All Parents',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: parents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final parent = parents[i];
          return GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.parentAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.family_restroom_rounded,
                      color: AppColors.parentAccent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(parent['name'] as String,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      Text(parent['children'] as String,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMid)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textLight, size: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SendNoticeScreen extends StatefulWidget {
  final String target; // 'Students', 'Teachers', 'Staff', 'Parents', 'All'

  const _SendNoticeScreen({this.target = 'All'});

  @override
  State<_SendNoticeScreen> createState() => _SendNoticeScreenState();
}

class _SendNoticeScreenState extends State<_SendNoticeScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _priority = 'normal'; // normal, high, urgent
  bool _isSending = false;
  bool _sent = false;

  final List<String> _priorities = ['normal', 'high', 'urgent'];

  Color _priorityColor(String p) {
    switch (p) {
      case 'high': return AppColors.warning;
      case 'urgent': return AppColors.error;
      default: return AppColors.info;
    }
  }

  IconData _priorityIcon(String p) {
    switch (p) {
      case 'high': return Icons.priority_high_rounded;
      case 'urgent': return Icons.warning_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Future<void> _sendNotice() async {
    if (_titleController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and message'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final db = DatabaseService();
      final targetAudience = widget.target.toLowerCase();
      final id = 'bcast_${DateTime.now().millisecondsSinceEpoch}';
      
      // Try with sent_by first, fall back without it if FK fails
      try {
        await db.client.from('broadcasts').insert({
          'id': id,
          'title': _titleController.text.trim(),
          'message': _messageController.text.trim(),
          'target_audience': targetAudience,
          'priority': _priority,
          'sent_by': 'a0000001-0000-0000-0000-000000000001',
          'sent_date': DateTime.now().toIso8601String(),
        });
        debugPrint('✓ Broadcast sent to $targetAudience');
      } catch (e1) {
        debugPrint('Retrying without sent_by: $e1');
        // Try inserting without sent_by (if it has a FK constraint issue)
        await db.client.from('broadcasts').insert({
          'id': '${id}_2',
          'title': _titleController.text.trim(),
          'message': _messageController.text.trim(),
          'target_audience': targetAudience,
          'priority': _priority,
          'sent_date': DateTime.now().toIso8601String(),
        });
        debugPrint('✓ Broadcast sent to $targetAudience (without sent_by)');
      }
    } catch (e) {
      debugPrint('Broadcast insert failed: $e');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isSending = false;
        _sent = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Send Notice to ${widget.target}',
            style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: _sent ? _buildSuccessView() : _buildForm(),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 72, color: AppColors.success),
            ),
            const SizedBox(height: 24),
            const Text('Notice Sent!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text('Your notice has been sent to all ${widget.target}.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textMid)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _sent = false;
                    _titleController.clear();
                    _messageController.clear();
                    _priority = 'normal';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Send Another', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target audience chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.group_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('To: ${widget.target}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Priority selector
          const Text('Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 10),
          Row(
            children: _priorities.map((p) {
              final selected = _priority == p;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? _priorityColor(p).withOpacity(0.15) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? _priorityColor(p) : Colors.grey[300]!,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_priorityIcon(p), size: 14, color: selected ? _priorityColor(p) : AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(p[0].toUpperCase() + p.substring(1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                              color: selected ? _priorityColor(p) : AppColors.textMid,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Title
          const Text('Title *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'e.g. Holiday Notice, Fee Reminder...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Message
          const Text('Message *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Write your notice here...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 32),

          // Send button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _sendNotice,
              icon: _isSending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded),
              label: Text(_isSending ? 'Sending...' : 'Send Notice',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.adminAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}


// ─── Simple Admin Profile Sheet ───────────────────────────────────────────────
class _SimpleAdminProfileSheet extends StatelessWidget {
  const _SimpleAdminProfileSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.7,
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
                  color: AppColors.adminAccent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_circle_rounded,
                    color: AppColors.adminAccent, size: 40),
              ),
              const SizedBox(height: 12),
              const Text(
                'Admin',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.adminAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.adminAccent),
                ),
              ),
              const SizedBox(height: 24),
              
              // Profile Info
              const _ProfileInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: 'admin@vidya.com'),
              const Divider(color: AppColors.divider, height: 24),
              const _ProfileInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: '+91 98765 43210'),
              const SizedBox(height: 24),
              
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
      ),
    );
  }
}

// ─── Old Admin Profile Sheet (DEPRECATED - keeping for reference) ────────────
class _AdminProfileSheet extends StatefulWidget {
  final VoidCallback onFeedbackUpdated;

  const _AdminProfileSheet({required this.onFeedbackUpdated});

  @override
  State<_AdminProfileSheet> createState() => _AdminProfileSheetState();
}

class _AdminProfileSheetState extends State<_AdminProfileSheet> {
  final _db = DatabaseService();
  List<AnonymousFeedback> _pendingFeedbacks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingFeedback();
  }

  Future<void> _loadPendingFeedback() async {
    setState(() => _loading = true);
    final feedbacks = await _db.getPendingFeedbackForAdmin();
    if (mounted) {
      setState(() {
        _pendingFeedbacks = feedbacks;
        _loading = false;
      });
    }
  }

  Future<void> _approveFeedback(AnonymousFeedback feedback) async {
    final success = await _db.approveFeedback(feedback.id, 'admin_001', null);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback approved and sent to teacher'),
          backgroundColor: Colors.green,
        ),
      );
      _loadPendingFeedback();
      widget.onFeedbackUpdated();
    }
  }

  Future<void> _rejectFeedback(AnonymousFeedback feedback) async {
    final success = await _db.rejectFeedback(feedback.id, 'admin_001', 'Not appropriate');
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback rejected'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadPendingFeedback();
      widget.onFeedbackUpdated();
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
                color: AppColors.adminAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_circle_rounded,
                  color: AppColors.adminAccent, size: 40),
            ),
            const SizedBox(height: 12),
            const Text(
              'Admin',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.adminAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.adminAccent),
              ),
            ),
            const SizedBox(height: 24),
            
            // Profile Info
            const _ProfileInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: 'admin@vidya.com'),
            const Divider(color: AppColors.divider, height: 24),
            const _ProfileInfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: '+91 98765 43210'),
            const SizedBox(height: 24),
            
            // Pending Feedback Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pending Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (_pendingFeedbacks.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_pendingFeedbacks.length}',
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
                  : _pendingFeedbacks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'No pending feedback',
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
                          itemCount: _pendingFeedbacks.length,
                          itemBuilder: (context, index) {
                            final feedback = _pendingFeedbacks[index];
                            return _FeedbackCard(
                              feedback: feedback,
                              categoryLabel: _getCategoryLabel(feedback.category),
                              categoryColor: _getCategoryColor(feedback.category),
                              onApprove: () => _approveFeedback(feedback),
                              onReject: () => _rejectFeedback(feedback),
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

// ─── Timetable Assignment Helper ──────────────────────────────────────────────
class _AssignClassToTimetable extends StatefulWidget {
  final List<Batch> batches;
  final List<Subject> subjects;
  final List<Teacher> teachers;
  final DatabaseService db;
  final VoidCallback onSuccess;

  const _AssignClassToTimetable({
    required this.batches,
    required this.subjects,
    required this.teachers,
    required this.db,
    required this.onSuccess,
  });

  @override
  State<_AssignClassToTimetable> createState() => _AssignClassToTimetableState();
}

class _AssignClassToTimetableState extends State<_AssignClassToTimetable> {
  String? _selectedBatchId;
  String? _selectedSubjectId;
  String? _selectedTeacherId;
  String? _selectedDay;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  final _roomController = TextEditingController();
  bool _isSaving = false;

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() => isStart ? _startTime = picked : _endTime = picked);
    }
  }

  Future<void> _save() async {
    if (_selectedBatchId == null ||
        _selectedSubjectId == null ||
        _selectedTeacherId == null ||
        _selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final tt = TimeTable(
        id: 'tt_${DateTime.now().millisecondsSinceEpoch}',
        batchId: _selectedBatchId!,
        subjectId: _selectedSubjectId!,
        teacherId: _selectedTeacherId!,
        day: _selectedDay!,
        startTime: _formatTime(_startTime),
        endTime: _formatTime(_endTime),
        room: _roomController.text.trim().isEmpty ? null : _roomController.text.trim(),
        createdAt: DateTime.now(),
      );
      await widget.db.createTimeTableEntry(tt);
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Timetable entry created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Assign Class',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 20),
            // Batch Dropdown
            const Text('Batch',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedBatchId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              hint: const Text('Select batch'),
              items: widget.batches
                  .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedBatchId = value),
            ),
            const SizedBox(height: 16),
            // Subject Dropdown
            const Text('Subject',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSubjectId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              hint: const Text('Select subject'),
              items: widget.subjects
                  .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSubjectId = value),
            ),
            const SizedBox(height: 16),
            // Teacher Dropdown
            const Text('Teacher',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTeacherId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              hint: const Text('Select teacher'),
              items: widget.teachers
                  .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedTeacherId = value),
            ),
            const SizedBox(height: 16),
            // Day
            const Text('Day',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              hint: const Text('Select day'),
              items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (value) => setState(() => _selectedDay = value),
            ),
            const SizedBox(height: 16),
            // Times
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Time',
                          style:
                              TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pickTime(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_formatTime(_startTime)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Time',
                          style:
                              TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pickTime(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_formatTime(_endTime)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Room
            const Text('Room (Optional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 8),
            TextField(
              controller: _roomController,
              decoration: InputDecoration(
                hintText: 'e.g., Room 101',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Feedback Card Widget ─────────────────────────────────────────────────────
class _FeedbackCard extends StatelessWidget {
  final AnonymousFeedback feedback;
  final String categoryLabel;
  final Color categoryColor;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _FeedbackCard({
    required this.feedback,
    required this.categoryLabel,
    required this.categoryColor,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
                child: Icon(Icons.feedback_outlined, color: categoryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.teacherName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      categoryLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating
              if (feedback.rating != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFA726), size: 14),
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
          
          // Sender Info
          Row(
            children: [
              Icon(
                feedback.senderRole == 'student'
                    ? Icons.school_outlined
                    : Icons.family_restroom_outlined,
                size: 14,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                'From ${feedback.senderRole}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.access_time, size: 14, color: AppColors.textLight),
              const SizedBox(width: 4),
              Text(
                '${feedback.submittedAt.day}/${feedback.submittedAt.month}/${feedback.submittedAt.year}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: AppColors.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
}

