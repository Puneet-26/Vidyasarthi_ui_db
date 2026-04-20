-- Quick verification of what exists in the database

-- Check Rita Vaidya specifically
SELECT 'RITA IN USERS' as check_type, * 
FROM users 
WHERE email = 'rita.vaidya@teachers.com';

SELECT 'RITA IN TEACHERS' as check_type, t.*, u.name, u.email
FROM teachers t
LEFT JOIN users u ON t.user_id = u.id
WHERE u.email = 'rita.vaidya@teachers.com';

-- Check all teachers with their user info
SELECT 'ALL TEACHERS' as info, 
  t.id as teacher_id,
  t.user_id,
  u.name,
  u.email,
  u.role,
  t.subjects,
  t.classes
FROM teachers t
LEFT JOIN users u ON t.user_id = u.id;

-- Check all students with their user info
SELECT 'ALL STUDENTS' as info,
  s.id as student_id,
  s.user_id,
  u.name,
  u.email,
  u.role,
  s.class,
  s.board
FROM students s
LEFT JOIN users u ON s.user_id = u.id
LIMIT 5;
