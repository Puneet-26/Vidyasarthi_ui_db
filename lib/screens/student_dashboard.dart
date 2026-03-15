import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'placeholder_screens.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    BottomNavItem(icon: Icons.book_outlined, activeIcon: Icons.book_rounded, label: 'Subjects'),
    BottomNavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Tasks'),
    BottomNavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Results'),
    BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  List<Widget> get _pages => [
    _StudentHomePage(),
    const _StudentSubjectsPage(),
    const _StudentTasksPage(),
    const _StudentResultsPage(),
    const _StudentProfilePage(),
  ];

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
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(
            name: 'Aryan Sharma',
            role: 'STUDENT',
            subtitle: 'Good Morning 🌸',
            roleColor: AppColors.studentAccent,
            notificationCount: 3,
          ),
              const SizedBox(height: 24),

              // Today's class banner
              _TodayClassBanner(),
              const SizedBox(height: 24),

              // Stats Row
              const Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Attendance',
                      value: '92%',
                      icon: Icons.how_to_reg_rounded,
                      color: AppColors.success,
                      subtitle: 'This month',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Avg. Grade',
                      value: 'A-',
                      icon: Icons.star_rounded,
                      color: AppColors.warning,
                      subtitle: 'Semester 2',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Pending Tasks',
                      value: '4',
                      icon: Icons.pending_actions_rounded,
                      color: AppColors.error,
                      subtitle: 'Due this week',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Rank',
                      value: '#7',
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.primary,
                      subtitle: 'Class of 40',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Subject Performance
              SectionHeader(
                title: 'Subject Performance',
                action: 'View All',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SyllabusTrackingScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),
              const GlassCard(
                child: Column(
                  children: [
                    LabeledProgressBar(label: 'Mathematics', value: 0.85, color: AppColors.primary),
                    SizedBox(height: 14),
                    LabeledProgressBar(label: 'Science', value: 0.78, color: AppColors.info),
                    SizedBox(height: 14),
                    LabeledProgressBar(label: 'English', value: 0.91, color: AppColors.success),
                    SizedBox(height: 14),
                    LabeledProgressBar(label: 'History', value: 0.65, color: AppColors.warning),
                    SizedBox(height: 14),
                    LabeledProgressBar(label: 'Computer', value: 0.95, color: AppColors.studentAccent),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Upcoming Assignments
              SectionHeader(
                title: 'Upcoming Assignments',
                action: 'See All',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeworkSystemScreen()),
                  );
                },
              ),
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

              // Timetable Today
              SectionHeader(
                title: "Today's Timetable",
                action: 'Full Week',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TimetableManagementScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),
              _TimetableList(),
              const SizedBox(height: 24),

              // Notices
              SectionHeader(
                title: 'Recent Notices',
                action: 'All',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackSystemScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),
              const _NoticeItem(
                title: 'Annual Sports Day - Registration Open',
                time: '2 hours ago',
                icon: Icons.sports_soccer_rounded,
                color: AppColors.warning,
              ),
              const SizedBox(height: 10),
              const _NoticeItem(
                title: 'PTM Scheduled for March 20th',
                time: 'Yesterday',
                icon: Icons.people_rounded,
                color: AppColors.info,
              ),
              const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ============================================================
//  STUDENT TAB PAGES
// ============================================================

class _StudentSubjectsPage extends StatelessWidget {
  const _StudentSubjectsPage();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'My Subjects'),
          const SizedBox(height: 16),
          _SubjectCard(name: 'Physics', code: 'PHY101', teacher: 'Mr. Arun Kumar', progress: 0.65, color: AppColors.primary),
          const SizedBox(height: 12),
          _SubjectCard(name: 'Chemistry', code: 'CHM101', teacher: 'Mrs. Priya Sharma', progress: 0.72, color: AppColors.info),
          const SizedBox(height: 12),
          _SubjectCard(name: 'Mathematics', code: 'MTH101', teacher: 'Mr. Vikram Singh', progress: 0.85, color: AppColors.success),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recent Syllabus'),
          const SizedBox(height: 12),
          _SyllabusTile(topic: 'Newton\'s Laws of Motion', subject: 'Physics', done: true),
          const SizedBox(height: 8),
          _SyllabusTile(topic: 'Chemical Bonding', subject: 'Chemistry', done: true),
          const SizedBox(height: 8),
          _SyllabusTile(topic: 'Differential Calculus', subject: 'Mathematics', done: false),
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
  const _SubjectCard({required this.name, required this.code, required this.teacher, required this.progress, required this.color});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.book_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    Text('$code • $teacher', style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
                  ],
                ),
              ),
              Text('${(progress * 100).round()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          LabeledProgressBar(label: 'Syllabus completed', value: progress, color: color),
        ],
      ),
    );
  }
}

