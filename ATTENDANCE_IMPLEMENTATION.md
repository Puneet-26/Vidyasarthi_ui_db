# Attendance System Implementation

## Overview
Complete attendance marking and viewing system for VidyaSarathi with database integration.

## Files Created

### 1. Database Schema
**File:** `attendance_schema.sql`
- Creates `attendance` table with proper foreign keys
- Indexes for performance optimization
- Views for attendance summary and daily reports
- Supports statuses: present, absent, late, leave, half_day

### 2. Attendance Service
**File:** `lib/services/attendance_service.dart`
- `markAttendance()` - Mark attendance for multiple students
- `getAttendanceByDate()` - Get attendance for specific date/batch/subject
- `getStudentsForAttendance()` - Get students in a batch
- `getStudentAttendanceSummary()` - Get attendance statistics
- `getStudentAttendanceHistory()` - Get attendance history
- `getBatchAttendanceSummary()` - Get batch-wise summary

### 3. Teacher Attendance Marking Screen
**File:** `lib/screens/mark_attendance_screen.dart`
- Mark attendance for entire batch
- Quick actions: Mark All Present/Absent
- Individual student status selection
- Date picker for marking past attendance
- Real-time present/absent count
- Saves to database

### 4. Student/Parent Attendance Viewing Screen
**File:** `lib/screens/view_attendance_screen.dart`
- Attendance percentage display
- Monthly summary (Present, Absent, Late, Leave)
- Detailed attendance history
- Subject-wise attendance records
- Teacher information
- Pull-to-refresh functionality

## Database Schema

```sql
CREATE TABLE attendance (
    id TEXT PRIMARY KEY,
    student_id TEXT REFERENCES students(id),
    batch_id TEXT REFERENCES batches(id),
    subject_id TEXT REFERENCES subjects(id),
    teacher_id TEXT REFERENCES teachers(id),
    attendance_date DATE NOT NULL,
    status TEXT CHECK (status IN ('present', 'absent', 'late', 'leave', 'half_day')),
    marked_at TIMESTAMP,
    remarks TEXT,
    UNIQUE(student_id, attendance_date, subject_id)
);
```

## Integration Steps

### Step 1: Run Database Migration
Execute the SQL file in your Supabase SQL Editor:
```bash
# Copy contents of attendance_schema.sql and run in Supabase
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Integrate with Teacher Dashboard

Add to teacher dashboard navigation:
```dart
import 'package:vidyasarathi/screens/mark_attendance_screen.dart';

// In teacher dashboard, add button/action:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MarkAttendanceScreen(
      teacherId: 'teacher_001',
      batchId: 'batch_12_science_a',
      batchName: 'Class 12 Science A',
      subjectId: 'sub_physics',
      subjectName: 'Physics',
    ),
  ),
);
```

### Step 4: Integrate with Student Dashboard

Add to student dashboard:
```dart
import 'package:vidyasarathi/screens/view_attendance_screen.dart';

// In student dashboard, add button/card:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ViewAttendanceScreen(
      studentId: 'student_001',
      studentName: 'Student Name',
    ),
  ),
);
```

### Step 5: Integrate with Parent Dashboard

Same as student dashboard - parents can view their child's attendance.

## Features

### For Teachers:
✅ Mark attendance batch-wise
✅ Select date (today or past dates)
✅ Quick mark all present/absent
✅ Individual student status (Present/Absent/Late/Leave)
✅ Real-time statistics
✅ Save to database
✅ Update existing attendance

### For Students/Parents:
✅ View attendance percentage
✅ Monthly summary statistics
✅ Detailed attendance history
✅ Subject-wise records
✅ Teacher information
✅ Status indicators with colors
✅ Pull-to-refresh

## Status Types

| Status | Color | Icon | Description |
|--------|-------|------|-------------|
| Present | Green | ✓ | Student attended class |
| Absent | Red | ✗ | Student was absent |
| Late | Orange | ⏰ | Student arrived late |
| Leave | Blue | 📅 | Student on approved leave |
| Half Day | Orange | ⏱ | Student attended half day |

## API Methods

### Mark Attendance
```dart
await AttendanceService().markAttendance(
  batchId: 'batch_id',
  subjectId: 'subject_id',
  teacherId: 'teacher_id',
  studentAttendance: [
    {'student_id': 'student_1', 'status': 'present', 'remarks': ''},
    {'student_id': 'student_2', 'status': 'absent', 'remarks': 'Sick'},
  ],
  date: DateTime.now(),
);
```

### Get Student Summary
```dart
final summary = await AttendanceService().getStudentAttendanceSummary(
  studentId: 'student_001',
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime.now(),
);
// Returns: {present: 45, absent: 3, late: 2, leave: 1, percentage: '93.8'}
```

### Get Attendance History
```dart
final history = await AttendanceService().getStudentAttendanceHistory(
  studentId: 'student_001',
  limit: 30,
);
```

## Next Steps

1. **Run the SQL migration** in Supabase
2. **Install dependencies**: `flutter pub get`
3. **Update teacher dashboard** to add "Mark Attendance" button
4. **Update student/parent dashboards** to add "View Attendance" button
5. **Test the flow** end-to-end

## Testing

1. Login as teacher
2. Navigate to Mark Attendance
3. Select batch and subject
4. Mark attendance for students
5. Save
6. Login as student/parent
7. View attendance records
8. Verify data matches

## Notes

- Attendance is unique per student, date, and subject
- Teachers can update attendance for past dates
- Percentage calculation excludes leave days
- All timestamps are stored in UTC
- Supports batch-wise and subject-wise attendance
