-- Attendance Table Schema for VidyaSarathi

-- Drop existing attendance table if exists
DROP TABLE IF EXISTS attendance CASCADE;

-- Create attendance table
CREATE TABLE attendance (
    id TEXT PRIMARY KEY,
    student_id TEXT REFERENCES students(id) ON DELETE CASCADE,
    batch_id TEXT REFERENCES batches(id),
    subject_id TEXT REFERENCES subjects(id),
    teacher_id TEXT REFERENCES teachers(id),
    attendance_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late', 'leave', 'half_day')),
    marked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(student_id, attendance_date, subject_id)
);

-- Create indexes for better performance
CREATE INDEX idx_attendance_student_id ON attendance(student_id);
CREATE INDEX idx_attendance_batch_id ON attendance(batch_id);
CREATE INDEX idx_attendance_date ON attendance(attendance_date);
CREATE INDEX idx_attendance_teacher_id ON attendance(teacher_id);
CREATE INDEX idx_attendance_subject_id ON attendance(subject_id);
CREATE INDEX idx_attendance_status ON attendance(status);

-- Create view for attendance summary
CREATE VIEW attendance_summary AS
SELECT 
    s.id as student_id,
    s.roll_number,
    u.name as student_name,
    b.name as batch_name,
    COUNT(CASE WHEN a.status = 'present' THEN 1 END) as present_count,
    COUNT(CASE WHEN a.status = 'absent' THEN 1 END) as absent_count,
    COUNT(CASE WHEN a.status = 'late' THEN 1 END) as late_count,
    COUNT(CASE WHEN a.status = 'leave' THEN 1 END) as leave_count,
    COUNT(CASE WHEN a.status = 'half_day' THEN 1 END) as half_day_count,
    COUNT(*) as total_days,
    ROUND((COUNT(CASE WHEN a.status = 'present' THEN 1 END)::NUMERIC / NULLIF(COUNT(*), 0)) * 100, 2) as attendance_percentage
FROM students s
JOIN users u ON s.user_id = u.id
JOIN batches b ON s.batch_id = b.id
LEFT JOIN attendance a ON s.id = a.student_id
WHERE u.is_active = true
GROUP BY s.id, s.roll_number, u.name, b.name;

-- Create view for daily attendance report
CREATE VIEW daily_attendance_report AS
SELECT 
    a.attendance_date,
    b.name as batch_name,
    sub.name as subject_name,
    tu.name as teacher_name,
    COUNT(*) as total_students,
    COUNT(CASE WHEN a.status = 'present' THEN 1 END) as present,
    COUNT(CASE WHEN a.status = 'absent' THEN 1 END) as absent,
    COUNT(CASE WHEN a.status = 'late' THEN 1 END) as late,
    COUNT(CASE WHEN a.status = 'leave' THEN 1 END) as leave,
    ROUND((COUNT(CASE WHEN a.status = 'present' THEN 1 END)::NUMERIC / NULLIF(COUNT(*), 0)) * 100, 2) as attendance_percentage
FROM attendance a
JOIN batches b ON a.batch_id = b.id
JOIN subjects sub ON a.subject_id = sub.id
JOIN teachers t ON a.teacher_id = t.id
JOIN users tu ON t.user_id = tu.id
GROUP BY a.attendance_date, b.name, sub.name, tu.name
ORDER BY a.attendance_date DESC;