class _SyllabusTile extends StatelessWidget {
  final String topic;
  final String subject;
  final bool done;
  const _SyllabusTile({required this.topic, required this.subject, required this.done});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: done ? AppColors.success : AppColors.textLight, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: done ? AppColors.textMid : AppColors.textDark,
                    decoration: done ? TextDecoration.lineThrough : null)),
                Text(subject, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (done ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(done ? 'Done' : 'Pending',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                    color: done ? AppColors.success : AppColors.warning)),
          ),
        ],
      ),
    );
  }
}

class _StudentTasksPage extends StatelessWidget {
  const _StudentTasksPage();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Pending Homework'),
          const SizedBox(height: 12),
          _TaskItem(title: 'Laws of Motion Problems', subject: 'Physics', due: 'Due in 3 days', urgent: false),
          const SizedBox(height: 10),
          _TaskItem(title: 'Chemical Bonding Worksheet', subject: 'Chemistry', due: 'Due in 5 days', urgent: false),
          const SizedBox(height: 10),
          _TaskItem(title: 'Integration Practice', subject: 'Mathematics', due: 'Due Tomorrow', urgent: true),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Upcoming Tests'),
          const SizedBox(height: 12),
          _TestItem(title: 'Mid-Term Physics Exam', date: 'Mar 28, 2026', marks: 100, color: AppColors.primary),
          const SizedBox(height: 10),
          _TestItem(title: 'Mid-Term Mathematics Exam', date: 'Apr 1, 2026', marks: 100, color: AppColors.studentAccent),
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
  const _TaskItem({required this.title, required this.subject, required this.due, required this.urgent});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 4, height: 48,
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
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(subject, style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (urgent) Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                child: const Text('URGENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.error)),
              ),
              Text(due, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
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
  const _TestItem({required this.title, required this.date, required this.marks, required this.color});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.quiz_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text('$date • $marks marks', style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text('Scheduled', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}

class _StudentResultsPage extends StatelessWidget {
  const _StudentResultsPage();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Test Results'),
          const SizedBox(height: 16),
          const GlassCard(
            child: Column(
              children: [
                LabeledProgressBar(label: 'Physics - Unit Test 1 (85/100)', value: 0.85, color: AppColors.primary),
                SizedBox(height: 14),
                LabeledProgressBar(label: 'Chemistry - Unit Test 1 (91/100)', value: 0.91, color: AppColors.info),
                SizedBox(height: 14),
                LabeledProgressBar(label: 'Mathematics - Unit Test 1 (76/100)', value: 0.76, color: AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Fee Status'),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Fees', style: TextStyle(fontSize: 14, color: AppColors.textMid)),
                    const Text('₹50,000', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Paid', style: TextStyle(fontSize: 14, color: AppColors.textMid)),
                    Text('₹50,000', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('✅ Fees Fully Paid', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.success)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _StudentProfilePage extends StatelessWidget {
  const _StudentProfilePage();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          GradientAvatar(initials: 'AS', color: AppColors.studentAccent, size: 72),
          const SizedBox(height: 12),
          const Text('Aryan Sharma', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const Text('Student • Class 10-A', style: TextStyle(fontSize: 13, color: AppColors.textMid)),
          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ProfileRow(icon: Icons.email_outlined, label: 'Email', value: 'aryan.sharma@students.com'),
                const Divider(height: 20),
                _ProfileRow(icon: Icons.phone_outlined, label: 'Phone', value: '+91-9876543210'),
                const Divider(height: 20),
                _ProfileRow(icon: Icons.people_outlined, label: 'Parent', value: 'Mr. Rajesh Sharma'),
                const Divider(height: 20),
                _ProfileRow(icon: Icons.class_outlined, label: 'Batch', value: 'Class 10-A'),
                const Divider(height: 20),
                _ProfileRow(icon: Icons.calendar_today_outlined, label: 'Enrolled', value: 'March 2025'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
  const _ProfileRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ],
        ),
      ],
    );
  }
}

class _TodayClassBanner extends StatelessWidget {
  const _TodayClassBanner();

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
                const Text(
                  'Next Class',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mathematics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: Colors.white70, size: 14),
                    SizedBox(width: 4),
                    Text(
                      '10:30 AM  •  Room 204',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
  final List<Map<String, String>> periods = const [
    {'time': '08:00', 'subject': 'English', 'teacher': 'Mrs. Priya Nair', 'room': '101'},
    {'time': '09:00', 'subject': 'Mathematics', 'teacher': 'Mr. Rajan Kumar', 'room': '204'},
    {'time': '10:30', 'subject': 'Science', 'teacher': 'Dr. Shalini Rao', 'room': 'Lab 2'},
    {'time': '12:00', 'subject': 'Lunch Break', 'teacher': '', 'room': ''},
    {'time': '13:00', 'subject': 'History', 'teacher': 'Mr. Anand Joshi', 'room': '108'},
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
                  ? const Border(bottom: BorderSide(color: AppColors.divider, width: 1))
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
                          color: isLunch ? AppColors.warning : AppColors.textDark,
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
