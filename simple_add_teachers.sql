-- Simple script to add teachers and students
-- This works with the existing table structure

-- ============================================================================
-- CLEAN UP OLD DATA (if any)
-- ============================================================================

-- Delete old test users
DELETE FROM users WHERE email IN (
  'priya.nair@teachers.com',
  'rita.vaidya@teachers.com',
  'aryan.sharma@students.com',
  'priya.singh@students.com',
  'reet.saran@students.com',
  'rajesh.sharma@parents.com',
  'sunita.patel@parents.com',
  'deven.saran@parents.com'
);

-- ============================================================================
-- ADD USERS FIRST
-- ============================================================================

-- Add teacher users
INSERT INTO users (name, email, phone_number, role, is_active, created_at)
VALUES 
  ('Priya Nair', 'priya.nair@teachers.com', '9876543210', 'teacher', true, NOW()),
  ('Rita Vaidya', 'rita.vaidya@teachers.com', '9876543211', 'teacher', true, NOW())
ON CONFLICT (email) DO NOTHING;

-- Add student users
INSERT INTO users (name, email, phone_number, role, is_active, created_at)
VALUES 
  ('Aryan Sharma', 'aryan.sharma@students.com', '9123456780', 'student', true, NOW()),
  ('Priya Singh', 'priya.singh@students.com', '9123456782', 'student', true, NOW()),
  ('Reet Saran', 'reet.saran@students.com', '9123456784', 'student', true, NOW())
ON CONFLICT (email) DO NOTHING;

-- Add parent users
INSERT INTO users (name, email, phone_number, role, is_active, created_at)
VALUES 
  ('Rajesh Sharma', 'rajesh.sharma@parents.com', '9123456781', 'parent', true, NOW()),
  ('Sunita Patel', 'sunita.patel@parents.com', '9123456783', 'parent', true, NOW()),
  ('Deven Saran', 'deven.saran@parents.com', '9123456785', 'parent', true, NOW())
ON CONFLICT (email) DO NOTHING;

-- ============================================================================
-- ADD TEACHERS (check what columns exist first)
-- ============================================================================

-- First, let's see what columns the teachers table has
SELECT column_name FROM information_schema.columns WHERE table_name = 'teachers';

-- ============================================================================
-- ADD STUDENTS
-- ============================================================================

-- Get a batch ID to use
DO $$
DECLARE
  v_batch_id UUID;
  v_aryan_user_id UUID;
  v_priya_user_id UUID;
  v_reet_user_id UUID;
BEGIN
  -- Get first available batch
  SELECT id INTO v_batch_id FROM batches LIMIT 1;
  
  -- Get user IDs
  SELECT id INTO v_aryan_user_id FROM users WHERE email = 'aryan.sharma@students.com';
  SELECT id INTO v_priya_user_id FROM users WHERE email = 'priya.singh@students.com';
  SELECT id INTO v_reet_user_id FROM users WHERE email = 'reet.saran@students.com';
  
  -- Add students
  INSERT INTO students (
    user_id, batch_id, parent_name, parent_phone,
    class, board, total_fees, fees_paid, fee_status, enrollment_status,
    date_of_birth, address, admission_date, created_at
  )
  VALUES 
    (v_aryan_user_id, v_batch_id, 'Rajesh Sharma', '9123456781',
     '10th', 'CBSE', 50000, 35000, 'partial', 'active',
     '2008-05-15', 'Mumbai', NOW(), NOW()),
    (v_priya_user_id, v_batch_id, 'Sunita Patel', '9123456783',
     '9th', 'CBSE', 45000, 45000, 'full', 'active',
     '2009-08-20', 'Pune', NOW(), NOW()),
    (v_reet_user_id, v_batch_id, 'Deven Saran', '9123456785',
     '8th', 'CBSE', 40000, 20000, 'partial', 'active',
     '2010-03-10', 'Delhi', NOW(), NOW())
  ON CONFLICT DO NOTHING;
  
  RAISE NOTICE 'Added 3 students';
END $$;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SELECT 'USERS CREATED' as info, COUNT(*) as count, role
FROM users
WHERE email LIKE '%@teachers.com' OR email LIKE '%@students.com' OR email LIKE '%@parents.com'
GROUP BY role;

SELECT 'STUDENTS CREATED' as info, COUNT(*) as count
FROM students s
JOIN users u ON s.user_id = u.id;
