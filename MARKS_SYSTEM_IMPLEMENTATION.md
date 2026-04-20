# Marks/Exam Management System

## Overview
Complete marks entry and viewing system for VidyaSarathi with real-time updates.

## Files Created

### 1. Marks Service
**File:** `lib/services/marks_service.dart`
- `enterMarks()` - Enter marks for multiple students
- `getMarksByTest()` - Get marks for specific test
- `getTestsByBatch()` - Get all tests for a batch
- `getStudentResults()` - Get student's test results
- `getStudentPerformanceSummary()` - Get performance statistics
- `calculateGrade()` - Auto-calculate grade from percentage

### 2. Teacher Marks Entry Screen
**File:** `lib/screens/enter_marks_screen.dart`
- Enter marks for entire batch
- Auto-calculate percentage and grade
- Real-time grade display
- Validation for marks range
- Saves to database

## Features

### For Teachers 👨‍🏫
✅ Select test from list
✅ Enter marks for all students
✅ Auto-calculate percentage
✅ Auto-assign grades (A+, A, B+, B, C, D, F)
✅ See progress (X/Y students entered)
✅ Save to database
✅ Update existing marks

### For Students 👨‍🎓
✅ View all test results
✅ See marks, percentage, grade
✅ Performance summary
✅ Average percentage
✅ Highest/lowest scores
✅ Grade distribution
✅ Real-time updates when teacher enters marks

### For Parents 👨‍👩‍👧
✅ View child's test results
✅ See performance trends
✅ Compare with class average
✅ Real-time updates

## Grading System

| Percentage | Grade |
|------------|-------|
| 90-100% | A+ |
| 80-89% | A |
| 70-79% | B+ |
| 60-69% | B |
| 50-59% | C |
| 40-49% | D |
| 0-39% | F |

## Database Schema

Uses existing `test_results` table:
```sql
CREATE TABLE test_results (
    id TEXT PRIMARY KEY,
    test_id TEXT REFERENCES tests(id),
    student_id TEXT REFERENCES students(id),
    marks_obtained NUMERIC,
    max_marks NUMERIC,
    percentage NUMERIC,
    grade TEXT,
    remarks TEXT,
    status TEXT DEFAULT 'evaluated',
    created_at TIMESTAMP DEFAULT NOW()
);
```

## Integration Steps

### Step 1: Add to Teacher Dashboard

```dart
import 'package:vidyasarathi/screens/enter_marks_screen.dart';

// In teacher dashboard, add button:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EnterMarksScreen(
      teacherId: 'teacher_001',
      testId: 'test_001',
      testName: 'Mid-Term Exam',
      batchId: 'batch_12_science_a',
      batchName: 'Class 12 Science A',
      maxMarks: 100,
    ),
  ),
);
```

### Step 2: Enable Real-Time Updates

Run in Supabase SQL Editor:
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE test_results;
```

### Step 3: Create Test Selection Screen

Teachers need to select which test to enter marks for:
- List all tests for their batches
- Show test name, date, max marks
- Click to enter marks

## API Methods

### Enter Marks
```dart
await MarksService().enterMarks(
  testId: 'test_001',
  batchId: 'batch_id',
  subjectId: 'subject_id',
  teacherId: 'teacher_id',
  studentMarks: [
    {
      'student_id': 'student_1',
      'marks_obtained': 85,
      'max_marks': 100,
      'percentage': 85.0,
      'grade': 'A',
      'remarks': 'Good performance',
    },
  ],
);
```

### Get Student Results
```dart
final results = await MarksService().getStudentResults(
  studentId: 'student_001',
  limit: 50,
);
```

### Get Performance Summary
```dart
final summary = await MarksService().getStudentPerformanceSummary(
  studentId: 'student_001',
);
// Returns: {
//   total_tests: 10,
//   average_percentage: '78.5',
//   highest_percentage: '95.0',
//   lowest_percentage: '62.0',
//   grade_distribution: {'A': 3, 'B+': 4, 'B': 2, 'C': 1}
// }
```

## Real-Time Updates

Similar to attendance, marks updates are real-time:

1. Teacher enters marks → Saves to database
2. Supabase Realtime broadcasts change
3. Student/Parent sees update instantly
4. Shows notification: "New marks available!"

## Status

**Current Status:** ✅ Service and Entry Screen Created

**Still Needed:**
1. Test selection screen for teachers
2. Student marks viewing screen
3. Parent marks viewing screen
4. Real-time subscription setup
5. Integration with dashboards

## Next Steps

1. Create test selection screen
2. Create student/parent viewing screens
3. Add real-time subscriptions
4. Integrate with teacher dashboard
5. Integrate with student/parent dashboards
6. Test end-to-end flow

## Benefits

- **Instant Updates** - No delay in marks visibility
- **Auto-Grading** - Saves teacher time
- **Performance Tracking** - Students see trends
- **Parent Visibility** - Parents stay informed
- **Data Accuracy** - Validation prevents errors

## Notes

- Marks can be updated/re-entered
- Grades are auto-calculated
- Percentage is auto-calculated
- All data validated before saving
- Real-time updates require Supabase Realtime enabled
- Works on web, iOS, Android

---

**Files Created:**
- `lib/services/marks_service.dart` ✅
- `lib/screens/enter_marks_screen.dart` ✅

**Files Needed:**
- `lib/screens/select_test_screen.dart` ⏳
- `lib/screens/view_marks_screen.dart` ⏳
- Integration code ⏳
