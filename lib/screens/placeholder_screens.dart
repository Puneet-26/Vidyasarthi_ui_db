import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

// Placeholder screens for Phase 2-5 features

// ============ Phase 2: Timetable Management ============
class TimetableManagementScreen extends StatelessWidget {
  const TimetableManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Timetable',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Timetable Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 20),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text('📅 Weekly Timetable',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('View and manage class schedules', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('View Timetable'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.swap_horizontal_circle_rounded, size: 48, color: AppColors.studentAccent),
                    const SizedBox(height: 12),
                    const Text('🔄 Proxy Lectures',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('Manage substitute teachers', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.studentAccent),
                      child: const Text('Manage Proxies'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Phase 2: Syllabus Tracking ============
class SyllabusTrackingScreen extends StatelessWidget {
  const SyllabusTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Syllabus',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Syllabus & Portion Tracking',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 20),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.checklist_rounded, size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text('📚 Teacher View',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('Track topics completed and assignments', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('View Syllabus Checklist'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.trending_up_rounded, size: 48, color: AppColors.parentAccent),
                    const SizedBox(height: 12),
                    const Text('👁️ Student/Parent View',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('See progress bars of completed topics', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.parentAccent),
                      child: const Text('View Progress'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Phase 2: Homework System ============
class HomeworkSystemScreen extends StatelessWidget {
  const HomeworkSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Homework',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Homework Tracking',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 20),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.assignment_rounded, size: 48, color: AppColors.teacherAccent),
                    const SizedBox(height: 12),
                    const Text('👨‍🏫 Assign & Track',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('Assign homework and mark submission status', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherAccent),
                      child: const Text('Manage Homework'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.notifications_active_rounded, size: 48, color: Colors.orange),
                    const SizedBox(height: 12),
                    const Text('🔔 Auto-Notifications',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('Notify parents of incomplete homework', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text('View Notifications'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Phase 3: Fee Management ============
class FeePaymentPortalScreen extends StatelessWidget {
  const FeePaymentPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Fee Payment',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fee Management Portal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 20),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, size: 48, color: Colors.green),
                    const SizedBox(height: 12),
                    const Text('💳 Process Payments',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('Record student fee payments and concessions', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Manage Payments'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_rounded, size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text('📋 View Balance',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('Check remaining dues and payment history', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('View Balance'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Phase 3: Live Class Integration ============
class LiveClassScreen extends StatelessWidget {
  const LiveClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Live Classes',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Live Class Integration',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 20),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.video_call_rounded, size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text('🎥 Join Live Class',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('Access Zoom/Google Meet links (Fee-locked)', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Join Class'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Phase 4: Feedback System ============
class FeedbackSystemScreen extends StatelessWidget {
  const FeedbackSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Feedback',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Feedback Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 20),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.feedback_rounded, size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text('💭 Submit Feedback',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('Share anonymous suggestions (Parent-only)', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Submit Feedback'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Phase 4: Doubt Tracking ============
class DoubtTrackingScreen extends StatelessWidget {
  const DoubtTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Doubts',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Doubt & Query Tracking',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 20),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.help_rounded, size: 48, color: AppColors.studentAccent),
                    const SizedBox(height: 12),
                    const Text('❓ Raise a Doubt',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('Submit questions for teachers to resolve', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.studentAccent),
                      child: const Text('Ask Question'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Phase 5: Tests & Practice ============
class TestsAndPracticeScreen extends StatelessWidget {
  const TestsAndPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Tests',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tests & Practice',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 20),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.quiz_rounded, size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text('📝 MCQ Practice',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('Self-study practice with multiple-choice questions', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Start Practice'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.leaderboard_rounded, size: 48, color: Colors.orange),
                    const SizedBox(height: 12),
                    const Text('📊 Test Results',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('View scores and performance analysis', style: TextStyle(color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text('View Results'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Phase 5: Self-Study Room Availability ============
class SelfStudyRoomScreen extends StatelessWidget {
  const SelfStudyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Self-Study Rooms',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Self-Study Room Availability',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              SizedBox(height: 20),
              GlassCard(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.meeting_room, size: 48, color: Colors.green),
                    SizedBox(height: 12),
                    Text('🚪 Room A',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    SizedBox(height: 8),
                    Text('Status: Available (3/20 students)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text('Capacity: 20 students', style: TextStyle(color: AppColors.textMid)),
                  ],
                ),
              ),
              SizedBox(height: 12),
              GlassCard(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.meeting_room, size: 48, color: Colors.orange),
                    SizedBox(height: 12),
                    Text('🚪 Room B',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    SizedBox(height: 8),
                    Text('Status: Full (20/20 students)', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text('Capacity: 20 students', style: TextStyle(color: AppColors.textMid)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
