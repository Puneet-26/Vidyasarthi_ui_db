import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class ScheduleExamScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;

  const ScheduleExamScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  State<ScheduleExamScreen> createState() => _ScheduleExamScreenState();
}

class _ScheduleExamScreenState extends State<ScheduleExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _maxMarksController = TextEditingController();

  String? _selectedBatch;
  String? _selectedSubject;
  DateTime? _selectedDate;
  bool _isSaving = false;

  List<Map<String, String>> _batches = [];
  List<Map<String, String>> _subjects = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final client = Supabase.instance.client;
      
      // Fetch Batches
      final batchesData = await client.from('batches').select('id, name');
      
      // Fetch Subjects
      final subjectsData = await client.from('subjects').select('id, name');

      if (mounted) {
        setState(() {
          _batches = List<Map<String, dynamic>>.from(batchesData)
              .map((b) => {'id': b['id'].toString(), 'name': b['name'].toString()})
              .toList();
          _subjects = List<Map<String, dynamic>>.from(subjectsData)
              .map((s) => {'id': s['id'].toString(), 'name': s['name'].toString()})
              .toList();
          _isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      if (mounted) {
        setState(() => _isLoadingData = false);
        _showError('Failed to load batches/subjects. Please check database connection.');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _maxMarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _scheduleExam() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBatch == null) {
      _showError('Please select a batch');
      return;
    }

    if (_selectedSubject == null) {
      _showError('Please select a subject');
      return;
    }

    if (_selectedDate == null) {
      _showError('Please select exam date');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final examData = {
        'id': _generateUuid(),
        'title': _titleController.text.trim(),
        'subject_id': _selectedSubject,
        'batch_id': _selectedBatch,
        'teacher_id': widget.teacherId,
        'test_date': _selectedDate!.toIso8601String(),
        'total_marks': int.parse(_maxMarksController.text),
        'status': 'scheduled',
        'created_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('tests').insert(examData);

      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Exam scheduled successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showError('Failed to schedule exam: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  String _generateUuid() {
    final random = Random.secure();
    String hex(int n) => random.nextInt(n).toRadixString(16).padLeft(4, '0');
    return '${hex(65536)}${hex(65536)}-${hex(65536)}-4${hex(4096).substring(1)}-${(8 + random.nextInt(4)).toRadixString(16)}${hex(4096).substring(1)}-${hex(65536)}${hex(65536)}${hex(65536)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Exam'),
        backgroundColor: AppColors.teacherAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingData 
        ? const Center(child: CircularProgressIndicator())
        : Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
            // Exam Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Exam Title *',
                hintText: 'e.g., Mid-Term Examination',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter exam title';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Batch Selection
            DropdownButtonFormField<String>(
              initialValue: _selectedBatch,
              decoration: InputDecoration(
                labelText: 'Select Batch *',
                prefixIcon: const Icon(Icons.class_),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _batches.map((batch) {
                return DropdownMenuItem(
                  value: batch['id'],
                  child: Text(batch['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedBatch = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a batch';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Subject Selection
            DropdownButtonFormField<String>(
              initialValue: _selectedSubject,
              decoration: InputDecoration(
                labelText: 'Select Subject *',
                prefixIcon: const Icon(Icons.book),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject['id'],
                  child: Text(subject['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedSubject = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a subject';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Exam Date
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Exam Date *',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Select date',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedDate != null
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Max Marks
            TextFormField(
              controller: _maxMarksController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Total Marks *',
                hintText: '100',
                prefixIcon: const Icon(Icons.grade),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                final marks = int.tryParse(value);
                if (marks == null || marks <= 0) {
                  return 'Invalid';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Schedule Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _scheduleExam,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.schedule),
                label: Text(_isSaving ? 'Scheduling...' : 'Schedule Exam'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teacherAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Students and parents will be notified about this exam',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
