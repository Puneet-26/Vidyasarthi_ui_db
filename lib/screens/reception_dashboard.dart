import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/database_service.dart';
import '../services/data_seeder.dart';
import '../models/models.dart';

class ReceptionDashboard extends StatefulWidget {
  const ReceptionDashboard({super.key});

  @override
  State<ReceptionDashboard> createState() => _ReceptionDashboardState();
}

class _ReceptionDashboardState extends State<ReceptionDashboard> {
  int _selectedIndex = 0;

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home'),
    BottomNavItem(
        icon: Icons.person_add_outlined,
        activeIcon: Icons.person_add_rounded,
        label: 'Add Student'),
    BottomNavItem(
        icon: Icons.people_outlined,
        activeIcon: Icons.people_rounded,
        label: 'Students'),
    BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person_rounded,
        label: 'Profile'),
  ];

  List<Widget> get _pages => [
        const _ReceptionHomePage(),
        const _AddStudentPage(),
        const _StudentsListPage(),
        const _ReceptionProfilePage(),
      ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      bottomNavigationBar: VidyaBottomNav(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: (i) => setState(() => _selectedIndex = i),
        activeColor: AppColors.primary,
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

// ─── Reception Home Page ─────────────────────────────────────────────────────
class _ReceptionHomePage extends StatefulWidget {
  const _ReceptionHomePage();

  @override
  State<_ReceptionHomePage> createState() => _ReceptionHomePageState();
}

class _ReceptionHomePageState extends State<_ReceptionHomePage> {
  bool _isSeeding = false;

  Future<void> _seedDatabase() async {
    setState(() => _isSeeding = true);

    try {
      final seeder = DataSeeder();
      await seeder.seedDatabase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Database seeded successfully with 120+ students!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Database seeding failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSeeding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(
            name: 'Reception Staff',
            role: 'RECEPTION',
            subtitle: 'Reception Dashboard',
            roleColor: AppColors.primary,
            notificationCount: 0,
            onNotification: () {},
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: 'Add New Student',
                  icon: Icons.person_add_rounded,
                  color: AppColors.success,
                  onTap: () => Navigator.pushNamed(context, '/add-student'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  title: 'View Students',
                  icon: Icons.people_rounded,
                  color: AppColors.info,
                  onTap: () => Navigator.pushNamed(context, '/students-list'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: _isSeeding ? 'Seeding...' : 'Seed Database',
                  icon: _isSeeding
                      ? Icons.hourglass_empty
                      : Icons.storage_rounded,
                  color: AppColors.warning,
                  onTap: _isSeeding ? () {} : _seedDatabase,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()), // Empty space for alignment
            ],
          ),
          const SizedBox(height: 24),

          // Statistics
          const SectionHeader(title: 'Today\'s Summary'),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'New Admissions',
                  value: '3',
                  icon: Icons.person_add_rounded,
                  color: AppColors.success,
                  subtitle: 'Today',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Total Students',
                  value: '156',
                  icon: Icons.people_rounded,
                  color: AppColors.primary,
                  subtitle: 'Active',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Add Student Page ────────────────────────────────────────────────────────
class _AddStudentPage extends StatefulWidget {
  const _AddStudentPage();

  @override
  State<_AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<_AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();

  // Student Information Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _addressController = TextEditingController();

  // Parent Information Controllers
  final _parentNameController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  // Fee Information Controllers
  final _totalFeesController = TextEditingController();

  DateTime? _dateOfBirth;
  String _selectedBatch = 'batch_12_science';
  List<String> _selectedSubjects = [];
  bool _isLoading = false;

  final List<Map<String, String>> _batches = [
    {'id': 'batch_12_science', 'name': 'Class 12 Science'},
    {'id': 'batch_11_science', 'name': 'Class 11 Science'},
    {'id': 'batch_10_all', 'name': 'Class 10'},
  ];

  final List<Map<String, String>> _subjects = [
    {'id': 'sub_physics', 'name': 'Physics'},
    {'id': 'sub_chemistry', 'name': 'Chemistry'},
    {'id': 'sub_mathematics', 'name': 'Mathematics'},
    {'id': 'sub_biology', 'name': 'Biology'},
    {'id': 'sub_english', 'name': 'English'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rollNumberController.dispose();
    _addressController.dispose();
    _parentNameController.dispose();
    _parentEmailController.dispose();
    _parentPhoneController.dispose();
    _totalFeesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2006),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _dateOfBirth = date);
    }
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }
    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one subject')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final studentId = 'student_${DateTime.now().millisecondsSinceEpoch}';
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

      final student = Student(
        id: studentId,
        userId: userId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        batchId: _selectedBatch,
        rollNumber: _rollNumberController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        address: _addressController.text.trim(),
        parentName: _parentNameController.text.trim(),
        parentEmail: _parentEmailController.text.trim(),
        parentPhone: _parentPhoneController.text.trim(),
        admissionDate: DateTime.now(),
        enrollmentDate: DateTime.now(),
        totalFees: double.tryParse(_totalFeesController.text) ?? 50000,
        feesPaid: 0,
        feeStatus: 'pending',
        isActive: true,
        enrollmentStatus: 'active',
        subjectIds: _selectedSubjects,
      );

      final success = await _db.createStudent(student);

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Student ${student.name} added successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Failed to add student. Please check the console for details and try again.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _rollNumberController.clear();
    _addressController.clear();
    _parentNameController.clear();
    _parentEmailController.clear();
    _parentPhoneController.clear();
    _totalFeesController.clear();
    setState(() {
      _dateOfBirth = null;
      _selectedBatch = 'batch_12_science';
      _selectedSubjects.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Add New Student'),
            const SizedBox(height: 20),

            // Student Information Section
            const Text(
              'Student Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outlined,
              validator: (value) =>
                  value?.isEmpty == true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty == true) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value!)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value?.isEmpty == true ? 'Phone number is required' : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _rollNumberController,
                    label: 'Roll Number',
                    icon: Icons.numbers_outlined,
                    validator: (value) => value?.isEmpty == true
                        ? 'Roll number is required'
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDateOfBirth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _dateOfBirth == null
                                  ? 'Date of Birth'
                                  : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                              style: TextStyle(
                                color: _dateOfBirth == null
                                    ? AppColors.textLight
                                    : AppColors.textDark,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (value) =>
                  value?.isEmpty == true ? 'Address is required' : null,
            ),
            const SizedBox(height: 24),

            // Batch Selection
            const Text(
              'Batch & Subjects',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedBatch,
              decoration: InputDecoration(
                labelText: 'Select Batch',
                prefixIcon:
                    const Icon(Icons.class_outlined, color: AppColors.primary),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _batches
                  .map((batch) => DropdownMenuItem(
                        value: batch['id'],
                        child: Text(batch['name']!),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedBatch = value!),
            ),
            const SizedBox(height: 16),

            // Subject Selection
            const Text('Select Subjects:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _subjects.map((subject) {
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
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Parent Information Section
            const Text(
              'Parent Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _parentNameController,
              label: 'Parent Name',
              icon: Icons.person_outline,
              validator: (value) =>
                  value?.isEmpty == true ? 'Parent name is required' : null,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _parentEmailController,
              label: 'Parent Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty == true) return 'Parent email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value!)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _parentPhoneController,
              label: 'Parent Phone',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value?.isEmpty == true ? 'Parent phone is required' : null,
            ),
            const SizedBox(height: 24),

            // Fee Information
            const Text(
              'Fee Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _totalFeesController,
              label: 'Total Annual Fees (₹)',
              icon: Icons.currency_rupee_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) =>
                  value?.isEmpty == true ? 'Total fees is required' : null,
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Adding Student...',
                              style: TextStyle(color: Colors.white)),
                        ],
                      )
                    : const Text(
                        'Add Student',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// ─── Students List Page ──────────────────────────────────────────────────────
class _StudentsListPage extends StatefulWidget {
  const _StudentsListPage();

  @override
  State<_StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<_StudentsListPage> {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader(title: 'All Students'),
              IconButton(
                onPressed: _loadStudents,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_students.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No students found.\nAdd some students to see them here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMid),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final student = _students[index];
                return _StudentCard(student: student);
              },
            ),
        ],
      ),
    );
  }
}

