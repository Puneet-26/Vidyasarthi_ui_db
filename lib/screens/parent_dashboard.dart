import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/database_service.dart';
import '../models/models.dart';
import 'connect_with_us_screen.dart';
import 'faculty_screen.dart';
import 'submit_feedback_screen_premium.dart';
import 'view_attendance_screen.dart';

class ParentDashboard extends StatefulWidget {
  final String parentEmail;
  const ParentDashboard(
      {super.key, this.parentEmail = 'rajesh.sharma@parents.com'});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;
  int _selectedChild = 0;
  List<Student> _students = [];
  bool _loadingStudents = true;

  final _db = DatabaseService();

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home'),
    BottomNavItem(
        icon: Icons.child_care_outlined,
        activeIcon: Icons.child_care_rounded,
        label: 'Children'),
    BottomNavItem(
        icon: Icons.payment_outlined,
        activeIcon: Icons.payment_rounded,
        label: 'Fees'),
    BottomNavItem(
        icon: Icons.message_outlined,
        activeIcon: Icons.message_rounded,
        label: 'Feedback'),
    BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person_rounded,
        label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    debugPrint('Loading students for parent: ${widget.parentEmail}');
    final students = await _db.getStudentsByParentEmail(widget.parentEmail);
    debugPrint('Found ${students.length} students');
    if (mounted)
      setState(() {
        _students = students;
        _loadingStudents = false;
      });
  }

  List<Widget> get _pages => [
        _ParentHomePage(
            students: _students,
            loading: _loadingStudents,
            selectedChild: _selectedChild,
            onSelectChild: (i) => setState(() => _selectedChild = i),
            onNotification: () => _showNoticesSheet(context)),
        _ParentChildrenPage(students: _students, loading: _loadingStudents),
        _ParentFeesPage(students: _students, loading: _loadingStudents),
        _ParentTeacherFeedbackPage(
            students: _students, loading: _loadingStudents),
        const _ParentProfilePage(),
      ];

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
        builder: (_, sc) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(
              controller: sc,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  const Text('Notices & Updates',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  const _EventItem(
                      title: 'Mid-Term Exams - March 28',
                      date: 'March 28, 2026',
                      icon: Icons.quiz_rounded,
                      color: AppColors.warning),
                  const SizedBox(height: 10),
                ],
              )),
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
        onTap: (i) => setState(() => _selectedIndex = i),
        activeColor: AppColors.parentAccent,
      ),
      child: SafeArea(
          child: IndexedStack(index: _selectedIndex, children: _pages)),
    );
  }
}

