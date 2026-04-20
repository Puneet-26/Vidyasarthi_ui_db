import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/database_service.dart';
import '../models/models.dart';

/// Submit Anonymous Feedback Screen
/// Allows students and parents to send anonymous feedback to teachers
class SubmitFeedbackScreen extends StatefulWidget {
  final String senderRole; // 'student' or 'parent'
  final String? senderId; // Optional for tracking
  
  const SubmitFeedbackScreen({
    super.key,
    required this.senderRole,
    this.senderId,
  });

  @override
  State<SubmitFeedbackScreen> createState() => _SubmitFeedbackScreenState();
}

class _SubmitFeedbackScreenState extends State<SubmitFeedbackScreen> {
  final _db = DatabaseService();
  final _feedbackController = TextEditingController();
  
  List<Map<String, String>> _teachers = [];
  bool _loading = true;
  bool _submitting = false;
  
  String? _selectedTeacherId;
  String? _selectedTeacherName;
  String _selectedCategory = 'teaching';
  int _selectedRating = 5;

  final List<Map<String, dynamic>> _categories = const [
    {'value': 'teaching', 'label': 'Teaching Style', 'icon': Icons.school_rounded},
    {'value': 'behavior', 'label': 'Behavior', 'icon': Icons.emoji_emotions_rounded},
    {'value': 'communication', 'label': 'Communication', 'icon': Icons.chat_rounded},
    {'value': 'subject_knowledge', 'label': 'Subject Knowledge', 'icon': Icons.psychology_rounded},
    {'value': 'punctuality', 'label': 'Punctuality', 'icon': Icons.access_time_rounded},
    {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    final teachers = await _db.getAllTeachersForFeedback();
    if (mounted) {
      setState(() {
        _teachers = teachers;
        _loading = false;
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (_selectedTeacherId == null) {
      _showError('Please select a teacher');
      return;
    }
    
    if (_feedbackController.text.trim().isEmpty) {
      _showError('Please write your feedback');
      return;
    }

    setState(() => _submitting = true);

    final feedback = AnonymousFeedback(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      senderRole: widget.senderRole,
      senderId: widget.senderId,
      teacherId: _selectedTeacherId!,
      teacherName: _selectedTeacherName!,
      category: _selectedCategory,
      feedbackText: _feedbackController.text.trim(),
      rating: _selectedRating,
      submittedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    final success = await _db.submitAnonymousFeedback(feedback);

    if (mounted) {
      setState(() => _submitting = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Feedback submitted successfully! It will be reviewed by admin.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      } else {
        _showError('Failed to submit feedback. Please try again.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Send Anonymous Feedback',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
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
                                'Your feedback is anonymous',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Teachers will not know who sent this feedback. It will be reviewed by admin first.',
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
                  const SizedBox(height: 24),

                  // Select Teacher
                  const Text(
                    'Select Teacher',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedTeacherId,
                        hint: const Text('Choose a teacher'),
                        items: _teachers.map((teacher) {
                          return DropdownMenuItem<String>(
                            value: teacher['id'],
                            child: Text(teacher['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTeacherId = value;
                            _selectedTeacherName = _teachers
                                .firstWhere((t) => t['id'] == value)['name'];
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Select Category
                  const Text(
                    'Feedback Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['value'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat['value'] as String),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.divider,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 18,
                                color: isSelected ? Colors.white : AppColors.textMid,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat['label'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Rating
                  const Text(
                    'Rating (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedRating = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < _selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: AppColors.warning,
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Feedback Text
                  const Text(
                    'Your Feedback',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _feedbackController,
                      maxLines: 6,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: 'Write your feedback here...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: AppColors.textLight),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Submit Feedback',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
