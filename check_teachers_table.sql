-- Check the actual teachers table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'teachers'
ORDER BY ordinal_position;

-- Check existing teachers
SELECT * FROM teachers LIMIT 5;

-- Check auth_credentials for teachers
SELECT email, name, role, created_at
FROM auth_credentials
WHERE role = 'teacher'
ORDER BY created_at DESC;
