# VidyaSarathi - Academic Management System
## Implementation Roadmap & Setup Guide

---

## 📱 **Application Architecture**

### **Role Hierarchy**
1. **Super Admin** - Full system access, manage users, staff, batches
2. **Reception/Admin Staff** - Manage admissions, fees, timetables, broadcasts
3. **Teachers** - Manage syllabus, homework, tests, doubts
4. **Students** - Access timetable, homework, tests, doubts, notices
5. **Parents** - Monitor student performance, fees, notices

### **Project Structure**
```
lib/
├── main.dart                          # App entry point & routing
├── models/
│   └── models.dart                    # Data models (Supabase-compatible)
├── data/
│   └── mock_data.dart                 # Mock data for all scenarios
├── screens/
│   ├── login_screen.dart              # Authentication
│   ├── loading_screen.dart            # Loading with role-based routing
│   ├── student_dashboard.dart         # Student home screen
│   ├── teacher_dashboard.dart         # Teacher home screen
│   ├── parent_dashboard.dart          # Parent home screen
│   ├── admin_dashboard.dart           # Super Admin home screen
│   ├── non_teaching_staff_dashboard.dart  # Reception staff home
│   └── placeholder_screens.dart       # All Phase 2-5 feature placeholders
├── theme/
│   └── app_theme.dart                 # Colors, typography, styling
├── widgets/
│   └── shared_widgets.dart            # Reusable UI components
└── services/
    └── supabase_config.dart           # Supabase integration template
```

---

## 🔐 **Demo Login Credentials**

| Role | Email | Password |
|------|-------|----------|
| Super Admin | `admin@vidya.com` | `admin123` |
| Reception Staff | `staff@vidya.com` | `staff123` |
| Teacher | `teacher@vidya.com` | `teacher123` |
| Student | `student@vidya.com` | `student123` |
| Parent | `parent@vidya.com` | `parent123` |

---

## 📋 **Phase-Wise Implementation Plan**

### **Phase 1: Foundation & Architecture** ✅ COMPLETE
- [x] Authentication with email/password
- [x] Role-based access routing system
- [x] Data models designed for Supabase
- [x] Mock data for all roles
- [x] Basic dashboards for each role
- [x] Navigation between screens

**Current Status**: Login → Loading → Dashboard routing works perfectly

---

### **Phase 2: Core Academic Operations** 🔲 READY (Placeholder)

#### 2.1 Timetable Management
- **What it does**: Display/manage class schedules, handle proxy lectures
- **Who accesses**: Admin staff, Teachers, Students, Parents
- **Button location**: Dashboard > Timetable
- **Placeholder**: `TimetableManagementScreen`
- **Supabase table**: `timetables`

#### 2.2 Syllabus/Portion Tracking
- **What it does**: Teachers mark topics as complete, students see progress bars
- **Who accesses**: Teachers (write), Students/Parents (read-only)
- **Button location**: Dashboard > Syllabus
- **Placeholder**: `SyllabusTrackingScreen`
- **Supabase table**: `syllabus_items`

#### 2.3 Homework Tracking
- **What it does**: Assign homework, track submissions, auto-notify parents
- **Who accesses**: Teachers (write), Students (view/submit), Parents (view)
- **Button location**: Dashboard > Homework
- **Placeholder**: `HomeworkSystemScreen`
- **Supabase tables**: `homework`, `homework_submissions`

---

### **Phase 3: Business & Access Management** 🔲 READY (Placeholder)

#### 3.1 Fee Management System
- **What it does**: Process payments, track dues, set concessions
- **Who accesses**: Admin staff, Parents
- **Button location**: Dashboard > Fees
- **Placeholder**: `FeePaymentPortalScreen`
- **Supabase tables**: `fee_payments`, `students` (fee_status field)

#### 3.2 Live Class Integration
- **What it does**: Embed Zoom/Google Meet, access locked behind fee payment
- **Who accesses**: Students, Teachers (if fees paid)
- **Button location**: Dashboard > Live Classes
- **Placeholder**: `LiveClassScreen`
- **Supabase integration**: Link meeting URLs to batches

---

### **Phase 4: Communication & Trust Building** 🔲 READY (Placeholder)

#### 4.1 Anonymous Feedback System
- **What it does**: Parents submit suggestions, Admin reviews/approves
- **Who accesses**: Parents (submit), Admin (review), Teachers (view approved)
- **Button location**: Dashboard > Feedback
- **Placeholder**: `FeedbackSystemScreen`
- **Supabase table**: `feedbacks`

#### 4.2 Doubt Tracking
- **What it does**: Students ask questions, Teachers resolve
- **Who accesses**: Students (ask), Teachers (answer)
- **Button location**: Dashboard > Doubts
- **Placeholder**: `DoubtTrackingScreen`
- **Supabase table**: `doubts`

#### 4.3 Emergency Contacts
- **Static page**: School & emergency contact numbers
- **Button location**: Settings/More menu

---

### **Phase 5: Student Engagement & Extras** 🔲 READY (Placeholder)

#### 5.1 Tests & Practice (MCQ)
- **What it does**: Self-study quizzes, gamified learning
- **Who accesses**: Students
- **Button location**: Dashboard > Tests & Practice
- **Placeholder**: `TestsAndPracticeScreen`
- **Supabase tables**: `tests`, `test_results`
- **Note**: MCQ implementation is a placeholder, ready for expansion

#### 5.2 Self-Study Room Availability
- **What it does**: Real-time indicator of available study rooms
- **Who accesses**: Students
- **Button location**: Dashboard > Rooms
- **Placeholder**: `SelfStudyRoomScreen`
- **Supabase integration**: Room availability toggle system

