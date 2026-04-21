import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/database_service.dart';
import '../models/models.dart';
import 'login_screen.dart';
import 'non_teaching_staff_dashboard.dart';

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
      builder: (_) => const _SimpleAdminProfileSheet(),
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
            const _StudentsTab(),
            _TeachersTab(),
            _StaffTab(),
            const _ParentsTab(),
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
    builder: (_) => _AdminNotificationsSheet(),
  );
}

class _AdminNotificationsSheet extends StatefulWidget {
  @override
  State<_AdminNotificationsSheet> createState() =>
      _AdminNotificationsSheetState();
}

class _AdminNotificationsSheetState extends State<_AdminNotificationsSheet> {
  final _db = DatabaseService();
  List<Map<String, dynamic>> _activities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final activities = await _db.getRecentActivityLog(limit: 15);
    if (mounted) {
      setState(() {
        _activities = activities;
        _loading = false;
      });
    }
  }

  String _timeAgo(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  IconData _icon(String type) {
    switch (type) {
      case 'student_added':
        return Icons.person_add_rounded;
      case 'teacher_added':
        return Icons.school_rounded;
      case 'fee_payment':
        return Icons.account_balance_wallet_rounded;
      case 'notice_sent':
        return Icons.campaign_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _color(String colorKey) {
    switch (colorKey) {
      case 'success':
        return AppColors.success;
      case 'teacher':
        return AppColors.teacherAccent;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
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
            const Text('Recent Activity',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _activities.isEmpty
                      ? const Center(
                          child: Text('No recent activity.',
                              style: TextStyle(color: AppColors.textLight)))
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: _activities.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final a = _activities[i];
                            final color = _color(a['color'] ?? '');
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(_icon(a['type'] ?? ''),
                                      color: color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(a['title'] ?? '',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textDark)),
                                      const SizedBox(height: 2),
                                      Text(a['desc'] ?? '',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textLight)),
                                      const SizedBox(height: 4),
                                      Text(_timeAgo(a['time'] ?? ''),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: color,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// Removed unused notification widget to reduce analyzer noise.

class _DashboardTab extends StatefulWidget {
  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final _db = DatabaseService();
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _batchAttendance = [];
  List<Map<String, dynamic>> _batchPerformance = [];
  List<Map<String, dynamic>> _activityLog = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _db.getAdminDashboardStats(),
      _db.getBatchAttendanceSummaries(),
      _db.getBatchPerformanceSummaries(),
      _db.getRecentActivityLog(limit: 5),
    ]);
    if (mounted) {
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _batchAttendance = results[1] as List<Map<String, dynamic>>;
        _batchPerformance = results[2] as List<Map<String, dynamic>>;
        _activityLog = results[3] as List<Map<String, dynamic>>;
        _loading = false;
      });
    }
  }

  String _timeAgo(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  IconData _activityIcon(String type) {
    switch (type) {
      case 'student_added':
        return Icons.person_add_rounded;
      case 'teacher_added':
        return Icons.school_rounded;
      case 'fee_payment':
        return Icons.payment_rounded;
      case 'notice_sent':
        return Icons.campaign_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _activityColor(String colorKey) {
    switch (colorKey) {
      case 'success':
        return AppColors.success;
      case 'teacher':
        return AppColors.teacherAccent;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalStudents = _stats['total_students'] ?? 0;
    final totalTeachers = _stats['total_teachers'] ?? 0;
    final totalBatches = _stats['total_batches'] ?? 0;
    final feePending = _stats['fee_pending_count'] ?? 0;
    final attendancePct = _stats['attendance_pct'] ?? '0.0';

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(
              name: 'Admin',
              role: 'ADMIN',
              roleColor: AppColors.adminAccent,
              notificationCount: _loading ? 0 : feePending,
              onNotification: () => _showNotificationsSheet(context),
            ),
            const SizedBox(height: 24),
            _SchoolSummaryBannerLive(
              totalStudents: totalStudents,
              totalTeachers: totalTeachers,
              totalBatches: totalBatches,
              loading: _loading,
            ),
            const SizedBox(height: 24),

            // Key Stats Row
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Students',
                      value: '$totalStudents',
                      icon: Icons.school_rounded,
                      color: AppColors.primary,
                      subtitle: 'Enrolled',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Total Teachers',
                      value: '$totalTeachers',
                      icon: Icons.person_rounded,
                      color: AppColors.teacherAccent,
                      subtitle: 'Active',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Attendance',
                      value: '$attendancePct%',
                      icon: Icons.how_to_reg_rounded,
                      color: AppColors.success,
                      subtitle: 'This month',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Fee Pending',
                      value: '$feePending',
                      icon: Icons.warning_rounded,
                      color: AppColors.warning,
                      subtitle: 'Students',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Batch Attendance
            const SectionHeader(title: 'Batch Attendance (This Month)'),
            const SizedBox(height: 14),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_batchAttendance.isEmpty)
              const GlassCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No attendance data yet.',
                        style: TextStyle(color: AppColors.textMid)),
                  ),
                ),
              )
            else
              GlassCard(
                child: Column(
                  children: _batchAttendance.asMap().entries.map((e) {
                    final b = e.value;
                    final colors = [
                      AppColors.success,
                      AppColors.primary,
                      AppColors.teacherAccent,
                      AppColors.warning,
                      AppColors.info,
                    ];
                    final color = colors[e.key % colors.length];
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: e.key < _batchAttendance.length - 1 ? 14 : 0),
                      child: LabeledProgressBar(
                        label: b['batch_name'] ?? 'Batch',
                        value: (b['attendance_pct'] as double).clamp(0.0, 1.0),
                        color: color,
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24),

            // Top Performing Batches
            const SectionHeader(title: 'Top Performing Batches'),
            const SizedBox(height: 14),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_batchPerformance.isEmpty)
              const GlassCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No performance data yet.',
                        style: TextStyle(color: AppColors.textMid)),
                  ),
                ),
              )
            else
              GlassCard(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: _batchPerformance
                      .take(5)
                      .toList()
                      .asMap()
                      .entries
                      .map((e) {
                    final b = e.value;
                    final colors = [
                      AppColors.success,
                      AppColors.primary,
                      AppColors.teacherAccent,
                      AppColors.warning,
                      AppColors.info,
                    ];
                    final color = colors[e.key % colors.length];
                    final avg = (b['avg_score'] as double).toStringAsFixed(1);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: e.key < _batchPerformance.length - 1
                            ? const Border(
                                bottom: BorderSide(color: AppColors.divider))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('#${e.key + 1}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: color)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(b['batch_name'] ?? 'Batch',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark)),
                          ),
                          Text('$avg%',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: color)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24),

            // Recent Activity Feed
            const SectionHeader(title: 'Recent Activity'),
            const SizedBox(height: 14),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_activityLog.isEmpty)
              const GlassCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No recent activity.',
                        style: TextStyle(color: AppColors.textMid)),
                  ),
                ),
              )
            else
              ..._activityLog.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _activityColor(a['color'] ?? '')
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _activityIcon(a['type'] ?? ''),
                              color: _activityColor(a['color'] ?? ''),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a['title'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark)),
                                const SizedBox(height: 2),
                                Text(a['desc'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMid,
                                        height: 1.4)),
                              ],
                            ),
                          ),
                          Text(
                            _timeAgo(a['time'] ?? ''),
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textLight),
                          ),
                        ],
                      ),
                    ),
                  )),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// Removed unused Reports tab placeholder.

