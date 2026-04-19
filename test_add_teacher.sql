-- ==================== TEST ADD TEACHER FEATURE ====================

-- STEP 1: Check if teachers table exists and has correct structure
SELECT 
    '=== TEACHERS TABLE STRUCTURE ===' as section,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'teachers'
ORDER BY ordinal_position;

-- STEP 2: Check existing teachers
SELECT 
    '=== EXISTING TEACHERS ===' as section,
    id,
    name,
    email,
    phone,
    subjects,
    classes,
    board,
    is_active,
    created_at
FROM teachers
ORDER BY created_at DESC;

-- STEP 3: Check teacher auth credentials
SELECT 
    '=== TEACHER AUTH CREDENTIALS ===' as section,
    email,
    name,
    role,
    password_hash,
    created_at
FROM auth_credentials
WHERE role = 'teacher'
ORDER BY created_at DESC;

-- STEP 4: Verify email uniqueness
SELECT 
    '=== EMAIL UNIQUENESS CHECK ===' as section,
    email,
    COUNT(*) as count
FROM teachers
GROUP BY email
HAVING COUNT(*) > 1;
-- Expected: No rows (all emails should be unique)

-- STEP 5: Check for teachers without auth credentials
SELECT 
    '=== TEACHERS WITHOUT AUTH ===' as section,
    t.name,
    t.email
FROM teachers t
LEFT JOIN auth_credentials ac ON t.email = ac.email
WHERE ac.email IS NULL;
-- Expected: No rows (all teachers should have auth credentials)

-- STEP 6: Check for auth credentials without teacher records
SELECT 
    '=== AUTH WITHOUT TEACHER RECORD ===' as section,
    ac.email,
    ac.name
FROM auth_credentials ac
LEFT JOIN teachers t ON ac.email = t.email
WHERE ac.role = 'teacher' AND t.email IS NULL;
-- Expected: No rows (all teacher auth should have teacher records)

-- STEP 7: Sample teacher data format
SELECT 
    '=== SAMPLE TEACHER DATA ===' as section,
    name,
    email,
    STRING_TO_ARRAY(subjects, ',') as subjects_array,
    STRING_TO_ARRAY(classes, ',') as classes_array,
    board,
    employee_id
FROM teachers
LIMIT 3;

-- ==================== MANUAL TEST INSTRUCTIONS ====================
/*
1. Run the migration script first:
   - Execute: teachers_table_migration.sql

2. Add a test teacher via Admin Dashboard:
   - Name: Test Teacher
   - Phone: 9876543210
   - Subjects: Mathematics, Physics
   - Classes: 10th, 11th
   - Board: CBSE

3. Verify the teacher was added:
   SELECT * FROM teachers WHERE name = 'Test Teacher';
   SELECT * FROM auth_credentials WHERE email = 'test.teacher@teachers.com';

4. Test teacher login:
   - Email: test.teacher@teachers.com
   - Password: Teacher@123

5. Expected Results:
   - Teacher record exists in teachers table
   - Auth credentials exist with role='teacher'
   - Login successful, redirects to Teacher Dashboard
   - Subjects stored as: "Mathematics,Physics"
   - Classes stored as: "10th,11th"
*/

-- ==================== CLEANUP (if needed) ====================
-- Uncomment to delete test teacher
-- DELETE FROM teachers WHERE email = 'test.teacher@teachers.com';
-- DELETE FROM auth_credentials WHERE email = 'test.teacher@teachers.com';
