-- Fix user relationships for students and teachers

-- First, let's see what we have
SELECT 'ORPHANED STUDENTS' as issue, s.id, s.user_id, s.parent_name
FROM students s
LEFT JOIN users u ON s.user_id = u.id
WHERE u.id IS NULL;

SELECT 'ORPHANED TEACHERS' as issue, t.id, t.user_id
FROM teachers t
LEFT JOIN users u ON t.user_id = u.id
WHERE u.id IS NULL;

-- Check what users exist
SELECT 'EXISTING USERS' as info, id, name, email, role
FROM users
ORDER BY role, name;

-- Check auth.users to see what accounts exist
SELECT 'AUTH USERS' as info, id, email
FROM auth.users
ORDER BY email;
