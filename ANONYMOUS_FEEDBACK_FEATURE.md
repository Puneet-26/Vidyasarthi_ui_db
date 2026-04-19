# 📝 Anonymous Feedback System

## Overview
A complete anonymous feedback system where students and parents can send feedback to teachers. All feedback goes through admin approval before reaching teachers.

## 🎯 Features

### ✅ For Students/Parents:
- **Anonymous submission** - Teachers never know who sent the feedback
- **Select teacher** from dropdown
- **Choose category**: Teaching, Behavior, Communication, Subject Knowledge, Punctuality, Other
- **Rate teacher** (1-5 stars, optional)
- **Write detailed feedback** (up to 500 characters)
- **Track submission status** - See if feedback is pending, approved, or rejected
- **View admin notes** - If admin adds comments

### ✅ For Admin:
- **Review all feedback** before it reaches teachers
- **Approve or reject** feedback
- **Add notes** when reviewing
- **Filter by status** (pending, approved, rejected)
- **See submission details** (category, rating, date)

### ✅ For Teachers:
- **View approved feedback only**
- **Cannot see sender identity** (completely anonymous)
- **Mark as read**
- **Filter by category**
- **See ratings and dates**

## 📍 Feature Placement

### Student Dashboard:
- **New 6th tab**: "Feedback" (between Results and Profile)
- Icon: feedback_outlined / feedback_rounded
- Color: Student accent (purple)

### Parent Dashboard:
- **Existing 4th tab**: "Feedback"
- Added "Send Feedback to Teacher" option
- Keeps existing "View Teacher Feedback" feature

## 🗄️ Database Schema

### Table: `anonymous_feedback`

```sql
- id (TEXT, PRIMARY KEY)
- sender_role (TEXT) - 'student' or 'parent'
- sender_id (TEXT) - For tracking only, not shown to teacher
- teacher_id (TEXT)
- teacher_name (TEXT)
- category (TEXT) - teaching, behavior, communication, etc.
- feedback_text (TEXT)
- rating (INTEGER) - 1-5 stars (optional)
- status (TEXT) - 'pending', 'approved', 'rejected'
- admin_notes (TEXT)
- reviewed_by (TEXT) - Admin who reviewed
- reviewed_at (TIMESTAMP)
- is_read_by_teacher (BOOLEAN)
- read_at (TIMESTAMP)
- submitted_at (TIMESTAMP)
- created_at (TIMESTAMP)
```

## 🚀 Setup Instructions

### Step 1: Run Database Migration

1. Open Supabase Dashboard → SQL Editor
2. Copy contents of `anonymous_feedback_migration.sql`
3. Paste and click "Run"
4. Wait for success message

### Step 2: Restart the App

```bash
# Stop current process
# Then restart
flutter run -d chrome --web-port 3000
```

### Step 3: Test the Feature

**Login as Student:**
- Email: `aryan.sharma@students.com`
- Password: `Student@123`
- Go to "Feedback" tab (5th tab)
- Click "Send Feedback to Teacher"
- Fill form and submit

**Check Status:**
- Return to Feedback tab
- See your submitted feedback with "Pending Review" status

## 📱 User Flow

### Student/Parent Flow:
1. Navigate to Feedback tab
2. Click "Send Feedback to Teacher"
3. Select teacher from dropdown
4. Choose feedback category
5. Rate teacher (optional)
6. Write feedback message
7. Submit
8. See confirmation message
9. Track status in "My Submitted Feedback"

### Admin Flow (To be implemented):
1. Login as admin
2. Go to Feedback Management
3. See all pending feedback
4. Review each feedback
5. Approve or Reject with notes
6. Feedback becomes visible to teacher (if approved)

### Teacher Flow (To be implemented):
1. Login as teacher
2. Go to Feedback section
3. See only approved feedback
4. Cannot see sender identity
5. Mark as read
6. Filter by category/rating

## 🎨 UI Components

### Submit Feedback Screen:
- **Info card** - Explains anonymity
- **Teacher dropdown** - Select from active teachers
- **Category chips** - Visual category selection
- **Star rating** - Interactive 5-star rating
- **Text area** - 500 character limit
- **Submit button** - With loading state

### Feedback Status Card:
- **Teacher name** - Who received it
- **Category badge** - Color-coded
- **Status badge** - Pending/Approved/Rejected
- **Feedback preview** - First 3 lines
- **Rating stars** - If provided
- **Submission date**
- **Admin notes** - If any

## 🔒 Privacy & Security

### Anonymity Protection:
- ✅ Teacher never sees sender name
- ✅ Teacher never sees sender ID
- ✅ Only admin can see sender info (for moderation)
- ✅ Sender can track their own submissions

### Admin Moderation:
- ✅ All feedback reviewed before reaching teacher
- ✅ Admin can reject inappropriate feedback
- ✅ Admin can add context notes
- ✅ Audit trail (who reviewed, when)

### Row Level Security (RLS):
- ✅ Students/parents can insert feedback
- ✅ Students/parents can view their own submissions
- ✅ Teachers can only view approved feedback for them
- ✅ Admins can view and update all feedback

## 📊 Sample Data

The migration includes 5 sample feedback entries:
- 2 approved (visible to teachers)
- 3 pending (waiting for admin review)
- Mix of students and parents
- Different categories and ratings

## 🔧 Code Structure

```
lib/
├── models/
│   └── models.dart (+ AnonymousFeedback model)
├── services/
│   └── database_service.dart (+ 8 new methods)
├── screens/
│   ├── submit_feedback_screen.dart (NEW)
│   ├── student_dashboard.dart (+ Feedback tab)
│   └── parent_dashboard.dart (to be updated)
└── anonymous_feedback_migration.sql (NEW)
```

## 🎯 Next Steps

### To Complete the Feature:

1. **Add to Parent Dashboard:**
   - Update parent Feedback tab
   - Add "Send Feedback" button
   - Use same SubmitFeedbackScreen

2. **Create Admin Review Screen:**
   - List all pending feedback
   - Approve/Reject buttons
   - Add notes field
   - Filter by status

3. **Update Teacher Dashboard:**
   - Add Feedback section
   - Show approved feedback only
   - Mark as read functionality
   - Filter by category

4. **Add Notifications:**
   - Notify admin of new feedback
   - Notify teacher of approved feedback
   - Notify sender of status change

## 📝 Notes

- Feedback is stored with sender_id for tracking but never shown to teacher
- Admin can see sender info for moderation purposes
- Teachers only see approved feedback
- Students/parents can track their submission status
- System prevents spam with character limits
- All timestamps are tracked for audit purposes

## ✅ Current Status

**Completed:**
- ✅ Database schema and migration
- ✅ AnonymousFeedback model
- ✅ Database service methods
- ✅ Submit feedback screen
- ✅ Student dashboard integration
- ✅ Feedback status tracking
- ✅ Sample data

**Pending:**
- ⏳ Parent dashboard integration
- ⏳ Admin review screen
- ⏳ Teacher feedback view
- ⏳ Notifications
- ⏳ Analytics/Reports
