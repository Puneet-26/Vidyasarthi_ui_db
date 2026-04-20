import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/attendance_service.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String teacherId;
  final String batchId;
  final String batchName;
  final String subjectId;
  final String subjectName;

  const MarkAttendanceScreen({
    super.key,
    required this.teacherId,
    required this.batchId,
    required this.batchName,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  
  List<Map<String, dynamic>> _students = [];
  Map<String, String> _attendanceStatus = {}; // student_id -> status
  Map<String, String> _remarks = {}; // student_id -> remarks
  
  bool _isLoading = true;
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);

    try {
      // Load students
      final students = await _attendanceService.getStudentsForAttendance(
        batchId: widget.batchId,
      );

      // Load existing attendance for selected date
      final existingAttendance = await _attendanceService.getAttendanceByDate(
        batchId: widget.batchId,
        subjectId: widget.subjectId,
        date: _selectedDate,
      );

      // Initialize attendance status
      final statusMap = <String, String>{};
      final remarksMap = <String, String>{};

      for (final student in students) {
        final studentId = student['id'];
        // Check if attendance already marked
        final existing = existingAttendance.firstWhere(
          (a) => a['student_id'] == studentId,
          orElse: () => {},
        );

        if (existing.isNotEmpty) {
          statusMap[studentId] = existing['status'];
          remarksMap[studentId] = existing['remarks'] ?? '';
        } else {
          statusMap[studentId] = 'present'; // Default to present
          remarksMap[studentId] = '';
        }
      }

      setState(() {
        _students = students;
        _attendanceStatus = statusMap;
        _remarks = remarksMap;
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

  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);

    try {
      final attendanceRecords = _students.map((student) {
        final studentId = student['id'];
        return {
          'student_id': studentId,
          'status': _attendanceStatus[studentId] ?? 'present',
          'remarks': _remarks[studentId] ?? '',
        };
      }).toList();

      final result = await _attendanceService.markAttendance(
        batchId: widget.batchId,
        subjectId: widget.subjectId,
        teacherId: widget.teacherId,
        studentAttendance: attendanceRecords,
        date: _selectedDate,
      );

      setState(() => _isSaving = false);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Attendance saved successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to save attendance'),
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

  void _markAllPresent() {
    setState(() {
      for (final student in _students) {
        _attendanceStatus[student['id']] = 'present';
      }
    });
  }

  void _markAllAbsent() {
    setState(() {
      for (final student in _students) {
        _attendanceStatus[student['id']] = 'absent';
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _attendanceStatus.values.where((s) => s == 'present').length;
    final absentCount = _attendanceStatus.values.where((s) => s == 'absent').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: AppColors.teacherAccent,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _selectDate,
              tooltip: 'Select Date',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Info
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.teacherAccent.withOpacity(0.1),
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
                                  widget.batchName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.subjectName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total: ${_students.length}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatChip(
                              label: 'Present',
                              value: presentCount.toString(),
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatChip(
                              label: 'Absent',
                              value: absentCount.toString(),
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _markAllPresent,
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Mark All Present'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: const BorderSide(color: AppColors.success),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _markAllAbsent,
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Mark All Absent'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Student List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final studentId = student['id'];
                      final studentName = student['users']['name'];
                      final rollNumber = student['roll_number'];
                      final status = _attendanceStatus[studentId] ?? 'present';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
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
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _StatusChip(
                                    label: 'Present',
                                    icon: Icons.check_circle,
                                    color: AppColors.success,
                                    isSelected: status == 'present',
                                    onTap: () {
                                      setState(() {
                                        _attendanceStatus[studentId] = 'present';
                                      });
                                    },
                                  ),
                                  _StatusChip(
                                    label: 'Absent',
                                    icon: Icons.cancel,
                                    color: AppColors.error,
                                    isSelected: status == 'absent',
                                    onTap: () {
                                      setState(() {
                                        _attendanceStatus[studentId] = 'absent';
                                      });
                                    },
                                  ),
                                  _StatusChip(
                                    label: 'Late',
                                    icon: Icons.access_time,
                                    color: AppColors.warning,
                                    isSelected: status == 'late',
                                    onTap: () {
                                      setState(() {
                                        _attendanceStatus[studentId] = 'late';
                                      });
                                    },
                                  ),
                                  _StatusChip(
                                    label: 'Leave',
                                    icon: Icons.event_busy,
                                    color: AppColors.info,
                                    isSelected: status == 'leave',
                                    onTap: () {
                                      setState(() {
                                        _attendanceStatus[studentId] = 'leave';
                                      });
                                    },
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
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveAttendance,
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
                      label: Text(_isSaving ? 'Saving...' : 'Save Attendance'),
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
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