// ─── Home Page ────────────────────────────────────────────────────────────────
class _ParentHomePage extends StatefulWidget {
  final List<Student> students;
  final bool loading;
  final int selectedChild;
  final ValueChanged<int> onSelectChild;
  final VoidCallback onNotification;
  const _ParentHomePage(
      {required this.students,
      required this.loading,
      required this.selectedChild,
      required this.onSelectChild,
      required this.onNotification});
  @override
  State<_ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<_ParentHomePage> {
  late int _selectedChild;

  @override
  void initState() {
    super.initState();
    _selectedChild = widget.selectedChild;
  }

  @override
  void didUpdateWidget(covariant _ParentHomePage old) {
    super.didUpdateWidget(old);
    if (old.selectedChild != widget.selectedChild)
      _selectedChild = widget.selectedChild;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) return const Center(child: CircularProgressIndicator());
    if (widget.students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.family_restroom_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No children found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please contact admin for enrollment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final student = widget.students[_selectedChild];
    final feeProgress = student.totalFees > 0
        ? (student.feesPaid / student.totalFees).clamp(0.0, 1.0)
        : 0.0;
    final feeLabel = student.feeStatus == 'full'
        ? 'Paid'
        : student.feeStatus == 'partial'
            ? 'Partial'
            : 'Due';
    final feeColor = student.feeStatus == 'full'
        ? AppColors.success
        : student.feeStatus == 'partial'
            ? AppColors.warning
            : AppColors.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DashboardHeader(
            name: 'Parent',
            role: 'PARENT',
            subtitle: 'Parent Dashboard',
            roleColor: AppColors.parentAccent,
            notificationCount: 1,
            onNotification: widget.onNotification,
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
                    color: AppColors.parentAccent,
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
                    color: AppColors.parentAccent,
                    size: 22,
                  ),
                ),
              ),
            ]),
        const SizedBox(height: 24),
        const SectionHeader(title: 'My Children'),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(widget.students.length, (i) {
              final s = widget.students[i];
              final isSelected = i == _selectedChild;
              return SizedBox(
                width: (constraints.maxWidth - 10) / 2,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedChild = i);
                    widget.onSelectChild(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.parentAccent
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.parentAccent
                                .withValues(alpha: isSelected ? 0.3 : 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: Row(children: [
                      GradientAvatar(
                          initials: s.name.substring(0, 2),
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.5)
                              : AppColors.parentAccent,
                          size: 38),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(s.name.split(' ')[0],
                                style: TextStyle(
                                    fontSize: Responsive.sp(context, 13),
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textDark)),
                            Text(s.batchId,
                                style: TextStyle(
                                    fontSize: Responsive.sp(context, 11),
                                    color: isSelected
                                        ? Colors.white70
                                        : AppColors.textLight)),
                          ])),
                    ]),
                  ),
                ),
              );
            }),
          );
        }),
        const SizedBox(height: 24),
        
        // Performance Banner
        _PerformanceBanner(studentName: student.name.split(' ')[0]),
        const SizedBox(height: 24),
        
        // Stats Cards
        Wrap(spacing: 12, runSpacing: 12, children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewAttendanceScreen(
                    studentId: student.id,
                    studentName: student.name,
                  ),
                ),
              );
            },
            child: SizedBox(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                child: const StatCard(
                    title: 'Attendance',
                    value: '92%',
                    icon: Icons.how_to_reg_rounded,
                    color: AppColors.success,
                    subtitle: 'This month')),
          ),
          SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 2,
              child: const StatCard(
                  title: 'Overall Grade',
                  value: 'A-',
                  icon: Icons.star_rounded,
                  color: AppColors.parentAccent,
                  subtitle: 'Semester 2')),
          SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 2,
              child: StatCard(
                  title: 'Fee Status',
                  value: feeLabel,
                  icon: feeColor == AppColors.success
                      ? Icons.check_circle_rounded
                      : Icons.pending_rounded,
                  color: feeColor,
                  subtitle: '${(feeProgress * 100).toInt()}% paid')),
          SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 2,
              child: const StatCard(
                  title: 'Class Rank',
                  value: '#7',
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.warning,
                  subtitle: 'Out of 40')),
        ]),
        const SizedBox(height: 24),
        
        // Academic Progress
        const SectionHeader(title: 'Academic Progress'),
        const SizedBox(height: 14),
        const _AcademicProgressCard(),
        const SizedBox(height: 24),
        
        const SectionHeader(title: 'Fee Progress'),
        const SizedBox(height: 14),
        GlassCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('₹${student.feesPaid.toInt()} / ₹${student.totalFees.toInt()}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: feeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(feeLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: feeColor))),
          ]),
          const SizedBox(height: 12),
          LabeledProgressBar(
              label: 'Fees Paid', value: feeProgress, color: feeColor),
        ])),
        const SizedBox(height: 30),
      ]),
    );
  }
}

