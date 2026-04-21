import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'mark_attendance_screen.dart';

class SelectBatchForAttendanceScreen extends StatelessWidget {
  final String teacherId;
  final String teacherName;

  const SelectBatchForAttendanceScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    // Sample batches and subjects - in production, fetch from database
    final batches = [
      {
        'batchId': 'batch_12_science_a',
        'batchName': 'Class 12 Science A',
        'subjectId': 'sub_physics',
        'subjectName': 'Physics',
        'students': 35,
      },
      {
        'batchId': 'batch_12_science_b',
        'batchName': 'Class 12 Science B',
        'subjectId': 'sub_physics',
        'subjectName': 'Physics',
        'students': 35,
      },
      {
        'batchId': 'batch_11_science_a',
        'batchName': 'Class 11 Science A',
        'subjectId': 'sub_physics',
        'subjectName': 'Physics',
        'students': 40,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Batch'),
        backgroundColor: AppColors.teacherAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: batches.length,
        itemBuilder: (context, index) {
          final batch = batches[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.teacherAccent.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.class_,
                  color: AppColors.teacherAccent,
                ),
              ),
              title: Text(
                batch['batchName'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    batch['subjectName'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                  Text(
                    '${batch['students']} students',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textLight,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarkAttendanceScreen(
                      teacherId: teacherId,
                      batchId: batch['batchId'] as String,
                      batchName: batch['batchName'] as String,
                      subjectId: batch['subjectId'] as String,
                      subjectName: batch['subjectName'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
