# Exam Scheduling System

## Overview
Complete exam scheduling system allowing teachers to schedule exams and students/parents to view upcoming exams with real-time updates.

## Features

### For Teachers 👨‍🏫
✅ Schedule new exams
✅ Set exam title, description
✅ Select batch and subject
✅ Choose date and time
✅ Set duration (in minutes)
✅ Set maximum marks
✅ Assign room number
✅ Auto-save to database
✅ Students/parents notified automatically

### For Students/Parents 👨‍🎓👨‍👩‍👧
✅ View all upcoming exams
✅ See exam details (date, time, duration, marks)
✅ Real-time updates when exams are scheduled
✅ Countdown timer (X days left)
✅ Filter by batch
✅ Pull-to-refresh
✅ Detailed exam information

## Files Created

### 1. Schedule Exam Screen (Teachers)
**File:** `lib/screens/schedule_exam_screen.dart`
- Form to schedule new exam
- Batch and subject selection
- Date and time pickers
- Duration and max marks input
- Room number assignment
- Validation
- Saves to `tests` table

### 2. View Exams Screen (Students/Parents)
**File:** `lib/screens/view_exams_screen.dart`
- List of upcoming exams
- Real-time updates
- Exam details modal
- Status indicators (scheduled, ongoing, completed)
- Countdown timer
- Pull-to-refresh

## Database Schema

Uses existing `tests` table:
```sql
CREATE TABLE tests (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    subject_id TEXT REFERENCES subjects(id),
    batch_id TEXT REFERENCES batches(id),
    teacher_id TEXT REFERENCES teachers(id),
    test_date DATE,
    start_time TIME,
    duration_minutes INTEGER,
    max_marks INTEGER,
    status TEXT DEFAULT 'scheduled',
    room_number TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## Integration Steps

### Step 1: Add to Teacher Dashboard

```dart
import 'package:vidyasarathi/screens/schedule_exam_screen.dart';

// Add button in teacher dashboard:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ScheduleExamScreen(
      teacherId: 'teacher_001',
      teacherName: 'Dr. Arun Kumar',
    ),
  ),
);
```

### Step 2: Add to Student Dashboard

```dart
import 'package:vidyasarathi/screens/view_exams_screen.dart';

// Add button/card in student dashboard:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ViewExamsScreen(
      studentId: 'student_001',
      batchId: 'batch_12_science_a',
      title: 'Upcoming Exams',
    ),
  ),
);
```

### Step 3: Add to Parent Dashboard

```dart
// Same as student - parents can view child's exams
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ViewExamsScreen(
      studentId: childStudentId,
      batchId: childBatchId,
      title: 'Child\'s Upcoming Exams',
    ),
  ),
);
```

### Step 4: Enable Real-Time Updates

Run in Supabase SQL Editor:
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE tests;
```

## Exam Status Types

| Status | Description | Color |
|--------|-------------|-------|
| scheduled | Exam is scheduled | Blue |
| ongoing | Exam is in progress | Orange |
| completed | Exam finished | Green |
| cancelled | Exam cancelled | Red |

## Real-Time Updates

When teacher schedules an exam:
1. Exam saved to database
2. Supabase Realtime broadcasts change
3. Students/parents see notification: "Exam schedule updated!"
4. List auto-refreshes
5. New exam appears instantly

## Usage Flow

### Teacher Scheduling Exam:
1. Click "Schedule Exam"
2. Fill in exam details:
   - Title: "Mid-Term Examination"
   - Description: "Chapters 1-5"
   - Batch: "Class 12 Science A"
   - Subject: "Physics"
   - Date: Select from calendar
   - Time: Select from time picker
   - Duration: 180 minutes
   - Max Marks: 100
   - Room: "Room 101"
3. Click "Schedule Exam"
4. Success message shown
5. Students/parents notified

### Student Viewing Exams:
1. Click "Upcoming Exams" card
2. See list of all exams
3. Each exam shows:
   - Title and status
   - Date and time
   - Duration and max marks
   - Room number
   - Countdown (X days left)
4. Click exam for full details
5. Pull down to refresh

## Validation

- Title is required
- Batch must be selected
- Subject must be selected
- Date must be in future
- Time must be selected
- Duration must be positive number
- Max marks must be positive number

## Notifications

When exam is scheduled:
- ✅ Saved to database
- ✅ Real-time broadcast to all clients
- ✅ Students see notification
- ✅ Parents see notification
- ✅ Exam appears in upcoming list

## Benefits

- **Instant Visibility** - Students see exams immediately
- **No Confusion** - All details in one place
- **Reminders** - Countdown shows time remaining
- **Organization** - Teachers can plan ahead
- **Transparency** - Parents stay informed
- **Real-Time** - No delays or refresh needed

## Future Enhancements

Possible improvements:
- [ ] Edit/update scheduled exams
- [ ] Cancel exams
- [ ] Send push notifications
- [ ] Add exam reminders (1 day before, 1 hour before)
- [ ] Attach syllabus/study material
- [ ] Mark exam as completed automatically
- [ ] Generate exam reports
- [ ] Export exam schedule to calendar

## Testing

1. **Schedule Exam (Teacher):**
   - Login as teacher
   - Click "Schedule Exam"
   - Fill all details
   - Click "Schedule Exam"
   - Verify success message

2. **View Exam (Student):**
   - Login as student
   - Click "Upcoming Exams"
   - Verify exam appears
   - Click exam for details

3. **Real-Time Update:**
   - Open student view in one window
   - Schedule exam in teacher window
   - Watch student view update automatically

## Status

**Current Status:** ✅ Complete and Ready

**Files Created:**
- `lib/screens/schedule_exam_screen.dart` ✅
- `lib/screens/view_exams_screen.dart` ✅
- `EXAM_SCHEDULING.md` ✅

**Integration Needed:**
- Add to teacher dashboard ⏳
- Add to student dashboard ⏳
- Add to parent dashboard ⏳
- Enable realtime in Supabase ⏳

## Summary

Teachers can now schedule exams with all details, and students/parents can view upcoming exams with real-time updates. The system is complete and ready for integration into the dashboards.

---

**Total Features Implemented:**
1. ✅ Attendance System (with real-time)
2. ✅ Marks Entry System
3. ✅ Exam Scheduling System (with real-time)