// Performance Banner Widget
class _PerformanceBanner extends StatelessWidget {
  final String studentName;
  const _PerformanceBanner({required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.parentAccent, Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.parentAccent.withValues(alpha: 0.35),
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
                      "$studentName's Performance",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Doing great this semester! Consistent\nimprovement in all subjects.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tests: 8/10',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Homework: 95%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
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

// Academic Progress Card Widget
class _AcademicProgressCard extends StatelessWidget {
  const _AcademicProgressCard();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        children: [
          LabeledProgressBar(
            label: 'Physics',
            value: 0.85,
            color: Color(0xFF667EEA),
          ),
          SizedBox(height: 14),
          LabeledProgressBar(
            label: 'Chemistry',
            value: 0.78,
            color: Color(0xFF26C6DA),
          ),
          SizedBox(height: 14),
          LabeledProgressBar(
            label: 'Mathematics',
            value: 0.91,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

// ─── Children Page ────────────────────────────────────────────────────────────
class _ParentChildrenPage extends StatelessWidget {
  final List<Student> students;
  final bool loading;
  const _ParentChildrenPage({required this.students, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No children enrolled',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contact admin to add your child',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    final subjectColors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(title: 'Children Progress'),
        const SizedBox(height: 16),
        ...students
            .map((s) =>
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              GradientAvatar(
                                  initials: s.name.substring(0, 2),
                                  color: AppColors.parentAccent,
                                  size: 48),
                              const SizedBox(width: 14),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(s.name,
                                        style: TextStyle(
                                            fontSize:
                                                Responsive.sp(context, 16),
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textDark)),
                                    Text('${s.batchId} • ${s.email}',
                                        style: TextStyle(
                                            fontSize:
                                                Responsive.sp(context, 12),
                                            color: AppColors.textMid)),
                                  ])),
                            ]),
                            const SizedBox(height: 14),
                            Text('Enrollment: ${s.enrollmentStatus}',
                                style: TextStyle(
                                    fontSize: Responsive.sp(context, 12),
                                    color: AppColors.textMid)),
                            const SizedBox(height: 8),
                            Text('Subjects: ${s.subjectIds.join(', ')}',
                                style: TextStyle(
                                    fontSize: Responsive.sp(context, 12),
                                    color: AppColors.textMid)),
                            const SizedBox(height: 14),
                            const Divider(color: AppColors.divider),
                            const SizedBox(height: 10),
                            Text('Fee Summary',
                                style: TextStyle(
                                    fontSize: Responsive.sp(context, 12),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMid)),
                            const SizedBox(height: 8),
                            LabeledProgressBar(
                              label:
                                  '₹${s.feesPaid.toInt()} of ₹${s.totalFees.toInt()} paid',
                              value: s.totalFees > 0
                                  ? (s.feesPaid / s.totalFees).clamp(0.0, 1.0)
                                  : 0.0,
                              color: subjectColors[
                                  students.indexOf(s) % subjectColors.length],
                            ),
                          ])),
                  const SizedBox(height: 16),
                ]))
            .toList(),
        const SizedBox(height: 14),
      ]),
    );
  }
}

// ─── Fees Page (live DB data) ─────────────────────────────────────────────────
class _ParentFeesPage extends StatefulWidget {
  final List<Student> students;
  final bool loading;
  const _ParentFeesPage({required this.students, required this.loading});
  @override
  State<_ParentFeesPage> createState() => _ParentFeesPageState();
}

class _ParentFeesPageState extends State<_ParentFeesPage> {
  int _selectedChild = 0;
  List<FeePayment> _payments = [];
  bool _loadingPayments = false;
  final _db = DatabaseService();

  @override
  void didUpdateWidget(covariant _ParentFeesPage old) {
    super.didUpdateWidget(old);
    if (old.students != widget.students && widget.students.isNotEmpty)
      _loadPayments();
  }

  @override
  void initState() {
    super.initState();
    if (widget.students.isNotEmpty) _loadPayments();
  }

  Future<void> _loadPayments() async {
    if (widget.students.isEmpty) return;
    setState(() => _loadingPayments = true);
    final p =
        await _db.getFeePaymentsByStudent(widget.students[_selectedChild].id);
    if (mounted)
      setState(() {
        _payments = p;
        _loadingPayments = false;
      });
  }

  void _onChildSwitch(int i) {
    setState(() {
      _selectedChild = i;
      _payments = [];
    });
    _loadPayments();
  }

