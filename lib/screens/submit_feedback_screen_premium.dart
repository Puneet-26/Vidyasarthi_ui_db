import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/models.dart';
import 'package:uuid/uuid.dart';

/// Premium Anonymous Feedback Screen
/// Modern, clean UI with smooth animations and professional design
class SubmitFeedbackScreenPremium extends StatefulWidget {
  final String senderRole; // 'student' or 'parent'
  final String? senderId;
  
  const SubmitFeedbackScreenPremium({
    super.key,
    required this.senderRole,
    this.senderId,
  });

  @override
  State<SubmitFeedbackScreenPremium> createState() => _SubmitFeedbackScreenPremiumState();
}

class _SubmitFeedbackScreenPremiumState extends State<SubmitFeedbackScreenPremium> 
    with SingleTickerProviderStateMixin {
  
  // Form state
  String? _selectedTeacher;
  String? _selectedTeacherName;
  String _selectedCategory = 'teaching';
  int _selectedRating = 0;
  final _feedbackController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Database
  final _dbService = DatabaseService();
  List<Map<String, String>> _teachers = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Categories with icons
  final List<Map<String, dynamic>> _categories = [
    {'value': 'teaching', 'label': 'Teaching Style', 'icon': Icons.school_rounded},
    {'value': 'behavior', 'label': 'Behavior', 'icon': Icons.emoji_emotions_rounded},
    {'value': 'communication', 'label': 'Communication', 'icon': Icons.chat_rounded},
    {'value': 'subject_knowledge', 'label': 'Subject Knowledge', 'icon': Icons.psychology_rounded},
    {'value': 'punctuality', 'label': 'Punctuality', 'icon': Icons.access_time_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final teachers = await _dbService.getAllTeachersForFeedback();
    setState(() {
      _teachers = teachers;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return !_isSubmitting; // Button always enabled unless submitting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Premium gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE8EAF6),
              Color(0xFFF3E5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              _buildAppBar(),
              
              // Scrollable content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info Card
                        _buildInfoCard(),
                        const SizedBox(height: 28),
                        
                        // Teacher Selection
                        _buildSectionTitle('Select Teacher'),
                        const SizedBox(height: 12),
                        _buildTeacherDropdown(),
                        const SizedBox(height: 28),
                        
                        // Category Selection
                        _buildSectionTitle('Feedback Category'),
                        const SizedBox(height: 12),
                        _buildCategoryChips(),
                        const SizedBox(height: 28),
                        
                        // Rating Section
                        _buildSectionTitle('Rate Your Experience *'),
                        const SizedBox(height: 8),
                        _buildRatingStars(),
                        const SizedBox(height: 28),
                        
                        // Feedback Input
                        _buildSectionTitle('Your Feedback'),
                        const SizedBox(height: 12),
                        _buildFeedbackInput(),
                        const SizedBox(height: 32),
                        
                        // Submit Button
                        _buildSubmitButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== UI COMPONENTS ====================

  /// Custom AppBar with gradient
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
            color: const Color(0xFF5E35B1),
          ),
          const Text(
            'Anonymous Feedback',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3142),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Info card with lock icon
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your feedback is anonymous',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'It will be reviewed by admin before reaching the teacher',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2D3142),
        letterSpacing: -0.3,
      ),
    );
  }

  /// Premium teacher dropdown
  Widget _buildTeacherDropdown() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_teachers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('No teachers available'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedTeacher,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF667EEA)),
          hintText: 'Choose a teacher',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF667EEA)),
        dropdownColor: Colors.white,
        items: _teachers.map((teacher) {
          return DropdownMenuItem<String>(
            value: teacher['id'],
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school_rounded, size: 18, color: Color(0xFF667EEA)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        teacher['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        teacher['subject'] ?? 'General',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedTeacher = value;
            _selectedTeacherName = _teachers.firstWhere((t) => t['id'] == value)['name'];
          });
        },
      ),
    );
  }

  /// Modern category chips
  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = cat['value'] as String;
              _selectedRating = 0; // Reset rating when category changes
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    )
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey[300]!,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat['icon'] as IconData,
                  size: 18,
                  color: isSelected ? Colors.white : const Color(0xFF667EEA),
                ),
                const SizedBox(width: 8),
                Text(
                  cat['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF2D3142),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Star rating with animation
  Widget _buildRatingStars() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: _selectedRating == 0 
            ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _selectedRating == 0 ? 'Please rate (required)' : 'Tap to change rating',
            style: TextStyle(
              fontSize: 12,
              color: _selectedRating == 0 ? Colors.red : const Color(0xFF9E9E9E),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedScale(
                    scale: _selectedRating >= index + 1 ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      index < _selectedRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: index < _selectedRating
                          ? const Color(0xFFFFA726)
                          : Colors.grey[300],
                      size: 40,
                    ),
                  ),
                ),
              );
            }),
          ),
          if (_selectedRating > 0) ...[
            const SizedBox(height: 8),
            Text(
              _getRatingText(_selectedRating),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF667EEA),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return '';
    }
  }

  /// Premium feedback input
  Widget _buildFeedbackInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _feedbackController,
            maxLines: 6,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Write your feedback here...\n\nBe specific and constructive.',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(20),
              counterStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9E9E9E),
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }

  /// Premium submit button with gradient
  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: _canSubmit
            ? const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              )
            : null,
        color: _canSubmit ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        boxShadow: _canSubmit
            ? [
                BoxShadow(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _canSubmit ? _handleSubmit : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        color: _canSubmit ? Colors.white : Colors.grey[500],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Submit Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _canSubmit ? Colors.white : Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ==================== ACTIONS ====================

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    // Validate all required fields
    if (_selectedTeacher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a teacher'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please give a rating (1-5 stars)'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write your feedback'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);

    try {
      // Create feedback object
      final feedback = AnonymousFeedback(
        id: const Uuid().v4(),
        senderRole: widget.senderRole,
        senderId: widget.senderId,
        teacherId: _selectedTeacher!,
        teacherName: _selectedTeacherName!,
        category: _selectedCategory,
        feedbackText: _feedbackController.text.trim(),
        rating: _selectedRating, // Now required, not optional
        submittedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Submit to database
      final success = await _dbService.submitAnonymousFeedback(feedback);

      if (!mounted) return;

      if (success) {
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildSuccessDialog(),
        );
        
        // Auto close after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Close feedback screen
        }
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit feedback. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Feedback Submitted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your feedback will be reviewed by admin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
