-- Enable Realtime for Attendance Table
-- This allows real-time updates when attendance is marked

-- Enable realtime for the attendance table
ALTER PUBLICATION supabase_realtime ADD TABLE attendance;

-- Verify realtime is enabled
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
AND tablename = 'attendance';

-- Note: After running this, students and parents will see attendance updates in real-time!
