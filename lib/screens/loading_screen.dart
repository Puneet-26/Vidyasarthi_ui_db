import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/student_dashboard.dart';
import '../screens/teacher_dashboard.dart';
import '../screens/parent_dashboard.dart';
import '../screens/admin_dashboard.dart';
import '../screens/reception_dashboard.dart';
import '../widgets/shared_widgets.dart';

class LoadingScreen extends StatefulWidget {
  final String role;
  final String? userEmail;

  const LoadingScreen({super.key, required this.role, this.userEmail});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Navigate after delay
    Future.delayed(const Duration(seconds: 3), _navigateToDashboard);
  }

  void _navigateToDashboard() {
    Widget destination;

    switch (widget.role.toLowerCase()) {
      case 'super_admin':
        destination = const AdminDashboard();
        break;
      case 'admin_staff':
        destination = const ReceptionDashboard();
        break;
      case 'teacher':
        destination = TeacherDashboard(teacherEmail: widget.userEmail);
        break;
      case 'student':
        destination = const StudentDashboard();
        break;
      case 'parent':
        destination = ParentDashboard(parentEmail: widget.userEmail ?? 'rajesh.sharma@parents.com');
        break;
      default:
        destination = const StudentDashboard();
    }

    Navigator.of(context).pushReplacementNamed(
      '/dashboard',
      arguments: destination,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradStart,
              AppColors.gradMid,
              AppColors.gradEnd,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'VIDYASARATHI',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 28),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Welcome, ${widget.role}',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 16),
                    color: AppColors.textMid,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading your dashboard...',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 13),
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
