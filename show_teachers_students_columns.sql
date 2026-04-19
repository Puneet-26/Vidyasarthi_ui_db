-- Show only teachers and students table columns

SELECT 
    'TEACHERS' as table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'teachers'
ORDER BY ordinal_position;

SELECT 
    'STUDENTS' as table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'students'
ORDER BY ordinal_position;