// ============================================================
//  LIVE STAT WIDGETS
// ============================================================

class _LiveStudentStats extends StatefulWidget {
  @override
  State<_LiveStudentStats> createState() => _LiveStudentStatsState();
}

class _LiveStudentStatsState extends State<_LiveStudentStats> {
  final _db = DatabaseService();
  int _total = 0;
  int _newThisMonth = 0;
  String _avgAttendance = '0.0';
  int _feePending = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _db.getAdminDashboardStats();
    final students = await _db.getAllStudents();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final newThisMonth =
        students.where((s) => s.enrollmentDate.isAfter(monthStart)).length;
    if (mounted) {
      setState(() {
        _total = stats['total_students'] ?? 0;
        _newThisMonth = newThisMonth;
        _avgAttendance = stats['attendance_pct'] ?? '0.0';
        _feePending = stats['fee_pending_count'] ?? 0;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Students',
                value: '$_total',
                icon: Icons.school_rounded,
                color: AppColors.primary,
                subtitle: 'Enrolled',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'New This Month',
                value: '$_newThisMonth',
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
                subtitle: 'Admissions',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Avg Attendance',
                value: '$_avgAttendance%',
                icon: Icons.how_to_reg_rounded,
                color: AppColors.info,
                subtitle: 'This month',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Fee Pending',
                value: '$_feePending',
                icon: Icons.warning_rounded,
                color: AppColors.warning,
                subtitle: 'Students',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LiveTeacherStats extends StatefulWidget {
  @override
  State<_LiveTeacherStats> createState() => _LiveTeacherStatsState();
}

class _LiveTeacherStatsState extends State<_LiveTeacherStats> {
  final _db = DatabaseService();
  int _total = 0;
  int _totalBatches = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _db.getAdminDashboardStats();
    if (mounted) {
      setState(() {
        _total = stats['total_teachers'] ?? 0;
        _totalBatches = stats['total_batches'] ?? 0;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Teachers',
            value: '$_total',
            icon: Icons.person_rounded,
            color: AppColors.teacherAccent,
            subtitle: 'Active',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Total Batches',
            value: '$_totalBatches',
            icon: Icons.class_rounded,
            color: AppColors.primary,
            subtitle: 'Configured',
          ),
        ),
      ],
    );
  }
}

class _LiveParentStats extends StatefulWidget {
  @override
  State<_LiveParentStats> createState() => _LiveParentStatsState();
}

class _LiveParentStatsState extends State<_LiveParentStats> {
  final _db = DatabaseService();
  int _totalStudents = 0;
  int _feePaid = 0;
  int _feePending = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final students = await _db.getAllStudents();
    int paid = 0;
    int pending = 0;
    for (final s in students) {
      if (s.totalFees > 0 && s.feesPaid >= s.totalFees) {
        paid++;
      } else if (s.totalFees > s.feesPaid) {
        pending++;
      }
    }
    if (mounted) {
      setState(() {
        _totalStudents = students.length;
        _feePaid = paid;
        _feePending = pending;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Students',
                value: '$_totalStudents',
                icon: Icons.people_rounded,
                color: AppColors.parentAccent,
                subtitle: 'Enrolled',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Fees Cleared',
                value: '$_feePaid',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                subtitle: 'Students',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Fee Pending',
                value: '$_feePending',
                icon: Icons.pending_rounded,
                color: AppColors.warning,
                subtitle: 'Students',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LiveParentActivity extends StatefulWidget {
  @override
  State<_LiveParentActivity> createState() => _LiveParentActivityState();
}

class _LiveParentActivityState extends State<_LiveParentActivity> {
  final _db = DatabaseService();
  List<Map<String, dynamic>> _activities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await _db.getRecentActivityLog(limit: 10);
    final feeActivities = all.where((a) => a['type'] == 'fee_payment').toList();
    if (mounted) {
      setState(() {
        _activities = feeActivities.take(5).toList();
        _loading = false;
      });
    }
  }

  String _timeAgo(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Text('No fee activity yet.',
              style: TextStyle(color: Colors.grey[500])),
        ),
      );
    }
    return Column(
      children: _activities
          .map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ParentActivityItem(
                  parentName: 'Fee Payment',
                  activity: a['desc'] ?? '',
                  time: _timeAgo(a['time'] ?? ''),
                  icon: Icons.payment_rounded,
                  color: AppColors.success,
                ),
              ))
          .toList(),
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
    final studentFeedbacks =
        allFeedbacks.where((f) => f.senderRole == 'student').toList();
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
      if (!mounted) return;
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
    final success =
        await _db.rejectFeedback(feedback.id, 'admin_001', 'Not appropriate');
    if (success) {
      if (!mounted) return;
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
                        MaterialPageRoute(builder: (_) => const _AddStudentScreen()));
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
                      MaterialPageRoute(builder: (_) => const _AddBatchScreen())),
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
                      MaterialPageRoute(builder: (_) => const _AllStudentsScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.campaign_rounded,
                  label: 'Send Notice',
                  color: AppColors.info,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const _SendNoticeScreen(target: 'Students'))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Student Stats
          const SectionHeader(title: 'Student Overview'),
          const SizedBox(height: 14),
          _LiveStudentStats(),
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
                    batch: s.studentClass != null
                        ? 'Class ${s.studentClass}'
                        : s.email,
                    status:
                        s.enrollmentStatus == 'active' ? 'Active' : 'Pending',
                    statusColor: s.enrollmentStatus == 'active'
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ))),

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