// ─── Reception Profile Page ──────────────────────────────────────────────────
class _ReceptionProfilePage extends StatelessWidget {
  const _ReceptionProfilePage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const GradientAvatar(
              initials: 'RS', color: AppColors.primary, size: 72),
          const SizedBox(height: 12),
          const Text(
            'Reception Staff',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const Text(
            'Student Admissions',
            style: TextStyle(fontSize: 13, color: AppColors.textMid),
          ),
          const SizedBox(height: 24),
          const GlassCard(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _ProfileRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: 'reception@vidya.com',
                ),
                Divider(height: 20),
                _ProfileRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: '+91-9876543200',
                ),
              ],
            ),
          ),
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
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
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
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
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

class _StudentCard extends StatelessWidget {
  final Student student;

  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GradientAvatar(
            initials: student.name.substring(0, 2).toUpperCase(),
            color: AppColors.primary,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${student.rollNumber} • ${student.batchId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMid,
                  ),
                ),
                Text(
                  student.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: student.feeStatus == 'full'
                  ? AppColors.success.withValues(alpha: 0.12)
                  : student.feeStatus == 'partial'
                      ? AppColors.warning.withValues(alpha: 0.12)
                      : AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              student.feeStatus.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: student.feeStatus == 'full'
                    ? AppColors.success
                    : student.feeStatus == 'partial'
                        ? AppColors.warning
                        : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textLight),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
