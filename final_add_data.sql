-- Add Rita Vaidya and other test data
-- Based on the actual table structure

-- ============================================================================
-- ADD TEACHERS
-- ============================================================================

-- Add Rita Vaidya
INSERT INTO teachers (
  name, email, phone, subjects, classes, board, 
  qualification, experience, created_at
)
VALUES (
  'Rita Vaidya',
  'rita.vaidya@teachers.com',
  '9876543211',
  ARRAY['Mathematics'],
  ARRAY['7th', '8th', '9th'],
  'CBSE',
  'M.Sc Mathematics',
  '8 years',
  NOW()
)
ON CONFLICT (email) DO UPDATE SET
  name = EXCLUDED.name,
  phone = EXCLUDED.phone;

-- Add Priya Nair
INSERT INTO teachers (
  name, email, phone, subjects, classes, board,
  qualification, experience, created_at
)
VALUES (
  'Priya Nair',
  'priya.nair@teachers.com',
  '9876543210',
  ARRAY['Physics'],
  ARRAY['9th', '10th'],
  'CBSE',
  'M.Sc Physics',
  '5 years',
  NOW()
)
ON CONFLICT (email) DO UPDATE SET
  name = EXCLUDED.name,
  phone = EXCLUDED.phone;

-- ============================================================================
-- ADD MORE STUDENTS (if needed)
-- ============================================================================

-- Get a batch ID
DO $$
DECLARE
  v_batch_id UUID;
BEGIN
  SELECT id INTO v_batch_id FROM batches LIMIT 1;
  
  -- Add Aryan Sharma (if not exists)
  INSERT INTO students (
    name, email, phone, parent_name, parent_phone, batch_id,
    class, board, total_fees, fees_paid, fee_status,
    enrollment_st, enrollment_date, date_of_birth, address, created_at
  )
  VALUES (
    'Aryan Sharma',
    'aryan.sharma@students.com',
    '9123456780',
    'Rajesh Sharma',
    '9123456781',
    v_batch_id,
    '10th',
    'CBSE',
    50000,
    35000,
    'partial',
    'active',
    NOW(),
    '2008-05-15',
    'Mumbai',
    NOW()
  )
  ON CONFLICT (email) DO NOTHING;
  
  -- Add Priya Singh
  INSERT INTO students (
    name, email, phone, parent_name, parent_phone, batch_id,
    class, board, total_fees, fees_paid, fee_status,
    enrollment_st, enrollment_date, date_of_birth, address, created_at
  )
  VALUES (
    'Priya Singh',
    'priya.singh@students.com',
    '9123456782',
    'Sunita Patel',
    '9123456783',
    v_batch_id,
    '9th',
    'CBSE',
    45000,
    45000,
    'full',
    'active',
    NOW(),
    '2009-08-20',
    'Pune',
    NOW()
  )
  ON CONFLICT (email) DO NOTHING;
  
END $$;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SELECT 'TEACHERS' as type, name, email, subjects, classes FROM teachers;
SELECT 'STUDENTS' as type, name, email, class, parent_name FROM students LIMIT 5;
