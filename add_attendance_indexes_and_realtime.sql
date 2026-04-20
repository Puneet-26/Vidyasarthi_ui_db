-- Add indexes for better performance (if they don't exist)
CREATE INDEX IF NOT EXISTS idx_attendance_student_id ON attendance(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_batch_id ON attendance(batch_id);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON attendance(attendance_date);
CREATE INDEX IF NOT EXISTS idx_attendance_teacher_id ON attendance(teacher_id);
CREATE INDEX IF NOT EXISTS idx_attendance_subject_id ON attendance(subject_id);
CREATE INDEX IF NOT EXISTS idx_attendance_status ON attendance(status);

-- Enable realtime for attendance table
ALTER PUBLICATION supabase_realtime ADD TABLE attendance;

-- Verify it worked
SELECT 'Indexes and Realtime enabled successfully!' as status;
