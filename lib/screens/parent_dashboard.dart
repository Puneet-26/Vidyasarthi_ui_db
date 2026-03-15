import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'placeholder_screens.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;
  int _selectedChild = 0;

  final List<Map<String, String>> _children = const [
    {'name': 'Aryan Sharma', 'class': 'Class 9-A', 'rollNo': '15'},
    {'name': 'Priya Sharma', 'class': 'Class 6-B', 'rollNo': '08'},
  ];

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    BottomNavItem(icon: Icons.child_care_outlined, activeIcon: Icons.child_care_rounded, label: 'Children'),
    BottomNavItem(icon: Icons.payment_outlined, activeIcon: Icons.payment_rounded, label: 'Fees'),
    BottomNavItem(icon: Icons.chat_outlined, activeIcon: Icons.chat_rounded, label: 'Chat'),
    BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  List<Widget> get _pages => [
    _ParentHomePage(children: _children, selectedChild: _selectedChild, onSelectChild: (i) => setState(() => _selectedChild = i)),
    const _ParentChildrenPage(),
    const _ParentFeesPage(),
    const _ParentChatPage(),
    const _ParentProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      bottomNavigationBar: VidyaBottomNav(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: (i) => setState(() => _selectedIndex = i),
        activeColor: AppColors.parentAccent,
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

class _ParentHomePage extends StatelessWidget {
  final List<Map<String, String>> children;
  final int selectedChild;
  final ValueChanged<int> onSelectChild;
  const _ParentHomePage({required this.children, required this.selectedChild, required this.onSelectChild});
  @override
  Widget build(BuildContext context) {
    final child = children[selectedChild];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(
            name: 'Mr. Ramesh Sharma',
            role: 'PARENT',
            subtitle: 'Welcome back 👋',
            roleColor: AppColors.parentAccent,
            notificationCount: 2,
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'My Children'),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(children.length, (i) {
                  final c = children[i];
                  final isSelected = i == selectedChild;
                  return SizedBox(
                    width: (constraints.maxWidth - 10) / 2,
                    child: GestureDetector(
                      onTap: () => onSelectChild(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.parentAccent : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.parentAccent.withValues(alpha: isSelected ? 0.3 : 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            GradientAvatar(
                              initials: c['name']!.substring(0, 2),
                              color: isSelected ? Colors.white.withValues(alpha: 0.5) : AppColors.parentAccent,
                              size: 38,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c['name']!.split(' ')[0],
                                      style: TextStyle(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700,
                                          color: isSelected ? Colors.white : AppColors.textDark)),
                                  Text(c['class']!,
                                      style: TextStyle(fontSize: Responsive.sp(context, 11),
                                          color: isSelected ? Colors.white70 : AppColors.textLight)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 24),
          _ChildPerformanceBanner(childName: child['name']!.split(' ')[0]),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                child: const StatCard(title: 'Attendance', value: '92%', icon: Icons.how_to_reg_rounded, color: AppColors.success, subtitle: 'This month'),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                child: const StatCard(title: 'Overall Grade', value: 'A-', icon: Icons.grade_rounded, color: AppColors.parentAccent, subtitle: 'Semester 2'),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                child: const StatCard(title: 'Fee Status', value: 'Paid', icon: Icons.check_circle_rounded, color: AppColors.success, subtitle: 'March 2026'),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                child: const StatCard(title: 'Class Rank', value: '#7', icon: Icons.leaderboard_rounded, color: AppColors.warning, subtitle: 'Out of 40'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Academic Progress'),
          const SizedBox(height: 14),
          const GlassCard(
            child: Column(
              children: [
                LabeledProgressBar(label: 'Physics', value: 0.85, color: AppColors.primary),
                SizedBox(height: 14),
                LabeledProgressBar(label: 'Chemistry', value: 0.78, color: AppColors.info),
                SizedBox(height: 14),
                LabeledProgressBar(label: 'Mathematics', value: 0.91, color: AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Upcoming Events'),
          const SizedBox(height: 14),
          const _EventItem(title: 'Parent-Teacher Meeting', date: 'March 20, 2026', icon: Icons.people_rounded, color: AppColors.info),
          const SizedBox(height: 8),
          const _EventItem(title: 'Annual Sports Day', date: 'March 28, 2026', icon: Icons.sports_rounded, color: AppColors.warning),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ParentChildrenPage extends StatelessWidget {
  const _ParentChildrenPage();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Children Progress'),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const GradientAvatar(initials: 'AS', color: AppColors.parentAccent, size: 48),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Aryan Sharma', style: TextStyle(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        Text('Class 10-A • Roll No. 15', style: TextStyle(fontSize: Responsive.sp(context, 12), color: AppColors.textMid)),
                      ],
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                const LabeledProgressBar(label: 'Physics (85%)', value: 0.85, color: AppColors.primary),
                const SizedBox(height: 10),
                const LabeledProgressBar(label: 'Chemistry (91%)', value: 0.91, color: AppColors.info),
                const SizedBox(height: 10),
                const LabeledProgressBar(label: 'Mathematics (76%)', value: 0.76, color: AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recent Test Results'),
          const SizedBox(height: 12),
          const GlassCard(
            child: Column(
              children: [
                LabeledProgressBar(label: 'Unit Test 1 - Physics (85/100)', value: 0.85, color: AppColors.primary),
                SizedBox(height: 14),
                LabeledProgressBar(label: 'Unit Test 1 - Chemistry (91/100)', value: 0.91, color: AppColors.info),
                SizedBox(height: 14),
                LabeledProgressBar(label: 'Unit Test 1 - Mathematics (76/100)', value: 0.76, color: AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ParentFeesPage extends StatelessWidget {
  const _ParentFeesPage();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Fee Details'),
          const SizedBox(height: 14),
          _FeeCard(),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Payment History'),
          const SizedBox(height: 12),
          _PaymentHistoryTile(amount: '₹25,000', method: 'UPI', date: 'Jan 1, 2026', ref: 'UPI-20240101-001'),
          const SizedBox(height: 8),
          _PaymentHistoryTile(amount: '₹25,000', method: 'Bank Transfer', date: 'Feb 1, 2026', ref: 'NEFT-20240201-001'),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _PaymentHistoryTile extends StatelessWidget {
  final String amount;
  final String method;
  final String date;
  final String ref;
  const _PaymentHistoryTile({required this.amount, required this.method, required this.date, required this.ref});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amount, style: TextStyle(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Text('$method • $date', style: TextStyle(fontSize: Responsive.sp(context, 11), color: AppColors.textMid)),
                Text('Ref: $ref', style: TextStyle(fontSize: Responsive.sp(context, 10), color: AppColors.textLight)),
              ],
            ),
          ),
          const Text('Paid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
        ],
      ),
    );
  }
}

class _ParentChatPage extends StatelessWidget {
  const _ParentChatPage();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Teacher Messages'),
          const SizedBox(height: 14),
          const _MessageItem(
            teacher: 'Mr. Arun Kumar',
            subject: 'Physics',
            message: 'Aryan performed well in the recent test. Keep it up!',
            time: '1 day ago',
          ),
          const SizedBox(height: 10),
          const _MessageItem(
            teacher: 'Mrs. Priya Sharma',
            subject: 'Chemistry',
            message: 'Please ensure the lab report is submitted on time.',
            time: '2 days ago',
          ),
          const SizedBox(height: 10),
          const _MessageItem(
            teacher: 'Mr. Vikram Singh',
            subject: 'Mathematics',
            message: 'Aryan has improved significantly in integration. Well done!',
            time: '3 days ago',
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'School Notices'),
          const SizedBox(height: 14),
          const _EventItem(title: 'Parent-Teacher Meeting - March 22', date: 'March 22, 2026', icon: Icons.people_rounded, color: AppColors.info),
          const SizedBox(height: 8),
          const _EventItem(title: 'Mid-Term Exams - March 28', date: 'March 28, 2026', icon: Icons.quiz_rounded, color: AppColors.warning),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ParentProfilePage extends StatelessWidget {
  const _ParentProfilePage();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const GradientAvatar(initials: 'RS', color: AppColors.parentAccent, size: 72),
          const SizedBox(height: 12),
          Text('Mr. Ramesh Sharma', style: TextStyle(fontSize: Responsive.sp(context, 20), fontWeight: FontWeight.w800, color: AppColors.textDark)),
          Text('Parent • 1 child enrolled', style: TextStyle(fontSize: Responsive.sp(context, 13), color: AppColors.textMid)),
          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ProfileRow2(icon: Icons.email_outlined, label: 'Email', value: 'rajesh.sharma@parents.com'),
                const Divider(height: 20),
                _ProfileRow2(icon: Icons.phone_outlined, label: 'Phone', value: '+91-9876543200'),
                const Divider(height: 20),
                _ProfileRow2(icon: Icons.child_care_outlined, label: 'Child', value: 'Aryan Sharma'),
                const Divider(height: 20),
                _ProfileRow2(icon: Icons.class_outlined, label: 'Class', value: 'Class 10-A'),
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

class _ProfileRow2 extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow2({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.parentAccent, size: 20),
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

class _ChildPerformanceBanner extends StatelessWidget {
  final String childName;

  const _ChildPerformanceBanner({required this.childName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.parentAccent, Color(0xFF1AA89A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.parentAccent.withOpacity(0.35),
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
                  "$childName's Performance",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Doing great this semester! Consistent improvement in all subjects.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    _PillStat(label: 'Tests', value: '8/10'),
                    SizedBox(width: 8),
                    _PillStat(label: 'Homework', value: '95%'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.trending_up_rounded, size: 60, color: Colors.white24),
        ],
      ),
    );
  }
}

class _PillStat extends StatelessWidget {
  final String label;
  final String value;

  const _PillStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Annual Fee 2025-26',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PAID',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),
          const _FeeRow(label: 'Tuition Fee', amount: '₹45,000', paid: true),
          const SizedBox(height: 8),
          const _FeeRow(label: 'Sports Fee', amount: '₹2,500', paid: true),
          const SizedBox(height: 8),
          const _FeeRow(label: 'Lab Fee', amount: '₹3,000', paid: true),
          const SizedBox(height: 8),
          const _FeeRow(label: 'Q4 Installment', amount: '₹12,500', paid: false),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.payment_rounded, size: 18),
              label: const Text('Pay Q4 Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.parentAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool paid;

  const _FeeRow({required this.label, required this.amount, required this.paid});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMid,
          ),
        ),
        Row(
          children: [
            Text(
              amount,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              paid ? Icons.check_circle_rounded : Icons.pending_rounded,
              size: 16,
              color: paid ? AppColors.success : AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }
}

class _MessageItem extends StatelessWidget {
  final String teacher;
  final String subject;
  final String message;
  final String time;

  const _MessageItem({
    required this.teacher,
    required this.subject,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientAvatar(
            initials: teacher.split(' ').last.substring(0, 2),
            color: AppColors.parentAccent,
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      teacher,
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 11),
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 11),
                    color: AppColors.parentAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 12),
                    color: AppColors.textMid,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventItem extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final Color color;

  const _EventItem({
    required this.title,
    required this.date,
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
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 11),
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'RSVP',
              style: TextStyle(
                fontSize: Responsive.sp(context, 11),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
