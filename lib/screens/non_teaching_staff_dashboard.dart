import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

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
                subtitle: 'Staff Dashboard',
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
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 18),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Admission Applications',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 20),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showRegistrationDialog,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_admissions.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.person_add_disabled_rounded, size: 64, color: AppColors.textLight.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No applications found',
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 16),
                      color: AppColors.textMid,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
                              style: TextStyle(
                                fontSize: Responsive.sp(context, 15),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Parent: ${admission.parentName}',
                              style: TextStyle(
                                fontSize: Responsive.sp(context, 12),
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
                              fontSize: Responsive.sp(context, 11),
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
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 12),
                          color: AppColors.textMid,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Subjects: $subjects',
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 12),
                          color: AppColors.textMid,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Email: ${admission.email}',
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 12),
                          color: AppColors.textMid,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phone: ${admission.phoneNumber}',
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 12),
                          color: AppColors.textMid,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Applied: ${admission.appliedDate.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 12),
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

  void _showRegistrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _StudentRegistrationDialog(
        batches: _batches,
        subjects: _subjects,
        onComplete: _fetchData,
      ),
    );
  }
}

class _StudentRegistrationDialog extends StatefulWidget {
  final List<Batch> batches;
  final List<Subject> subjects;
  final VoidCallback onComplete;

  const _StudentRegistrationDialog({
    required this.batches,
    required this.subjects,
    required this.onComplete,
  });

  @override
  State<_StudentRegistrationDialog> createState() => _StudentRegistrationDialogState();
}

class _StudentRegistrationDialogState extends State<_StudentRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = DatabaseService();
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _feesController = TextEditingController(text: '15000');

  String? _selectedBatchId;
  final List<String> _selectedSubjectIds = [];
  bool _isLoading = false;
  Map<String, dynamic>? _generatedCredentials;

  @override
  void dispose() {
    _nameController.dispose();
    _parentNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _parentPhoneController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  String _generatePassword() {
    // Simple numeric password for demo
    return (100000 + (999999 - 100000) * (DateTime.now().millisecond / 1000)).toInt().toString();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a batch')));
      return;
    }
    if (_selectedSubjectIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one subject')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final password = _generatePassword();

      // 1. Create Credentials
      final authResult = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: 'student',
      );

      if (!authResult['success']) throw Exception(authResult['error']);

      final userId = authResult['userId'];
      final studentId = 'student_${DateTime.now().millisecondsSinceEpoch}';

      // 2. Create Student Profile
      final student = Student(
        id: studentId,
        userId: userId,
        name: name,
        email: email,
        phoneNumber: _phoneController.text.trim(),
        parentPhone: _parentPhoneController.text.trim(),
        parentName: _parentNameController.text.trim(),
        parentEmail: '', // Optional
        batchId: _selectedBatchId!,
        subjectIds: _selectedSubjectIds,
        totalFees: double.tryParse(_feesController.text) ?? 15000,
        feesPaid: 0,
        feeStatus: 'pending',
        enrollmentStatus: 'active',
        enrollmentDate: DateTime.now(),
      );

      final success = await _dbService.createStudent(student);
      if (!success) throw Exception('Failed to create student profile');

      setState(() {
        _generatedCredentials = {
          'id': email,
          'password': password,
        };
        _isLoading = false;
      });
      
      widget.onComplete();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_generatedCredentials != null) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                'Registration Successful!',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please share these credentials with the student:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.sp(context, 13),
                  color: AppColors.textMid,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _credentialRow('Login ID:', _generatedCredentials!['id']),
                    const Divider(height: 24),
                    _credentialRow('Password:', _generatedCredentials!['password']),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Student Admission',
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 18),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildField('Student Full Name', _nameController, Icons.person_outline),
                const SizedBox(height: 16),
                _buildField('Parent Full Name', _parentNameController, Icons.family_restroom_outlined),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildField('Email Address', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField('Admission Fees', _feesController, Icons.currency_rupee_rounded, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildField('Student Phone', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField('Parent Phone', _parentPhoneController, Icons.phone_android_outlined, keyboardType: TextInputType.phone)),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Academic Details',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Select Batch', Icons.group_outlined),
                  value: _selectedBatchId,
                  items: widget.batches
                      .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedBatchId = val;
                      // Auto-select subjects for this batch if not already selected
                      final batch = widget.batches.firstWhere((b) => b.id == val);
                      _selectedSubjectIds.clear();
                      _selectedSubjectIds.addAll(batch.subjects);
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Subjects',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 12),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMid,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.subjects.map((s) {
                    final isSelected = _selectedSubjectIds.contains(s.id);
                    return FilterChip(
                      label: Text(s.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSubjectIds.add(s.id);
                          } else {
                            _selectedSubjectIds.remove(s.id);
                          }
                        });
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Add Student to Database', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _credentialRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textMid)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'monospace')),
      ],
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
              Text(
                'Student-wise Fees',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 16),
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
                                  style: TextStyle(
                                    fontSize: Responsive.sp(context, 13),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  student.id,
                                  style: TextStyle(
                                    fontSize: Responsive.sp(context, 11),
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
                                    style: TextStyle(
                                      fontSize: Responsive.sp(context, 10),
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
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 11),
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
            style: TextStyle(
              fontSize: Responsive.sp(context, 11),
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.sp(context, 16),
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
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 11),
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