---

## 🚀 **Integration Steps with Supabase**

### **Step 1: Set up Supabase Project**
```bash
1. Go to https://supabase.com and create an account
2. Create a new project
3. Go to Project Settings → API Settings
4. Copy your Project URL and anon key
```

### **Step 2: Update Supabase Config**
Edit `lib/services/supabase_config.dart`:
```dart
static const String supabaseUrl = 'YOUR_PROJECT_URL';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

### **Step 3: Create Database Tables**
Use Supabase SQL editor to create tables listed in `supabase_config.dart`

### **Step 4: Install Supabase Package**
```bash
flutter pub add supabase
```

### **Step 5: Initialize Supabase in main.dart**
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(const VidyaSarathiApp());
}
```

### **Step 6: Update Mock Data Functions**
Convert functions to actual Supabase calls:
```dart
// Replace
List<Student> allStudents = [...]

// With
Future<List<Student>> getStudents() async {
  final response = await Supabase.instance.client
    .from('students')
    .select();
  return response.map((student) => Student.fromJson(student)).toList();
}
```

---

## 🎯 **Current Button Navigation Map**

All dashboard buttons are **ready for integration**. Here's where they should route:

### **Student Dashboard Buttons**
- "Timetable" → `TimetableManagementScreen`
- "Homework" → `HomeworkSystemScreen`
- "Tests" → `TestsAndPracticeScreen`
- "Doubts" → `DoubtTrackingScreen`
- "MCQ Practice" → `TestsAndPracticeScreen`

### **Teacher Dashboard Buttons**
- "Syllabus" → `SyllabusTrackingScreen`
- "Assign Homework" → `HomeworkSystemScreen`
- "Manage Tests" → `TestsAndPracticeScreen`
- "Resolve Doubts" → `DoubtTrackingScreen`

### **Parent Dashboard Buttons**
- "Timetable" → `TimetableManagementScreen`
- "Homework Status" → `HomeworkSystemScreen`
- "Test Scores" → `TestsAndPracticeScreen`
- "Fee Status" → `FeePaymentPortalScreen`
- "Send Feedback" → `FeedbackSystemScreen`

### **Admin Staff Dashboard Buttons**
- "Admissions" → Admission management (already implemented)
- "Timetable" → `TimetableManagementScreen`
- "Broadcasts" → Already implemented
- "Fees" → Fees already implemented
- "Live Classes" → `LiveClassScreen`

### **Super Admin Dashboard Buttons**
- All staff features + user management
- Batch management
- Student onboarding

---

## 🎨 **UI/UX Guidelines**

### **Color System**
```dart
AppColors.primary       // #7C5CBF - Main purple
AppColors.studentAccent // #FFB84D - Orange for students
AppColors.teacherAccent // #5C7EFF - Blue for teachers
AppColors.parentAccent  // #4CAF50 - Green for parents
AppColors.adminAccent   // #FF6B6B - Red for admins
```

### **Component Library**
- `GradientScaffold` - Main background with purple-pink gradient
- `GlassCard` - Frosted glass effect Card widget
- `StatCard` - Statistics display card
- `DashboardHeader` - User greeting + role badge
- `VidyaBottomNav` - Custom bottom navigation

### **Font Family**
- Default system fonts (Poppins references removed for flexibility)
- FontWeight: Regular (400), Medium (500), Bold (700)

---

## ⚠️ **Important Notes**

### **Current State**
- ✅ Login system fully functional
- ✅ Role-based routing works
- ✅ Mock data comprehensive
- ✅ All 15+ placeholder screens ready
- ✅ Database schema designed
- ✅ Navigation structure complete

### **Next Steps**
1. Get Supabase credentials from user
2. Update `supabase_config.dart`
3. Add state management (Provider/Riverpod)
4. Connect database queries to UI
5. Implement phase 2-5 features one by one
6. Add push notifications for homework reminders
7. Implement fee payment gateway integration

---

## 📞 **Support & Customization**

### **To add a new feature:**
1. Create model in `lib/models/models.dart`
2. Add Supabase table schema in `supabase_config.dart`
3. Create placeholder screen in `lib/screens/placeholder_screens.dart`
4. Add navigation button in appropriate dashboard
5. Implement database connection once Supabase is ready

### **To modify existing screens:**
- Button styles: Edit `lib/theme/app_theme.dart`
- Widget structure: Update relevant dashboard screen
- Colors: Modify `AppColors` class
- Layout: Use responsive widgets from `shared_widgets.dart`

---

## 🔒 **Security Considerations**

1. **Row Level Security (RLS)**: Enable in Supabase for all tables
2. **Authentication**: Implement email verification before signup
3. **Fee Payment**: Use Razorpay/Stripe for PCI compliance
4. **Data Privacy**: Ensure parent/student data isolation
5. **Admin Access**: Implement 2FA for admin accounts
6. **API Keys**: Never commit real keys to git

---

## 📊 **Mock Data Overview**

- **3 Subjects**: Physics, Chemistry, Mathematics
- **3 Batches**: Class 10-A, Class 10-B, Class 11-A
- **3 Students**: With different fee statuses
- **2 Admissions**: In pending/approved state
- **4 Timetables**: Sample weekly schedule
- **2 Tests**: Scheduled tests with results
- **2 Homework**: Active assignments
- **3 Broadcasts**: Messages for different audiences

All mock data is **realistic** and follows your business logic.

---

**Ready to launch Phase 2! All buttons work, routing works, just need to connect to actual database. 🚀**
