-- ==================== PARENT-STUDENT ISOLATION TEST ====================
-- This script demonstrates that each parent sees ONLY their own children

-- ==================== STEP 1: View All Students with Parent Info ====================
SELECT 
  '=== ALL STUDENTS ===' as section,
  name as student_name,
  email as student_email,
  parent_name,
  SUBSTRING(parent_name FROM '\(([^)]+)\)') as parent_email_extracted
FROM students
ORDER BY parent_name;

-- ==================== STEP 2: Test Parent A (Deven Saran) ====================
SELECT 
  '=== DEVEN SARAN''S CHILDREN ===' as section,
  name as student_name,
  email as student_email,
  parent_name
FROM students
WHERE parent_name ILIKE '%deven.saran@parents.com%';

-- Expected Result: Only Reet Saran

-- ==================== STEP 3: Test Parent B (Rajesh Sharma) ====================
SELECT 
  '=== RAJESH SHARMA''S CHILDREN ===' as section,
  name as student_name,
  email as student_email,
  parent_name
FROM students
WHERE parent_name ILIKE '%rajesh.sharma@parents.com%';

-- Expected Result: Only Aryan Sharma

-- ==================== STEP 4: Test Parent C (Abha Sawant) ====================
SELECT 
  '=== ABHA SAWANT''S CHILDREN ===' as section,
  name as student_name,
  email as student_email,
  parent_name
FROM students
WHERE parent_name ILIKE '%abha.sawant@parents.com%';

-- Expected Result: Only Siya Sawant

-- ==================== STEP 5: Verify No Cross-Contamination ====================
SELECT 
  '=== PARENT-CHILD SUMMARY ===' as section,
  SUBSTRING(parent_name FROM '\(([^)]+)\)') as parent_email,
  COUNT(*) as number_of_children,
  STRING_AGG(name, ', ') as children_names
FROM students
GROUP BY parent_email
ORDER BY parent_email;

-- Expected Result: Each parent email should have their own children only

-- ==================== STEP 6: Check Auth Credentials ====================
SELECT 
  '=== PARENT AUTH CREDENTIALS ===' as section,
  email,
  name,
  role,
  created_at
FROM auth_credentials
WHERE role = 'parent'
ORDER BY email;

-- ==================== VERIFICATION CHECKLIST ====================
-- ✅ Each parent email appears in exactly one student's parent_name
-- ✅ No parent sees another parent's children
-- ✅ All parents have auth credentials with role='parent'
-- ✅ Parent emails match the format: name@parents.com

-- ==================== TEST NEW STUDENT ADDITION ====================
-- To test: Add a new student via Admin Dashboard
-- 1. Go to Admin Dashboard → Students → Add Student
-- 2. Fill in student and parent details
-- 3. Submit the form
-- 4. Login as the parent
-- 5. Verify you see ONLY the newly added student

-- Example:
-- Student: Test Student
-- Parent: Test Parent
-- Expected parent email: test.parent@parents.com
-- Expected parent_name in DB: "Test Parent (test.parent@parents.com)"
-- Expected result: Test Parent sees only Test Student
