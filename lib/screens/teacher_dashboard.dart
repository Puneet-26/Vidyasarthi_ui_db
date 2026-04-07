import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'login_screen.dart';
import 'placeholder_screens.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;

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
        const _TeacherHomePage(),
        const _TeacherClassesPage(),
      ];

  void _showProfileSheet(BuildContext context) {
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
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                      color: AppColors.teacherAccent.withOpacity(0.12),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.account_circle_rounded,
                      color: AppColors.teacherAccent, size: 40),
                ),
                const SizedBox(height: 12),
                const Text('Mrs. Priya Nair',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.teacherAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('TEACHER',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teacherAccent)),
                ),
                const SizedBox(height: 24),
                const _TeacherProfileInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'priya.nair@vidyasarathi.edu'),
                const Divider(color: AppColors.divider, height: 24),
                const _TeacherProfileInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: '+91 98765 12345'),
                const SizedBox(height: 24),
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

class _TeacherHomePage extends StatelessWidget {
  const _TeacherHomePage();

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
                const Text('Notices & Announcements',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 16),
                const _NoticeCard(
                    title: 'VidyaSarathi Platform Launch!',
                    from: 'Admin',
                    time: '2 days ago',
                    priority: 'high'),
                const SizedBox(height: 10),
                const _NoticeCard(
                    title: 'Staff Meeting - Training Update',
                    from: 'Admin',
                    time: '3 days ago',
                    priority: 'normal'),
                const SizedBox(height: 10),
                const _NoticeCard(
                    title: 'Holiday Notice - Holi',
                    from: 'Admin',
                    time: '5 days ago',
                    priority: 'normal'),
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
            name: 'Mrs. Priya Nair',
            role: 'TEACHER',
            subtitle: 'Teacher Dashboard',
            roleColor: AppColors.teacherAccent,
            notificationCount: 5,
            onNotification: () => _showNoticesSheet(context),
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 24),

          // Today's Schedule
          const SectionHeader(title: "Today's Schedule"),
          const SizedBox(height: 14),
          _TeacherSchedule(),
          const SizedBox(height: 24),

          // Attendance Summary
          const SectionHeader(title: 'Attendance Summary'),
          const SizedBox(height: 14),
          _AttendanceSummaryCard(),
          const SizedBox(height: 24),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _TeacherClassesPage extends StatelessWidget {
  const _TeacherClassesPage();
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'My Classes'),
          SizedBox(height: 12),
          _ClassCard(
              batch: 'Class 10-A',
              subject: 'Chemistry',
              students: 40,
              room: 'Room 101',
              time: 'Mon/Tue 9–10 AM',
              attendanceStatus: 'Marked',
              present: 38),
          SizedBox(height: 10),
          _ClassCard(
              batch: 'Class 10-B',
              subject: 'Chemistry',
              students: 38,
              room: 'Room 201',
              time: 'Tue 10–11 AM',
              attendanceStatus: 'Pending',
              present: 0),
          SizedBox(height: 10),
          _ClassCard(
              batch: 'Class 11-A',
              subject: 'Chemistry',
              students: 35,
              room: 'Room 301',
              time: 'Wed 11 AM–12 PM',
              attendanceStatus: 'Pending',
              present: 0),
          SizedBox(height: 30),
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

