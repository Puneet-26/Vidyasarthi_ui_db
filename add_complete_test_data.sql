-- ============================================================================
-- COMPLETE TEST DATA WITH PROPER USER RELATIONSHIPS
-- Run this in Supabase SQL Editor
-- ============================================================================

-- First, clean up existing test data (optional - comment out if you want to keep existing data)
DELETE FROM students WHERE parent_name IN ('Rajesh Sharma', 'Sunita Patel', 'Deven Saran');
DELETE FROM teachers WHERE user_id IN (
  SELECT id FROM users WHERE email IN ('priya.nair@teachers.com', 'rita.vaidya@teachers.com')
);
DELETE FROM users WHERE email IN (
  'aryan.sharma@students.com', 'rajesh.sharma@parents.com',
  'priya.singh@students.com', 'sunita.patel@parents.com',
  'reet.saran@students.com', 'deven.saran@parents.com',
  'priya.nair@teachers.com', 'rita.vaidya@teachers.com'
);

-- ============================================================================
-- ADD TEACHERS
-- ============================================================================

-- Teacher 1: Priya Nair (Physics)
DO $$
DECLARE
  v_user_id UUID;
  v_teacher_id UUID;
  v_batch_id UUID;
BEGIN
  -- Create user record
  INSERT INTO users (id, name, email, phone_number, role, is_active, created_at)
  VALUES (
    gen_random_uuid(),
    'Priya Nair',
    'priya.nair@teachers.com',
    '9876543210',
    'teacher',
    true,
    NOW()
  )
  RETURNING id INTO v_user_id;

  -- Get a batch ID (use first available batch)
  SELECT id INTO v_batch_id FROM batches LIMIT 1;

  -- Create teacher record
  INSERT INTO teachers (
    id, user_id, employee_id, subjects, classes, board, batch_id,
    qualification, experience_years, salary, is_active, created_at
  )
  VALUES (
    gen_random_uuid(),
    v_user_id,
    'EMP001',
    ARRAY['Physics'],
    ARRAY['9th', '10th'],
    'CBSE',
    v_batch_id,
    'M.Sc Physics',
    5,
    50000,
    true,
    NOW()
  );

  -- Create auth credentials
  INSERT INTO auth.users (
    id, email, encrypted_password, email_confirmed_at, created_at, updated_at
  )
  VALUES (
    v_user_id,
    'priya.nair@teachers.com',
    crypt('Teacher@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (email) DO NOTHING;

  RAISE NOTICE 'Added teacher: Priya Nair';
END $$;

-- Teacher 2: Rita Vaidya (Mathematics)
DO $$
DECLARE
  v_user_id UUID;
  v_teacher_id UUID;
  v_batch_id UUID;
BEGIN
  -- Create user record
  INSERT INTO users (id, name, email, phone_number, role, is_active, created_at)
  VALUES (
    gen_random_uuid(),
    'Rita Vaidya',
    'rita.vaidya@teachers.com',
    '9876543211',
    'teacher',
    true,
    NOW()
  )
  RETURNING id INTO v_user_id;

  -- Get a batch ID
  SELECT id INTO v_batch_id FROM batches LIMIT 1;

  -- Create teacher record
  INSERT INTO teachers (
    id, user_id, employee_id, subjects, classes, board, batch_id,
    qualification, experience_years, salary, is_active, created_at
  )
  VALUES (
    gen_random_uuid(),
    v_user_id,
    'EMP002',
    ARRAY['Mathematics'],
    ARRAY['7th', '8th', '9th'],
    'CBSE',
    v_batch_id,
    'M.Sc Mathematics',
    8,
    55000,
    true,
    NOW()
  );

  -- Create auth credentials
  INSERT INTO auth.users (
    id, email, encrypted_password, email_confirmed_at, created_at, updated_at
  )
  VALUES (
    v_user_id,
    'rita.vaidya@teachers.com',
    crypt('Teacher@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (email) DO NOTHING;

  RAISE NOTICE 'Added teacher: Rita Vaidya';
END $$;

-- ============================================================================
-- ADD STUDENTS
-- ============================================================================

-- Student 1: Aryan Sharma
DO $$
DECLARE
  v_student_user_id UUID;
  v_parent_user_id UUID;
  v_batch_id UUID;
BEGIN
  -- Get a batch ID
  SELECT id INTO v_batch_id FROM batches LIMIT 1;

  -- Create student user record
  INSERT INTO users (id, name, email, phone_number, role, is_active, created_at)
  VALUES (
    gen_random_uuid(),
    'Aryan Sharma',
    'aryan.sharma@students.com',
    '9123456780',
    'student',
    true,
    NOW()
  )
  RETURNING id INTO v_student_user_id;

  -- Create parent user record
  INSERT INTO users (id, name, email, phone_number, role, is_active, created_at)
  VALUES (
    gen_random_uuid(),
    'Rajesh Sharma',
    'rajesh.sharma@parents.com',
    '9123456781',
    'parent',
    true,
    NOW()
  )
  RETURNING id INTO v_parent_user_id;

  -- Create student record
  INSERT INTO students (
    id, user_id, roll_number, batch_id, parent_name, parent_phone,
    class, board, total_fees, fees_paid, fee_status, enrollment_status,
    date_of_birth, address, admission_date, created_at
  )
  VALUES (
    gen_random_uuid(),
    v_student_user_id,
    'STU001',
    v_batch_id,
    'Rajesh Sharma',
    '9123456781',
    '10th',
    'CBSE',
    50000,
    35000,
    'partial',
    'active',
    '2008-05-15',
    'Mumbai, Maharashtra',
    NOW(),
    NOW()
  );

  -- Create auth credentials for student
  INSERT INTO auth.users (
    id, email, encrypted_password, email_confirmed_at, created_at, updated_at
  )
  VALUES (
    v_student_user_id,
    'aryan.sharma@students.com',
    crypt('Student@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (email) DO NOTHING;

  -- Create auth credentials for parent
  INSERT INTO auth.users (
    id, email, encrypted_password, email_confirmed_at, created_at, updated_at
  )
  VALUES (
    v_parent_user_id,
    'rajesh.sharma@parents.com',
    crypt('Parent@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (email) DO NOTHING;

  RAISE NOTICE 'Added student: Aryan Sharma';
END $$;

-- Student 2: Priya Singh
DO $$
DECLARE
  v_student_user_id UUID;
  v_parent_user_id UUID;
  v_batch_id UUID;
BEGIN
  -- Get a batch ID
  SELECT id INTO v_batch_id FROM batches LIMIT 1;

  -- Create student user record
  INSERT INTO users (id, name, email, phone_number, role, is_active, created_at)
  VALUES (
    gen_random_uuid(),
    'Priya Singh',
    'priya.singh@students.com',
    '9123456782',
    'student',
    true,
    NOW()
  )
  RETURNING id INTO v_student_user_id;

  -- Create parent user record
  INSERT INTO users (id, name, email, phone_number, role, is_active, created_at)
  VALUES (
    gen_random_uuid(),
    'Sunita Patel',
    'sunita.patel@parents.com',
    '9123456783',
    'parent',
    true,
    NOW()
  )
  RETURNING id INTO v_parent_user_id;

  -- Create student record
  INSERT INTO students (
    id, user_id, roll_number, batch_id, parent_name, parent_phone,
    class, board, total_fees, fees_paid, fee_status, enrollment_status,
    date_of_birth, address, admission_date, created_at
  )
  VALUES (
    gen_random_uuid(),
    v_student_user_id,
    'STU002',
    v_batch_id,
    'Sunita Patel',
    '9123456783',
    '9th',
    'CBSE',
    45000,
    45000,
    'full',
    'active',
    '2009-08-20',
    'Pune, Maharashtra',
    NOW(),
    NOW()
  );

  -- Create auth credentials for student
  INSERT INTO auth.users (
    id, email, encrypted_password, email_confirmed_at, created_at, updated_at
  )
  VALUES (
    v_student_user_id,
    'priya.singh@students.com',
    crypt('Student@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (email) DO NOTHING;

  -- Create auth credentials for parent
  INSERT INTO auth.users (
    id, email, encrypted_password, email_confirmed_at, created_at, updated_at
  )
  VALUES (
    v_parent_user_id,
    'sunita.patel@parents.com',
    crypt('Parent@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (email) DO NOTHING;

  RAISE NOTICE 'Added student: Priya Singh';
END $$;

-- Student 3: Reet Saran
DO $$
DECLARE
  v_student_user_id UUID;
  v_parent_user_id UUID;
  v_batch_id UUID;
BEGIN
  -- Get a batch ID
  SELECT id INTO v_batch_id FROM batches LIMIT 1;

  -- Create student user record
  INSERT INTO users (id, name, email, phone_number, role, is_active, created_at)
  VALUES (
    gen_random_uuid(),
    'Reet Saran',
    'reet.saran@students.com',
    '9123456784',
    'student',
    true,
    NOW()
  )
  RETURNING id INTO v_student_user_id;

  -- Create parent user record
  INSERT INTO users (id, name, email, phone_number, role, is_active, created_at)
  VALUES (
    gen_random_uuid(),
    'Deven Saran',
    'deven.saran@parents.com',
    '9123456785',
    'parent',
    true,
    NOW()
  )
  RETURNING id INTO v_parent_user_id;

  -- Create student record
  INSERT INTO students (
    id, user_id, roll_number, batch_id, parent_name, parent_phone,
    class, board, total_fees, fees_paid, fee_status, enrollment_status,
    date_of_birth, address, admission_date, created_at
  )
  VALUES (
    gen_random_uuid(),
    v_student_user_id,
    'STU003',
    v_batch_id,
    'Deven Saran',
    '9123456785',
    '8th',
    'CBSE',
    40000,
    20000,
    'partial',
    'active',
    '2010-03-10',
    'Delhi',
    NOW(),
    NOW()
  );

  -- Create auth credentials for student
  INSERT INTO auth.users (
    id, email, encrypted_password, email_confirmed_at, created_at, updated_at
  )
  VALUES (
    v_student_user_id,
    'reet.saran@students.com',
    crypt('Student@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (email) DO NOTHING;

  -- Create auth credentials for parent
  INSERT INTO auth.users (
    id, email, encrypted_password, email_confirmed_at, created_at, updated_at
  )
  VALUES (
    v_parent_user_id,
    'deven.saran@parents.com',
    crypt('Parent@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (email) DO NOTHING;

  RAISE NOTICE 'Added student: Reet Saran';
END $$;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Check what was created
SELECT 'TEACHERS' as type, u.name, u.email, t.subjects, t.classes
FROM teachers t
JOIN users u ON t.user_id = u.id
ORDER BY u.name;

SELECT 'STUDENTS' as type, u.name, u.email, s.class, s.board, s.parent_name
FROM students s
JOIN users u ON s.user_id = u.id
ORDER BY u.name;

SELECT 'SUMMARY' as info,
  (SELECT COUNT(*) FROM teachers) as total_teachers,
  (SELECT COUNT(*) FROM students) as total_students,
  (SELECT COUNT(*) FROM users WHERE role = 'teacher') as teacher_users,
  (SELECT COUNT(*) FROM users WHERE role = 'student') as student_users,
  (SELECT COUNT(*) FROM users WHERE role = 'parent') as parent_users;
