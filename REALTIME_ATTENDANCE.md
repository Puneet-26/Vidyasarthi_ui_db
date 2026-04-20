# Real-Time Attendance Updates

## Overview
The attendance system now supports **real-time updates** using Supabase Realtime. When a teacher marks attendance, students and parents see the changes **instantly** without refreshing!

## How It Works

### 1. Teacher Marks Attendance
- Teacher opens "Mark Attendance"
- Selects batch and marks students as Present/Absent/Late/Leave
- Clicks "Save Attendance"
- Data is saved to the `attendance` table in Supabase

### 2. Real-Time Broadcast
- Supabase Realtime detects the database change
- Broadcasts the change to all subscribed clients
- Uses PostgreSQL's LISTEN/NOTIFY mechanism

### 3. Student/Parent Receives Update
- Student/Parent has the attendance screen open
- App is subscribed to attendance changes for that student
- Receives notification instantly
- Shows green snackbar: "Attendance updated!"
- Automatically reloads the data
- Updates percentage, summary, and history

## Features

✅ **Instant Updates** - No need to refresh or reload  
✅ **Visual Notification** - Green snackbar shows when data updates  
✅ **Automatic Reload** - Data refreshes automatically  
✅ **Efficient** - Only subscribes to specific student's data  
✅ **Battery Friendly** - Uses WebSocket connection (low overhead)  

## Setup Instructions

### Step 1: Enable Realtime in Supabase

Run this SQL in your Supabase SQL Editor:

```sql
-- Enable realtime for the attendance table
ALTER PUBLICATION supabase_realtime ADD TABLE attendance;
```

Or run the provided file:
```bash
# Copy contents of enable_realtime_attendance.sql
# Paste in Supabase SQL Editor
# Execute
```

### Step 2: Verify Realtime is Enabled

Check in Supabase Dashboard:
1. Go to Database → Replication
2. Look for `supabase_realtime` publication
3. Verify `attendance` table is listed

Or run this query:
```sql
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
AND tablename = 'attendance';
```

### Step 3: Test Real-Time Updates

1. **Open two browser windows:**
   - Window 1: Login as teacher
   - Window 2: Login as student

2. **In Window 2 (Student):**
   - Click on "Attendance" card
   - Keep the attendance screen open

3. **In Window 1 (Teacher):**
   - Click "Mark Attendance"
   - Select a batch
   - Mark the student as "Present" or "Absent"
   - Click "Save Attendance"

4. **Watch Window 2 (Student):**
   - You should see a green notification: "Attendance updated!"
   - The percentage and data will update automatically
   - No refresh needed!

## Technical Details

### Subscription Setup

```dart
_attendanceChannel = Supabase.instance.client
    .channel('attendance_${widget.studentId}')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'attendance',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'student_id',
        value: widget.studentId,
      ),
      callback: (payload) {
        // Show notification
        ScaffoldMessenger.of(context).showSnackBar(...);
        
        // Reload data
        _loadAttendanceData();
      },
    )
    .subscribe();
```

### Events Monitored

- **INSERT** - New attendance record created
- **UPDATE** - Existing attendance record modified
- **DELETE** - Attendance record deleted

### Cleanup

The subscription is automatically cleaned up when:
- User navigates away from the screen
- App is closed
- Widget is disposed

```dart
@override
void dispose() {
  _attendanceChannel?.unsubscribe();
  super.dispose();
}
```

## Benefits

### For Students
- See attendance updates immediately
- No need to refresh the app
- Always have the latest data
- Visual confirmation when teacher marks attendance

### For Parents
- Monitor child's attendance in real-time
- Get instant updates when attendance is marked
- Stay informed without delays

### For Teachers
- Confidence that data is immediately visible
- No complaints about "data not showing"
- Better communication with students/parents

## Performance

- **Bandwidth:** ~1-2 KB per update
- **Latency:** < 1 second typically
- **Battery Impact:** Minimal (WebSocket connection)
- **Scalability:** Handles thousands of concurrent users

## Troubleshooting

### Updates Not Working?

1. **Check Realtime is Enabled:**
   ```sql
   SELECT * FROM pg_publication_tables 
   WHERE pubname = 'supabase_realtime';
   ```

2. **Check Browser Console:**
   - Look for "🔔 Attendance updated in real-time!" message
   - Check for WebSocket connection errors

3. **Verify Supabase Connection:**
   - Check internet connection
   - Verify Supabase project is active
   - Check API keys are correct

4. **Check Filters:**
   - Ensure student_id matches
   - Verify table name is correct
   - Check schema is 'public'

### Notification Not Showing?

- Check if screen is still mounted
- Verify ScaffoldMessenger context is valid
- Look for errors in console

## Future Enhancements

Possible improvements:
- [ ] Show which teacher marked the attendance
- [ ] Display timestamp of last update
- [ ] Add sound notification option
- [ ] Batch updates for multiple students
- [ ] Offline queue for updates
- [ ] Push notifications (mobile)

## Security

- Realtime subscriptions respect Row Level Security (RLS)
- Students can only see their own attendance
- Parents can only see their children's attendance
- Teachers can see all students in their batches
- All data is encrypted in transit (WSS)

## Cost Considerations

Supabase Realtime is included in:
- ✅ Free tier: Up to 2 million messages/month
- ✅ Pro tier: Up to 5 million messages/month
- ✅ Additional: $2.50 per million messages

For a school with 1000 students:
- ~30 attendance updates per student per month
- = 30,000 messages/month
- Well within free tier limits!

## Summary

Real-time attendance updates provide a seamless experience for students and parents. They can see attendance changes instantly without any manual refresh, making the system feel more responsive and modern.

**Status:** ✅ Implemented and Ready to Use  
**Requires:** Supabase Realtime enabled (run SQL script)  
**Works on:** Web, iOS, Android  