  void _showPayDialog(Student student) {
    final amountCtrl = TextEditingController();
    String method = 'upi';
    showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
              builder: (ctx, setS) => AlertDialog(
                title: const Text('Record Payment'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                      'Outstanding: ₹${(student.totalFees - student.feesPaid).toInt()}',
                      style: const TextStyle(
                          color: AppColors.textMid, fontSize: 13)),
                  const SizedBox(height: 12),
                  TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Amount (₹)',
                          border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: method,
                    decoration: const InputDecoration(
                        labelText: 'Method', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'upi', child: Text('UPI')),
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(
                          value: 'bank_transfer', child: Text('Bank Transfer')),
                      DropdownMenuItem(value: 'card', child: Text('Card')),
                    ],
                    onChanged: (v) => setS(() => method = v!),
                  ),
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.parentAccent),
                    onPressed: () async {
                      final amt = double.tryParse(amountCtrl.text.trim());
                      if (amt == null || amt <= 0) return;
                      Navigator.pop(ctx);
                      final payment = FeePayment(
                        id: 'fee_${DateTime.now().microsecondsSinceEpoch}',
                        studentId: student.id,
                        amount: amt,
                        paymentMethod: method,
                        paymentDate: DateTime.now(),
                        status: 'completed',
                        reference:
                            '${method.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}',
                      );
                      final newPaid = student.feesPaid + amt;
                      final ok = await _db.createFeePaymentAndUpdateStudent(
                          payment, newPaid, student.totalFees);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? 'Payment recorded successfully'
                              : 'Failed to record payment'),
                          backgroundColor:
                              ok ? AppColors.success : AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ));
                        if (ok) _loadPayments();
                      }
                    },
                    child: const Text('Pay',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) return const Center(child: CircularProgressIndicator());
    if (widget.students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No fee records',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fee details will appear once enrolled',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final student = widget.students[_selectedChild];
    final feeProgress = student.totalFees > 0
        ? (student.feesPaid / student.totalFees).clamp(0.0, 1.0)
        : 0.0;
    final feeColor = student.feeStatus == 'full'
        ? AppColors.success
        : student.feeStatus == 'partial'
            ? AppColors.warning
            : AppColors.error;
    final feeLabel = student.feeStatus == 'full'
        ? 'PAID'
        : student.feeStatus == 'partial'
            ? 'PARTIAL'
            : 'DUE';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(title: 'Fee Details'),
        const SizedBox(height: 14),
        // Child selector
        Row(
            children: List.generate(widget.students.length, (i) {
          final s = widget.students[i];
          final isSelected = i == _selectedChild;
          return Expanded(
              child: GestureDetector(
            onTap: () => _onChildSwitch(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  right: i < widget.students.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.parentAccent
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.parentAccent
                          .withValues(alpha: isSelected ? 0.25 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(children: [
                GradientAvatar(
                    initials: s.name.substring(0, 2),
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.4)
                        : AppColors.parentAccent,
                    size: 32),
                const SizedBox(width: 8),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(s.name.split(' ')[0],
                          style: TextStyle(
                              fontSize: Responsive.sp(context, 13),
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textDark)),
                      Text(s.batchId,
                          style: TextStyle(
                              fontSize: Responsive.sp(context, 10),
                              color: isSelected
                                  ? Colors.white70
                                  : AppColors.textLight)),
                    ])),
              ]),
            ),
          ));
        })),
        const SizedBox(height: 16),
        // Fee card
        GlassCard(
            child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Annual Fee 2025-26',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: feeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(feeLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: feeColor))),
          ]),
          const SizedBox(height: 16),
          LabeledProgressBar(
              label:
                  '₹${student.feesPaid.toInt()} of ₹${student.totalFees.toInt()} paid',
              value: feeProgress,
              color: feeColor),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          _FeeRow(
              label: 'Total Fees',
              amount: '₹${student.totalFees.toInt()}',
              paid: true),
          const SizedBox(height: 6),
          _FeeRow(
              label: 'Fees Paid',
              amount: '₹${student.feesPaid.toInt()}',
              paid: true),
          const SizedBox(height: 6),
          _FeeRow(
              label: 'Outstanding',
              amount: '₹${(student.totalFees - student.feesPaid).toInt()}',
              paid: student.feeStatus == 'full'),
          const SizedBox(height: 12),
          if (student.feeStatus != 'full')
            SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showPayDialog(student),
                  icon: const Icon(Icons.payment_rounded, size: 18),
                  label: const Text('Record Payment'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.parentAccent),
                )),
        ])),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Payment History'),
        const SizedBox(height: 12),
        if (_loadingPayments)
          const Center(child: CircularProgressIndicator())
        else if (_payments.isEmpty)
          const Text('No payments recorded yet.',
              style: TextStyle(color: AppColors.textMid))
        else
          ..._payments.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PaymentHistoryTile(
                  amount: '₹${p.amount.toInt()}',
                  method: p.paymentMethod.toUpperCase(),
                  date:
                      '${p.paymentDate.day}/${p.paymentDate.month}/${p.paymentDate.year}',
                  ref: p.reference,
                ),
              )),
        const SizedBox(height: 30),
      ]),
    );
  }
}

