-- Simple query to see what's in the database

-- Show all teachers
SELECT * FROM teachers LIMIT 3;

-- Show all students  
SELECT * FROM students LIMIT 3;

-- Show all users with role teacher or student
SELECT id, name, email, role FROM users 
WHERE role IN ('teacher', 'student', 'parent')
LIMIT 10;