class _TeachersTab extends StatefulWidget {
  @override
  State<_TeachersTab> createState() => _TeachersTabState();
}

class _TeachersTabState extends State<_TeachersTab> {
  final _db = DatabaseService();
  List<Teacher> _teachers = [];
  bool _loadingTeachers = true;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final teachers = await _db.getAllTeachers();
    if (mounted) {
      setState(() {
        _teachers = teachers;
        _loadingTeachers = false;
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
                      MaterialPageRoute(builder: (_) => const _AddTeacherScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.list_alt_rounded,
                  label: 'View All',
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const _AllTeachersScreen())),
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
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const _SendNoticeScreen(target: 'Teachers'))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Teacher Stats
          const SectionHeader(title: 'Teacher Overview'),
          const SizedBox(height: 14),
          _LiveTeacherStats(),
          const SizedBox(height: 24),

          // Teacher List
          const SectionHeader(title: 'Teaching Staff'),
          const SizedBox(height: 14),
          if (_loadingTeachers)
            const Center(child: CircularProgressIndicator())
          else if (_teachers.isEmpty)
            const GlassCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('No teachers found',
                      style: TextStyle(color: AppColors.textMid)),
                ),
              ),
            )
          else
            ..._teachers.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TeacherListItem(
                    name: t.name,
                    subject:
                        t.subjects.isNotEmpty ? t.subjects.first : 'General',
                    classes: '${t.classes.length} Classes',
                    statusColor:
                        t.isActive ? AppColors.success : AppColors.warning,
                  ),
                )),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StaffTab extends StatefulWidget {
  @override
  State<_StaffTab> createState() => _StaffTabState();
}

