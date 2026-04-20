-- Check actual students table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'students'
ORDER BY ordinal_position;

-- Check sample student data
SELECT * FROM students LIMIT 3;
