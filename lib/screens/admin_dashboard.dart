import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.adminAccent.withOpacity(0.12),
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
                    color: AppColors.adminAccent.withOpacity(0.12),
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
          const SectionHeader(title: 'Pending Actions', action: 'Resolve All'),
          const SizedBox(height: 14),
          _PendingAlerts(),
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

class _ActivitiesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Recent Activities'),
          SizedBox(height: 14),
          _ActivityItem(
            title: 'New Teacher Onboarded',
            desc: 'Ms. Kavita Singh joined as Science teacher for Class 7',
            time: '1 hour ago',
            icon: Icons.person_add_rounded,
            color: AppColors.success,
          ),
          SizedBox(height: 8),
          _ActivityItem(
            title: 'Fee Reminder Sent',
            desc: '45 parents notified for pending Q4 fees',
            time: '3 hours ago',
            icon: Icons.send_rounded,
            color: AppColors.warning,
          ),
          SizedBox(height: 8),
          _ActivityItem(
            title: 'Timetable Updated',
            desc: 'Class 10-A timetable revised for exam preparation',
            time: '2 days ago',
            icon: Icons.schedule_rounded,
            color: AppColors.adminAccent,
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ============================================================
//  NEW COMPREHENSIVE ADMIN TABS
// ============================================================

class _StudentsTab extends StatelessWidget {
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
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => _AddStudentScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.list_alt_rounded,
                  label: 'View All',
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => _AllStudentsScreen())),
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
                  color: AppColors.info,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => _SendNoticeScreen())),
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

          // Recent Students
          const SectionHeader(title: 'Recent Admissions'),
          const SizedBox(height: 14),
          const _StudentListItem(
              name: 'Aryan Sharma',
              batch: 'Class 10-A',
              status: 'Active',
              statusColor: AppColors.success),
          const SizedBox(height: 8),
          const _StudentListItem(
              name: 'Priya Patel',
              batch: 'Class 9-B',
              status: 'Active',
              statusColor: AppColors.success),
          const SizedBox(height: 8),
          const _StudentListItem(
              name: 'Rohan Mehta',
              batch: 'Class 11-C',
              status: 'Pending',
              statusColor: AppColors.warning),

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
                      MaterialPageRoute(builder: (_) => _SendNoticeScreen())),
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

class _StaffTab extends StatelessWidget {
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

          // Pending Tasks
          const SectionHeader(title: 'Pending Tasks'),
          const SizedBox(height: 14),
          const GlassCard(
            child: Column(
              children: [
                _PendingTaskItem(
                  title: 'Admission Applications',
                  count: '7',
                  icon: Icons.person_add_rounded,
                  color: AppColors.primary,
                ),
                Divider(color: AppColors.divider, height: 20),
                _PendingTaskItem(
                  title: 'Fee Reminders',
                  count: '14',
                  icon: Icons.notifications_rounded,
                  color: AppColors.warning,
                ),
                Divider(color: AppColors.divider, height: 20),
                _PendingTaskItem(
                  title: 'Timetable Conflicts',
                  count: '2',
                  icon: Icons.warning_rounded,
                  color: AppColors.error,
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

class _ParentsTab extends StatelessWidget {
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
                      MaterialPageRoute(builder: (_) => _SendNoticeScreen())),
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

class _AddStudentScreen extends StatelessWidget {
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
        title: const Text('Add New Student',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GlassCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.person_add_rounded,
                          size: 64, color: AppColors.primary),
                      SizedBox(height: 16),
                      Text('Student Registration Form',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      SizedBox(height: 8),
                      Text('Coming soon...',
                          style: TextStyle(color: AppColors.textLight)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllStudentsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> students = const [
    {
      'name': 'Aryan Sharma',
      'batch': 'Class 10-A',
      'status': 'Active',
      'attendance': '94%'
    },
    {
      'name': 'Priya Patel',
      'batch': 'Class 9-B',
      'status': 'Active',
      'attendance': '96%'
    },
    {
      'name': 'Rohan Mehta',
      'batch': 'Class 11-C',
      'status': 'Active',
      'attendance': '89%'
    },
    {
      'name': 'Sneha Iyer',
      'batch': 'Class 10-A',
      'status': 'Active',
      'attendance': '92%'
    },
    {
      'name': 'Karan Singh',
      'batch': 'Class 12-A',
      'status': 'Active',
      'attendance': '97%'
    },
    {
      'name': 'Ananya Nair',
      'batch': 'Class 9-A',
      'status': 'Active',
      'attendance': '91%'
    },
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
        title: const Text('All Students',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final student = students[i];
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
                      Text(student['name'] as String,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      Text('${student['batch']} • ${student['attendance']}',
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

class _AddTeacherScreen extends StatelessWidget {
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
        title: const Text('Add New Teacher',
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
                  Icon(Icons.person_add_rounded,
                      size: 64, color: AppColors.teacherAccent),
                  SizedBox(height: 16),
                  Text('Teacher Registration Form',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  SizedBox(height: 8),
                  Text('Coming soon...',
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

class _AllTeachersScreen extends StatelessWidget {
  final List<Map<String, dynamic>> teachers = const [
    {'name': 'Mrs. Priya Nair', 'subject': 'Physics', 'classes': '3 Classes'},
    {
      'name': 'Mr. Arun Kumar',
      'subject': 'Mathematics',
      'classes': '4 Classes'
    },
    {'name': 'Dr. Meena Verma', 'subject': 'Chemistry', 'classes': '3 Classes'},
    {'name': 'Mrs. Sunita Rao', 'subject': 'English', 'classes': '5 Classes'},
    {'name': 'Mr. Vikram Singh', 'subject': 'History', 'classes': '3 Classes'},
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
        title: const Text('All Teachers',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: teachers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final teacher = teachers[i];
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
                      Text(teacher['name'] as String,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      Text('${teacher['subject']} • ${teacher['classes']}',
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

class _AdminAdmissionsScreen extends StatelessWidget {
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
        title: const Text('Admissions',
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
                  Icon(Icons.person_add_rounded,
                      size: 64, color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Admission Management',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  SizedBox(height: 8),
                  Text('View and manage all admission applications',
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

class _AdminTimetableScreen extends StatelessWidget {
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
        title: const Text('Timetable',
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
                  Icon(Icons.schedule_rounded, size: 64, color: AppColors.info),
                  SizedBox(height: 16),
                  Text('Timetable Management',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  SizedBox(height: 8),
                  Text('Create and manage class schedules',
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

class _SendNoticeScreen extends StatelessWidget {
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
        title: const Text('Send Notice',
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
                  Icon(Icons.message_rounded, size: 64, color: AppColors.info),
                  SizedBox(height: 16),
                  Text('Send Notice to Parents',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  SizedBox(height: 8),
                  Text('Compose and send notices',
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