class _StaffTabState extends State<_StaffTab> {
  final _db = DatabaseService();
  int _feeReminderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFeeReminders();
  }

  Future<void> _loadFeeReminders() async {
    final students = await _db.getAllStudents();
    final due = students.where((s) => s.totalFees > s.feesPaid).length;
    if (mounted) setState(() => _feeReminderCount = due);
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
                        builder: (_) => const NonTeachingStaffDashboard())),
              ),
              _StaffActionCard(
                icon: Icons.schedule_rounded,
                label: 'Timetable',
                color: AppColors.info,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NonTeachingStaffDashboard())),
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

          // Fee reminders only
          const SectionHeader(title: 'Fee Reminders'),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(
              children: [
                _PendingTaskItem(
                  title: 'Students with pending fees',
                  count: '$_feeReminderCount',
                  icon: Icons.notifications_rounded,
                  color: AppColors.warning,
                ),
              ],
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
    final parentFeedbacks =
        allFeedbacks.where((f) => f.senderRole == 'parent').toList();
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
      if (!mounted) return;
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
    final success =
        await _db.rejectFeedback(feedback.id, 'admin_001', 'Not appropriate');
    if (success) {
      if (!mounted) return;
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
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const _SendNoticeScreen(target: 'Parents'))),
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
          _LiveParentStats(),
          const SizedBox(height: 24),

          // Recent Parent Activity - from fee payments
          const SectionHeader(title: 'Recent Fee Activity'),
          const SizedBox(height: 14),
          _LiveParentActivity(),

          const SizedBox(height: 32),

          // Pending Feedback Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader(title: 'Parent Feedback Review'),
              if (_pendingFeedbacks.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

class _SchoolSummaryBannerLive extends StatelessWidget {
  final int totalStudents;
  final int totalTeachers;
  final int totalBatches;
  final bool loading;

  const _SchoolSummaryBannerLive({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalBatches,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final quarter = 'Q${((now.month - 1) ~/ 3) + 1} • ${months[now.month - 1]}';

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
            color: AppColors.adminAccent.withValues(alpha: 0.35),
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
                      'Academic Year ${now.year}-${now.year + 1}',
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  quarter,
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
          if (loading)
            const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
          else
            Row(
              children: [
                _BannerStat(label: 'Students', value: '$totalStudents'),
                const SizedBox(width: 24),
                _BannerStat(label: 'Teachers', value: '$totalTeachers'),
                const SizedBox(width: 24),
                _BannerStat(label: 'Batches', value: '$totalBatches'),
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

// Removed unused activity item widget.

class _PendingAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Alerts placeholder removed — not referenced.
    return const SizedBox.shrink();
  }
}

// Removed unused _AlertRow to lower analyzer noise.

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
                color: color.withValues(alpha: 0.12),
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
                color: color.withValues(alpha: 0.12),
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
              color: statusColor.withValues(alpha: 0.12),
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
            color: color.withValues(alpha: 0.12),
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
            color: color.withValues(alpha: 0.12),
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
              color: color.withValues(alpha: 0.12),
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
  final List<String> _selectedSubjects = [];

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
        _availableBatches = batches
            .map((b) => {
                  'id': b.id,
                  'name': b.name,
                })
            .toList();
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
      final parentEmail =
          _generateEmail(_parentNameController.text, 'parents.com');

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
                  Text('Student Email: $studentEmail',
                      style: const TextStyle(fontSize: 12)),
                  Text('Parent Email: $parentEmail',
                      style: const TextStyle(fontSize: 12)),
                  const Text('Password: Student@123 / Parent@123',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
          Navigator.pop(
              context, true); // true = student was added, trigger refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('❌ Failed to add student. Check console for details.'),
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
                  border:
                      Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    SizedBox(width: 12),
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
              _buildTextField(
                  'Full Name *', _nameController, 'Enter student name'),
              const SizedBox(height: 12),
              _buildTextField(
                  'Phone', _phoneController, '10-digit mobile number',
                  keyboardType: TextInputType.phone, maxLength: 10),
              const SizedBox(height: 12),
              _buildDateField('Date of Birth', _dateOfBirth,
                  (date) => setState(() => _dateOfBirth = date)),
              const SizedBox(height: 12),
              _buildTextField(
                  'Address', _addressController, 'Enter full address',
                  maxLines: 2),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // Academic Details Section
              _buildSectionHeader('Academic Details', Icons.school_rounded),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown('Class *', _selectedClass, _classes,
                        (value) => setState(() => _selectedClass = value!),
                        isRequired: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown('Board *', _selectedBoard, _boards,
                        (value) => setState(() => _selectedBoard = value!),
                        isRequired: true),
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
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: 18),
                          SizedBox(width: 8),
                          Text('No batches found. Create a batch first.',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.orange)),
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
                          initialValue: _selectedBatch,
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
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          items: _availableBatches
                              .map((b) => DropdownMenuItem<String>(
                                    value: b['id'],
                                    child: Text(b['name']!),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedBatch = value),
                          validator: (value) =>
                              value == null ? 'Please select a batch' : null,
                        ),
                      ],
                    ),
              const SizedBox(height: 12),
              _buildDateField('Admission Date *', _admissionDate,
                  (date) => setState(() => _admissionDate = date)),
              const SizedBox(height: 12),
              _buildSubjectSelector(),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // Parent Details Section
              _buildSectionHeader(
                  'Parent/Guardian Details', Icons.family_restroom_rounded),
              const SizedBox(height: 16),
              _buildTextField(
                  'Parent Name *', _parentNameController, 'Enter parent name'),
              const SizedBox(height: 12),
              _buildTextField('Parent Phone *', _parentPhoneController,
                  '10-digit mobile number',
                  keyboardType: TextInputType.phone, maxLength: 10),
              const SizedBox(height: 12),
              _buildTextField('Emergency Contact', _emergencyContactController,
                  '10-digit mobile number',
                  keyboardType: TextInputType.phone, maxLength: 10),
              const SizedBox(height: 12),
              _buildTextField(
                  'Parent Address', _parentAddressController, 'Enter address',
                  maxLines: 2),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // Fee Details Section
              _buildSectionHeader(
                  'Fee Details', Icons.account_balance_wallet_rounded),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                        'Total Fees', _totalFeesController, '0',
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                        'Fees Paid', _feesPaidController, '0',
                        keyboardType: TextInputType.number),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: label.contains('*')
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged,
      {bool isRequired = false}) {
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
          initialValue: value,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField(
      String label, DateTime? date, Function(DateTime) onDateSelected) {
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
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select date',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? AppColors.textDark : Colors.grey[500],
                  ),
                ),
                const Icon(Icons.calendar_today,
                    size: 18, color: AppColors.primary),
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
              content:
                  Text('❌ Failed to create batch. Check console for details.'),
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
                  border: Border.all(
                      color: AppColors.adminAccent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.adminAccent, size: 20),
                    SizedBox(width: 12),
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
                    child: const Icon(Icons.class_rounded,
                        color: AppColors.adminAccent, size: 20),
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
                    initialValue: _selectedClass,
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
                        borderSide: const BorderSide(
                            color: AppColors.adminAccent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    items: _classes
                        .map((cls) =>
                            DropdownMenuItem(value: cls, child: Text(cls)))
                        .toList(),
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
                    initialValue: _selectedDiv,
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
                        borderSide: const BorderSide(
                            color: AppColors.adminAccent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    items: _divisions
                        .map((div) =>
                            DropdownMenuItem(value: div, child: Text(div)))
                        .toList(),
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
                    initialValue: _selectedBoard,
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
                        borderSide: const BorderSide(
                            color: AppColors.adminAccent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    items: _boards
                        .map((board) =>
                            DropdownMenuItem(value: board, child: Text(board)))
                        .toList(),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
                                Icon(Icons.class_outlined,
                                    size: 40, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'No batches created yet',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: _existingBatches.map((batch) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
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
                                      color: AppColors.adminAccent
                                          .withValues(alpha: 0.1),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success
                                          .withValues(alpha: 0.1),
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
                              color: AppColors.studentAccent
                                  .withValues(alpha: 0.12),
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
                                        color:
                                            statusColor.withValues(alpha: 0.12),
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
                                        color: feeStatusColor.withValues(
                                            alpha: 0.12),
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
  final List<String> _selectedSubjects = [];
  final List<String> _selectedClasses = [];
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
        _availableBatches = batches
            .map((b) => {
                  'id': b.id,
                  'name': b.name,
                })
            .toList();
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
                  Text('Email: $teacherEmail',
                      style: const TextStyle(fontSize: 12)),
                  const Text('Password: Teacher@123',
                      style: TextStyle(fontSize: 12)),
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
                  border:
                      Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    SizedBox(width: 12),
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
              _buildTextField(
                  'Full Name *', _nameController, 'Enter teacher name'),
              const SizedBox(height: 12),
              _buildTextField(
                  'Phone Number *', _phoneController, '10-digit mobile number',
                  keyboardType: TextInputType.phone, maxLength: 10),
              const SizedBox(height: 12),
              _buildTextField('Qualification', _qualificationController,
                  'e.g., M.Sc, B.Ed'),
              const SizedBox(height: 12),
              _buildTextField('Experience (Years)', _experienceController, '0',
                  keyboardType: TextInputType.number),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // Subject and Class Assignment Section
              _buildSectionHeader(
                  'Subject & Class Assignment', Icons.school_rounded),
              const SizedBox(height: 16),
              _buildSubjectSelector(),
              const SizedBox(height: 16),
              _buildClassSelector(),
              const SizedBox(height: 12),
              _buildDropdown('Board *', _selectedBoard, _boards,
                  (value) => setState(() => _selectedBoard = value!),
                  isRequired: true),
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
                      initialValue: _selectedBatch,
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
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      items: _availableBatches
                          .map((b) => DropdownMenuItem<String>(
                                value: b['id'],
                                child: Text(b['name']!),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedBatch = value),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: label.contains('*')
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged,
      {bool isRequired = false}) {
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
          initialValue: value,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField(
      String label, DateTime? date, Function(DateTime) onDateSelected) {
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
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select date',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? AppColors.textDark : Colors.grey[500],
                  ),
                ),
                const Icon(Icons.calendar_today,
                    size: 18, color: AppColors.primary),
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
                              color: AppColors.teacherAccent
                                  .withValues(alpha: 0.12),
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
                                        fontSize: 11,
                                        color: AppColors.textMid)),
                                const SizedBox(height: 2),
                                Text(teacher.email,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textLight)),
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

// Removed unused admin sub-screens (Admissions/Timetable) to reduce analyzer noise.

class _AdminBroadcastScreen extends StatelessWidget {
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
        title: const Text('Broadcast',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: GlassCard(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.campaign_rounded,
                      size: 64, color: AppColors.warning),
                  SizedBox(height: 16),
                  Text('Broadcast Messages',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  SizedBox(height: 8),
                  Text('Send notices to students, teachers, and parents',
                      style: TextStyle(color: AppColors.textLight)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminFeesScreen extends StatelessWidget {
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
        title: const Text('Fee Management',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: GlassCard(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet_rounded,
                      size: 64, color: AppColors.success),
                  SizedBox(height: 16),
                  Text('Fee Management',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  SizedBox(height: 8),
                  Text('Track and manage student fees',
                      style: TextStyle(color: AppColors.textLight)),
                ],
              ),
            ),
          ),
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
                    color: AppColors.parentAccent.withValues(alpha: 0.12),
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
      case 'high':
        return AppColors.warning;
      case 'urgent':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _priorityIcon(String p) {
    switch (p) {
      case 'high':
        return Icons.priority_high_rounded;
      case 'urgent':
        return Icons.warning_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Future<void> _sendNotice() async {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in title and message'),
            backgroundColor: Colors.orange),
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
            style: const TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
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
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  size: 72, color: AppColors.success),
            ),
            const SizedBox(height: 24),
            const Text('Notice Sent!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Send Another',
                    style: TextStyle(fontWeight: FontWeight.w700)),
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.group_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('To: ${widget.target}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Priority selector
          const Text('Priority',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 10),
          Row(
            children: _priorities.map((p) {
              final selected = _priority == p;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? _priorityColor(p).withValues(alpha: 0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? _priorityColor(p) : Colors.grey[300]!,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_priorityIcon(p),
                            size: 14,
                            color: selected
                                ? _priorityColor(p)
                                : AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(p[0].toUpperCase() + p.substring(1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: selected
                                  ? _priorityColor(p)
                                  : AppColors.textMid,
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
          const Text('Title *',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'e.g. Holiday Notice, Fee Reminder...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Message
          const Text('Message *',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Write your notice here...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2)),
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
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded),
              label: Text(_isSending ? 'Sending...' : 'Send Notice',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.adminAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
      if (!mounted) return;
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
    final success =
        await _db.rejectFeedback(feedback.id, 'admin_001', 'Not appropriate');
    if (success) {
      if (!mounted) return;
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              categoryLabel:
                                  _getCategoryLabel(feedback.category),
                              categoryColor:
                                  _getCategoryColor(feedback.category),
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
                child: Icon(Icons.feedback_outlined,
                    color: categoryColor, size: 18),
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
              const Icon(Icons.access_time, size: 14, color: AppColors.textLight),
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

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.adminAccent.withValues(alpha: 0.1),
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
