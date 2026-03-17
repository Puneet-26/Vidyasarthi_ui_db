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
    BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    BottomNavItem(icon: Icons.class_outlined, activeIcon: Icons.class_rounded, label: 'Classes'),
    BottomNavItem(icon: Icons.fact_check_outlined, activeIcon: Icons.fact_check_rounded, label: 'Attendance'),
    BottomNavItem(icon: Icons.assessment_outlined, activeIcon: Icons.assessment_rounded, label: 'Marks'),
    BottomNavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded, label: 'Activities'),
    BottomNavItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle_rounded, label: 'Profile'),
  ];

  List<Widget> get _pages => [
    const _TeacherHomePage(),
    const _TeacherClassesPage(),
    const _TeacherAttendancePage(),
    const _TeacherMarksPage(),
    const _TeacherMessagesPage(),
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
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: AppColors.teacherAccent.withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.account_circle_rounded, color: AppColors.teacherAccent, size: 40),
            ),
            const SizedBox(height: 12),
            const Text('Mrs. Priya Nair',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.teacherAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('TEACHER',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teacherAccent)),
            ),
            const SizedBox(height: 24),
            _TeacherProfileInfoRow(icon: Icons.email_outlined, label: 'Email', value: 'priya.nair@vidyasarathi.edu'),
            const Divider(color: AppColors.divider, height: 24),
            _TeacherProfileInfoRow(icon: Icons.phone_outlined, label: 'Phone', value: '+91 98765 12345'),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
          if (i == 5) {
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
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              const DashboardHeader(
                name: 'Mrs. Priya Nair',
                role: 'TEACHER',
                subtitle: 'Good Morning 🌟',
                roleColor: AppColors.teacherAccent,
                notificationCount: 5,
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 14),
              _QuickActionsGrid(),
              const SizedBox(height: 24),

              // Stats
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 52) / 2,
                    child: const StatCard(
                      title: 'My Classes',
                      value: '6',
                      icon: Icons.class_rounded,
                      color: AppColors.teacherAccent,
                      subtitle: 'This semester',
                    ),
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 52) / 2,
                    child: const StatCard(
                      title: 'Total Students',
                      value: '184',
                      icon: Icons.groups_rounded,
                      color: AppColors.primary,
                      subtitle: 'Across all classes',
                    ),
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 52) / 2,
                    child: const StatCard(
                      title: "Today's Classes",
                      value: '4',
                      icon: Icons.schedule_rounded,
                      color: AppColors.success,
                      subtitle: '2 remaining',
                    ),
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 52) / 2,
                    child: const StatCard(
                      title: 'Pending Marks',
                      value: '12',
                      icon: Icons.pending_rounded,
                      color: AppColors.warning,
                      subtitle: 'Need entry',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Today's Schedule
              const SectionHeader(title: "Today's Schedule", action: 'Full Timetable'),
              const SizedBox(height: 14),
              _TeacherSchedule(),
              const SizedBox(height: 24),

              // Class Performance Overview
              const SectionHeader(title: 'Class Performance', action: 'Details'),
              const SizedBox(height: 14),
              _ClassPerformanceList(),
              const SizedBox(height: 24),

              // Attendance Summary
              const SectionHeader(title: 'Attendance Summary', action: 'Mark Today'),
              const SizedBox(height: 14),
              _AttendanceSummaryCard(),
              const SizedBox(height: 24),

              // Recent Student Activity
              const SectionHeader(title: 'Recent Submissions', action: 'View All'),
              const SizedBox(height: 14),
              const _SubmissionItem(
                student: 'Aryan Sharma',
                assignment: 'Math - Chapter 5',
                time: '10 min ago',
                isLate: false,
              ),
              const SizedBox(height: 8),
              const _SubmissionItem(
                student: 'Sneha Patel',
                assignment: 'Science Lab Report',
                time: '1 hour ago',
                isLate: true,
              ),
              const SizedBox(height: 8),
              const _SubmissionItem(
                student: 'Rohan Mehta',
                assignment: 'English Essay',
                time: '2 hours ago',
                isLate: false,
              ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'My Classes'),
          const SizedBox(height: 12),
          _ClassCard(batch: 'Class 10-A', subject: 'Physics', students: 40, room: 'Room 101', time: 'Mon/Tue 9–10 AM'),
          const SizedBox(height: 10),
          _ClassCard(batch: 'Class 10-B', subject: 'Physics', students: 38, room: 'Room 201', time: 'Tue 10–11 AM'),
          const SizedBox(height: 10),
          _ClassCard(batch: 'Class 11-A', subject: 'Physics', students: 35, room: 'Room 301', time: 'Wed 11 AM–12 PM'),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Upcoming Homework'),
          const SizedBox(height: 12),
          _HomeworkCard(title: 'Laws of Motion Problems', batch: 'Class 10-A', due: 'Due in 3 days'),
          const SizedBox(height: 10),
          _HomeworkCard(title: 'Kinematics Assignment', batch: 'Class 10-B', due: 'Overdue'),
          const SizedBox(height: 30),
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
  const _ClassCard({required this.batch, required this.subject, required this.students, required this.room, required this.time});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.teacherAccent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.class_rounded, color: AppColors.teacherAccent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(batch, style: TextStyle(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Text('$subject • $room', style: TextStyle(fontSize: Responsive.sp(context, 12), color: AppColors.textMid)),
                Text(time, style: TextStyle(fontSize: Responsive.sp(context, 11), color: AppColors.textLight)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('$students', style: TextStyle(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  final String title;
  final String batch;
  final String due;
  const _HomeworkCard({required this.title, required this.batch, required this.due});
  @override
  Widget build(BuildContext context) {
    final isOverdue = due.toLowerCase().contains('overdue');
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.assignment_rounded, color: isOverdue ? AppColors.error : AppColors.teacherAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(batch, style: TextStyle(fontSize: Responsive.sp(context, 11), color: AppColors.textMid)),
              ],
            ),
          ),
          Text(due, style: TextStyle(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w600, color: isOverdue ? AppColors.error : AppColors.textLight)),
        ],
      ),
    );
  }
}

