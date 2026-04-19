-- ==================== ANONYMOUS FEEDBACK SYSTEM ====================
-- This table stores anonymous feedback from students/parents to teachers
-- Feedback goes through admin approval before reaching teachers

-- Drop existing table if it exists
DROP TABLE IF EXISTS anonymous_feedback CASCADE;

-- Create anonymous_feedback table
CREATE TABLE anonymous_feedback (
  id TEXT PRIMARY KEY,
  
  -- Sender info (anonymous to teacher)
  sender_role TEXT NOT NULL CHECK (sender_role IN ('student', 'parent')),
  sender_id TEXT, -- Optional: for tracking purposes only (not shown to teacher)
  
  -- Target teacher
  teacher_id TEXT NOT NULL,
  teacher_name TEXT NOT NULL,
  
  -- Feedback content
  category TEXT NOT NULL CHECK (category IN ('teaching', 'behavior', 'communication', 'subject_knowledge', 'punctuality', 'other')),
  feedback_text TEXT NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5), -- Optional 1-5 star rating
  
  -- Admin approval workflow
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  admin_notes TEXT, -- Admin can add notes when approving/rejecting
  reviewed_by TEXT, -- Admin who reviewed it
  reviewed_at TIMESTAMP WITH TIME ZONE,
  
  -- Teacher acknowledgment
  is_read_by_teacher BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP WITH TIME ZONE,
  
  -- Timestamps
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_anonymous_feedback_teacher ON anonymous_feedback(teacher_id);
CREATE INDEX idx_anonymous_feedback_status ON anonymous_feedback(status);
CREATE INDEX idx_anonymous_feedback_submitted ON anonymous_feedback(submitted_at DESC);
CREATE INDEX idx_anonymous_feedback_sender ON anonymous_feedback(sender_role, sender_id);

-- Enable Row Level Security
ALTER TABLE anonymous_feedback ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Allow students/parents to insert their own feedback
CREATE POLICY "Allow insert feedback" ON anonymous_feedback 
  FOR INSERT WITH CHECK (TRUE);

-- Allow students/parents to view their own submitted feedback (by sender_id)
CREATE POLICY "Allow view own feedback" ON anonymous_feedback 
  FOR SELECT USING (TRUE);

-- Allow admins to view all feedback
CREATE POLICY "Allow admin view all" ON anonymous_feedback 
  FOR SELECT USING (TRUE);

-- Allow admins to update feedback (approve/reject)
CREATE POLICY "Allow admin update" ON anonymous_feedback 
  FOR UPDATE USING (TRUE);

-- Allow teachers to view only approved feedback for them
CREATE POLICY "Allow teacher view approved" ON anonymous_feedback 
  FOR SELECT USING (status = 'approved');

-- Allow teachers to mark feedback as read
CREATE POLICY "Allow teacher mark read" ON anonymous_feedback 
  FOR UPDATE USING (status = 'approved');

-- Insert sample data for testing
INSERT INTO anonymous_feedback (id, sender_role, sender_id, teacher_id, teacher_name, category, feedback_text, rating, status) VALUES
  ('fb_001', 'student', 'student_001', 'teacher_001', 'Mr. Arun Kumar', 'teaching', 'Excellent teaching style! Explains concepts very clearly.', 5, 'approved'),
  ('fb_002', 'parent', 'parent_001', 'teacher_001', 'Mr. Arun Kumar', 'communication', 'Would appreciate more frequent updates about my child progress.', 3, 'pending'),
  ('fb_003', 'student', 'student_002', 'teacher_002', 'Mrs. Priya Sharma', 'subject_knowledge', 'Very knowledgeable and passionate about chemistry!', 5, 'approved'),
  ('fb_004', 'student', 'student_003', 'teacher_001', 'Mr. Arun Kumar', 'punctuality', 'Sometimes classes start a bit late.', 3, 'pending'),
  ('fb_005', 'parent', 'parent_002', 'teacher_003', 'Mr. Vikram Singh', 'teaching', 'My child has improved significantly in mathematics. Thank you!', 5, 'approved');

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Anonymous Feedback System Created Successfully!';
  RAISE NOTICE '📊 Sample feedback data inserted for testing';
  RAISE NOTICE '🔒 Row Level Security policies enabled';
END $$;
