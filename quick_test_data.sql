-- ==================== QUICK TEST DATA ====================
-- Matches your EXACT table structure
-- Run this in Supabase SQL Editor

-- ==================== Add Students with Parent Info ====================
INSERT INTO students (
  id, 
  name, 
  email, 
  phone, 
  parent_name, 
  parent_phone,
  batch_id,
  enrollment_status
) VALUES 
(
  gen_random_uuid(), 
  'Aryan Sharma',
  'aryan.sharma@students.com',
  '+91-9876543210',
  'Mr. Rajesh Sharma (rajesh.sharma@parents.com)',
  '+91-9876543211',
  (SELECT id FROM batches LIMIT 1),
  'active'
),
(
  gen_random_uuid(), 
  'Priya Singh',
  'priya.singh@students.com',
  '+91-9876543212',
  'Mr. Amit Singh (amit.singh@parents.com)',
  '+91-9876543214',
  (SELECT id FROM batches LIMIT 1),
  'active'
);

-- ==================== SUCCESS MESSAGE ====================
SELECT 
  '✅ Students Added Successfully!' as status,
  COUNT(*) as total_students
FROM students 
WHERE email IN ('aryan.sharma@students.com', 'priya.singh@students.com');

-- Show the added students
SELECT 
  name as student,
  email,
  parent_name as parent,
  parent_phone,
  enrollment_status
FROM students 
WHERE email IN ('aryan.sharma@students.com', 'priya.singh@students.com');
