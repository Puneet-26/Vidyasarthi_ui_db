-- Create teacher_feedback table if it doesn't exist
CREATE TABLE IF NOT EXISTS teacher_feedback (
    id TEXT PRIMARY KEY,
    teacher_id TEXT NOT NULL,
    teacher_name TEXT NOT NULL,
    student_id TEXT NOT NULL,
    student_name TEXT NOT NULL,
    subject_id TEXT NOT NULL,
    subject_name TEXT NOT NULL,
    message TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_teacher_feedback_student_id ON teacher_feedback(student_id);
CREATE INDEX IF NOT EXISTS idx_teacher_feedback_teacher_id ON teacher_feedback(teacher_id);
CREATE INDEX IF NOT EXISTS idx_teacher_feedback_created_at ON teacher_feedback(created_at);

-- Insert some sample data
INSERT INTO teacher_feedback (id, teacher_id, teacher_name, student_id, student_name, subject_id, subject_name, message, category, created_at)
VALUES 
    ('feedback_001', 'teacher_001', 'Mr. Arun Kumar', 'student_001', 'Aryan Sharma', 'sub_physics', 'Physics', 'Aryan shows excellent understanding of physics concepts. Keep up the good work!', 'academic', NOW()),
    ('feedback_002', 'teacher_002', 'Mrs. Priya Sharma', 'student_001', 'Aryan Sharma', 'sub_chemistry', 'Chemistry', 'Good progress in organic chemistry. Needs to focus more on inorganic reactions.', 'academic', NOW()),
    ('feedback_003', 'teacher_001', 'Mr. Arun Kumar', 'student_002', 'Priya Singh', 'sub_physics', 'Physics', 'Priya is very attentive in class and asks good questions.', 'behaviour', NOW())
ON CONFLICT (id) DO NOTHING;