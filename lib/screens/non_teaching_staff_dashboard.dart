import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class NonTeachingStaffDashboard extends StatefulWidget {
  const NonTeachingStaffDashboard({super.key});

  @override
  State<NonTeachingStaffDashboard> createState() =>
      _NonTeachingStaffDashboardState();
}

class _NonTeachingStaffDashboardState extends State<NonTeachingStaffDashboard> {
  int _selectedIndex = 0;

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(
        icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    BottomNavItem(
        icon: Icons.person_add_outlined,
        activeIcon: Icons.person_add_rounded,
        label: 'Admissions'),
    BottomNavItem(
        icon: Icons.schedule_outlined,
        activeIcon: Icons.schedule_rounded,
        label: 'TimeTable'),
    BottomNavItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications_rounded,
        label: 'Broadcast'),
    BottomNavItem(
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet_rounded,
        label: 'Fees'),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      bottomNavigationBar: VidyaBottomNav(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: (i) => setState(() => _selectedIndex = i),
        activeColor: AppColors.adminAccent,
      ),
      child: SafeArea(
        child: _getPageContent(),
      ),
    );
  }

  Widget _getPageContent() {
    switch (_selectedIndex) {
      case 0:
        return _HomePage();
      case 1:
        return _AdmissionsPage();
      case 2:
        return _TimeTablePage();
      case 3:
        return _BroadcastPage();
      case 4:
        return _FeesPage();
      default:
        return _HomePage();
    }
  }
}

class _HomePage extends StatefulWidget {
  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final DatabaseService _dbService = DatabaseService();

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final admissions = await _dbService.getAllAdmissions();
    final students = await _dbService.getAllStudents();
    final broadcasts = await _dbService.getAllBroadcasts();

    int pendingAdmissions = admissions.where((e) => e.status == 'pending').length;
    int pendingFeesStudents = students.where((e) => e.feesPaid < e.totalFees).length;

