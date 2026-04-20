-- Check the actual structure of teachers and students tables

SELECT 
    'TEACHERS TABLE COLUMNS' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'teachers'
ORDER BY ordinal_position;

SELECT 
    'STUDENTS TABLE COLUMNS' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'students'
ORDER BY ordinal_position;

SELECT 
    'USERS TABLE COLUMNS' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;
