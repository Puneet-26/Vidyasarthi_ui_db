import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/marks_service.dart';

class EnterMarksScreen extends StatefulWidget {
  final String teacherId;
  final String testId;
  final String testName;
  final String batchId;
  final String batchName;
  final int maxMarks;

  const EnterMarksScreen({
    super.key,
    required this.teacherId,
    required this.testId,
    required this.testName,
    required this.batchId,
    required this.batchName,
    required this.maxMarks,
  });

  @override
  State<EnterMarksScreen> createState() => _EnterMarksScreenState();
}

class _EnterMarksScreenState extends State<EnterMarksScreen> {
  final MarksService _marksService = MarksService();
  
  List<Map<String, dynamic>> _students = [];
  Map<String, TextEditingController> _marksControllers = {};
  Map<String, double> _percentages = {};
  Map<String, String> _grades = {};
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    for (var controller in _marksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);

    try {
      final students = await _marksService.getStudentsForMarks(
        batchId: widget.batchId,
      );

      // Load existing marks if any
      final existingMarks = await _marksService.getMarksByTest(
        testId: widget.testId,
      );

      final controllers = <String, TextEditingController>{};
      final percentages = <String, double>{};
      final grades = <String, String>{};

      for (final student in students) {
        final studentId = student['id'];
        final existing = existingMarks.firstWhere(
          (m) => m['student_id'] == studentId,
          orElse: () => {},
        );

        final marksObtained = existing.isNotEmpty 
            ? (existing['marks_obtained'] ?? 0).toString()
            : '';
        
        controllers[studentId] = TextEditingController(text: marksObtained);
        
        if (marksObtained.isNotEmpty) {
          final marks = double.tryParse(marksObtained) ?? 0;
          final percentage = (marks / widget.maxMarks) * 100;
          percentages[studentId] = percentage;
          grades[studentId] = _marksService.calculateGrade(percentage);
        }
      }

      setState(() {
        _students = students;
        _marksControllers = controllers;
        _percentages = percentages;
        _grades = grades;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading students: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _calculateGrade(String studentId, String marksText) {
    final marks = double.tryParse(marksText);
    if (marks != null && marks >= 0 && marks <= widget.maxMarks) {
      final percentage = (marks / widget.maxMarks) * 100;
      final grade = _marksService.calculateGrade(percentage);
      
      setState(() {
        _percentages[studentId] = percentage;
        _grades[studentId] = grade;
      });
    } else {
      setState(() {
        _percentages.remove(studentId);
        _grades.remove(studentId);
      });
    }
  }

  Future<void> _saveMarks() async {
    // Validate all marks are entered
    final studentMarks = <Map<String, dynamic>>[];
    
    for (final student in _students) {
      final studentId = student['id'];
      final marksText = _marksControllers[studentId]?.text ?? '';
      
      if (marksText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter marks for all students'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      final marks = double.tryParse(marksText);
      if (marks == null || marks < 0 || marks > widget.maxMarks) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid marks for ${student['users']['name']}'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      studentMarks.add({
        'student_id': studentId,
        'marks_obtained': marks,
        'max_marks': widget.maxMarks,
        'percentage': _percentages[studentId] ?? 0,
        'grade': _grades[studentId] ?? 'F',
        'remarks': '',
      });
    }

    setState(() => _isSaving = true);

    try {
      final result = await _marksService.enterMarks(
        testId: widget.testId,
        batchId: widget.batchId,
        subjectId: '',
        teacherId: widget.teacherId,
        studentMarks: studentMarks,
      );

      setState(() => _isSaving = false);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Marks saved successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to save marks'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enteredCount = _marksControllers.values.where((c) => c.text.isNotEmpty).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Marks'),
        backgroundColor: AppColors.teacherAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Info
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.teacherAccent.withValues(alpha: 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.testName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.batchName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoChip(
                              label: 'Max Marks',
                              value: widget.maxMarks.toString(),
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _InfoChip(
                              label: 'Entered',
                              value: '$enteredCount/${_students.length}',
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Student List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final studentId = student['id'];
                      final studentName = student['users']['name'];
                      final rollNumber = student['roll_number'];
                      final percentage = _percentages[studentId];
                      final grade = _grades[studentId];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primaryLight,
                                    child: Text(
                                      studentName[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          studentName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Roll: $rollNumber',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (grade != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getGradeColor(grade).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _getGradeColor(grade),
                                        ),
                                      ),
                                      child: Text(
                                        grade,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _getGradeColor(grade),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _marksControllers[studentId],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d{0,2}'),
                                        ),
                                      ],
                                      decoration: InputDecoration(
                                        labelText: 'Marks Obtained',
                                        hintText: '0',
                                        suffixText: '/ ${widget.maxMarks}',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        _calculateGrade(studentId, value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (percentage != null)
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.info.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppColors.info.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              '${percentage.toStringAsFixed(1)}%',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.info,
                                              ),
                                            ),
                                            const Text(
                                              'Percentage',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textLight,
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
                        ),
                      );
                    },
                  ),
                ),

                // Save Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveMarks,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save Marks'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teacherAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return AppColors.success;
      case 'B+':
      case 'B':
        return AppColors.info;
      case 'C':
        return AppColors.warning;
      case 'D':
      case 'F':
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