    return {
      'pendingAdmissions': pendingAdmissions,
      'pendingFeesStudents': pendingFeesStudents,
      'totalStudents': students.length,
      'totalBroadcasts': broadcasts.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data ?? {
          'pendingAdmissions': 0,
          'pendingFeesStudents': 0,
          'totalStudents': 0,
          'totalBroadcasts': 0,
        };

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardHeader(
                name: 'Admin Staff',
                role: 'NON-TEACHING',
                subtitle: 'Good Morning 🏫',
                roleColor: AppColors.adminAccent,
                notificationCount: 5,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      icon: Icons.person_add_rounded,
                      title: 'Pending Admissions',
                      value: '${data['pendingAdmissions']}',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Pending Fees',
                      value: '${data['pendingFeesStudents']}',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      icon: Icons.school_rounded,
                      title: 'Total Students',
                      value: '${data['totalStudents']}',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      icon: Icons.notifications_rounded,
                      title: 'Broadcasts',
                      value: '${data['totalBroadcasts']}',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              const GlassCard(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    _QuickActionTile(
                      icon: Icons.person_add_rounded,
                      title: 'Manage Admissions',
                      subtitle: 'Review and approve student applications',
                    ),
                    Divider(height: 16),
                    _QuickActionTile(
                      icon: Icons.schedule_rounded,
                      title: 'Update TimeTable',
                      subtitle: 'Manage class schedules and subjects',
                    ),
                    Divider(height: 16),
                    _QuickActionTile(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Track Fees',
                      subtitle: 'Monitor student fee payments',
                    ),
                    Divider(height: 16),
                    _QuickActionTile(
                      icon: Icons.notifications_rounded,
                      title: 'Send Broadcast',
                      subtitle: 'Communicate with parents and students',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdmissionsPage extends StatefulWidget {
  @override
  State<_AdmissionsPage> createState() => _AdmissionsPageState();
}

class _AdmissionsPageState extends State<_AdmissionsPage> {
  final DatabaseService _dbService = DatabaseService();
  List<Admission> _admissions = [];
  List<Batch> _batches = [];
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final futures = await Future.wait([
      _dbService.getAllAdmissions(),
      _dbService.getAllBatches(),
      _dbService.getAllSubjects(),
    ]);

    if (mounted) {
      setState(() {
        _admissions = futures[0] as List<Admission>;
        _batches = futures[1] as List<Batch>;
        _subjects = futures[2] as List<Subject>;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String admissionId, String status) async {
    final success = await _dbService.updateAdmissionStatus(admissionId, status);
    if (success && mounted) {
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status to $status')),
      );
    }
  }

  void _approveAdmission(String admissionId) => _updateStatus(admissionId, 'approved');
  void _rejectAdmission(String admissionId) => _updateStatus(admissionId, 'rejected');

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admission Applications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ..._admissions.map((admission) {
            final statusColor = admission.status == 'pending'
                ? Colors.orange
                : admission.status == 'approved'
                    ? Colors.green
                    : Colors.red;

            final batch = _batches.firstWhere((b) => b.id == admission.appliedBatchId,
                orElse: () => Batch(id: '', name: 'Unknown', level: '', subjects: [], createdAt: DateTime.now()));
            final subjects = _subjects.where((s) => admission.requestedSubjectIds.contains(s.id)).map((s) => s.name).join(', ');

            return GlassCard(
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
                            Text(
                              admission.studentName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Parent: ${admission.parentName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          admission.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Applied Batch: ${batch.name}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMid,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Subjects: $subjects',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMid,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Email: ${admission.email}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMid,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phone: ${admission.phoneNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMid,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Applied: ${admission.appliedDate.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  if (admission.status == 'pending') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _approveAdmission(admission.id),
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _rejectAdmission(admission.id),
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TimeTablePage extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService();

  Future<Map<String, dynamic>> _fetchTimeTableData() async {
    final timetables = await _dbService.getAllTimeTables();
    final batches = await _dbService.getAllBatches();
    final subjects = await _dbService.getAllSubjects();
    return {
      'timetables': timetables,
      'batches': batches,
      'subjects': subjects,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchTimeTableData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data!;
        final allTimeTable = data['timetables'] as List<TimeTable>;
        final allBatches = data['batches'] as List<Batch>;
        final allSubjects = data['subjects'] as List<Subject>;

        final groupedTimeTable = <String, List<TimeTable>>{};
        for (final tt in allTimeTable) {
          final batch = allBatches.firstWhere((b) => b.id == tt.batchId,
              orElse: () => Batch(id: '', name: 'Unknown', level: '', subjects: [], createdAt: DateTime.now()));
          if (!groupedTimeTable.containsKey(batch.name)) {
            groupedTimeTable[batch.name] = [];
          }
          groupedTimeTable[batch.name]!.add(tt);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'School TimeTable',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              if (groupedTimeTable.isEmpty)
                const Center(child: Text('No timetable entries found.')),
              ...groupedTimeTable.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...entry.value.map((tt) {
                      final subject = allSubjects.firstWhere((s) => s.id == tt.subjectId,
                          orElse: () => Subject(id: '', name: 'Unknown', code: '', description: ''));
                      return GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.schedule_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subject.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    '${tt.day} | ${tt.startTime} - ${tt.endTime}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  Text(
                                    'Teacher ID: ${tt.teacherId}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMid,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _BroadcastPage extends StatefulWidget {
  @override
  State<_BroadcastPage> createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<_BroadcastPage> {
  final DatabaseService _dbService = DatabaseService();
  List<Broadcast> _broadcasts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBroadcasts();
  }

  Future<void> _fetchBroadcasts() async {
    final broadcasts = await _dbService.getAllBroadcasts();
    if (mounted) {
      setState(() {
        _broadcasts = broadcasts;
        _isLoading = false;
      });
    }
  }

  void _sendBroadcast() {
    // Navigate to a dedicated "Compose Broadcast" page logic or show a dialog
    // It would call _dbService.createBroadcast(newBroadcast) eventually
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Broadcast creation dialog would open here')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Broadcasts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _sendBroadcast,
                icon: const Icon(Icons.add),
                label: const Text('New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_broadcasts.isEmpty)
             const Center(child: Text('No broadcasts found.')),
          ..._broadcasts.map((broadcast) {
            final audienceColor = broadcast.targetAudience == 'all'
                ? Colors.purple
                : broadcast.targetAudience == 'students'
                    ? Colors.blue
                    : Colors.green;

            return GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          broadcast.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: audienceColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          broadcast.targetAudience.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: audienceColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    broadcast.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMid,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'From ${broadcast.sentBy} • ${broadcast.sentDate.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FeesPage extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Student>>(
      future: _dbService.getAllStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allStudents = snapshot.data ?? [];
        final totalFees = allStudents.fold<double>(0, (sum, s) => sum + s.totalFees);
        final totalPaid = allStudents.fold<double>(0, (sum, s) => sum + s.feesPaid);
        final totalPending = totalFees - totalPaid;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fees Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Total Fees',
                      value: '₹${totalFees.toStringAsFixed(0)}',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      icon: Icons.check_circle_rounded,
                      title: 'Paid',
                      value: '₹${totalPaid.toStringAsFixed(0)}',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatBox(
                icon: Icons.pending_actions_rounded,
                title: 'Pending',
                value: '₹${totalPending.toStringAsFixed(0)}',
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Student-wise Fees',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              if (allStudents.isEmpty)
                const Center(child: Text('No students found.')),
              ...allStudents.map((student) {
                final pending = student.totalFees - student.feesPaid;
                final percentage = student.totalFees > 0 ? (student.feesPaid / student.totalFees * 100).toInt() : 0;
                final valueIndicator = student.totalFees > 0 ? (student.feesPaid / student.totalFees) : 0.0;

                return GlassCard(
                  padding: const EdgeInsets.all(12),
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
                                Text(
                                  student.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  student.id,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: valueIndicator,
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation(
                                      student.feesPaid == student.totalFees
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                  Text(
                                    '$percentage%',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Paid: ₹${student.feesPaid} / ₹${student.totalFees} | Pending: ₹${pending.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
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
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.primary),
        ],
      ),
    );
  }
}
