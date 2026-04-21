import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ViewExamsScreen extends StatefulWidget {
  final String? studentId;
  final String? batchId;
  final String title;

  const ViewExamsScreen({
    super.key,
    this.studentId,
    this.batchId,
    this.title = 'Upcoming Exams',
  });

  @override
  State<ViewExamsScreen> createState() => _ViewExamsScreenState();
}

class _ViewExamsScreenState extends State<ViewExamsScreen> {
  List<Map<String, dynamic>> _exams = [];
  bool _isLoading = true;
  RealtimeChannel? _examChannel;

  @override
  void initState() {
    super.initState();
    _loadExams();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _examChannel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    _examChannel = Supabase.instance.client
        .channel('exams_${widget.batchId ?? widget.studentId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tests',
          callback: (payload) {
            debugPrint('🔔 Exam schedule updated!');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Exam schedule updated!'),
                    ],
                  ),
                  backgroundColor: AppColors.info,
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _loadExams();
            }
          },
        )
        .subscribe();
  }

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);

    try {
      var query = Supabase.instance.client
          .from('tests')
          .select('*')
          .gte('test_date', DateTime.now().toIso8601String().split('T')[0]);

      if (widget.batchId != null) {
        query = query.eq('batch_id', widget.batchId!);
      }

      final response = await query.order('test_date', ascending: true);
      final exams = List<Map<String, dynamic>>.from(response);

      setState(() {
        _exams = exams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading exams: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return AppColors.info;
      case 'ongoing':
        return AppColors.warning;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'scheduled':
        return Icons.schedule;
      case 'ongoing':
        return Icons.play_circle;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getTimeRemaining(DateTime examDate) {
    final now = DateTime.now();
    final difference = examDate.difference(now);

    if (difference.isNegative) {
      return 'Past';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} left';
    } else {
      return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.studentAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadExams,
              child: _exams.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No upcoming exams',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _exams.length,
                      itemBuilder: (context, index) {
                        final exam = _exams[index];
                        final examDate = DateTime.parse(exam['test_date']);
                        final status = exam['status'] ?? 'scheduled';
                        final timeRemaining = _getTimeRemaining(examDate);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              _showExamDetails(exam);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          exam['title'] ?? 'Exam',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _getStatusColor(status),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getStatusIcon(status),
                                              size: 14,
                                              color: _getStatusColor(status),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: _getStatusColor(status),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: AppColors.textLight,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat('EEEE, MMM d, yyyy')
                                            .format(examDate),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: AppColors.textLight,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${exam['start_time']} • ${exam['duration_minutes']} mins',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.grade,
                                        size: 16,
                                        color: AppColors.textLight,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Max Marks: ${exam['max_marks']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (exam['room_number'] != null &&
                                          exam['room_number'].toString().isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.meeting_room,
                                              size: 16,
                                              color: AppColors.textLight,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              exam['room_number'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          size: 14,
                                          color: AppColors.warning,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          timeRemaining,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _showExamDetails(Map<String, dynamic> exam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exam['title'] ?? 'Exam Details',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (exam['description'] != null &&
                exam['description'].toString().isNotEmpty) ...[
              Text(
                exam['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),
            ],
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: DateFormat('EEEE, MMM d, yyyy')
                  .format(DateTime.parse(exam['test_date'])),
            ),
            _DetailRow(
              icon: Icons.access_time,
              label: 'Time',
              value: exam['start_time'] ?? 'N/A',
            ),
            _DetailRow(
              icon: Icons.timer,
              label: 'Duration',
              value: '${exam['duration_minutes']} minutes',
            ),
            _DetailRow(
              icon: Icons.grade,
              label: 'Max Marks',
              value: exam['max_marks'].toString(),
            ),
            if (exam['room_number'] != null &&
                exam['room_number'].toString().isNotEmpty)
              _DetailRow(
                icon: Icons.meeting_room,
                label: 'Room',
                value: exam['room_number'],
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
