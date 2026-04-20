import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/attendance_service.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewAttendanceScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const ViewAttendanceScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  
  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  
  // Real-time subscription
  RealtimeChannel? _attendanceChannel;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _attendanceChannel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    // Subscribe to attendance changes for this student
    _attendanceChannel = Supabase.instance.client
        .channel('attendance_${widget.studentId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'attendance',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'student_id',
            value: widget.studentId,
          ),
          callback: (payload) {
            debugPrint('🔔 Attendance updated in real-time!');
            
            // Show notification
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Attendance updated!'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            
            // Reload data when attendance changes
            _loadAttendanceData();
          },
        )
        .subscribe();
  }

  Future<void> _loadAttendanceData() async {
    setState(() => _isLoading = true);

    try {
      // Load summary for current month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      final summary = await _attendanceService.getStudentAttendanceSummary(
        studentId: widget.studentId,
        startDate: startOfMonth,
        endDate: now,
      );

      final history = await _attendanceService.getStudentAttendanceHistory(
        studentId: widget.studentId,
        limit: 50,
      );

      setState(() {
        _summary = summary;
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading attendance: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return AppColors.success;
      case 'absent':
        return AppColors.error;
      case 'late':
        return AppColors.warning;
      case 'leave':
        return AppColors.info;
      case 'half_day':
        return AppColors.warning;
      default:
        return AppColors.textLight;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.access_time;
      case 'leave':
        return Icons.event_busy;
      case 'half_day':
        return Icons.timelapse;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppColors.studentAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAttendanceData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Info
                    Text(
                      widget.studentName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current Month Attendance',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Attendance Percentage Card
                    GlassCard(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.success,
                                      AppColors.success.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${_summary['percentage'] ?? '0'}%',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _SummaryItem(
                                label: 'Present',
                                value: '${_summary['present'] ?? 0}',
                                color: AppColors.success,
                                icon: Icons.check_circle,
                              ),
                              _SummaryItem(
                                label: 'Absent',
                                value: '${_summary['absent'] ?? 0}',
                                color: AppColors.error,
                                icon: Icons.cancel,
                              ),
                              _SummaryItem(
                                label: 'Late',
                                value: '${_summary['late'] ?? 0}',
                                color: AppColors.warning,
                                icon: Icons.access_time,
                              ),
                              _SummaryItem(
                                label: 'Leave',
                                value: '${_summary['leave'] ?? 0}',
                                color: AppColors.info,
                                icon: Icons.event_busy,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Attendance History
                    const Text(
                      'Attendance History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_history.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'No attendance records found',
                            style: TextStyle(color: AppColors.textLight),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final record = _history[index];
                          final date = DateTime.parse(record['attendance_date']);
                          final status = record['status'];
                          final subject = record['subjects'];
                          final teacher = record['teachers'];
                          final remarks = record['remarks'] ?? '';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(status).withOpacity(0.2),
                                child: Icon(
                                  _getStatusIcon(status),
                                  color: _getStatusColor(status),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                DateFormat('EEEE, MMM d, yyyy').format(date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    subject != null ? subject['name'] : 'N/A',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  if (teacher != null && teacher['users'] != null)
                                    Text(
                                      'Teacher: ${teacher['users']['name']}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  if (remarks.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Note: $remarks',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getStatusColor(status),
                                  ),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}