class _HomeworkCard extends StatelessWidget {
  final String title;
  final String batch;
  final String due;
  const _HomeworkCard(
      {required this.title, required this.batch, required this.due});
  @override
  Widget build(BuildContext context) {
    final isOverdue = due.toLowerCase().contains('overdue');
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.assignment_rounded,
              color: isOverdue ? AppColors.error : AppColors.teacherAccent,
              size: 24),
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
          Text(due,
              style: TextStyle(
                  fontSize: Responsive.sp(context, 11),
                  fontWeight: FontWeight.w600,
                  color: isOverdue ? AppColors.error : AppColors.textLight)),
        ],
      ),
    );
  }
}

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
    _tabController = TabController(length: 2, vsync: this);
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
  // 0 = mark today, 1 = view history
  int _view = 0;
  DateTime _selectedDate = DateTime.now();

  // Sample student roster
  late List<Map<String, dynamic>> _students;

  // Sample history: date string -> map of studentId -> bool
  final Map<String, Map<String, bool>> _history = {};

  @override
  void initState() {
    super.initState();
    _students = [
      {'id': 'S001', 'name': 'Aryan Sharma', 'present': false},
      {'id': 'S002', 'name': 'Sneha Patel', 'present': false},
      {'id': 'S003', 'name': 'Rohan Mehta', 'present': false},
      {'id': 'S004', 'name': 'Priya Iyer', 'present': false},
      {'id': 'S005', 'name': 'Karan Singh', 'present': false},
      {'id': 'S006', 'name': 'Ananya Nair', 'present': false},
      {'id': 'S007', 'name': 'Vikram Rao', 'present': false},
      {'id': 'S008', 'name': 'Divya Menon', 'present': false},
    ];
    // Dummy history data
    final now = DateTime.now();
    _history[_dateKey(now.subtract(const Duration(days: 1)))] = {
      'S001': true,
      'S002': true,
      'S003': false,
      'S004': true,
      'S005': true,
      'S006': false,
      'S007': true,
      'S008': true,
    };
    _history[_dateKey(now.subtract(const Duration(days: 2)))] = {
      'S001': true,
      'S002': false,
      'S003': true,
      'S004': true,
      'S005': false,
      'S006': true,
      'S007': true,
      'S008': false,
    };
    _history[_dateKey(now.subtract(const Duration(days: 3)))] = {
      'S001': true,
      'S002': true,
      'S003': true,
      'S004': false,
      'S005': true,
      'S006': true,
      'S007': false,
      'S008': true,
    };
    _history[_dateKey(now.subtract(const Duration(days: 5)))] = {
      'S001': false,
      'S002': true,
      'S003': true,
      'S004': true,
      'S005': true,
      'S006': true,
      'S007': true,
      'S008': true,
    };
    _history[_dateKey(now.subtract(const Duration(days: 6)))] = {
      'S001': true,
      'S002': true,
      'S003': false,
      'S004': false,
      'S005': true,
      'S006': true,
      'S007': true,
      'S008': true,
    };
    _history[_dateKey(now.subtract(const Duration(days: 8)))] = {
      'S001': true,
      'S002': true,
      'S003': true,
      'S004': true,
      'S005': false,
      'S006': false,
      'S007': true,
      'S008': true,
    };
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int get _presentCount => _students.where((s) => s['present'] == true).length;

  void _saveToday() {
    final key = _dateKey(DateTime.now());
    setState(() {
      _history[key] = {
        for (var s in _students) s['id'] as String: s['present'] as bool
      };
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Attendance saved successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.teacherAccent.withOpacity(0.08),
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
                    onTap: () => setState(() => _view = 1)),
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
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final s = _students[i];
              final isPresent = s['present'] as bool;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPresent
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.teacherAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(s['id'] as String,
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
                    GestureDetector(
                      onTap: () =>
                          setState(() => _students[i]['present'] = !isPresent),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPresent
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPresent ? 'Present' : 'Absent',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color:
                                isPresent ? AppColors.success : AppColors.error,
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
              onPressed: _saveToday,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save Attendance'),
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
    final dayRecord = _history[key];
    final isToday = _dateKey(_selectedDate) == _dateKey(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple date picker row
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
                  onTap: () => setState(() => _selectedDate = date),
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
          if (isToday && dayRecord == null)
            const GlassCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Today's attendance not saved yet.",
                      style:
                          TextStyle(color: AppColors.textLight, fontSize: 13)),
                ),
              ),
            )
          else if (dayRecord == null)
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
                    value: '${dayRecord.values.where((v) => v).length}',
                    color: AppColors.success),
                const SizedBox(width: 10),
                _MiniStat(
                    label: 'Absent',
                    value: '${dayRecord.values.where((v) => !v).length}',
                    color: AppColors.error),
              ],
            ),
            const SizedBox(height: 12),
            ...dayRecord.entries.map((e) {
              final student = _students.firstWhere((s) => s['id'] == e.key,
                  orElse: () => {'id': e.key, 'name': 'Unknown'});
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: e.value
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.teacherAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(e.key,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.teacherAccent)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(student['name'] as String,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: e.value
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          e.value ? 'Present' : 'Absent',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: e.value
                                  ? AppColors.success
                                  : AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 80),
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
        color: color.withOpacity(0.08),
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

// ─── Test model ───────────────────────────────────────────────────────────────
class _TestEntry {
  String title;
  int maxMarks;
  String status; // 'Upcoming', 'Pending', 'Graded'
  Map<String, int?> studentMarks; // studentId -> marks (null = not entered)

  _TestEntry(
      {required this.title,
      required this.maxMarks,
      required this.status,
      required this.studentMarks});
}

class _ClassMarksTab extends StatefulWidget {
  final String batch;
  const _ClassMarksTab({required this.batch});

  @override
  State<_ClassMarksTab> createState() => _ClassMarksTabState();
}

class _ClassMarksTabState extends State<_ClassMarksTab> {
  late List<_TestEntry> _tests;

  final List<Map<String, String>> _students = const [
    {'id': 'S001', 'name': 'Aryan Sharma'},
    {'id': 'S002', 'name': 'Sneha Patel'},
    {'id': 'S003', 'name': 'Rohan Mehta'},
    {'id': 'S004', 'name': 'Priya Iyer'},
    {'id': 'S005', 'name': 'Karan Singh'},
    {'id': 'S006', 'name': 'Ananya Nair'},
    {'id': 'S007', 'name': 'Vikram Rao'},
    {'id': 'S008', 'name': 'Divya Menon'},
  ];

  @override
  void initState() {
    super.initState();
    _tests = [
      _TestEntry(
        title: 'Unit Test 1 - Laws of Motion',
        maxMarks: 25,
        status: 'Graded',
        studentMarks: {
          'S001': 22,
          'S002': 19,
          'S003': 23,
          'S004': 17,
          'S005': 21,
          'S006': 24,
          'S007': 18,
          'S008': 20
        },
      ),
      _TestEntry(
        title: 'Unit Test 2 - Atomic Structure',
        maxMarks: 25,
        status: 'Pending',
        studentMarks: {
          for (var s in [
            'S001',
            'S002',
            'S003',
            'S004',
            'S005',
            'S006',
            'S007',
            'S008'
          ])
            s: null
        },
      ),
      _TestEntry(
        title: 'Mid-Term Physics Exam',
        maxMarks: 50,
        status: 'Upcoming',
        studentMarks: {
          for (var s in [
            'S001',
            'S002',
            'S003',
            'S004',
            'S005',
            'S006',
            'S007',
            'S008'
          ])
            s: null
        },
      ),
    ];
  }

  void _showScheduleDialog() {
    final titleCtrl = TextEditingController();
    final maxCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Schedule New Test',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Test Title',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: maxCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Max Marks',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final max = int.tryParse(maxCtrl.text.trim()) ?? 0;
              if (title.isNotEmpty && max > 0) {
                setState(() {
                  _tests.add(_TestEntry(
                    title: title,
                    maxMarks: max,
                    status: 'Upcoming',
                    studentMarks: {for (var s in _students) s['id']!: null},
                  ));
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teacherAccent,
                foregroundColor: Colors.white),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _openGrading(_TestEntry test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GradeStudentsPage(
            test: test, students: _students, onSaved: () => setState(() {})),
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
          Row(
            children: [
              const Expanded(child: SectionHeader(title: 'Tests')),
              GestureDetector(
                onTap: _showScheduleDialog,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.teacherAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Schedule',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._tests.map((test) {
            Color statusColor = test.status == 'Graded'
                ? AppColors.success
                : test.status == 'Upcoming'
                    ? AppColors.info
                    : AppColors.warning;
            final gradedCount =
                test.studentMarks.values.where((v) => v != null).length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap:
                    test.status == 'Upcoming' ? null : () => _openGrading(test),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.quiz_rounded,
                            color: statusColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(test.title,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark)),
                            Text(
                                'Max: ${test.maxMarks} marks${test.status != 'Upcoming' ? ' • $gradedCount/${_students.length} graded' : ''}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMid)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(test.status,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor)),
                          ),
                          if (test.status != 'Upcoming') ...[
                            const SizedBox(height: 4),
                            const Text('Tap to grade',
                                style: TextStyle(
                                    fontSize: 10, color: AppColors.textLight)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _GradeStudentsPage extends StatefulWidget {
  final _TestEntry test;
  final List<Map<String, String>> students;
  final VoidCallback onSaved;

  const _GradeStudentsPage(
      {required this.test, required this.students, required this.onSaved});

  @override
  State<_GradeStudentsPage> createState() => _GradeStudentsPageState();
}

class _GradeStudentsPageState extends State<_GradeStudentsPage> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (var s in widget.students)
        s['id']!: TextEditingController(
          text: widget.test.studentMarks[s['id']] != null
              ? '${widget.test.studentMarks[s['id']]}'
              : '',
        )
    };
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    bool hasError = false;
    for (var s in widget.students) {
      final val = int.tryParse(_controllers[s['id']]!.text.trim());
      if (_controllers[s['id']]!.text.trim().isNotEmpty) {
        if (val == null || val < 0 || val > widget.test.maxMarks) {
          hasError = true;
          break;
        }
        widget.test.studentMarks[s['id']!] = val;
      }
    }
    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Marks must be between 0 and ${widget.test.maxMarks}'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    final allGraded = widget.test.studentMarks.values.every((v) => v != null);
    widget.test.status = allGraded ? 'Graded' : 'Pending';
    widget.onSaved();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Marks saved successfully'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    Navigator.pop(context);
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
            Text(widget.test.title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            Text('Max Marks: ${widget.test.maxMarks}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: widget.students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final s = widget.students[i];
                final ctrl = _controllers[s['id']]!;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.teacherAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(s['id']!,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.teacherAccent)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(s['name']!,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                      ),
                      SizedBox(
                        width: 72,
                        child: TextField(
                          controller: ctrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark),
                          decoration: InputDecoration(
                            hintText: '—',
                            hintStyle:
                                const TextStyle(color: AppColors.textLight),
                            suffixText: '/${widget.test.maxMarks}',
                            suffixStyle: const TextStyle(
                                fontSize: 11, color: AppColors.textLight),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: AppColors.divider),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: AppColors.teacherAccent),
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
                onPressed: _save,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save Marks'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teacherAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
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
          SectionHeader(title: 'Mark Attendance'),
          SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Class',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                SizedBox(height: 12),
                _AttendanceClassTile(
                    batch: 'Class 10-A',
                    status: 'Marked',
                    present: 38,
                    total: 40),
                Divider(height: 20),
                _AttendanceClassTile(
                    batch: 'Class 10-B',
                    status: 'Pending',
                    present: 0,
                    total: 38),
                Divider(height: 20),
                _AttendanceClassTile(
                    batch: 'Class 11-A',
                    status: 'Pending',
                    present: 0,
                    total: 35),
              ],
            ),
          ),
          SizedBox(height: 24),
          SectionHeader(title: 'Summary - Today'),
          SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                LabeledProgressBar(
                    label: 'Class 10-A (38/40)',
                    value: 0.95,
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

class _AttendanceClassTile extends StatelessWidget {
  final String batch;
  final String status;
  final int present;
  final int total;
  const _AttendanceClassTile(
      {required this.batch,
      required this.status,
      required this.present,
      required this.total});
  @override
  Widget build(BuildContext context) {
    final isDone = status == 'Marked';
    return Row(
      children: [
        Icon(isDone ? Icons.check_circle_rounded : Icons.pending_rounded,
            color: isDone ? AppColors.success : AppColors.warning, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(batch,
                  style: TextStyle(
                      fontSize: Responsive.sp(context, 13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              Text(isDone ? 'Present: $present / $total' : 'Not yet marked',
                  style: TextStyle(
                      fontSize: Responsive.sp(context, 11),
                      color: AppColors.textMid)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: (isDone ? AppColors.success : AppColors.warning)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDone ? AppColors.success : AppColors.warning)),
        ),
      ],
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
          SectionHeader(title: 'Test Results Entry'),
          SizedBox(height: 12),
          _MarksTestCard(
              title: 'Unit Test 1 - Laws of Motion',
              batch: 'Class 10-A',
              status: 'Graded'),
          SizedBox(height: 10),
          _MarksTestCard(
              title: 'Unit Test 1 - Atomic Structure',
              batch: 'Class 10-B',
              status: 'Pending'),
          SizedBox(height: 24),
          SectionHeader(title: 'Scheduled Tests'),
          SizedBox(height: 12),
          _MarksTestCard(
              title: 'Mid-Term Physics Exam',
              batch: 'Class 10-A',
              status: 'Upcoming'),
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
  const _TeacherMessagesPage();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 14),
          _QuickActionsGrid(),
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
                    color: color.withOpacity(0.12),
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
    final List<Widget> screens = [
      const TimetableManagementScreen(), // Mark Attendance
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
  final List<Map<String, String>> schedule = const [
    {
      'time': '09:00 AM',
      'class': 'Class 8-A',
      'subject': 'Chemistry',
      'room': 'Room 204',
      'status': 'done'
    },
    {
      'time': '10:30 AM',
      'class': 'Class 9-B',
      'subject': 'Chemistry',
      'room': 'Room 301',
      'status': 'current'
    },
    {
      'time': '12:30 PM',
      'class': 'Class 7-C',
      'subject': 'Chemistry',
      'room': 'Room 105',
      'status': 'upcoming'
    },
    {
      'time': '02:00 PM',
      'class': 'Class 10-A',
      'subject': 'Chemistry',
      'room': 'Room 204',
      'status': 'upcoming'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: schedule.map((s) {
        Color statusColor;
        String statusLabel;
        switch (s['status']) {
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
            color: s['status'] == 'current'
                ? AppColors.success.withOpacity(0.08)
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
                    color: statusColor.withOpacity(0.12),
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

class _AttendanceSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _AttendanceStat(
                    label: 'Present', value: '162', color: AppColors.success),
              ),
              Container(width: 1, height: 48, color: AppColors.divider),
              const Expanded(
                child: _AttendanceStat(
                    label: 'Absent', value: '18', color: AppColors.error),
              ),
              Container(width: 1, height: 48, color: AppColors.divider),
              const Expanded(
                child: _AttendanceStat(
                    label: 'Leave', value: '4', color: AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  flex: 162,
                  child: Container(height: 10, color: AppColors.success),
                ),
                Expanded(
                  flex: 18,
                  child: Container(height: 10, color: AppColors.error),
                ),
                Expanded(
                  flex: 4,
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
                    color: AppColors.error.withOpacity(0.1),
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
            color: AppColors.teacherAccent.withOpacity(0.1),
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