// ─── Teacher Feedback Page (parent view) ─────────────────────────────────────
class _ParentTeacherFeedbackPage extends StatefulWidget {
  final List<Student> students;
  final bool loading;
  const _ParentTeacherFeedbackPage(
      {required this.students, required this.loading});
  @override
  State<_ParentTeacherFeedbackPage> createState() =>
      _ParentTeacherFeedbackPageState();
}

class _ParentTeacherFeedbackPageState
    extends State<_ParentTeacherFeedbackPage> {

  @override
  Widget build(BuildContext context) {
    if (widget.loading) return const Center(child: CircularProgressIndicator());
    if (widget.students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No feedback available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enroll your child to send feedback',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final currentStudent = widget.students[0]; // Use first student for feedback

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(title: 'Feedback'),
        const SizedBox(height: 14),
        
        // Send Anonymous Feedback Section
        const GlassCard(
          child: Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.info, size: 28),
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
                      'Share your thoughts with teachers anonymously',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubmitFeedbackScreenPremium(
                    senderRole: 'parent',
                    senderId: currentStudent.parentEmail,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Send Feedback to Teacher'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.parentAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        const SizedBox(height: 30),
      ]),
    );
  }
}

// ─── Profile Page ─────────────────────────────────────────────────────────────
class _ParentProfilePage extends StatelessWidget {
  const _ParentProfilePage();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 20),
        const GradientAvatar(
            initials: 'RS', color: AppColors.parentAccent, size: 72),
        const SizedBox(height: 12),
        Text('Parent',
            style: TextStyle(
                fontSize: Responsive.sp(context, 20),
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        Text('Parent Dashboard',
            style: TextStyle(
                fontSize: Responsive.sp(context, 13),
                color: AppColors.textMid)),
        const SizedBox(height: 24),
        const GlassCard(
            padding: EdgeInsets.all(16),
            child: Column(children: [
              _ProfileRow2(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: 'rajesh.sharma@parents.com'),
              Divider(height: 20),
              _ProfileRow2(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: '+91-9876543200'),
            ])),
        const SizedBox(height: 20),
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
                      borderRadius: BorderRadius.circular(14))),
            )),
        const SizedBox(height: 30),
      ]),
    );
  }
}

class _ProfileRow2 extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow2(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppColors.parentAccent, size: 20),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
      ]),
    ]);
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool paid;
  const _FeeRow(
      {required this.label, required this.amount, required this.paid});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: const TextStyle(fontSize: 13, color: AppColors.textMid)),
      Row(children: [
        Text(amount,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(width: 8),
        Icon(paid ? Icons.check_circle_rounded : Icons.pending_rounded,
            size: 16, color: paid ? AppColors.success : AppColors.warning),
      ]),
    ]);
  }
}

class _PaymentHistoryTile extends StatelessWidget {
  final String amount;
  final String method;
  final String date;
  final String ref;
  const _PaymentHistoryTile(
      {required this.amount,
      required this.method,
      required this.date,
      required this.ref});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 22)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(amount,
                    style: TextStyle(
                        fontSize: Responsive.sp(context, 15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                Text('$method • $date',
                    style: TextStyle(
                        fontSize: Responsive.sp(context, 11),
                        color: AppColors.textMid)),
                Text('Ref: $ref',
                    style: TextStyle(
                        fontSize: Responsive.sp(context, 10),
                        color: AppColors.textLight)),
              ])),
        ]));
  }
}

class _EventItem extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final Color color;
  const _EventItem(
      {required this.title,
      required this.date,
      required this.icon,
      required this.color});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20)),
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
                Text(date,
                    style: TextStyle(
                        fontSize: Responsive.sp(context, 11),
                        color: AppColors.textLight)),
              ])),
        ]));
  }
}
