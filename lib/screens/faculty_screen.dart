import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Know Our Faculty Screen
/// Displays list of faculty members with their details
class FacultyScreen extends StatelessWidget {
  const FacultyScreen({super.key});

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
          'Know Our Faculty',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header message
            const GlassCard(
              child: Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meet Our Educators',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Dedicated professionals committed to your success',
                          style: TextStyle(
                            fontSize: 12,
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

            // Faculty Members
            const SectionHeader(title: 'Our Faculty'),
            const SizedBox(height: 14),

            _FacultyCard(
              name: 'Dr. Arun Kumar',
              designation: 'Head of Physics Department',
              subject: 'Physics',
              qualification: 'Ph.D. in Quantum Physics',
              experience: '15 years',
              email: 'arun.kumar@vidyasarthi.edu.in',
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),

            _FacultyCard(
              name: 'Mrs. Priya Sharma',
              designation: 'Senior Chemistry Teacher',
              subject: 'Chemistry',
              qualification: 'M.Sc. in Organic Chemistry',
              experience: '12 years',
              email: 'priya.sharma@vidyasarthi.edu.in',
              color: AppColors.info,
            ),
            const SizedBox(height: 12),

            _FacultyCard(
              name: 'Mr. Vikram Singh',
              designation: 'Mathematics Department Head',
              subject: 'Mathematics',
              qualification: 'M.Sc. in Applied Mathematics',
              experience: '18 years',
              email: 'vikram.singh@vidyasarthi.edu.in',
              color: AppColors.success,
            ),
            const SizedBox(height: 12),

            _FacultyCard(
              name: 'Dr. Meera Patel',
              designation: 'English Literature Professor',
              subject: 'English',
              qualification: 'Ph.D. in English Literature',
              experience: '10 years',
              email: 'meera.patel@vidyasarthi.edu.in',
              color: AppColors.warning,
            ),
            const SizedBox(height: 12),

            _FacultyCard(
              name: 'Mr. Rajesh Gupta',
              designation: 'Computer Science Teacher',
              subject: 'Computer Science',
              qualification: 'M.Tech in Computer Science',
              experience: '8 years',
              email: 'rajesh.gupta@vidyasarthi.edu.in',
              color: const Color(0xFF9C27B0),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

/// Faculty Card Widget
class _FacultyCard extends StatelessWidget {
  final String name;
  final String designation;
  final String subject;
  final String qualification;
  final String experience;
  final String email;
  final Color color;

  const _FacultyCard({
    required this.name,
    required this.designation,
    required this.subject,
    required this.qualification,
    required this.experience,
    required this.email,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),

              // Name and designation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      designation,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMid,
                      ),
                    ),
                  ],
                ),
              ),

              // Subject badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subject,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 10),

          // Details
          _DetailRow(
            icon: Icons.school_rounded,
            label: 'Qualification',
            value: qualification,
          ),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.work_history_rounded,
            label: 'Experience',
            value: experience,
          ),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.email_rounded,
            label: 'Email',
            value: email,
          ),
        ],
      ),
    );
  }
}

/// Detail Row Widget
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
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textLight,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMid,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