class _TeacherAttendancePage extends StatelessWidget {
  const _TeacherAttendancePage();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Mark Attendance'),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Class', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 12),
                _AttendanceClassTile(batch: 'Class 10-A', status: 'Marked', present: 38, total: 40),
                const Divider(height: 20),
                _AttendanceClassTile(batch: 'Class 10-B', status: 'Pending', present: 0, total: 38),
                const Divider(height: 20),
                _AttendanceClassTile(batch: 'Class 11-A', status: 'Pending', present: 0, total: 35),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Summary - Today'),
          const SizedBox(height: 12),
          const GlassCard(
            child: Column(
              children: [
                LabeledProgressBar(label: 'Class 10-A (38/40)', value: 0.95, color: AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: 30),
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
  const _AttendanceClassTile({required this.batch, required this.status, required this.present, required this.total});
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
              Text(batch, style: TextStyle(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: AppColors.textDark)),
              Text(isDone ? 'Present: $present / $total' : 'Not yet marked', style: TextStyle(fontSize: Responsive.sp(context, 11), color: AppColors.textMid)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: (isDone ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Test Results Entry'),
          const SizedBox(height: 12),
          _MarksTestCard(title: 'Unit Test 1 - Laws of Motion', batch: 'Class 10-A', status: 'Graded'),
          const SizedBox(height: 10),
          _MarksTestCard(title: 'Unit Test 1 - Atomic Structure', batch: 'Class 10-B', status: 'Pending'),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Scheduled Tests'),
          const SizedBox(height: 12),
          _MarksTestCard(title: 'Mid-Term Physics Exam', batch: 'Class 10-A', status: 'Upcoming'),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _MarksTestCard extends StatelessWidget {
  final String title;
  final String batch;
  final String status;
  const _MarksTestCard({required this.title, required this.batch, required this.status});
  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Graded' ? AppColors.success : status == 'Upcoming' ? AppColors.info : AppColors.warning;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.quiz_rounded, color: AppColors.teacherAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(batch, style: TextStyle(fontSize: Responsive.sp(context, 11), color: AppColors.textMid)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w600, color: statusColor)),
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
          const SectionHeader(title: 'Notices & Announcements'),
          const SizedBox(height: 12),
          _NoticeCard(title: 'VidyaSarathi Platform Launch!', from: 'Admin', time: '2 days ago', priority: 'high'),
          const SizedBox(height: 10),
          _NoticeCard(title: 'Staff Meeting - Training Update', from: 'Admin', time: '3 days ago', priority: 'normal'),
          const SizedBox(height: 10),
          _NoticeCard(title: 'Holiday Notice - Holi', from: 'Admin', time: '5 days ago', priority: 'normal'),
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
  const _NoticeCard({required this.title, required this.from, required this.time, required this.priority});
  @override
  Widget build(BuildContext context) {
    final isHigh = priority == 'high';
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(isHigh ? Icons.priority_high_rounded : Icons.notifications_rounded,
              color: isHigh ? AppColors.error : AppColors.teacherAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text('From $from • $time', style: TextStyle(fontSize: Responsive.sp(context, 11), color: AppColors.textMid)),
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
    {'label': 'Mark\nAttendance', 'icon': Icons.how_to_reg_rounded, 'color': AppColors.success, 'screen': 0},
    {'label': 'Upload\nAssignment', 'icon': Icons.upload_file_rounded, 'color': AppColors.teacherAccent, 'screen': 1},
    {'label': 'Enter\nMarks', 'icon': Icons.edit_note_rounded, 'color': AppColors.warning, 'screen': 2},
    {'label': 'Send\nNotice', 'icon': Icons.campaign_rounded, 'color': AppColors.error, 'screen': 3},
    {'label': 'Schedule\nTest', 'icon': Icons.quiz_rounded, 'color': AppColors.primary, 'screen': 4},
    {'label': 'Student\nReports', 'icon': Icons.analytics_rounded, 'color': AppColors.info, 'screen': 5},
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
    {'time': '09:00 AM', 'class': 'Class 8-A', 'subject': 'Mathematics', 'room': 'Room 204', 'status': 'done'},
    {'time': '10:30 AM', 'class': 'Class 9-B', 'subject': 'Mathematics', 'room': 'Room 301', 'status': 'current'},
    {'time': '12:30 PM', 'class': 'Class 7-C', 'subject': 'Mathematics', 'room': 'Room 105', 'status': 'upcoming'},
    {'time': '02:00 PM', 'class': 'Class 10-A', 'subject': 'Mathematics', 'room': 'Room 204', 'status': 'upcoming'},
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          LabeledProgressBar(label: 'Class 8-A  (32 students)', value: 0.82, color: AppColors.success),
          SizedBox(height: 14),
          LabeledProgressBar(label: 'Class 9-B  (38 students)', value: 0.74, color: AppColors.teacherAccent),
          SizedBox(height: 14),
          LabeledProgressBar(label: 'Class 7-C  (35 students)', value: 0.68, color: AppColors.warning),
          SizedBox(height: 14),
          LabeledProgressBar(label: 'Class 10-A (40 students)', value: 0.88, color: AppColors.primary),
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
                child: _AttendanceStat(label: 'Present', value: '162', color: AppColors.success),
              ),
              Container(width: 1, height: 48, color: AppColors.divider),
              const Expanded(
                child: _AttendanceStat(label: 'Absent', value: '18', color: AppColors.error),
              ),
              Container(width: 1, height: 48, color: AppColors.divider),
              const Expanded(
                child: _AttendanceStat(label: 'Leave', value: '4', color: AppColors.warning),
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
            initials: student.substring(0, 2),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

  const _TeacherProfileInfoRow({required this.icon, required this.label, required this.value});

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
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
