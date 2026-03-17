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
              child: const Icon(Icons.account_circle_rounded, color: AppColors.adminAccent, size: 40),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dr. Vijay Menon',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.adminAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.adminAccent),
              ),
            ),
            const SizedBox(height: 24),
            _ProfileInfoRow(icon: Icons.email_outlined, label: 'Email', value: 'vijay.menon@vidyasarathi.edu'),
            const Divider(color: AppColors.divider, height: 24),
            _ProfileInfoRow(icon: Icons.phone_outlined, label: 'Phone', value: '+91 98765 43210'),
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

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard'),
    BottomNavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Reports'),
    BottomNavItem(icon: Icons.history_rounded, activeIcon: Icons.history_rounded, label: 'Activities'),
    BottomNavItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      bottomNavigationBar: VidyaBottomNav(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: (i) {
          if (i == 3) {
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
            _ReportsTab(),
            _ActivitiesTab(),
          ],
        ),
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
          const DashboardHeader(
            name: 'Dr. Vijay Menon',
            role: 'ADMIN',
            subtitle: 'School Overview 🏫',
            roleColor: AppColors.adminAccent,
            notificationCount: 8,
          ),
          const SizedBox(height: 24),
          _SchoolSummaryBanner(),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Key Metrics'),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: const StatCard(
                      title: 'Total Students',
                      value: '1,248',
                      icon: Icons.school_rounded,
                      color: AppColors.primary,
                      subtitle: '+12 this month',
                    ),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: const StatCard(
                      title: 'Teaching Staff',
                      value: '84',
                      icon: Icons.person_rounded,
                      color: AppColors.teacherAccent,
                      subtitle: '6 part-time',
                    ),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: const StatCard(
                      title: "Today's Attendance",
                      value: '94%',
                      icon: Icons.how_to_reg_rounded,
                      color: AppColors.success,
                      subtitle: '1,173 present',
                    ),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: const StatCard(
                      title: 'Fee Collection',
                      value: '₹8.2L',
                      icon: Icons.account_balance_rounded,
                      color: AppColors.warning,
                      subtitle: 'March 2026',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Admin Actions'),
          const SizedBox(height: 14),
          _AdminActionsGrid(),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Department Attendance', action: 'Full Report'),
          const SizedBox(height: 14),
          const GlassCard(
            child: Column(
              children: [
                LabeledProgressBar(label: 'Primary (Std 1-5)', value: 0.96, color: AppColors.success),
                SizedBox(height: 14),
                LabeledProgressBar(label: 'Middle (Std 6-8)', value: 0.91, color: AppColors.primary),
                SizedBox(height: 14),
                LabeledProgressBar(label: 'Secondary (Std 9-10)', value: 0.88, color: AppColors.teacherAccent),
                SizedBox(height: 14),
                LabeledProgressBar(label: 'Senior (Std 11-12)', value: 0.94, color: AppColors.warning),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Fee Collection Overview', action: 'Details'),
          const SizedBox(height: 14),
          _FeeOverviewCard(),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Reports'),
          const SizedBox(height: 14),
          const GlassCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Reports coming soon', style: TextStyle(color: AppColors.textLight)),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ActivitiesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Recent Activities', action: 'View Log'),
          const SizedBox(height: 14),
          const _ActivityItem(
            title: 'New Teacher Onboarded',
            desc: 'Ms. Kavita Singh joined as Science teacher for Class 7',
            time: '1 hour ago',
            icon: Icons.person_add_rounded,
            color: AppColors.success,
          ),
          const SizedBox(height: 8),
          const _ActivityItem(
            title: 'Fee Reminder Sent',
            desc: '45 parents notified for pending Q4 fees',
            time: '3 hours ago',
            icon: Icons.send_rounded,
            color: AppColors.warning,
          ),
          const SizedBox(height: 8),
          const _ActivityItem(
            title: 'Notice Published',
            desc: 'Annual Day notice sent to all students and parents',
            time: 'Yesterday',
            icon: Icons.campaign_rounded,
            color: AppColors.info,
          ),
          const SizedBox(height: 8),
          const _ActivityItem(
            title: 'Timetable Updated',
            desc: 'Class 10-A timetable revised for exam preparation',
            time: '2 days ago',
            icon: Icons.schedule_rounded,
            color: AppColors.adminAccent,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              _BannerStat(label: 'Classes', value: '36'),
              SizedBox(width: 24),
              _BannerStat(label: 'Staff', value: '104'),
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

class _AdminActionsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> actions = const [
    {'label': 'Manage\nStudents', 'icon': Icons.school_rounded, 'color': AppColors.primary},
    {'label': 'Manage\nTeachers', 'icon': Icons.people_rounded, 'color': AppColors.teacherAccent},
    {'label': 'Fee\nManagement', 'icon': Icons.account_balance_rounded, 'color': AppColors.warning},
    {'label': 'Timetable\nBuilder', 'icon': Icons.calendar_today_rounded, 'color': AppColors.success},
    {'label': 'Send\nNotice', 'icon': Icons.campaign_rounded, 'color': AppColors.adminAccent},
    {'label': 'View\nReports', 'icon': Icons.analytics_rounded, 'color': AppColors.info},
    {'label': 'Exam\nSchedule', 'icon': Icons.quiz_rounded, 'color': AppColors.parentAccent},
    {'label': 'Library\nManage', 'icon': Icons.local_library_rounded, 'color': AppColors.primaryLight},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: actions.length,
      itemBuilder: (_, i) {
        final item = actions[i];
        final color = item['color'] as Color;
        return GlassCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                item['label'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.sp(context, 10),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeeOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹82,40,000',
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 24),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Total Collected (2025-26)',
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 12),
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),
          const LabeledProgressBar(
            label: 'Collection Target',
            value: 0.76,
            color: AppColors.success,
            trailing: '76% of ₹1.08Cr',
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: _FeeStatusChip(label: 'Fully Paid', value: '824', color: AppColors.success)),
              SizedBox(width: 8),
              Expanded(child: _FeeStatusChip(label: 'Partial', value: '312', color: AppColors.warning)),
              SizedBox(width: 8),
              Expanded(child: _FeeStatusChip(label: 'Pending', value: '112', color: AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeeStatusChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FeeStatusChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(context, 10),
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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

  const _AlertRow({required this.title, required this.priority, required this.color});

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
    {'name': 'Class 10-A', 'teacher': 'Mr. Arun Pillai', 'score': 92, 'color': AppColors.success},
    {'name': 'Class 12-S', 'teacher': 'Dr. Meena Verma', 'score': 89, 'color': AppColors.primary},
    {'name': 'Class 9-B', 'teacher': 'Mrs. Sunita Rao', 'score': 87, 'color': AppColors.teacherAccent},
    {'name': 'Class 11-C', 'teacher': 'Mr. Kiran Shah', 'score': 85, 'color': AppColors.warning},
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

  const _ProfileInfoRow({required this.icon, required this.label, required this.value});

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
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
