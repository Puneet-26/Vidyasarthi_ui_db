-- ============================================================
--  MIGRATION: Add teacher_feedback table
--  Run this in Supabase SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS teacher_feedback (
  id TEXT PRIMARY KEY,
  teacher_id UUID NOT NULL REFERENCES users(id),
  teacher_name TEXT NOT NULL,
  student_id TEXT NOT NULL REFERENCES students(id),
  student_name TEXT NOT NULL,
  subject_id TEXT NOT NULL REFERENCES subjects(id),
  subject_name TEXT NOT NULL,
  message TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'general'
    CHECK (category IN ('academic', 'behaviour', 'attendance', 'general')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE teacher_feedback ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all teacher feedback" ON teacher_feedback FOR ALL USING (TRUE);

CREATE INDEX idx_teacher_feedback_student_id ON teacher_feedback(student_id);
CREATE INDEX idx_teacher_feedback_teacher_id ON teacher_feedback(teacher_id);

-- Sample seed data
INSERT INTO teacher_feedback (id, teacher_id, teacher_name, student_id, student_name, subject_id, subject_name, message, category) VALUES
  ('tf_001',
   'a0000001-0000-0000-0000-000000000004',
   'Mr. Arun Kumar',
   'stu_001',
   'Aryan Sharma',
   'subj_physics',
   'Physics',
   'Aryan performed exceptionally well in the recent unit test. Keep up the great work!',
   'academic'),
  ('tf_002',
   'a0000001-0000-0000-0000-000000000005',
   'Mrs. Priya Sharma',
   'stu_001',
   'Aryan Sharma',
   'subj_chemistry',
   'Chemistry',
   'Please ensure the lab report is submitted on time. Aryan has been slightly irregular with assignments.',
   'general'),
  ('tf_003',
   'a0000001-0000-0000-0000-000000000006',
   'Mr. Vikram Singh',
   'stu_002',
   'Priya Singh',
   'subj_math',
   'Mathematics',
   'Priya has shown significant improvement in integration. Encourage her to practice more problems at home.',
   'academic');
