-- Check if Rita Vaidya exists in the database

-- Check in users table
SELECT 'USERS TABLE' as table_name, id, name, email, role, is_active
FROM users
WHERE email LIKE '%rita%' OR name LIKE '%Rita%';

-- Check in teachers table
SELECT 'TEACHERS TABLE' as table_name, t.id, t.user_id, u.name, u.email
FROM teachers t
LEFT JOIN users u ON t.user_id = u.id
WHERE u.name LIKE '%Rita%' OR u.email LIKE '%rita%';

-- Check all teachers
SELECT 'ALL TEACHERS' as info, u.name, u.email, u.role
FROM teachers t
JOIN users u ON t.user_id = u.id;

-- Check all students
SELECT 'ALL STUDENTS' as info, u.name, u.email, u.role
FROM students s
JOIN users u ON s.user_id = u.id;
